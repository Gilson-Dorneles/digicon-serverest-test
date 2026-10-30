*** Settings ***
Documentation    Cadastro básico de usuário com sucesso, sem Gherkin/BDD.
Library          SeleniumLibrary
Test Setup       Open Browser    ${URL}    ${BROWSER}
Test Teardown    Close Browser


*** Variables ***
${URL}                 https://front.serverest.dev/
${BROWSER}             chrome
${NOME}                Ana Terra
${EMAIL}               usuario.basico@academy.com.br
${SENHA}               admin123
${MENSAGEM_SUCESSO}    Cadastro realizado com sucesso


*** Test Cases ***
Cadastrar um usuário com sucesso
    Wait Until Element Is Visible    link:Cadastre-se    timeout=10s
    Click Link    Cadastre-se
    Wait Until Element Is Visible    id:nome    timeout=10s
    Input Text    id:nome    ${NOME}
    Input Text    id:email    ${EMAIL}
    Input Password    id:password    ${SENHA}
    Click Button    tag:button
    Wait Until Page Contains    ${MENSAGEM_SUCESSO}    timeout=10s
    Capture Page Screenshot
