*** Settings ***
Library    String
Library    Collections
Resource    macros.robot
Suite Setup    Go To Api Tokens
Suite Teardown    Close All Browsers
Test Teardown    Refresh Page

*** Variables ***
&{scopes_map}=    admin=Admin    read=Read    trade=Trade    payments=Payments    trading_information=Trading information
${buttonPath}=    //button[contains(@class,'da-api-token__button')]
${deleteDialogBase}=   //div[@class='dc-modal']
${deleteDialog}=    ${deleteDialogBase}//div[@class='dc-modal-body']

*** Keywords ***
Get All Tokens
    ${count}=    Get Element Count    //table[@class='da-api-token__table']/tbody//tr
    @{tokens}=    Create List
    FOR  ${id}  IN RANGE    1    ${count}
        ${base}=     Set Variable    //table[@class='da-api-token__table']/tbody//tr[${id}]
        Click Element    ${base}/td[2]/div/div[3]
        ${val}=    Get Text    ${base}/td[2]/div/p
        Click Element    ${base}/td[2]/div/div[2]
        Insert Into List    ${tokens}    0    ${val}
    END
    RETURN    ${tokens}
Ensure Only Certain Scope
    [Arguments]    ${path}    @{scopes}
    @{keys}=    Get Dictionary Keys    ${scopes_map}
    FOR  ${current_key}  IN  @{keys}
        ${needed}=    Run Keyword And Return Status    List Should Contain Value    ${scopes}    ${current_key}
        ${value}=    Set Variable    ${scopes_map}[${current_key}]
        IF    ${needed}
        Page Should Contain Element    ${path}/td[3]//div[text()='${value}']
        ELSE
        Page Should Not Contain Element    ${path}/td[3]//div[text()='${value}']
        END
    END
    
New Token
    [Arguments]    @{scopes}
    ${tokenName}=    Generate Random String    10
    FOR  ${scope}  IN  @{scopes}
    Check Boxes By Name    ${scope}
    END
    ReplaceInput    //input[@name='token_name']    ${tokenName}
    Element Should Be Enabled    ${buttonPath}
    Click Element    ${buttonPath}
    Wait Until Button Settles
    ${path} =    Set Variable     //table[@class='da-api-token__table']//span[text()='${tokenName}']/../..
    #validate creation
    Element Text Should Be    ${path}/td[4]/span    Never
    Ensure Only Certain Scope    ${path}    @{scopes}
    RETURN    ${tokenName}

*** Test Cases ***
Normal Creation Shall Succeeded
    New Token    admin    read

Normal Deletion Shall Succeeded
    ${executable}=    Run Keyword And Return Status    Page Should Contain Element    //table[@class='da-api-token__table']/tbody//tr[1]
    IF  ${executable}!=True
        Fail    "No tokens here"
    END
    Click Element    //table[@class='da-api-token__table']/tbody//tr[1]/td[5]
    Wait Until Element Is Visible    ${deleteDialog}
    Element Should Contain    ${deleteDialogBase}    Delete token
    #click on cancel
    Click Element    ${deleteDialogBase}//span[text()='Cancel']/..
    Page Should Contain Element    //table[@class='da-api-token__table']/tbody//tr[1]
    Wait Until Element Is Not Visible    ${deleteDialog}
    #repeat
    ${id}=    Get Text    //table[@class='da-api-token__table']/tbody//tr[1]/td[1]/span
    Click Element    //table[@class='da-api-token__table']/tbody//tr[1]/td[5]
    Wait Until Element Is Visible    ${deleteDialog}
    Click Element    ${deleteDialogBase}//span[text()='Yes, delete']/..
    Wait Until Element Is Not Visible    ${deleteDialog}
    Page Should Not Contain Element    //table[@class='da-api-token__table']//span[text()='${id}']/../..

Token shall be hidden by default
    ${id}=    New Token    admin    trading_information
    ${path} =    Set Variable     //table[@class='da-api-token__table']//span[text()='${id}']/../..
    Page Should Contain Element    ${path}/td[2]//div[@class='da-api-token__pass-dot-container']

Token shall be unique to each other
    @{tokens}=    Get All Tokens
    List Should Not Contain Duplicates    ${tokens}

Token shall be persists across refresh
    @{tokens}=    Get All Tokens
    Refresh Page
    @{tokens2}=    Get All Tokens
    Lists Should Be Equal    ${tokens}    ${tokens2}

Copy Token Shall Works
    ${path}=    Set Variable    //table[@class='da-api-token__table']/tbody//tr[1]
    ${executable}=    Run Keyword And Return Status    Page Should Contain Element    ${path}
    IF  ${executable}!=True
        Fail    "No tokens here"
    END
    Click Element    ${path}/td[2]/div/div[2]
    ${dismissNeeded}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${deleteDialog}
    IF    ${dismissNeeded}
    Click Element    ${deleteDialogBase}//span[text()='OK']/..
    Wait Until Element Is Not Visible    ${deleteDialog}
    END
    Press Keys    //input[@name='token_name']    CTRL+a+v
    Click Element    ${path}/td[2]/div/div[3]
    ${val}=    Get Text    ${path}/td[2]/div/p
    Click Element    ${path}/td[2]/div/div[2]
    ${val2}=    Get Element Attribute    //input[@name='token_name']    value
    Should Be Equal As Strings    ${val}    ${val2}

Name is mandatory!
    ReplaceInput    //input[@name='token_name']    test
    Press Keys    //input[@name='token_name']    CTRL+a+DELETE
    Element Text Should Be    //div[contains(@class,'dc-field--error')]    Please enter a token name.

Scope is mandatory!
    ReplaceInput    //input[@name='token_name']    test
    Element Should Be Disabled    ${buttonPath}

Invalid Name
    ReplaceInput    //input[@name='token_name']    test@
    Element Text Should Be    //div[contains(@class,'dc-field--error')]    Only letters, numbers, and underscores are allowed.

Too short name
    ReplaceInput    //input[@name='token_name']    1
    Element Text Should Be    //div[contains(@class,'dc-field--error')]    Length of token name must be between 2 and 32 characters.

Too long name
    ReplaceInput    //input[@name='token_name']    123456789012345678901234567890212
    Element Text Should Be    //div[contains(@class,'dc-field--error')]    Maximum 32 characters.

All checkboxes are selectable
    Ensure Loaded
    @{keys}=    Get Dictionary Keys    ${scopes_map}
    FOR  ${current_key}  IN  @{keys}
    Check Boxes By Name    ${current_key}
    Uncheck Boxes By Name    ${current_key}
    END