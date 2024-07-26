let result=0;
function input()
{
    let n=parseInt(userInput.value);
    return n;
}
function res(operator, pre, next)
{
    let calc=`${pre} ${operator} ${next}`;
    outputResult(result,calc);
}
function add()
{
    let previous=result;
    result=result+input();
    res('+',previous,input());   
}
function subtract()
{
    let previous=result;
    result=result-input();
    res('-',previous,input());   
}
function multiply()
{
    let previous=result;
    result=result*input(); 
    res('*',previous,input());  
}
function divide()
{
    let x=input();
    let previous=result;
    if(x==0)
    {
        alert('Division by zero not possible');
        return;
    }
    result=result/input();
    res('/',previous,input());   
}
addBtn.addEventListener('click', add);
subtractBtn.addEventListener('click',subtract);
multiplyBtn.addEventListener('click',multiply);
divideBtn.addEventListener('click',divide);