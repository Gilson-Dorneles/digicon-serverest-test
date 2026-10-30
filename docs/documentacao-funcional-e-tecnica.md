# Documentação funcional e técnica

## Finalidade deste documento

Este documento descreve o projeto `Curso-de-Automacao` a partir do conteúdo existente no clone. A descrição separa o que o código pretende validar, o que foi comprovado por validação estática ou `dry-run` e o que ainda depende de uma execução real contra o ambiente externo do ServeRest.

O inventário considera os arquivos versionados do produto. O conteúdo interno de `.git` e eventuais arquivos locais ignorados pelo `.gitignore`, incluindo `.agents/`, não é código funcional do produto e não faz parte deste inventário.

---

## 1. Visão executiva

### Objetivo

O projeto automatiza, pelo navegador, fluxos da loja web ServeRest. O foco é verificar se um usuário consegue:

- abrir o sistema e acessar o cadastro;
- preencher e enviar um cadastro de usuário;
- autenticar com credenciais válidas;
- receber respostas esperadas para credenciais inválidas ou campos obrigatórios vazios;
- localizar um produto específico;
- adicioná-lo à lista de compras;
- adicioná-lo ao carrinho e chegar à rota do carrinho.

A automação cobre a interface web em `https://front.serverest.dev/`. Não há, no conjunto de dependências ou nos testes inventariados, uma suíte de chamadas diretas à API do ServeRest.

### Tipo de automação

A solução usa Robot Framework com SeleniumLibrary. Os cenários dirigem um navegador Chrome e interagem com a interface por IDs, atributos `data-testid`, CSS e XPath. Parte dos testes usa palavras-chave em português com estilo BDD, como `Dado`, `Quando`, `Então` e `E`; outra parte mantém testes diretos ou orientados a dados.

O projeto também usa FakerLibrary para criar dados de cadastro variáveis. A suíte não é apenas um exemplo de geração de dados: os dados Faker do fluxo E2E são usados para criar um usuário no sistema e depois reutilizados no login.

### O que o cliente pode esperar

O cliente pode esperar uma base de regressão web para os fluxos descritos, com:

- cenários positivos e negativos de cadastro e login;
- um fluxo E2E que encadeia cadastro, login, lista de compras e carrinho;
- mensagens esperadas declaradas explicitamente;
- separação entre cenários, passos de negócio, ações de página, localizadores e configuração;
- relatórios e screenshots produzidos pelo Robot Framework quando uma execução real é feita.

Há uma limitação funcional importante: o código atual não confirma que o produto aparece dentro do carrinho. Depois de adicionar o produto, ele espera que a aplicação esteja em uma URL que contenha `carrinho` e verifica a mensagem `Em construção aguarde`. Portanto, o material demonstra o caminho até a página atualmente sinalizada como em construção, mas não comprova uma compra, um item no carrinho, quantidade, preço ou total.

---

## 2. Escopo funcional e regras de negócio observadas

As regras abaixo são comportamentos observáveis pelos testes e pelos localizadores existentes. Elas não devem ser interpretadas como requisitos adicionais que não estejam implementados ou comprovados.

### 2.1 Cadastro de usuário

| Comportamento observado | Evidência no projeto | Resultado esperado |
|---|---|---|
| A página inicial oferece um acesso ao cadastro. | `resources/page_objects/cadastro_page_objects.resource` localiza `a[data-testid="cadastrar"]`; as páginas de cadastro e os testes clicam nesse acesso. | O formulário de cadastro deve aparecer. |
| O formulário recebe nome, e-mail e senha. | Os campos são `id:nome`, `id:email` e `id:password`. | Os três valores são preenchidos antes do envio. |
| O envio bem-sucedido mostra uma mensagem de confirmação. | `${MENSAGEM_CADASTRO_SUCESSO}` é `Cadastro realizado com sucesso`. | A mensagem deve aparecer após o envio. |
| Alguns cenários também representam o campo de administrador. | `tests/web/cadastrar_test.robot` recebe `EH_ADMINISTRADOR` e, quando verdadeiro, tenta clicar em `id:administrador`. | O cenário espera a mesma mensagem de sucesso para administrador e não administrador. |
| O fluxo E2E usa e-mail único. | O passo combina `FakerLibrary.Uuid4` com `@example.com`. | O cadastro tende a não reutilizar o e-mail de outra execução. Isso é uma estratégia do teste, não uma garantia do sistema. |

O fluxo compartilhado em `resources/steps/cadastrar_steps.resource` não preenche nem valida um campo de administrador. A regra de papel aparece somente no teste de cadastro orientado a dados. O código não contém cenários negativos de cadastro, validação de e-mail já utilizado, política de senha ou limpeza do usuário criado.

### 2.2 Geração de dados

Há dois usos diferentes de dados variáveis:

1. No fluxo E2E, Faker gera nome, UUID e senha. O UUID entra no e-mail, e os três valores são guardados como variáveis de teste para o login seguinte.
2. Em `cadastrar_aleatorio_test.robot`, Faker gera nome, e-mail com domínio `dbservices.pt` e senha de oito caracteres. Esse teste é independente do fluxo E2E.

`faker_test.robot` apenas gera um e-mail, um CNPJ e um texto de até 300 caracteres e os escreve no log. Esses valores não são enviados ao ServeRest.

### 2.3 Login positivo

O login positivo usa o usuário fixo `celso@rothmail.com` com a senha `admin123`. O cenário espera que:

1. a tela de login aceite e envie as credenciais;
2. a loja apresente o texto `Serverest Store`;
3. uma opção restrita, representada pelo botão de logout, esteja visível;
4. a página não contenha o texto `Login`.

O código não cria esse usuário antes do teste. Portanto, a execução real depende de ele existir e continuar habilitado no ambiente utilizado.

No E2E, o login é diferente: o cenário usa o e-mail e a senha gerados no cadastro imediatamente anterior. Assim, o encadeamento verifica que os dados recém-criados podem ser reutilizados para autenticação, desde que o cadastro tenha sido concluído.

### 2.4 Login negativo

O teste orientado a dados de login negativo cobre quatro situações:

