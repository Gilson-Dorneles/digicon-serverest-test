language: pt-br

*** Configurações ***
Documentação        Steps BDD de cadastro de usuário.

Biblioteca          SeleniumLibrary
Biblioteca          FakerLibrary        locale=pt_BR
Recurso             ../pages/cadastro_page.resource


*** Palavras-Chave ***
que acessei o sistema ServeRest
    Go To    ${URL}
    Esperar a tela de cadastro carregar


acessei a página de cadastro
    Abrir a página de cadastro


preencho o formulário com dados Faker únicos
    ${nome}=       FakerLibrary.Name
    ${uuid}=       FakerLibrary.Uuid4
    ${email}=      Set Variable    ${uuid}@example.com
    ${senha}=      FakerLibrary.Password    length=12
    Set Test Variable    ${NOME_USUARIO}    ${nome}
    Set Test Variable    ${EMAIL_USUARIO}   ${email}
    Set Test Variable    ${SENHA_USUARIO}   ${senha}
    Preencher o formulário de cadastro    ${nome}    ${email}    ${senha}


submeto os dados de cadastro
    Submeter o cadastro


devo ver a mensagem de cadastro realizado
    Esperar o cadastro ser concluído
