language: pt-br

*** Configurações ***
Documentação        E2E BDD de cadastro, login e carrinho.

Biblioteca          SeleniumLibrary
Biblioteca          FakerLibrary        locale=pt_BR
Recurso             ../../resources/configs/qa.resource
Recurso             ../../resources/steps/cadastrar_steps.resource
Recurso             ../../resources/steps/login_steps.resource
Recurso             ../../resources/steps/produtos_steps.resource
Recurso             ../../resources/steps/carrinho_steps.resource

Inicialização De Teste    Open Browser    ${URL}    ${BROWSER}
Finalização De Teste      Close Browser

Test Tags    e2e    cadastro    login    carrinho


*** Casos De Teste ***
Cadastro, login e adição de produto ao carrinho
    [Tags]    e2e    cadastro    login    carrinho
    Dado que acessei o sistema ServeRest
    E acessei a página de cadastro
    Quando preencho o formulário com dados Faker únicos
    E submeto os dados de cadastro
    Então devo ver a mensagem de cadastro realizado
    E abro a página de login para autenticar
    E que a tela de login do sistema carregou
    Quando preencho corretamente meus dados de login
    ...    ${EMAIL_USUARIO}
    ...    ${SENHA_USUARIO}
    E submeto o formulário para entrar
    Então devo visualizar a Serverest Store
    Quando seleciono o produto confirmado
    E abro a lista de compras
    Então devo visualizar o produto na lista de compras
    Quando adiciono o produto ao carrinho
    Então que a página do carrinho carregou