| Situação | Dados usados | Mensagem esperada |
|---|---|---|
| Senha incorreta | `eu@dev.com` / `errada123` | `Email e/ou senha inválidos` |
| E-mail não cadastrado | `nada@academy.dev` / `Senha123` | `Email e/ou senha inválidos` |
| E-mail vazio | e-mail vazio / `admin123` | `Email é obrigatório` |
| Senha vazia | `paul@dev.pt` / senha vazia | `Password é obrigatório` |

Esses cenários verificam mensagens exibidas pela interface. Eles não verificam bloqueio de conta, limite de tentativas, auditoria, recuperação de senha ou outros comportamentos de segurança.

### 2.5 Seleção de produto e lista de compras

O produto funcionalmente identificado pela suíte tem:

- ID configurado: `1793283513282`;
- nome esperado: `Produto 1793283513282`;
- botão de seleção: `data-testid="adicionarNaLista"`.

O localizador de produto exige que o mesmo cartão contenha o título esperado e o botão de adicionar à lista. Isso evita que o teste clique simplesmente no primeiro botão da página sem relacioná-lo ao produto configurado.

Depois da seleção, o fluxo abre diretamente `${URL}minhaListaDeProdutos`, espera um elemento com `data-testid="shopping-cart-product-name"` e clica no botão `data-testid="adicionar carrinho"`.

O código comprova a presença de algum item identificado pelo componente da lista, mas não compara, nessa etapa, o texto do item com `Produto 1793283513282`. A identificação exata ocorre na etapa anterior, na página de produtos.

### 2.6 Carrinho

A regra atualmente codificada para o carrinho é:

1. a localização do navegador deve conter `carrinho`;
2. a página deve conter o marcador `Em construção aguarde`;
3. a mensagem `Em construção aguarde` deve continuar visível.

Esse comportamento está refletido no README, em `qa.resource`, no Page Object do carrinho e nos passos do carrinho. Enquanto essa mensagem for o comportamento do ambiente, o teste E2E valida a chegada a uma página em construção, não a presença do produto.

Não há no código atual uma validação de nome, quantidade, preço, subtotal, total, remoção de item ou finalização de compra. Também não há um `Go To` explícito para `/carrinho` no E2E: depois do clique para adicionar ao carrinho, o teste espera que a aplicação navegue para uma URL contendo `carrinho`.

### 2.7 Pré-condições e efeitos externos

Para que os fluxos web tenham possibilidade de passar em execução real, são necessárias as seguintes condições:

- acesso de rede ao frontend `https://front.serverest.dev/`;
- Google Chrome instalado e utilizável pelo SeleniumLibrary;
- ambiente capaz de abrir as rotas `/`, `/login`, `/minhaListaDeProdutos` e a rota de carrinho;
- produto com ID `1793283513282` e o título esperado disponível no ambiente;
- usuário fixo do login positivo existente, com a senha esperada;
- mensagens da interface compatíveis com os textos exatos usados nos testes.

Os efeitos externos não são apenas de leitura:

- os testes de cadastro podem criar usuários no ambiente remoto;
- o E2E cria um usuário com dados Faker e altera sua lista de produtos e seu carrinho;
- os testes podem deixar estado persistente no ambiente, porque não existe keyword de limpeza;
- o navegador e os relatórios podem produzir screenshots e outros artefatos locais.

---

## 3. Fluxo end-to-end em linguagem de negócio

O cenário `Cadastro, login e adição de produto ao carrinho`, em `tests/web/cadastro_login_carrinho_e2e_test.robot`, representa o seguinte fluxo:

```text
Abrir a loja
     |
     v
Acessar cadastro -> preencher nome, e-mail único e senha -> enviar
     |
     v
Ver "Cadastro realizado com sucesso"
     |
     v
Abrir /login -> usar o mesmo e-mail e senha -> entrar
     |
     v
Ver "Serverest Store" e opção de logout
     |
     v
Localizar "Produto 1793283513282" -> adicionar à lista
     |
     v
Abrir /minhaListaDeProdutos -> confirmar item -> adicionar ao carrinho
     |
     v
Esperar URL com "carrinho" -> verificar "Em construção aguarde"
```

### O que esse fluxo valida

- A aplicação aceita um novo cadastro usando os dados gerados.
- A mensagem de cadastro aparece.
- Os dados usados no cadastro conseguem autenticar o mesmo usuário.
- A sessão autenticada apresenta a loja e uma opção restrita, representada pelo logout.
- O produto configurado pode ser localizado pelo nome e pelo botão correspondente.
- O produto pode ser encontrado na lista de compras.
- O botão de adicionar ao carrinho pode ser acionado.
- A aplicação leva o navegador, ou mantém o navegador, em uma localização que contém `carrinho`.
- A página atual apresenta o marcador `Em construção aguarde`.

### Limitação atual do carrinho

A etapa final não confirma o produto dentro do carrinho. O próprio teste espera a página em construção e não procura o nome do produto, uma linha de item, quantidade ou valor. Se `/carrinho` continuar mostrando `Em construção aguarde`, esse é o resultado esperado pelo teste atual e a confirmação comercial da adição do produto permanece pendente.

Para considerar a jornada de compra concluída, seria necessário que o produto do ambiente estivesse disponível na página do carrinho e que um cenário futuro confirmasse pelo menos o produto, a quantidade e o estado esperado do carrinho. Essa é uma recomendação de evolução, não uma alteração realizada por este documento.

---

## 4. Mapa da arquitetura

### 4.1 Estrutura do projeto

Considerando somente os arquivos do produto e o documento criado nesta solicitação, a estrutura é:

```text
Curso-de-Automacao/
├── .gitignore
├── README.md
├── requirements.txt
├── docs/
│   └── documentacao-funcional-e-tecnica.md
├── resources/
│   ├── configs/
│   │   └── qa.resource
│   ├── page_objects/
│   │   ├── cadastro_page_objects.resource
│   │   ├── carrinho_page_objects.resource
│   │   ├── home_page_objects.resource
│   │   ├── lista_compras_page_objects.resource
│   │   ├── login_page_objects.resource
│   │   └── produtos_page_objects.resource
│   ├── pages/
│   │   ├── cadastro_page.resource
│   │   ├── carrinho_page.resource
│   │   ├── home_page.resource
│   │   ├── lista_compras_page.resource
│   │   ├── login_page.resource
│   │   └── produtos_page.resource
│   └── steps/
│       ├── cadastrar_steps.resource
│       ├── carrinho_steps.resource
│       ├── login_steps.resource
│       └── produtos_steps.resource
└── tests/
    └── web/
        ├── cadastrar_aleatorio_test.robot
        ├── cadastrar_test.robot
        ├── cadastrar_usuario_basico.robot
        ├── cadastro_login_carrinho_e2e_test.robot
        ├── faker_test.robot
        ├── login_insucesso_test.robot
        └── login_sucesso_test.robot
```

