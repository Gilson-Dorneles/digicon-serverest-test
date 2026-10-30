language: pt-br

*** Configurações ***
Documentação        Ações da página inicial.

Biblioteca          SeleniumLibrary
Recurso             ../configs/qa.resource
Recurso             ../page_objects/home_page_objects.resource


*** Palavras-Chave ***
Esperar a tela de cadastro carregar
    Wait Until Page Contains Element    ${CADASTRESE_BUTTON}    timeout=${TIMEOUT_PADRAO}


Esperar a loja carregar
    Wait Until Page Contains    Serverest Store    timeout=${TIMEOUT_PADRAO}


Esperar as opções restritas carregarem
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=${TIMEOUT_PADRAO}
