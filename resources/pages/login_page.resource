language: pt-br

*** Configurações ***
Documentação        Ações da página de login.

Biblioteca          SeleniumLibrary
Recurso             ../configs/qa.resource
Recurso             ../page_objects/login_page_objects.resource


*** Palavras-Chave ***
Abrir a página de login
    Go To    ${URL}login
    Esperar a tela de login carregar


Esperar a tela de login carregar
    Wait Until Element Is Visible    ${EMAIL_TEXT_FIELD}       timeout=${TIMEOUT_PADRAO}
    Wait Until Element Is Visible    ${PASSWORD_TEXT_FIELD}    timeout=${TIMEOUT_PADRAO}
    Wait Until Element Is Enabled    ${ENTRAR_BUTTON}          timeout=${TIMEOUT_PADRAO}


Preencher campo de e-mail
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${EMAIL_TEXT_FIELD}    timeout=${TIMEOUT_PADRAO}
    Input Text                      ${EMAIL_TEXT_FIELD}    ${email}


Preencher campo de senha
    [Arguments]    ${senha}
    Wait Until Element Is Visible    ${PASSWORD_TEXT_FIELD}    timeout=${TIMEOUT_PADRAO}
    Input Password                   ${PASSWORD_TEXT_FIELD}    ${senha}


Submeter o formulário de login
    Wait Until Element Is Enabled    ${ENTRAR_BUTTON}    timeout=${TIMEOUT_PADRAO}
    Click Button                     ${ENTRAR_BUTTON}


Submeter o formulário de cadastro
    Submeter o formulário de login