### 4.2 Responsabilidade de cada camada

| Camada | Responsabilidade | O que não deveria concentrar |
|---|---|---|
| `tests/web` | Declara os cenários, dados, tags, setup e teardown. | Detalhes repetidos de todos os localizadores, quando o cenário usa a arquitetura em camadas. |
| `resources/configs` | Mantém URL, navegador, timeout e valores funcionais compartilhados. | Segredos reais ou dados que dependam de uma execução específica. |
| `resources/page_objects` | Mantém os localizadores da interface. | A sequência de negócio ou asserções completas. |
| `resources/pages` | Encapsula ações e esperas de uma página, combinando SeleniumLibrary com os localizadores. | A narrativa completa de um caso E2E. |
| `resources/steps` | Traduz uma intenção de negócio em chamadas às páginas. | Localizadores de baixo nível e dados fixos de um cenário. |
| `requirements.txt` | Fixa as versões das bibliotecas Python usadas. | Configuração do ambiente externo e do navegador. |
| `README.md` | Orienta clone, ambiente, validação e limitação conhecida. | Resultado atualizado de cada execução. |
| `docs` | Explica o comportamento e a manutenção do projeto. | Implementação executável do teste. |

### 4.3 Relação entre os imports

O fluxo E2E segue esta cadeia:

```text
tests/web/cadastro_login_carrinho_e2e_test.robot
  ├── resources/configs/qa.resource
  ├── resources/steps/cadastrar_steps.resource
  │     └── resources/pages/cadastro_page.resource
  │           ├── resources/configs/qa.resource
  │           └── resources/page_objects/cadastro_page_objects.resource
  ├── resources/steps/login_steps.resource
  │     ├── resources/pages/home_page.resource
  │     │     ├── resources/configs/qa.resource
  │     │     └── resources/page_objects/home_page_objects.resource
  │     └── resources/pages/login_page.resource
  │           ├── resources/configs/qa.resource
  │           └── resources/page_objects/login_page_objects.resource
  ├── resources/steps/produtos_steps.resource
  │     ├── resources/pages/produtos_page.resource
  │     │     ├── resources/configs/qa.resource
  │     │     └── resources/page_objects/produtos_page_objects.resource
  │     └── resources/pages/lista_compras_page.resource
  │           ├── resources/configs/qa.resource
  │           └── resources/page_objects/lista_compras_page_objects.resource
  └── resources/steps/carrinho_steps.resource
        └── resources/pages/carrinho_page.resource
              ├── resources/configs/qa.resource
              └── resources/page_objects/carrinho_page_objects.resource
```

Os testes de cadastro, login negativo e Faker também podem importar a configuração diretamente ou declarar suas próprias variáveis. Por isso, a arquitetura é parcialmente padronizada: o E2E e o login positivo usam a camada `steps`, enquanto os testes de cadastro existentes mantêm implementações locais mais diretas.

### 4.4 Bibliotecas e artefatos

As bibliotecas declaradas são:

- `robotframework==7.5`: executor, sintaxe e modelo de testes;
- `robotframework-seleniumlibrary==6.9.0`: comandos de navegador, campos, botões, esperas e screenshots;
- `robotframework-faker==6.0.0`: geração de dados com localidade `pt_BR`.

Uma execução real do Robot Framework pode gerar `output.xml`, `log.html`, `report.html` e screenshots. O README recomenda a pasta `results/` para a execução E2E, e o `.gitignore` ignora essa pasta e os arquivos padrão de saída. O `dry-run` usado para validação não abre o navegador e pode suprimir os relatórios com `--output NONE --log NONE --report NONE`.

---

## 5. Inventário arquivo por arquivo

O inventário abaixo descreve o comportamento real encontrado em cada arquivo lido.

### 5.1 Arquivos da raiz

| Caminho | Finalidade | Fluxo ou regra coberta | Entradas e saídas | Observações |
|---|---|---|---|---|
| `.gitignore` | Evitar que ambiente local, caches e resultados sejam versionados. | Exclui `.venv/`, `results/`, `output.xml`, `log.html`, `report.html`, caches Python e `.agents/`. | Entrada: arquivos gerados localmente. Saída: regra de exclusão do Git. | Não ignora toda e qualquer imagem ou segredo criado fora dessas áreas. Arquivos de execução devem ficar em `results/`. |
| `README.md` | Orientar clone, preparação do ambiente, validação e execução. | Documenta uso do branch `feature/gilson-dorneles`, criação do venv, `pip check`, `dry-run`, execução por tag e E2E. Também registra que `/carrinho` mostra `Em construção aguarde`. | Entrada: comandos PowerShell e caminhos relativos ao clone. Saída: instruções operacionais. | É a referência operacional existente. Não substitui o resultado de uma execução real atual. |
| `requirements.txt` | Fixar dependências Python. | Define Robot Framework, SeleniumLibrary e FakerLibrary nas versões `7.5`, `6.9.0` e `6.0.0`. | Entrada: arquivo usado pelo `pip install -r`. Saída: ambiente Python preparado para executar a suíte. | Não instala Chrome, driver, servidor ServeRest ou sistema operacional. |

### 5.2 Configuração compartilhada

| Caminho | Finalidade | Fluxo ou regra coberta | Entradas e saídas | Observações |
|---|---|---|---|---|
| `resources/configs/qa.resource` | Centralizar variáveis do ambiente de QA. | Define a URL do frontend, navegador Chrome, timeout de 10 segundos, mensagem de cadastro, ID e nome esperado do produto e mensagem do carrinho em construção. | Entradas: nenhuma, além da expansão de variáveis Robot. Saídas: `${URL}`, `${BROWSER}`, `${TIMEOUT_PADRAO}`, `${MENSAGEM_CADASTRO_SUCESSO}`, `${PRODUTO_ID}`, `${NOME_PRODUTO}` e `${MENSAGEM_CARRINHO_EM_CONSTRUCAO}`. | `${NOME_PRODUTO}` resulta de `Produto 1793283513282`. A URL é externa e não há configuração de credenciais nesse arquivo. |

