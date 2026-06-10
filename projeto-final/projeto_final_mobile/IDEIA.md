# IDEIA.md — Sistema de Academia (Mobile)

## Ideia atual
App Flutter para gestão de academia com dois tipos de usuário: **Professor** e **Aluno**.
Os cadastros são feitos pelos próprios usuários na tela inicial do app.
O Professor gerencia Treinos. O Aluno visualiza os Treinos cadastrados para ele.

---

## Entidades do banco (4 tabelas, já definidas no README do projeto)

| Entidade  | Campos principais                                              | Relações         |
|-----------|----------------------------------------------------------------|------------------|
| Plano     | id, nome (fixo: Mensal/Trimestral/Semestral/Anual)            | —                |
| Aluno     | id, idPlano (FK), nome, cpf, email, telefone, senha           | FK → Plano       |
| Professor | id, nome, cpf, email, telefone, senha                         | —                |
| Treino    | id, idAluno (FK), idProfessor (FK), titulo, descricao, dataCriacao | FK → Aluno, Professor |

---

## Escopo fechado — Telas e funcionalidades

### Tela Inicial / Login
- Campos: Email + Senha
- Botão **Entrar como Professor** → POST `/loginProfessor` → Home Professor
- Botão **Entrar como Aluno** → POST `/loginAluno` → Home Aluno
- Botão **Cadastrar como Aluno** → tela de cadastro do Aluno
- Botão **Cadastrar como Professor** → tela de cadastro do Professor
- Link **Esqueci minha senha** → fluxo de recuperação
- Técnica dos slides: `login_view.dart`, `Navigator.push`, `MaterialPageRoute`

### Cadastro do Aluno
- Campos: Nome, CPF, Email, Telefone, Senha + **DropdownButton** de Plano (4 opções)
- POST `/cadastrarAluno`
- Técnica dos slides: `cadastra_usuario_view.dart` + `DropdownButton` (material.dart)

### Cadastro do Professor
- Campos: Nome, CPF, Email, Telefone, Senha (sem Plano)
- POST `/cadastrarProfessor`
- Técnica dos slides: mesmo padrão de `cadastra_usuario_view.dart`

### Recuperação de Senha (compartilhada entre os dois tipos)
- Tela 1: campo Email → POST `/recuperaSenha`
- Tela 2: campo Código (6 dígitos) + Nova Senha + Confirmar Senha → PUT `/atualizaSenha`
- Técnica dos slides: `recupera_senha_view.dart` + `tela_nova_senha_view.dart`

---

### Home do Professor
Arquivo: `home_professor_view.dart`

| Funcionalidade | Interação | Endpoint | Técnica dos slides |
|---|---|---|---|
| Ver lista de Treinos criados por ele | `ListView.builder` | GET `/lerTreinosProfessor/{idProfessor}` | `home_view.dart` |
| Criar Treino | FAB → `AlertDialog` com campo Matrícula do Aluno (ID), Título, Descrição | POST `/cadastrarTreino` | `FloatingActionButton` + `showDialog` |
| Editar Treino (título, descrição, trocar aluno) | Ícone editar → `AlertDialog` | PUT `/atualizarTreino` | `AlertDialog` com `TextEditingController` |
| Excluir Treino | Ícone excluir → `AlertDialog` confirmação | DELETE `/deletarTreino` | `AlertDialog` com confirmação |
| Alterar próprios dados | Botão na AppBar → `AlertDialog` | PUT `/atualizarProfessor` | `showDialog` + `AlertDialog` |
| Excluir própria conta | Botão na AppBar → `AlertDialog` confirmação → volta ao Login | DELETE `/deletarProfessor` | `AlertDialog` + `Navigator.pushReplacement` |
| Logoff | Ícone na AppBar → volta ao Login | — | `Navigator.pushReplacement` |

---

### Home do Aluno
Arquivo: `home_aluno_view.dart`

| Funcionalidade | Interação | Endpoint | Técnica dos slides |
|---|---|---|---|
| Ver lista de Treinos cadastrados para ele | `ListView.builder` (somente leitura) | GET `/lerTreinosAluno/{idAluno}` | `home_view.dart` |
| Alterar próprios dados | Botão na AppBar → `AlertDialog` | PUT `/atualizarAluno` | `showDialog` + `AlertDialog` |
| Excluir própria conta | Botão na AppBar → `AlertDialog` confirmação → volta ao Login | DELETE `/deletarAluno` | `AlertDialog` + `Navigator.pushReplacement` |
| Logoff | Ícone na AppBar → volta ao Login | — | `Navigator.pushReplacement` |

---

## Estrutura de arquivos planejada

```
lib/
  main.dart
  services/
    utils.dart                        # classe Utils com ip_servidor
  views/
    login/
      login_view.dart                 # tela inicial
      cadastra_aluno_view.dart        # cadastro aluno + dropdown plano
      cadastra_professor_view.dart    # cadastro professor
      recupera_senha_view.dart        # envia código por e-mail
      tela_nova_senha_view.dart       # digita código + nova senha
    professor/
      home_professor_view.dart        # home do professor (treinos + CRUD)
    aluno/
      home_aluno_view.dart            # home do aluno (treinos read-only)
```

---

## Decisões fechadas

| # | Decisão |
|---|---------|
| 1 | `DropdownButton` para seleção de Plano no cadastro do Aluno — permitido |
| 2 | Login separado: dois botões ("Entrar como Professor" / "Entrar como Aluno") |
| 3 | Seleção de Aluno no Treino via campo de Matrícula (ID numérico digitado manualmente) |

## O que ainda falta definir

Nada em aberto — escopo fechado. Próximo passo: início da implementação.
