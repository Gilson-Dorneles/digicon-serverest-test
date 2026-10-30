language: pt-br

*** Configurações ***
Documentação        Steps BDD de produtos e lista de compras.

Biblioteca          SeleniumLibrary
Recurso             ../pages/produtos_page.resource
Recurso             ../pages/lista_compras_page.resource


*** Palavras-Chave ***
seleciono o produto confirmado
    Adicionar o produto confirmado à lista


abro a lista de compras
    Abrir a lista de compras


devo visualizar o produto na lista de compras
    Esperar o produto na lista de compras


adiciono o produto ao carrinho
    Adicionar o produto da lista ao carrinho
