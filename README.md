# Auto Dev Environment Setup

A single shell script that sets up a complete development environment from scratch — so new developers can go from zero to running in minutes.

## What it installs

| Tool | Description |
|------|-------------|
| Git | Version control + global config |
| curl / wget | HTTP utilities |
| Node.js (via nvm) | JavaScript runtime (LTS version) |
| npm global packages | nodemon, pm2, eslint, prettier, typescript, ts-node |
| Docker | Container runtime |
| docker-compose | Multi-container orchestration |
| VS Code Extensions | ESLint, Prettier, Docker, GitLens, and more |

## Usage

### On Ubuntu / WSL2

```bash
# Clone the repo
git clone https://github.com/arpit0112ak/auto-dev-setup.git
cd auto-dev-setup

# Make the script executable
chmod +x setup.sh

# Run it
./setup.sh
```

### What happens

```
Checking Ubuntu version...
Updating system packages...
Installing Git...
Installing curl & wget...
Installing Node.js via nvm...
Installing global npm packages...
Installing Docker...
Installing docker-compose...
Installing VS Code Extensions...
Installing project npm dependencies...
Generating .env from .env.example...
Done. ✅
```

## Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

The script does this automatically on first run.

## Requirements

- Ubuntu 20.04+ or WSL2 (Ubuntu)
- Internet connection
- `sudo` access

## Why this exists

Every new developer wastes 30–60 minutes installing tools manually.  
With this script, an intern can clone the repo and run `./setup.sh` — done.

---

Made by [Arpit Kumar](https://github.com/arpit0112ak)
