*** Settings ***
Resource    ../configs/qa.resource

*** Variables ***
${PRODUTO_CARD_CONFIRMADO}       xpath://div[contains(@class, "card")][.//h5[contains(@class, "card-title") and normalize-space(.)="${NOME_PRODUTO}"] and .//button[@data-testid="adicionarNaLista"]]
${ADICIONAR_PRODUTO_CONFIRMADO}  xpath://div[contains(@class, "card")][.//h5[contains(@class, "card-title") and normalize-space(.)="${NOME_PRODUTO}"]]//button[@data-testid="adicionarNaLista"]