### 5.3 Page Objects

| Caminho | Finalidade | Fluxo ou regra coberta | Entradas e saídas | Observações |
|---|---|---|---|---|
| `resources/page_objects/cadastro_page_objects.resource` | Declarar os localizadores da tela de cadastro. | Localiza o link de cadastro, os campos de nome, e-mail e senha e o botão de cadastro. | Entrada: DOM da tela. Saída: variáveis `${LINK_CADASTRO}`, `${CAMPO_NOME}`, `${CAMPO_EMAIL}`, `${CAMPO_SENHA}` e `${BOTAO_CADASTRAR}`. | Usa `data-testid="cadastrar"` no link e no botão e IDs nos campos. |
| `resources/page_objects/carrinho_page_objects.resource` | Declarar o localizador do estado atual do carrinho. | Procura no `body` o texto `Em construção aguarde`. | Entrada: DOM da rota do carrinho. Saída: `${CARRINHO_PLACEHOLDER}`. | Não há localizador de produto, quantidade ou preço no carrinho. |
| `resources/page_objects/home_page_objects.resource` | Declarar elementos da página inicial e da área autenticada. | Localiza o acesso ao cadastro e o botão de logout. | Entrada: DOM da página. Saída: `${CADASTRESE_BUTTON}` e `${LOGOUT_BUTTON}`. | O botão de cadastro aqui é uma âncora; o logout é um botão com `data-testid`. |
| `resources/page_objects/lista_compras_page_objects.resource` | Declarar elementos da lista de compras. | Localiza o nome de um produto na lista e o botão para adicioná-lo ao carrinho. | Entrada: DOM de `minhaListaDeProdutos`. Saída: `${PRODUTO_LISTA_ITEM}` e `${ADICIONAR_CARRINHO_BUTTON}`. | O seletor do produto verifica a existência de um elemento com o `data-testid`, mas não compara o texto nessa camada. |
| `resources/page_objects/login_page_objects.resource` | Declarar elementos usados no login. | Localiza e-mail, senha e botão `Entrar`. | Entrada: DOM da tela de login ou área autenticada. Saída: variáveis de campos e botões. | `${CADASTRAR_BUTTON}` usa o mesmo seletor de `${ENTRAR_BUTTON}` e `${LOGOUT_BUTTON}` é repetido em `home_page_objects`; essas variáveis não são usadas pelas keywords atuais de login. |
| `resources/page_objects/produtos_page_objects.resource` | Declarar localizadores do produto configurado. | Exige que o cartão contenha o título `${NOME_PRODUTO}` e o botão `data-testid="adicionarNaLista"`. | Entrada: configuração de QA e DOM da vitrine. Saída: `${PRODUTO_CARD_CONFIRMADO}` e `${ADICIONAR_PRODUTO_CONFIRMADO}`. | É o único Page Object que importa diretamente `qa.resource`, porque usa o nome configurado do produto no XPath. |

### 5.4 Ações de página

| Caminho | Finalidade | Fluxo ou regra coberta | Entradas e saídas | Observações |
|---|---|---|---|---|
| `resources/pages/cadastro_page.resource` | Encapsular ações e esperas da tela de cadastro. | Abre o cadastro pelo link, espera campos, preenche nome/e-mail/senha, envia e espera a mensagem de sucesso. | Entradas: `${nome}`, `${email}`, `${senha}` e elementos do DOM. Saídas: formulário enviado e mensagem esperada encontrada. | Usa `Input Password` para a senha. Não trata validações negativas nem campo de administrador. |
| `resources/pages/carrinho_page.resource` | Encapsular a espera da página de carrinho. | Espera uma URL contendo `carrinho`, encontra o marcador de construção e verifica a mensagem. | Entrada: URL e DOM da página. Saída: confirmação do estado `Em construção aguarde`. | A validação é deliberadamente compatível com uma página ainda em construção. |
| `resources/pages/home_page.resource` | Encapsular esperas da home e da área autenticada. | Espera o link de cadastro, o texto `Serverest Store` ou o botão de logout. | Entrada: DOM da página. Saída: confirmação de carregamento público ou autenticado. | O texto da loja e a visibilidade do logout são as evidências do login positivo. |
| `resources/pages/lista_compras_page.resource` | Encapsular navegação e ações da lista. | Navega para `${URL}minhaListaDeProdutos`, espera a rota, espera um produto e adiciona o produto ao carrinho. | Entrada: URL, DOM e botões da lista. Saída: navegador na lista e clique de adicionar realizado. | A navegação é direta por URL. O código não verifica o nome exato do item nessa página. |
| `resources/pages/login_page.resource` | Encapsular abertura, preenchimento e envio do login. | Abre `${URL}login`, espera campos e botão, preenche e-mail e senha e envia o formulário. | Entradas: `${email}` e `${senha}`. Saída: formulário de login enviado. | A keyword `Submeter o formulário de cadastro` apenas chama `Submeter o formulário de login`; o nome é incompatível com a ação real, embora seja usado pelo step de login. |
| `resources/pages/produtos_page.resource` | Encapsular localização e seleção do produto. | Espera o cartão confirmado e clica no botão para adicionar à lista. | Entrada: DOM da vitrine e nome configurado. Saída: seleção do produto realizada. | A confirmação depende do título e do botão estarem no mesmo cartão. |

### 5.5 Steps de negócio

