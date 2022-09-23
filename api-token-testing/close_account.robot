*** Settings ***
Library    Collections
Library    String
Resource    macros.robot
Suite Setup    Go To Account Closure
Suite Teardown    Close All Browsers
Test Teardown    Refresh Page

*** Variables ***
${closing_account}=    //div[@class='closing-account']
@{reasons}=    financial-priorities    stop-trading    not-interested    another-website    not-user-friendly    difficult-transactions    lack-of-features    unsatisfactory-service    other-reasons
${confirmDialogBase}=   //div[@class='dc-modal']
*** Keywords ***
Go to reason page
    Click Element    ${closing_account}//span[text()='Close my account']/..

Fill in the reasons
    Go to reason page
    Check Boxes By Name    not-user-friendly
    Click Element    ${closing_account}//span[text()='Continue']/..
    Wait Until Page Contains Element    ${confirmDialogBase}//div[contains(@class,'account-closure-warning-modal')]

*** Test Cases ***
The information is There
    Page Should Contain Element    ${closing_account}
    Page Should Contain Element    ${closing_account}//p[text()='Are you sure?']
    ${first_info}=    Set Variable    ${closing_account}//p[text()='If you close your account:']/following-sibling::ul
    Page Should Contain Element    ${first_info}/li[text()="You can't trade on Deriv."]
    Page Should Contain Element    ${first_info}/li[text()="You can't make transactions."]
    ${second_info}=    Set Variable    //div[@class='closing-account']//p[text()='Before closing your account:']/following-sibling::ul
    Page Should Contain Element    ${second_info}/li[text()="Close all your positions."]
    Page Should Contain Element    ${second_info}/li[text()="Withdraw your funds."]
    Page Should Contain    We shall delete your personal information as soon as our legal obligations are met, as mentioned in the section on Data Retention in our Security and privacy policy
    Page Should Contain Element    //a[@href='https://deriv.com/tnc/security-and-privacy.pdf' and text ()='Security and privacy policy']
    Page Should Not Contain Element    //div[@class='closing-account-reasons']

Cancel button brings users back to app
    Click Element    ${closing_account}//span[text()='Cancel']/..
    Sleep    1
    Location Should Be    https://app.deriv.com/
    Go To    https://app.deriv.com/account/closing-account
    Ensure Loaded

Close my account bring users to reason page
    Go to reason page
    Page Should Contain Element    ${closing_account}//div[@class='closing-account-reasons']

Reason page hint checks
    Go to reason page
    Element Attribute Value Should Be    ${closing_account}//textarea[@name='other_trading_platforms']    placeholder    If you don’t mind sharing, which other trading platforms do you use?
    Element Attribute Value Should Be    ${closing_account}//textarea[@name='do_to_improve']    placeholder    What could we do to improve?

All checkboxs shall be checkable
    Go to reason page
    #@{ids}=    Execute Javascript    Array.prototype.map.call(document.querySelectorAll("input[type=checkbox]"),(p)=>p.getAttribute("name"));
    FOR  ${current_key}  IN  @{reasons}
    Check Boxes By Name    ${current_key}
    Uncheck Boxes By Name    ${current_key}
    END

Reasons shall be mandatory
    Go to reason page
    FOR  ${current_key}  IN  @{reasons}
    Check Boxes By Name    ${current_key}
    Uncheck Boxes By Name    ${current_key}
    END
    Element Should Be Disabled    ${closing_account}//span[text()='Continue']/..
    Element Text Should Be    ${closing_account}//p[contains(@class,'closing-account-reasons__error')]    Please select at least one reason

Textboxes shall be optional
    Go to reason page
    Check Boxes By Name    not-user-friendly
    Element Should Be Enabled    ${closing_account}//span[text()='Continue']/..

Max 3 reasons
    Go to reason page
    ${count}=    Get Length    ${reasons}
    FOR    ${id}    IN RANGE    0    ${count}
    IF    ${id} < 3
    Check Boxes By Name    ${reasons}[${id}]
    ELSE
    Element Should Be Disabled    //input[@name='${reasons}[${id}]' and @type='checkbox']
    END
    END    

Total should be 110
    Go to reason page
    ${val}=    Generate Random String    110    
    ReplaceInput    ${closing_account}//textarea[@name='other_trading_platforms']    ${val}
    ${can}=    Run Keyword And Return Status    ReplaceInput    ${closing_account}//textarea[@name='do_to_improve']    ${val}
    IF    ${can}==True
        Fail    Over the bound!
    END
    ${text}=    Get Text    ${closing_account}//textarea[@name='do_to_improve']
    Should Be Empty    ${text}
    Press Keys    ${closing_account}//textarea[@name='other_trading_platforms']    CTRL+a+DELETE
    ReplaceInput    ${closing_account}//textarea[@name='do_to_improve']    ${val}
    ${can}=    Run Keyword And Return Status    ReplaceInput    ${closing_account}//textarea[@name='other_trading_platforms']    ${val}
    IF    ${can}==True
        Fail    Over the bound!
    END

Final confirmation
    Fill in the reasons
    Element Should Contain    ${confirmDialogBase}//div[contains(@class,'account-closure-warning-modal')]    Closing your account will automatically log you out. We shall delete your personal information as soon as our legal obligations are met.
    Click Element    ${confirmDialogBase}//span[text()='Go Back']/..
    Wait Until Page Does Not Contain    ${confirmDialogBase}//div[contains(@class,'account-closure-warning-modal')]

Close ITTTTTTT
    Fill in the reasons
    Click Element    ${confirmDialogBase}//span[text()='Close account']/..
    Wait Until Element Contains    ${confirmDialogBase}    We’re sorry to see you leave. Your account is now closed.
    Sleep    10
    Click Element At Coordinates    //body    0    0
    Location Should Be    https://deriv.com/