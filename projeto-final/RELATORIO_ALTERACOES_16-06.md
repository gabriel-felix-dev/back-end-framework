# Relatório de Alterações — Sistema Aqua Core

**Projeto:** Sistema de Academia (Flutter + Flask)
**Data:** 2026-06-10

---

## 1. Correções de Bugs

### 1.1 Flutter — Verificações de `mounted`

**Arquivos:** `login_view.dart`, `cadastra_aluno_view.dart`, `cadastra_professor_view.dart`, `recupera_senha_view.dart`, `tela_nova_senha_view.dart`, `home_professor_view.dart`, `home_aluno_view.dart`

**Problema:** Chamadas a `setState()` e `ScaffoldMessenger` após `await` de requisições HTTP sem verificar se o widget ainda estava montado. Causava crash quando o usuário navegava para outra tela durante uma requisição.

**Solução:** Adicionado `if (!mounted) return;` após cada `await http.*` e `if (mounted) setState(...)` nos blocos `finally`.

---

### 1.2 Flutter — `DropdownButtonFormField`

**Arquivo:** `cadastra_aluno_view.dart`

**Problema:** Parâmetro `value:` depreciado no Flutter 3.33+.

**Solução:** Substituído por `initialValue:`.

---

### 1.3 Flask — Configuração do Flask-Mail

**Arquivo:** `app.py`

**Problema:** A instância `Mail(app)` era criada dentro do handler da rota `/recuperaSenha`, causando erro de re-inicialização a cada requisição.

**Solução:** Movida a configuração e a instância `mail = Mail(app)` para o escopo global do módulo.

---

### 1.4 Flask — Código de recuperação de senha reutilizável

**Arquivo:** `app.py`

**Problema:** A variável `codigo_recuperacao_gerado` não era zerada após o uso, permitindo reutilização do código.

**Solução:** Adicionado `codigo_recuperacao_gerado = None` após a atualização bem-sucedida da senha em `atualizaSenha`.

---

### 1.5 Flask — `lerTreinosProfessor` e `lerTreinosAluno` retornavam lista plana

**Arquivo:** `app.py`

**Problema:** Ambas as rotas retornavam `jsonify(listaTreinos)` (lista plana). O Flutter acessava `jsonDecode(body)[0]` esperando uma lista aninhada, causando `TypeError: Instance of '_JsonMap'`.

**Solução:** Corrigido para `return jsonify([listaTreinos])`.

---

### 1.6 Flask — Exclusão de Professor/Aluno com vínculos

**Arquivo:** `app.py`

**Problema:** Tentar excluir um usuário com Treinos vinculados causava erro de integridade referencial no banco, retornando mensagem genérica.

**Solução:** Adicionado `SELECT COUNT(*)` antes do DELETE em ambas as rotas. Se houver treinos, retorna mensagem explicativa:
- Professor: *"Você é responsável por treinos cadastrados e não pode ser excluído."*
- Aluno: *"Você possui treinos vinculados à sua conta e não pode ser excluído."*

---

## 2. Novas Funcionalidades

### 2.1 Alteração de Email — Professor e Aluno

**Arquivos:** `home_professor_view.dart`, `home_aluno_view.dart`, `app.py`

- Campo de e-mail adicionado ao dialog de "Alterar Dados" de ambos os usuários.
- Flask: rotas `atualizarProfessor` e `atualizarAluno` atualizadas para aceitar o novo e-mail.
- Tratamento de `IntegrityError` para e-mails já cadastrados.

---

### 2.2 Alteração de Senha com Verificação — Professor e Aluno

**Arquivos:** `home_professor_view.dart`, `home_aluno_view.dart`, `app.py`

- Senha removida do dialog de "Alterar Dados".
- Criado dialog exclusivo "Alterar Senha" (botão `Icons.lock` na AppBar) com três campos: senha atual, nova senha e confirmação.
- A nova senha só é aceita se os campos "nova senha" e "confirmação" forem iguais (validação no cliente).
- Flask: criadas duas novas rotas:
  - `PUT /alterarSenhaProfessor` — verifica senha atual via `SELECT`, atualiza apenas se correta.
  - `PUT /alterarSenhaAluno` — mesma lógica.

---

### 2.3 Troca de Plano — Aluno

**Arquivos:** `home_aluno_view.dart`, `app.py`

- `DropdownButtonFormField` com os 4 planos adicionado ao dialog "Alterar Dados" do Aluno.
- Flask: rota `atualizarAluno` atualizada para receber e gravar `idPlanoFK`.

---

### 2.4 Lista de Alunos — Professor

**Arquivos:** `home_professor_view.dart`, `app.py`

- Novo botão `Icons.people` na AppBar do Professor.
- Abre dialog com lista de todos os alunos (nome, e-mail, telefone, matrícula).
- Flask: criada rota `GET /lerAlunos` retornando `[[{id, nome, email, telefone}]]`.

