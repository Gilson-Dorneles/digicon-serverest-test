language: pt-br

*** Configurações ***
Documentação        Ações da página de produtos.

Biblioteca          SeleniumLibrary
Recurso             ../configs/qa.resource
Recurso             ../page_objects/produtos_page_objects.resource


*** Palavras-Chave ***
Esperar o produto confirmado carregar
    Wait Until Page Contains Element    ${PRODUTO_CARD_CONFIRMADO}    timeout=${TIMEOUT_PADRAO}


Adicionar o produto confirmado à lista
    Esperar o produto confirmado carregar
    Wait Until Element Is Enabled    ${ADICIONAR_PRODUTO_CONFIRMADO}    timeout=${TIMEOUT_PADRAO}
    Click Button                     ${ADICIONAR_PRODUTO_CONFIRMADO}
