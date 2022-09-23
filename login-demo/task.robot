*** Settings ***
Library   SeleniumLibrary
Library   String
Resource  go_into_virtual.robot

*** Keywords ***
Init
    Login To Deriv
    Switch Into Virtual

EnsureInvalidForTrade
    [Arguments]  ${value}
    ReplaceInput    dt_amount_input    ${value}
    #trade-container__amount search for error
    Wait Until Page Contains Element    //*[contains(@class,'error')]    30

*** Tasks ***
Task 1 - Go to virtual acc
    Init
    Close Browser
Task 2 - Buy rise contract
    Init
    # show the menu
    SelectMarket   Synthetic Indices  synthetic_index  Volatility 10 (1s) Index
    NoNotificationAss
    #change the type to rise and fall
    Click Element    dt_contract_dropdown
    Click Element    dt_contract_rise_fall_item
    Ensure Loaded
    Click Element    dc_t_toggle_item
    Ensure Loaded
    Simulate Event    //div[contains(@class,'range-slider__ticks')]/span[@data-value=5]    click
    Click Element    dc_stake_toggle_item
    ReplaceInput    dt_amount_input    10
    Ensure Loaded
    WaitAndClick    dt_purchase_call_button
    Ensure Loaded
    Wait Until Page Contains Element    //div[@id='dt_positions_drawer']//*[contains(@class,'dc-contract-card__wrapper')]    30
    Close Browser
Task 3 - Buy lower contract
    Init
    # show the menu
    SelectMarket   Forex  forex  AUD/USD
    NoNotificationAss
    Click Element    dt_contract_dropdown
    Click Element    dt_contract_high_low_item
    Ensure Loaded
    ReplaceInput    //div[contains(@class,'dc-datepicker__input')]/input    4
    # dont want to see it
    Click Element    //div[contains(@class,'dc-datepicker__input')]
    Click Element    dc_payout_toggle_item
    ReplaceInput    dt_amount_input    15.50
    Ensure Loaded
    WaitAndClick    dt_purchase_put_button
    Ensure Loaded
    Wait Until Page Contains Element    //div[@id='dt_positions_drawer']//*[contains(@class,'dc-contract-card__wrapper')]    30
    Close Browser
Task 4 - Relative barrier error
    Init
    # show the menu
    SelectMarket   Forex  forex  AUD/USD
    NoNotificationAss
    Click Element    dt_contract_dropdown
    Click Element    dt_contract_high_low_item
    Ensure Loaded
    ReplaceInput    //div[contains(@class,'dc-datepicker__input')]/input    4
    # dont want to see it
    Click Element    //div[contains(@class,'dc-datepicker__input')]
    Click Element    dc_payout_toggle_item
    ReplaceInput    dt_amount_input    15.50
    Ensure Loaded
    ${base}=    Set Variable    //div[contains(@class,'trade-container__barriers-single')]
    ReplaceInput    ${base}//input    +0.12
    Wait Until Page Contains Element    ${base}/span[string-length(@data-tooltip)>0]
    Element Attribute Value Should Be    ${base}/span    data-tooltip    Contracts more than 24 hours in duration would need an absolute barrier.
    Element Should Be Disabled    dt_purchase_put_button
    Close Browser
Task 5 - Multiplier
    Init
    # show the menu
    SelectMarket   Synthetic Indices  synthetic_index  Volatility 50 Index
    NoNotificationAss
    Click Element    dt_contract_dropdown
    Click Element    dt_contract_multiplier_item
    Ensure Loaded
    Page Should Not Contain    payout
    #check DC and SL/TP mutual exclusiveness
    Click Element    //input[@id='dt_cancellation-checkbox_input']/../span
    Click Element    //input[@id='dc_stop_loss-checkbox_input']/../span
    Click Element    //input[@id='dc_take_profit-checkbox_input']/../span
    Checkbox Should Be Selected    dc_stop_loss-checkbox_input
    Checkbox Should Be Selected    dc_take_profit-checkbox_input
    Checkbox Should Not Be Selected    dt_cancellation-checkbox_input
    Click Element    //input[@id='dc_stop_loss-checkbox_input']/../span
    Click Element    //input[@id='dc_take_profit-checkbox_input']/../span
    Click Element    //input[@id='dt_cancellation-checkbox_input']/../span
    #multipliers
    ${dropdown}=    Set Variable    //div[contains(@class,'trade-container__multiplier-dropdown')]
    Click Element    ${dropdown}
    FOR  ${value}  IN  20    40    60    100    200
    Page Should Contain Element    ${dropdown}//div[@id='${value}']
    END
    Click Element    ${dropdown}
    #check stack fee colleration
    ${feeInfoPath}=    Set Variable    //div[@class='purchase-container']//div[contains(@class,'trade-container__cancel-deal-info')]/div[@class='trade-container__price-info-value']/*[string-length(text())>0]
    Wait Until Page Contains Element    ${feeInfoPath}
    ${originalValue} =    Get Element Attribute    dt_amount_input    value
    ${originalFee} =    Get Text    ${feeInfoPath}
    ${originalFee}=    Split String    ${originalFee} 
    ${originalValue}=    Convert To Number    ${originalValue}
    ${originalFee}=    Convert To Number    ${originalFee[0]}
    ReplaceInput    dt_amount_input   ${{${originalValue}+${20}}}
    Wait Until Page Contains Element    ${feeInfoPath}
    ${updatedFee} =    Get Text    ${feeInfoPath}
    ${updatedFee}=    Split String    ${updatedFee} 
    ${updatedFee}=    Convert To Number    ${updatedFee[0]}
    IF  ${updatedFee}<=${originalFee}
        Fail    The fee is not collerated
    END
    ${durationPath}=    Set Variable    //input[@id='dt_cancellation-checkbox_input']/../../..//div[contains(@class,'trade-container__multiplier-dropdown')]
    Click Element    ${durationPath}
    FOR  ${value}  IN  5    10    15    30    60
    Page Should Contain Element    ${durationPath}//div[@id='${value}m']
    END
    EnsureInvalidForTrade    0.99
    EnsureInvalidForTrade    3001
    Click Element    //input[@id='dc_take_profit-checkbox_input']/../span
    ReplaceInput    dc_take_profit_input    1
    Click Button    dc_take_profit_input_add
    Element Attribute Value Should Be    dc_take_profit_input    value    2
    Click Button    dc_take_profit_input_sub
    Element Attribute Value Should Be    dc_take_profit_input    value    1
    Close Browser