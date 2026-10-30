language: pt-br

*** Configurações ***
Documentação        Ações da página do carrinho.

Biblioteca          SeleniumLibrary
Recurso             ../configs/qa.resource
Recurso             ../page_objects/carrinho_page_objects.resource


*** Palavras-Chave ***
Esperar a página do carrinho carregar
    Wait Until Location Contains    carrinho    timeout=${TIMEOUT_PADRAO}
    Wait Until Page Contains Element    ${CARRINHO_PLACEHOLDER}    timeout=${TIMEOUT_PADRAO}


Esperar o marcador de construção do carrinho
    Esperar a página do carrinho carregar
    Wait Until Page Contains    ${MENSAGEM_CARRINHO_EM_CONSTRUCAO}    timeout=${TIMEOUT_PADRAO}
