language: pt-br

*** Configurações ***
Documentação        Implementação dos Steps da funcionalidade Login.

Biblioteca          SeleniumLibrary
Recurso             ../pages/home_page.resource
Recurso             ../pages/login_page.resource


*** Palavras-Chave ***
que a tela de login do sistema carregou
    Esperar a tela de login carregar


abro a página de login para autenticar
    Abrir a página de login


preencho corretamente meus dados de login
    [Arguments]     ${email}       ${senha}
    Preencher campo de e-mail      ${email}
    Preencher campo de senha       ${senha}


submeto o formulário para entrar
    Submeter o formulário de cadastro


devo visualizar a Serverest Store
    Esperar a loja carregar


devo visualizar as opções restritas
    Esperar as opções restritas carregarem


não devo mais visualizar a tela de login
    Page Should Not Contain    Login
    Capture Page Screenshot
