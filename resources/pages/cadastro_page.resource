language: pt-br

*** Configurações ***
Documentação        Ações da página de cadastro.

Biblioteca          SeleniumLibrary
Recurso             ../configs/qa.resource
Recurso             ../page_objects/cadastro_page_objects.resource


*** Palavras-Chave ***
Abrir a página de cadastro
    Wait Until Page Contains Element    ${LINK_CADASTRO}    timeout=${TIMEOUT_PADRAO}
    Click Element                        ${LINK_CADASTRO}
    Esperar o formulário de cadastro carregar


Esperar o formulário de cadastro carregar
    Wait Until Element Is Visible    ${CAMPO_NOME}    timeout=${TIMEOUT_PADRAO}
    Wait Until Element Is Visible    ${CAMPO_EMAIL}    timeout=${TIMEOUT_PADRAO}
    Wait Until Element Is Visible    ${CAMPO_SENHA}    timeout=${TIMEOUT_PADRAO}


Preencher o formulário de cadastro
    [Arguments]    ${nome}    ${email}    ${senha}
    Esperar o formulário de cadastro carregar
    Input Text        ${CAMPO_NOME}     ${nome}
    Input Text        ${CAMPO_EMAIL}    ${email}
    Input Password    ${CAMPO_SENHA}    ${senha}


Submeter o cadastro
    Wait Until Element Is Enabled    ${BOTAO_CADASTRAR}    timeout=${TIMEOUT_PADRAO}
    Click Button                     ${BOTAO_CADASTRAR}


Esperar o cadastro ser concluído
    Wait Until Page Contains    ${MENSAGEM_CADASTRO_SUCESSO}    timeout=${TIMEOUT_PADRAO}
