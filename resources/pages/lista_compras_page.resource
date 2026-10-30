language: pt-br

*** Configurações ***
Documentação        Ações da página da lista de compras.

Biblioteca          SeleniumLibrary
Recurso             ../configs/qa.resource
Recurso             ../page_objects/lista_compras_page_objects.resource


*** Palavras-Chave ***
Abrir a lista de compras
    Go To    ${URL}minhaListaDeProdutos
    Wait Until Location Contains    minhaListaDeProdutos    timeout=${TIMEOUT_PADRAO}


Esperar o produto na lista de compras
    Wait Until Page Contains Element    ${PRODUTO_LISTA_ITEM}    timeout=${TIMEOUT_PADRAO}


Adicionar o produto da lista ao carrinho
    Esperar o produto na lista de compras
    Wait Until Element Is Enabled    ${ADICIONAR_CARRINHO_BUTTON}    timeout=${TIMEOUT_PADRAO}
    Click Button                     ${ADICIONAR_CARRINHO_BUTTON}
