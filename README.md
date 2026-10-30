# digicon-serverest-test

Suíte de automação web com Robot Framework para o ServeRest.

## Clonar o repositório

No PowerShell, clone a branch do fluxo e entre na pasta do clone:

```powershell
git clone --branch feature/gilson-dorneles https://github.com/Gilson-Dorneles/Curso-de-Automacao.git Curso-de-Automacao
Set-Location .\Curso-de-Automacao
```

Se o clone já existir, entre diretamente na pasta `Curso-de-Automacao` e confirme a branch com `git status`.

## Preparar o ambiente

Execute os comandos a partir da raiz deste clone no PowerShell:

```powershell
py -m venv .venv
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt
& ".\.venv\Scripts\python.exe" -m pip check
```

O `pip check` deve terminar com `No broken requirements found.`.

## Validar as suítes

Para validar todas as suítes sem abrir o navegador:

```powershell
& ".\.venv\Scripts\python.exe" -m robot --dryrun --output NONE --log NONE --report NONE tests\web
```

Para executar somente os testes com uma tag, use `--include`. Por exemplo, o teste de login feliz usa as tags `login` e `happy_path`:

```powershell
& ".\.venv\Scripts\python.exe" -m robot --include login tests\web
```

A execução E2E do fluxo de cadastro, login e carrinho grava os artefatos em `results/e2e-cadastro-login-carrinho`:

```powershell
& ".\.venv\Scripts\python.exe" -m robot --outputdir results/e2e-cadastro-login-carrinho tests\web\cadastro_login_carrinho_e2e_test.robot
```

A rota `/carrinho` do ambiente atualmente exibe `Em construção aguarde`. Por isso, a execução real não confirma o produto dentro do carrinho e não deve depender de um locator de produto nessa página. O produto usado no fluxo é o ID `1793283513282`.

Os diretórios `.venv/` e `results/`, além dos arquivos gerados pelo Robot Framework, são ignorados pelo Git.