| Caminho | Finalidade | Fluxo ou regra coberta | Entradas e saídas | Observações |
|---|---|---|---|---|
| `resources/steps/cadastrar_steps.resource` | Oferecer steps BDD de cadastro. | Abre o ServeRest, acessa o cadastro, gera dados Faker únicos, salva as credenciais e valida o sucesso. | Entradas: URL, Faker e formulário. Saídas: `${NOME_USUARIO}`, `${EMAIL_USUARIO}` e `${SENHA_USUARIO}` como variáveis de teste, além da mensagem de sucesso. | Usa nome Faker, UUID4 no e-mail `@example.com` e senha Faker de 12 caracteres. |
| `resources/steps/carrinho_steps.resource` | Oferecer steps BDD para o estado atual do carrinho. | Tanto o dado de página carregada quanto a verificação final chamam a espera do marcador em construção. | Entrada: DOM e URL do carrinho. Saída: confirmação de `Em construção aguarde`. | O step não afirma que o produto foi exibido no carrinho. |
| `resources/steps/login_steps.resource` | Oferecer steps BDD de login e verificação da sessão. | Espera login, abre a página, preenche dados, envia, verifica a loja, verifica logout e confirma que `Login` não aparece. | Entradas: e-mail e senha. Saídas: evidências de área autenticada e screenshot na última verificação. | Usa o step de página com nome `Submeter o formulário de cadastro`, que na prática envia login. |
| `resources/steps/produtos_steps.resource` | Oferecer steps BDD para produto e lista. | Seleciona o produto confirmado, abre a lista, verifica item e adiciona ao carrinho. | Entrada: DOM das páginas de produto e lista. Saída: sequência de seleção e clique para carrinho. | Não inclui uma asserção de preço, quantidade ou nome textual do item na lista. |

### 5.6 Suítes e cenários Robot Framework

| Caminho | Finalidade | Fluxo ou regra coberta | Entradas e saídas | Observações |
|---|---|---|---|---|
| `tests/web/cadastrar_aleatorio_test.robot` | Testar cadastro positivo com dados aleatórios em um teste independente. | Abre o site, clica em `Cadastre-se`, preenche dados Faker e espera `Cadastro realizado com sucesso`. | Entradas: nome Faker, e-mail Faker com domínio `dbservices.pt` e senha Faker de oito caracteres. Saída: mensagem de sucesso e screenshot. | Tags `cadastro` e `faker`. Usa localizadores e keywords próprias, sem a camada `pages/steps`. |
| `tests/web/cadastrar_test.robot` | Testar cadastro positivo em dois casos orientados por dados. | Usa um template para cadastrar administrador e não administrador; marca `id:administrador` somente na linha verdadeira; espera mensagem parametrizada. | Entradas: `Celso`, `celso4@rothmail.com`, `admin123`, `${True}`; e `Fulane`, `fulane4@bol.com.br`, `teste123`, `${False}`. Saída: mensagem esperada e screenshot para cada linha. | Não declara tags. O campo de administrador aparece somente neste teste e sua existência real não é comprovada por `dry-run`. |
| `tests/web/cadastrar_usuario_basico.robot` | Manter um teste direto de cadastro básico, sem BDD e sem resources de páginas. | Abre a URL, clica em `Cadastre-se`, preenche o formulário fixo, envia e espera a mensagem de sucesso. | Entradas: `Ana Terra`, `usuario.basico@academy.com.br`, `admin123`. Saída: mensagem e screenshot. | Não declara tags e define URL, navegador, dados e mensagem localmente. Reexecuções podem encontrar o mesmo e-mail já criado. |
| `tests/web/cadastro_login_carrinho_e2e_test.robot` | Validar o encadeamento E2E de cadastro, login, produto, lista e carrinho. | Executa o fluxo descrito na seção 3 usando todos os steps em camadas. | Entradas: dados Faker únicos e produto `Produto 1793283513282`. Saída: sucessos de cadastro/login, item localizado na lista e mensagem de carrinho em construção. | Tags `e2e`, `cadastro`, `login` e `carrinho`. O teste não confirma o produto no carrinho. |
| `tests/web/faker_test.robot` | Demonstrar geração de dados Faker. | Gera e registra e-mail, CNPJ e texto. | Entradas: localidade `pt_BR` e limite de 300 caracteres para o texto. Saída: valores no log do Robot. | Tags `faker` e `exemplos`. Não abre navegador nem valida uma regra da loja. |
| `tests/web/login_insucesso_test.robot` | Validar rejeições de login com um template. | Executa os quatro casos de credencial inválida ou campo vazio e procura a mensagem correspondente. | Entradas: quatro combinações de e-mail, senha e mensagem esperada. Saída: mensagem de erro localizada na página. | Tag de suíte `login`. Usa `id: email`, `id: password` e XPath do botão cujo texto é `Entrar`. |
| `tests/web/login_sucesso_test.robot` | Validar autenticação positiva com um usuário existente. | Abre login, usa credencial fixa, verifica loja, logout e ausência do texto `Login`. | Entradas: `celso@rothmail.com` e `admin123`. Saída: verificações da área autenticada e screenshot na última keyword. | Tags `login` e `happy_path`. Depende de estado prévio no ambiente; o teste não cadastra o usuário. |

### 5.7 Documento criado nesta solicitação

| Caminho | Finalidade | Fluxo ou regra coberta | Entradas e saídas | Observações |
|---|---|---|---|---|
| `docs/documentacao-funcional-e-tecnica.md` | Registrar a visão funcional, arquitetura, inventário, execução, evidências e limitações do projeto. | Explica os comportamentos existentes sem alterar a implementação. | Entrada: arquivos do clone lidos antes da redação e resultados de `pip check` e `dry-run`; saída: documentação em português. | É o único arquivo criado nesta solicitação. |

---

## 6. Tabela de cenários de teste

A tabela abaixo trata cada caso declarado no código. Quando uma suíte usa `Test Tags`, as tags se aplicam aos casos daquela suíte. O tipo de validação indica a intenção da execução real; a coluna de evidência distingue isso do `dry-run`.

