*** Settings ***
Library   SeleniumLibrary

*** Variables ***
${login_button}    //button[@id='dt_login_button']

*** Keywords ***

Ensure Loaded
    Wait Until Page Does Not Contain Element    //*[contains(@aria-label,"Loading")]    30
	Wait Until Page Does Not Contain Element    //*[contains(@class,'chart-container__loader')]    30
    Wait Until Page Does Not Contain Element    //*[contains(@class,'initial-loader')]    30
Login To Deriv
    Open Browser    https://app.deriv.com    chrome
    Maximize Browser Window
    Ensure Loaded
	Click Element    dt_login_button
	Wait Until Page Contains Element    //input[@type='email']    10
	Input Text    //input[@type='email']    @
    Input Text    //input[@type='password']    @
	Click Element    //button[@type='submit']
    ${retrade}=    Run Keyword And Return Status    Wait Until Page Contains Element    btnGrant
    IF    ${retrade}
    Click Element    btnGrant
    END
