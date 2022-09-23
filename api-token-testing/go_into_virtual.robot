*** Settings ***
Library   SeleniumLibrary
Resource  login.robot
*** Keywords ***
WaitAndClick
    [Arguments]    ${ptr}
    Wait Until Element Is Enabled    ${ptr}
    Click Element    ${ptr}

SelectMarket
    [Arguments]  ${market_type}  ${market_type_id}  ${market}
    ${type_address} =    Catenate    //div[contains(@class,'sc-dialog')]//div[contains(@class,'sc-mcd__filter')]//div[text()='${market_type}']
    ${market_address} =    Catenate    //div[contains(@class,'sc-dialog')]//div[contains(@class,'sc-mcd__category--${market_type_id}')]//div[text()='${market}']/..
    Click Element    //div[contains(@class,'cq-top-ui-widgets')]//div[contains(@class,'cq-menu-btn')]
    Click Element    ${type_address}
    Click Element    ${market_address}
    Ensure Loaded
DeterministicClear
    [Arguments]    ${name}
    ${value} =    Get Element Attribute    ${name}    value
    ${len} =     Get Length    ${value}
    Set Focus To Element    ${name}
    Repeat Keyword    ${len}    Press Keys    ${name}    BACKSPACE
    Repeat Keyword    ${len}    Press Keys    ${name}    DELETE

ReplaceInput
    [Arguments]    ${name}    ${value}
    DeterministicClear    ${name}
    Input Text    ${name}    ${value}
    Element Attribute Value Should Be    ${name}  value  ${value}

Show Switcher
    Ensure Loaded
    Click Element    dt_core_account-info_acc-info
    Wait Until Page Contains Element    //div[contains(@class,'acc-switcher__list')]//div[@id='dt_logout_button']

Switch Into Virtual
    # click the account switcher
    # Wait Until Page Contains Element    //div[@data-testid='dt_contract_dropdown']
    Show Switcher
    Click Element    //div[contains(@class,'acc-switcher__list')]//*[@id='real_account_tab']
    Page Should Contain Element    //*[contains(@class,'acc-switcher__account--selected') and starts-with(@id,'dt_CR')]    It is not real account
    Click Element    //div[contains(@class,'acc-switcher__list')]//*[@id='dt_core_account-switcher_demo-tab']
    Click Element    //*[starts-with(@id,'dt_VR')]
    Show Switcher
    Click Element    //div[contains(@class,'acc-switcher__list')]//*[@id='dt_core_account-switcher_demo-tab']
    Page Should Contain Element    //*[contains(@class,'acc-switcher__account--selected') and starts-with(@id,'dt_VR')]    It is not virtual account
    ##//div[contains(@class,'sc-dialog')]//div[contains(@class,'sc-mcd__filter')]//div[text()='Synthetic Indices']

NoNotificationAss
    [Documentation]    Close the notification if it is there
    Run Keyword And Ignore Error    Click Element    //div[contains(@class,'notification-messages')]//button[contains(@class,'notification__close-button')]