| Suíte e cenário | Tags | Objetivo | Dados principais | Resultado esperado | Tipo e evidência |
|---|---|---|---|---|---|
| `cadastrar_aleatorio_test.robot` — Cadastrar um usuário com sucesso | `cadastro`, `faker` | Confirmar cadastro com dados variáveis. | Nome Faker; e-mail Faker com `dbservices.pt`; senha de 8 caracteres. | Mensagem `Cadastro realizado com sucesso`. | UI positiva, com screenshot. `dry-run`: passou; execução real: não comprovada nesta atualização. |
| `cadastrar_test.robot` — Cadastrar administrador | Sem tag declarada | Confirmar cadastro de administrador. | `Celso`, `celso4@rothmail.com`, `admin123`, administrador verdadeiro. | Checkbox `id:administrador` é marcado e a mensagem parametrizada aparece. | UI orientada a dados. `dry-run`: passou; execução real: não comprovada. |
| `cadastrar_test.robot` — Cadastrar não administrador | Sem tag declarada | Confirmar cadastro sem marcar administrador. | `Fulane`, `fulane4@bol.com.br`, `teste123`, administrador falso. | O cadastro é enviado sem marcar o campo e a mensagem aparece. | UI orientada a dados. `dry-run`: passou; execução real: não comprovada. |
| `cadastrar_usuario_basico.robot` — Cadastrar um usuário com sucesso | Sem tag declarada | Confirmar o fluxo direto mínimo de cadastro. | `Ana Terra`, `usuario.basico@academy.com.br`, `admin123`. | Mensagem de sucesso e screenshot. | UI positiva. `dry-run`: passou; execução real: não comprovada. |
| `cadastro_login_carrinho_e2e_test.robot` — Cadastro, login e adição de produto ao carrinho | `e2e`, `cadastro`, `login`, `carrinho` | Confirmar a cadeia de negócio entre cadastro, autenticação, lista e carrinho. | Nome Faker; UUID em e-mail `@example.com`; senha Faker de 12 caracteres; produto `1793283513282`. | Cadastro e login passam; produto é localizado e vai à lista; a rota contém `carrinho` e mostra `Em construção aguarde`. | End-to-end parcial. `dry-run`: passou; execução real: não comprovada; produto no carrinho não é confirmado. |
| `faker_test.robot` — Gerar um e-mail fake | `faker`, `exemplos` | Demonstrar a geração de e-mail. | `FakerLibrary.Email`. | Valor aparece no log. | Biblioteca/log, sem navegador. `dry-run`: passou; valor real não é evidência de regra da loja. |
| `faker_test.robot` — Gerar um CNPJ fake | `faker`, `exemplos` | Demonstrar a geração de CNPJ. | `FakerLibrary.Cnpj`. | Valor aparece no log. | Biblioteca/log. `dry-run`: passou; não valida cadastro. |
| `faker_test.robot` — Gerar um texto fake | `faker`, `exemplos` | Demonstrar a geração de texto. | `FakerLibrary.Text`, máximo de 300 caracteres. | Texto aparece no log. | Biblioteca/log. `dry-run`: passou; não valida a loja. |
| `login_insucesso_test.robot` — Senha incorreta | `login` | Confirmar rejeição de senha incorreta. | `eu@dev.com` / `errada123`. | `Email e/ou senha inválidos`. | UI negativa por mensagem. `dry-run`: passou; execução real não comprovada. |
| `login_insucesso_test.robot` — Email não cadastrado | `login` | Confirmar rejeição de e-mail inexistente. | `nada@academy.dev` / `Senha123`. | `Email e/ou senha inválidos`. | UI negativa por mensagem. `dry-run`: passou; execução real não comprovada. |
| `login_insucesso_test.robot` — Email vazio | `login` | Confirmar obrigatoriedade do e-mail. | E-mail vazio / `admin123`. | `Email é obrigatório`. | UI negativa por validação de campo. `dry-run`: passou; execução real não comprovada. |
| `login_insucesso_test.robot` — Senha vazia | `login` | Confirmar obrigatoriedade da senha. | `paul@dev.pt` / senha vazia. | `Password é obrigatório`. | UI negativa por validação de campo. `dry-run`: passou; execução real não comprovada. |
| `login_sucesso_test.robot` — Login com sucesso | `login`, `happy_path` | Confirmar entrada de um usuário existente. | `celso@rothmail.com` / `admin123`. | `Serverest Store`, logout visível e ausência de `Login`. | UI positiva, com screenshot. `dry-run`: passou; execução real não comprovada. |

### Dry-run versus execução real

- **Dry-run:** foi executado com `--dryrun --output NONE --log NONE --report NONE`. O Robot interpreta as suítes, resolve imports e keywords e não abre o Chrome. Não envia cadastro, não faz login no ambiente e não confirma locators contra o DOM real.
- **Execução real:** abre o Chrome, acessa o frontend externo e aplica os efeitos descritos na seção 2.7. Só essa modalidade pode confirmar mensagens, locators, navegação, estado de usuário e estado do carrinho.

---

## 7. Dados, segurança e ambiente

### Ambiente externo

- Frontend configurado: `https://front.serverest.dev/`.
- Navegador configurado: `chrome`.
- Timeout padrão: `10s`.
- Rotas usadas ou esperadas: `/`, `/login`, `/minhaListaDeProdutos` e uma localização contendo `carrinho`.
- Produto configurado: ID `1793283513282`, nome `Produto 1793283513282`.
- Mensagens funcionais configuradas: `Cadastro realizado com sucesso` e `Em construção aguarde`.

A disponibilidade, os dados e o comportamento do ServeRest são externos ao repositório. O arquivo `requirements.txt` não instala navegador ou driver. O ambiente de execução deve fornecer o Chrome e os componentes necessários para que o SeleniumLibrary o controle.

### Dados Faker e credenciais fixas

O E2E gera:

- nome com `FakerLibrary.Name`;
- e-mail no formato `${uuid}@example.com`;
- senha Faker com 12 caracteres.

O teste de cadastro aleatório usa e-mail Faker com domínio `dbservices.pt` e senha Faker com oito caracteres.

Ainda existem valores fixos no código:

- login positivo: `celso@rothmail.com` / `admin123`;
- cadastro de administrador: `celso4@rothmail.com` / `admin123`;
- cadastro sem administrador: `fulane4@bol.com.br` / `teste123`;
- cadastro básico: `usuario.basico@academy.com.br` / `admin123`;
- dados usados nos cenários negativos: `eu@dev.com`, `nada@academy.dev`, `paul@dev.pt`, com as senhas descritas na tabela de login negativo.

O código não comprova que esses valores sejam credenciais de produção, mas eles devem ser tratados como dados de teste. Se algum deles der acesso a um ambiente real, não deve ser reutilizado como segredo de produção. A suíte não usa variável de ambiente, cofre de segredos ou arquivo de configuração protegido para credenciais.

Senhas e dados gerados podem aparecer em argumentos de keywords, logs ou screenshots dependendo das opções de log do Robot. Execuções reais devem usar dados de teste e uma pasta de resultados com acesso controlado.

### Efeitos e isolamento

A criação de usuários e a alteração da lista ou do carrinho ocorrem no ambiente remoto. O E2E reduz colisões no e-mail de cadastro usando UUID, mas os testes diretos usam e-mails fixos e não limpam os registros. Por isso, o cliente deve executar a suíte contra um ambiente de QA controlado e considerar a necessidade de limpeza ou dados preparados.

