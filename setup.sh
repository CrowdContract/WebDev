#!/bin/bash

# ============================================================
#  Auto Dev Environment Setup Script
#  Author: Arpit Kumar
#  Description: One-command setup for new developers joining
#               the project. Installs all required tools and
#               configures the development environment.
# ============================================================

set -e  # Exit immediately on any error

# ---------- Colors for output ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ---------- Helper functions ----------
log()     { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[✓]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[✗]${NC}    $1"; exit 1; }
section() { echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

# ---------- Banner ----------
echo -e "${GREEN}"
echo "  █████╗ ██╗   ██╗████████╗ ██████╗     ██████╗ ███████╗██╗   ██╗"
echo " ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██╔══██╗██╔════╝██║   ██║"
echo " ███████║██║   ██║   ██║   ██║   ██║    ██║  ██║█████╗  ██║   ██║"
echo " ██╔══██║██║   ██║   ██║   ██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝"
echo " ██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ "
echo " ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  "
echo -e "${NC}"
echo -e "${YELLOW}  Dev Environment Setup — by Arpit Kumar${NC}"
echo ""

# ---------- Step 0: Check OS ----------
section "Step 0: Checking System"
log "Detecting operating system..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
    success "Detected: $OS_NAME $OS_VERSION"
else
    warn "Could not detect OS details. Proceeding anyway..."
fi

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    warn "Running as root. Skipping sudo prefix where applicable."
    SUDO=""
else
    SUDO="sudo"
fi

# ---------- Step 1: Update system ----------
section "Step 1: Updating System Packages"
log "Running apt update..."
$SUDO apt update -y && $SUDO apt upgrade -y
success "System packages updated."

# ---------- Step 2: Install Git ----------
section "Step 2: Installing Git"
if command -v git &>/dev/null; then
    GIT_VERSION=$(git --version)
    success "Git already installed: $GIT_VERSION"
else
    log "Installing Git..."
    $SUDO apt install -y git
    success "Git installed: $(git --version)"
fi

# Configure Git globals if not set
if [ -z "$(git config --global user.name)" ]; then
    read -rp "  Enter your Git username: " GIT_USER
    git config --global user.name "$GIT_USER"
fi
if [ -z "$(git config --global user.email)" ]; then
    read -rp "  Enter your Git email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi
success "Git configured for user: $(git config --global user.name)"

# ---------- Step 3: Install curl & wget ----------
section "Step 3: Installing curl & wget"
for tool in curl wget; do
    if command -v $tool &>/dev/null; then
        success "$tool already installed."
    else
        log "Installing $tool..."
        $SUDO apt install -y $tool
        success "$tool installed."
    fi
done

# ---------- Step 4: Install Node.js (via nvm) ----------
section "Step 4: Installing Node.js (via nvm)"
if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    success "Node.js already installed: $NODE_VERSION"
else
    log "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # Load nvm into current shell session
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    log "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
    success "Node.js installed: $(node --version)"
    success "npm installed: $(npm --version)"
fi

# ---------- Step 5: Install global npm packages ----------
section "Step 5: Installing Global npm Packages"

GLOBAL_PACKAGES=(
    "nodemon"
    "pm2"
    "http-server"
    "eslint"
    "prettier"
    "typescript"
    "ts-node"
)

for pkg in "${GLOBAL_PACKAGES[@]}"; do
    log "Installing $pkg globally..."
    npm install -g "$pkg" --silent
    success "$pkg installed."
done

# ---------- Step 6: Install Docker ----------
section "Step 6: Installing Docker"
if command -v docker &>/dev/null; then
    DOCKER_VERSION=$(docker --version)
    success "Docker already installed: $DOCKER_VERSION"
else
    log "Installing Docker..."
    $SUDO apt install -y \
        ca-certificates \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | \
        $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

    $SUDO apt update -y
    $SUDO apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Add current user to docker group (no sudo needed for docker)
    $SUDO usermod -aG docker "$USER"
    success "Docker installed: $(docker --version)"
    warn "Log out and back in (or run 'newgrp docker') for docker group changes to take effect."
fi

# Install docker-compose (standalone) if not present
if ! command -v docker-compose &>/dev/null; then
    log "Installing docker-compose..."
    $SUDO curl -SL "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64" \
        -o /usr/local/bin/docker-compose
    $SUDO chmod +x /usr/local/bin/docker-compose
    success "docker-compose installed: $(docker-compose --version)"
else
    success "docker-compose already installed: $(docker-compose --version)"
fi

# ---------- Step 7: Install VS Code Extensions ----------
section "Step 7: Installing VS Code Extensions"
if command -v code &>/dev/null; then
    EXTENSIONS=(
        "dbaeumer.vscode-eslint"
        "esbenp.prettier-vscode"
        "ms-azuretools.vscode-docker"
        "eamodio.gitlens"
        "christian-kohler.path-intellisense"
        "bradlc.vscode-tailwindcss"
        "ms-vscode.vscode-typescript-next"
        "PKief.material-icon-theme"
        "formulahendry.auto-rename-tag"
        "streetsidesoftware.code-spell-checker"
    )

    for ext in "${EXTENSIONS[@]}"; do
        log "Installing extension: $ext"
        code --install-extension "$ext" --force
        success "$ext installed."
    done
else
    warn "VS Code CLI not found. Skipping extension installation."
    warn "Install VS Code and run: code --install-extension <extension-id>"
fi

# ---------- Step 8: Install project npm dependencies ----------
section "Step 8: Installing Project Dependencies"
if [ -f "package.json" ]; then
    log "Found package.json. Running npm install..."
    npm install
    success "Project dependencies installed."
else
    warn "No package.json found. Skipping npm install."
    warn "Run 'npm init' to create one, then re-run this script."
fi

# ---------- Step 9: Generate .env.example ----------
section "Step 9: Setting Up Environment Variables"
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    log "Copying .env.example to .env..."
    cp .env.example .env
    success ".env file created from .env.example"
    warn "Open .env and fill in your actual values before running the app."
elif [ -f ".env" ]; then
    success ".env already exists. Skipping."
else
    log "No .env.example found. Creating a default .env.example..."
    cat > .env.example << 'EOF'
# ─────────────────────────────────────────
#  Environment Variables — .env.example
#  Copy this file to .env and fill values.
# ─────────────────────────────────────────

# App
NODE_ENV=development
PORT=3000
APP_NAME=MyApp

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_db
DB_USER=myuser
DB_PASSWORD=yourpassword

# Auth
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d

# External APIs
API_KEY=your_api_key_here
EOF
    success ".env.example created."
    cp .env.example .env
    success ".env created. Fill in your actual values."
fi

# ---------- Step 10: Final summary ----------
section "Setup Complete!"
echo ""
echo -e "${GREEN}  ✅  Everything is ready. Here's a summary:${NC}"
echo ""
echo -e "  ${CYAN}Tool          Version${NC}"
echo -e "  ──────────────────────────────"
command -v git     &>/dev/null && echo -e "  Git           $(git --version | awk '{print $3}')"
command -v node    &>/dev/null && echo -e "  Node.js       $(node --version)"
command -v npm     &>/dev/null && echo -e "  npm           $(npm --version)"
command -v docker  &>/dev/null && echo -e "  Docker        $(docker --version | awk '{print $3}' | tr -d ',')"
command -v curl    &>/dev/null && echo -e "  curl          $(curl --version | head -1 | awk '{print $2}')"
command -v wget    &>/dev/null && echo -e "  wget          $(wget --version 2>&1 | head -1 | awk '{print $3}')"
echo ""
echo -e "${YELLOW}  Next steps:${NC}"
echo -e "  1. Edit ${CYAN}.env${NC} with your actual credentials"
echo -e "  2. Run ${CYAN}npm start${NC} or ${CYAN}npm run dev${NC} to launch the app"
echo -e "  3. Run ${CYAN}docker compose up${NC} if using Docker services"
echo ""
echo -e "${GREEN}  Happy coding! 🚀${NC}"
echo ""
