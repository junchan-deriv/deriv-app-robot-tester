*** Settings ***
Resource    go_into_virtual.robot

*** Keywords ***
WaitAndClickWhenPresents
    [Arguments]    ${path}
    Wait Until Page Contains Element    ${path}
    Wait Until Element Is Visible    ${path}
    Click Element    ${path}
Go To Api Tokens
    Login To Deriv
    Switch Into Virtual
    Ensure Loaded
    Click Element    //a[@href='/account/personal-details']
    Ensure Loaded
    Click Element    //a[@href='/account/api-token']
    Ensure Loaded

Go To Account Closure
    Login To Deriv
    Switch Into Virtual
    Ensure Loaded
    Click Element    //a[@href='/account/personal-details']
    Ensure Loaded
    Click Element    //a[@href='/account/closing-account']
    Ensure Loaded
    Set Selenium Speed    0.5

Refresh Page
    Execute Javascript    document.location.reload();
    Sleep    1
    Ensure Loaded

Check Boxes By Name
    [Arguments]    ${name}
    ${path}=    Set Variable    //input[@name='${name}' and @type='checkbox']
    ${checked}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${path}
    IF   ${checked} != True
        Click Element    ${path}/../span[@class='dc-checkbox__box']
    END
Uncheck Boxes By Name
    [Arguments]    ${name}
    ${path}=    Set Variable    //input[@name='${name}' and @type='checkbox']
    ${checked}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${path}
    IF   ${checked} != False
        Click Element    ${path}/../span[@class='dc-checkbox__box dc-checkbox__box--active']
    END

Wait Until Button Settles
    Ensure Loaded