### Screenshots e resultados

Há chamadas a `Capture Page Screenshot` nos testes de cadastro e no login positivo. O Robot também pode produzir:

- `output.xml`;
- `log.html`;
- `report.html`;
- imagens associadas às evidências.

A execução E2E documentada no README usa `results/e2e-cadastro-login-carrinho` como `outputdir`. A pasta `results/` e os três arquivos padrão são ignorados pelo Git. Para não expor evidências acidentalmente, screenshots e relatórios devem ser gravados dentro de `results/` ou em outro diretório de artefatos fora do versionamento.

### O que não deve ser enviado ao repositório

Não devem ser versionados:

- `.venv/`;
- `results/`;
- `output.xml`, `log.html` e `report.html`;
- caches Python;
- screenshots ou logs contendo dados de execução fora de diretório ignorado;
- credenciais reais, tokens, cookies, arquivos `.env` ou dados pessoais de usuários.

O `.gitignore` atual cobre os ambientes e saídas listados no próprio arquivo, mas não é uma autorização para versionar um segredo que tenha outra extensão ou esteja em outro diretório.

---

## 8. Como executar no Windows PowerShell

Os comandos seguintes devem ser executados a partir da raiz do projeto, `Curso-de-Automacao`. Os caminhos dos testes e dos resultados são relativos a essa raiz.

### 8.1 Criar e preparar o ambiente

```powershell
py -m venv .venv
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt
& ".\.venv\Scripts\python.exe" -m pip check
```

O `pip check` deve terminar com:

```text
No broken requirements found.
```

A instalação não configura o Chrome nem garante a disponibilidade do frontend remoto. Esses itens precisam estar disponíveis na máquina e na rede.

### 8.2 Fazer o dry-run de toda a suíte

```powershell
& ".\.venv\Scripts\python.exe" -m robot --dryrun --output NONE --log NONE --report NONE tests\web
```

Essa validação não abre o navegador. Ela é apropriada para verificar sintaxe, imports e resolução das keywords antes de uma execução que altere o ambiente externo.

### 8.3 Executar por tag

Para executar os cenários marcados como login e gravar os artefatos em uma pasta ignorada:

```powershell
& ".\.venv\Scripts\python.exe" -m robot --include login --outputdir results\login tests\web
```

Para executar somente o fluxo E2E por tag:

```powershell
& ".\.venv\Scripts\python.exe" -m robot --include e2e --outputdir results\e2e tests\web
```

As tags existentes são `cadastro`, `faker`, `e2e`, `login`, `carrinho`, `happy_path` e `exemplos`, conforme cada arquivo. `cadastrar_test.robot` e `cadastrar_usuario_basico.robot` não declaram tags; portanto, uma execução filtrada por tag não seleciona esses dois arquivos por seus casos.

### 8.4 Executar o E2E com diretório nomeado

O comando documentado no README para o fluxo completo é:

```powershell
& ".\.venv\Scripts\python.exe" -m robot --outputdir results\e2e-cadastro-login-carrinho tests\web\cadastro_login_carrinho_e2e_test.robot
```

Esse comando pode criar um usuário e alterar dados no ServeRest. Use-o somente contra um ambiente autorizado de QA e confira previamente se o produto e as mensagens esperadas estão disponíveis.

### 8.5 Executar um arquivo direto

Exemplos para os testes sem tags:

```powershell
& ".\.venv\Scripts\python.exe" -m robot --outputdir results\cadastro-basico tests\web\cadastrar_usuario_basico.robot
& ".\.venv\Scripts\python.exe" -m robot --outputdir results\cadastro-dados tests\web\cadastrar_test.robot
```

O primeiro comando usa o e-mail fixo do cadastro básico. O segundo pode tentar criar dois usuários fixos e, por isso, pode depender do estado atual do ambiente.

---

## 9. Evidências e limitações

### Evidências obtidas para esta documentação

A análise foi feita lendo a árvore versionada e o conteúdo dos arquivos listados na seção final. Também foram executadas, sem instalar dependências e sem realizar uma execução web real:

1. `pip check` no ambiente virtual já existente, com resultado `No broken requirements found.`;
2. `robot --dryrun --output NONE --log NONE --report NONE tests\web`, com resultado de **13 testes aprovados e 0 falhos**.

O resultado do `dry-run` comprova que, no ambiente usado para a verificação, o Robot conseguiu interpretar as suítes, carregar os resources e resolver as keywords. Ele não comprova que o Chrome abre, que os seletores correspondem ao DOM atual, que o usuário fixo existe ou que o ServeRest responde com as mensagens esperadas.

### O que não foi comprovado

Não foi realizada, como parte desta documentação, uma execução real contra `front.serverest.dev`. Portanto, não há evidência nova de:

- criação de usuário no ambiente remoto;
- autenticação real com o usuário fixo;
- disponibilidade do produto `1793283513282`;
- comportamento atual dos locators;
- navegação automática após o clique de adicionar ao carrinho;
- estado do produto dentro do carrinho;
- screenshots de uma execução web bem-sucedida.

Os arquivos de resultado são locais e ignorados pelo Git. A ausência de um relatório versionado não deve ser interpretada como aprovação ou reprovação de uma execução real anterior.

### Limitação funcional declarada

O código e o README assumem que `/carrinho` exibe `Em construção aguarde`. O E2E foi ajustado para validar esse marcador, e não um produto. Assim, não é correto declarar que toda a jornada de compra está concluída: o cadastro, o login e a preparação do produto são cobertos no fluxo, mas a confirmação comercial do carrinho está pendente.

Também existem diferenças entre os testes antigos e a camada compartilhada:

- há três formas de cadastro, com dados, localizadores e keywords duplicados;
- somente um teste usa o campo de administrador;
- o login positivo depende de uma conta fixa, enquanto o E2E cria a própria conta;
- algumas variáveis de Page Object têm nomes inconsistentes ou não são usadas;
- os testes sem tags não entram em execuções filtradas por tag.

Essas observações são limitações de manutenção e cobertura observadas no código, não falhas corrigidas por este documento.

---

## 10. Recomendações priorizadas para evolução

As recomendações abaixo são propostas. Nenhuma delas foi implementada nesta solicitação.

### Prioridade de negócio