---

### 2.5 Busca de Aluno por Nome — Professor

**Arquivo:** `home_professor_view.dart`

- Novo botão `Icons.search` na AppBar do Professor.
- Abre dialog com campo de texto e botão "Buscar".
- A lista de resultados só aparece após clicar em "Buscar".
- Filtragem por parte do nome (case-insensitive), sem nova requisição ao servidor.
- Cada resultado exibe matrícula ("Matr."), nome, e-mail e telefone.

---

### 2.6 Nome do Professor no Treino do Aluno

**Arquivos:** `home_aluno_view.dart`, `app.py`

- Flask: rota `lerTreinosAluno` passou a fazer `JOIN Professor` para buscar o nome.
- Flutter: título do card de treino exibe `"<Título> - Prof. Responsável: <Nome>"`.

---

### 2.7 Visualização de Informações Pessoais — Professor e Aluno

**Arquivos:** `home_professor_view.dart`, `home_aluno_view.dart`, `app.py`

- Novo botão `Icons.info_outline` na AppBar de ambos os usuários.
- Abre dialog somente leitura com: Nome, E-mail, Telefone e CPF.
- Flask: rotas `loginProfessor` e `loginAluno` atualizadas para retornar o campo `cpf` no objeto `usuario`.

---

## 3. Melhorias Visuais

### 3.1 Cards de Treino

**Arquivos:** `home_professor_view.dart`, `home_aluno_view.dart`

- `ListTile` simples substituído por `Card` com `elevation: 3` e `BorderRadius.circular(10)`.
- Título do treino em negrito.

---

### 3.2 Paleta de Cores

**Arquivo:** `main.dart`

Paleta de 3 cores aplicada globalmente via `ThemeData`:

| Elemento | Cor | Hex |
|---|---|---|
| AppBar, botões primários, FAB, título | Azul escuro | `#4166A0` |
| Bordas focadas, secondary | Azul médio | `#99C6E8` |
| Fundo de todas as telas, surface | Azul claro | `#F2F9FE` |
| Cards | Branco com sombra | `#FFFFFF` |

Componentes configurados no tema global: `AppBarTheme`, `ElevatedButtonThemeData`, `OutlinedButtonThemeData`, `TextButtonThemeData`, `CardThemeData`, `InputDecorationTheme`, `FloatingActionButtonThemeData`.

---

### 3.3 Tela de Login — Layout e Identidade Visual

**Arquivo:** `login_view.dart`

- AppBar removida.
- Título "Aqua Core" inserido no corpo da tela com `fontSize: 36`, negrito, cor `#4166A0`.
- Layout distribuído com `Spacer(flex: 2)` no topo e `Spacer(flex: 1)` no rodapé para centralização proporcional.
- `SafeArea` adicionado para respeitar as áreas seguras do dispositivo.

---

### 3.4 Identificador de Matrícula nas Listas de Alunos

**Arquivo:** `home_professor_view.dart`

- Nos dialogs "Lista de Alunos" e "Buscar Aluno", o `CircleAvatar` com o ID agora exibe o rótulo "Matr." acima do número.

---

## 4. Resumo de Rotas Flask

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/cadastrarProfessor` | Cadastra professor |
| `POST` | `/loginProfessor` | Login professor (retorna id, nome, email, telefone, cpf) |
| `PUT` | `/atualizarProfessor` | Atualiza nome, telefone, email (senha opcional) |
| `PUT` | `/alterarSenhaProfessor` | Altera senha com verificação da senha atual |
| `DELETE` | `/deletarProfessor` | Exclui professor (bloqueia se houver treinos) |
| `POST` | `/cadastrarAluno` | Cadastra aluno |
| `POST` | `/loginAluno` | Login aluno (retorna id, nome, email, telefone, cpf) |
| `PUT` | `/atualizarAluno` | Atualiza nome, telefone, email, plano (senha opcional) |
| `PUT` | `/alterarSenhaAluno` | Altera senha com verificação da senha atual |
| `DELETE` | `/deletarAluno` | Exclui aluno (bloqueia se houver treinos) |
| `GET` | `/lerAlunos` | Lista todos os alunos |
| `POST` | `/recuperaSenha` | Envia código de recuperação por e-mail |
| `PUT` | `/atualizaSenha` | Atualiza senha via código de recuperação |
| `GET` | `/lerTreinosProfessor/<id>` | Lista treinos do professor |
| `GET` | `/lerTreinosAluno/<id>` | Lista treinos do aluno (com nome do professor) |
| `POST` | `/cadastrarTreino` | Cadastra treino |
| `PUT` | `/atualizarTreino` | Atualiza treino |
| `DELETE` | `/deletarTreino` | Exclui treino |