1. **P0 — Definir o critério de aceite do carrinho.** Decidir com o produto se a mensagem `Em construção aguarde` é temporária ou se o cenário deve continuar documentando apenas a disponibilidade da rota. Quando o carrinho estiver implementado, validar nome do produto, quantidade, preço e total.
2. **P1 — Definir a política de dados de teste.** Escolher se os testes devem criar usuários a cada execução, reutilizar fixtures ou limpar os dados ao final. Isso evita que cadastros fixos e listas remotas alterem a leitura dos resultados.
3. **P1 — Completar regras de cadastro.** Se administrador, unicidade de e-mail, formato de e-mail e política de senha forem requisitos do produto, criar cenários explícitos para essas regras em vez de inferi-las apenas dos dados atuais.
4. **P2 — Expandir a jornada de compra.** Depois de o carrinho funcionar, cobrir remoção de produto, quantidade, cálculo de valores e finalização, caso esses comportamentos façam parte do escopo comercial.

### Prioridade de confiabilidade

1. **P0 — Executar a suíte contra um ambiente de QA controlado.** Garantir que o frontend, o produto, o usuário de login positivo e as mensagens estejam na versão esperada antes de interpretar o resultado.
2. **P1 — Isolar e limpar estado remoto.** Preferir dados únicos por execução e uma estratégia de limpeza ou ambiente descartável. O e-mail UUID já reduz colisões no E2E, mas os testes diretos continuam usando valores fixos.
3. **P1 — Fortalecer as esperas e os contratos da interface.** Manter `data-testid` estáveis, aguardar mudanças de estado específicas e reduzir asserções amplas como procurar texto genérico no `body` quando um elemento de negócio estiver disponível.
4. **P1 — Registrar execução real com artefatos controlados.** Padronizar `outputdir`, retenção de logs e screenshots e proteger dados gerados antes de compartilhar um relatório.
5. **P2 — Automatizar a execução em CI.** Executar primeiro o `dry-run` e depois os cenários web em um agente com Chrome, rede e variáveis de ambiente controladas, sem expor credenciais.

### Prioridade de manutenção

1. **P1 — Consolidar os fluxos duplicados.** Avaliar a migração dos três testes de cadastro para `pages` e `steps`, mantendo casos diretos somente quando houver uma razão clara. Isso reduziria divergências de localizador e timeout.
2. **P1 — Padronizar nomes e tags.** Corrigir a nomenclatura de keywords como `Submeter o formulário de cadastro`, que envia login, e revisar variáveis duplicadas ou não utilizadas como `CADASTRAR_BUTTON`. A mudança deve ser acompanhada por atualização dos imports e dos cenários.
3. **P1 — Taggear todos os cenários de forma consistente.** Assim, execuções por `--include` terão comportamento previsível também para os testes de cadastro direto.
4. **P2 — Separar configuração de ambiente dos dados de teste.** Manter URL e navegador em configuração, mas fornecer credenciais e IDs variáveis por ambiente autorizado quando esses valores não forem universais.
5. **P2 — Manter a documentação junto com o contrato do sistema.** Atualizar o documento quando rotas, mensagens, produto de referência ou o comportamento do carrinho mudarem, registrando sempre se a evidência veio de `dry-run` ou de execução real.

---

## 11. Glossário para o cliente

| Termo | Explicação |
|---|---|
| **Suíte** | Conjunto de cenários Robot Framework reunidos em um arquivo ou diretório. |
| **Cenário** | Um caso de negócio executável, como cadastrar um usuário ou fazer login. |
| **Keyword** | Uma ação nomeada do Robot Framework. Pode ser fornecida por uma biblioteca, como `Click Button`, ou criada no projeto, como `Adicionar o produto confirmado à lista`. |
| **Resource** | Arquivo `.resource` reutilizável que guarda variáveis, localizadores ou keywords para outras suítes. |
| **Page Object** | Camada que concentra os localizadores dos elementos de uma página, separando o endereço técnico do elemento do fluxo de negócio. |
| **BDD** | Estilo de descrição de comportamento com linguagem próxima do negócio, usando termos como Dado, Quando e Então. |
| **Tag** | Rótulo associado a um cenário para filtrá-lo na execução, por exemplo `login` ou `e2e`. |
| **Dry-run** | Validação que carrega e interpreta os testes sem abrir o navegador nem acessar o sistema externo. Não substitui uma execução real. |
| **Teste end-to-end (E2E)** | Teste que percorre várias partes do sistema em uma única jornada, do cadastro ao carrinho neste projeto. |

---

## Arquivos lidos e confirmação de alteração

Foram lidos, antes da redação, os seguintes arquivos do clone:

- `.gitignore`
- `README.md`
- `requirements.txt`
- `resources/configs/qa.resource`
- `resources/page_objects/cadastro_page_objects.resource`
- `resources/page_objects/carrinho_page_objects.resource`
- `resources/page_objects/home_page_objects.resource`
- `resources/page_objects/lista_compras_page_objects.resource`
- `resources/page_objects/login_page_objects.resource`
- `resources/page_objects/produtos_page_objects.resource`
- `resources/pages/cadastro_page.resource`
- `resources/pages/carrinho_page.resource`
- `resources/pages/home_page.resource`
- `resources/pages/lista_compras_page.resource`
- `resources/pages/login_page.resource`
- `resources/pages/produtos_page.resource`
- `resources/steps/cadastrar_steps.resource`
- `resources/steps/carrinho_steps.resource`
- `resources/steps/login_steps.resource`
- `resources/steps/produtos_steps.resource`
- `tests/web/cadastrar_aleatorio_test.robot`
- `tests/web/cadastrar_test.robot`
- `tests/web/cadastrar_usuario_basico.robot`
- `tests/web/cadastro_login_carrinho_e2e_test.robot`
- `tests/web/faker_test.robot`
- `tests/web/login_insucesso_test.robot`
- `tests/web/login_sucesso_test.robot`

O conteúdo interno de `.git` e arquivos locais ignorados pelo `.gitignore`, incluindo eventuais artefatos internos de `.agents/`, foi excluído do escopo. Somente o arquivo `docs/documentacao-funcional-e-tecnica.md` foi criado. Nenhum arquivo de código, teste, resource, README, `requirements.txt` ou configuração foi alterado; nenhum pacote foi instalado, e não foi feito commit ou push.
