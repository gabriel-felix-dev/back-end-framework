# Relatório de Implementação — Sistema de Academia

**Projeto:** Projeto Final — Gerenciamento de Academia  
**Data:** 09/06/2026  
**Stack:** Flask (Python) + Flutter (Dart) + MySQL

---

## 1. Backend — Flask (`app.py`)

**Arquivo:** `d:\Dev - Falculdade\projeto-final-back-end\app.py`

### Configuração do banco de dados

| Parâmetro | Valor |
|-----------|-------|
| Host | `localhost` |
| Porta | `3307` |
| Usuário | `root` |
| Banco | `ProjetoJoseph` |

### Rotas implementadas (15 no total)

#### Professor

| Método | Rota | Body (JSON) | Descrição |
|--------|------|-------------|-----------|
| POST | `/cadastrarProfessor` | `nomeProfessor`, `cpfProfessor`, `emailProfessor`, `telefoneProfessor`, `senhaProfessor` | Cadastra professor |
| POST | `/loginProfessor` | `emailProfessor`, `senhaProfessor` | Login, retorna dados do usuário |
| PUT | `/atualizarProfessor` | `idProfessor`, `nomeProfessor`, `telefoneProfessor` | Atualiza nome e telefone |
| DELETE | `/deletarProfessor` | `idProfessor` | Remove professor |

#### Aluno

| Método | Rota | Body (JSON) | Descrição |
|--------|------|-------------|-----------|
| POST | `/cadastrarAluno` | `nomeAluno`, `cpfAluno`, `emailAluno`, `telefoneAluno`, `senhaAluno`, `idPlanoFK` | Cadastra aluno com plano |
| POST | `/loginAluno` | `emailAluno`, `senhaAluno` | Login, retorna dados do usuário |
| PUT | `/atualizarAluno` | `idAluno`, `nomeAluno`, `telefoneAluno` | Atualiza nome e telefone |
| DELETE | `/deletarAluno` | `idAluno` | Remove aluno |

#### Recuperação de Senha

| Método | Rota | Body (JSON) | Descrição |
|--------|------|-------------|-----------|
| POST | `/recuperaSenha` | `emailUsuario` | Gera código e envia por e-mail (busca em Professor e Aluno) |
| PUT | `/atualizaSenha` | `emailUsuario`, `novaSenha`, `codigoRecuperacao` | Valida código e atualiza senha |

#### Treino

| Método | Rota | Body / Param | Descrição |
|--------|------|-------------|-----------|
| GET | `/lerTreinosProfessor/<idProfessor>` | URL param | Lista treinos criados pelo professor |
| GET | `/lerTreinosAluno/<idAluno>` | URL param | Lista treinos do aluno |
| POST | `/cadastrarTreino` | `idAlunoFK`, `titulo`, `descricao`, `idProfessorFK` | Cria treino |
| PUT | `/atualizarTreino` | `idTreino`, `idAlunoFK`, `titulo`, `descricao`, `idProfessorFK` | Atualiza treino (só o professor dono) |
| DELETE | `/deletarTreino` | `idTreino`, `idProfessorFK` | Remove treino (só o professor dono) |

### Formato padrão de resposta

Todas as rotas retornam JSON no formato:

```json
{ "response": { "mensagem": "...", "codigo": 200 } }
```

As rotas de GET de lista retornam `[[{...}]]` (lista dentro de lista), pois o Flutter consome com `jsonDecode(body)[0]`.

### Ajustes feitos no `app.py`

- Nomes das colunas SQL corrigidos para **PascalCase** conforme o script do banco (`Nome`, `Id`, `Cpf`, `Email`, `Telefone`, `Senha`, `IdPlano`, `IdAluno`, `IdProfessor`, `Titulo`, `Descricao`)
- Nome do banco corrigido de `academia` para `ProjetoJoseph`
- Parâmetro de conexão corrigido de `passwd=''` para `password=''` (deprecação do pymysql)
- Toda resposta encapsulada em `{"response": {...}}` para compatibilidade com o Flutter
- Recuperação de senha busca em `Professor` e depois em `Aluno` com `cursor.rowcount == 0`

---

## 2. Frontend — Flutter

**Diretório:** `D:\Dev - Falculdade\projeto_final_mobile\lib\`

### Arquivos criados

```
lib/
├── main.dart
├── services/
│   └── utils.dart
└── views/
    ├── login/
    │   ├── login_view.dart
    │   ├── cadastra_professor_view.dart
    │   ├── cadastra_aluno_view.dart
    │   ├── recupera_senha_view.dart
    │   └── tela_nova_senha_view.dart
    ├── professor/
    │   └── home_professor_view.dart
    └── aluno/
        └── home_aluno_view.dart
```

### Descrição de cada arquivo

#### `main.dart`
Ponto de entrada do app. Inicializa `MaterialApp` com tema `ColorScheme.fromSeed(seedColor: Colors.blue)` e abre `LoginView` como tela inicial.

#### `services/utils.dart`
Centraliza o IP do servidor Flask:
```dart
static const String ipServidor = 'http://10.0.2.2:5000';
```
> `10.0.2.2` é o endereço do host no emulador Android. Para dispositivo físico, trocar pelo IP da máquina na rede local.

#### `views/login/login_view.dart`
Tela de login com:
- 2 botões de login (Professor / Aluno)
- 2 botões de cadastro (Professor / Aluno)
- Link "Esqueci minha senha"
- Navega para `HomeProfessorView` ou `HomeAlunoView` passando `Map<String, dynamic> usuario`

#### `views/login/cadastra_professor_view.dart`
Formulário com campos: Nome, CPF, E-mail, Telefone, Senha.  
POST `/cadastrarProfessor` → volta para login ao cadastrar com sucesso.

#### `views/login/cadastra_aluno_view.dart`
Formulário com campos: Nome, CPF, E-mail, Telefone, Senha + `DropdownButtonFormField` para selecionar o Plano (IDs 1–4).  
POST `/cadastrarAluno` → volta para login ao cadastrar com sucesso.

#### `views/login/recupera_senha_view.dart`
Campo de e-mail. POST `/recuperaSenha` → navega para `TelaNovaSenhaView` passando o e-mail.

#### `views/login/tela_nova_senha_view.dart`
Recebe o e-mail como parâmetro. Campos: código recebido, nova senha, confirmar senha.  
Valida que as senhas coincidem antes de chamar PUT `/atualizaSenha`.  
Sucesso → volta para `LoginView` limpando o histórico de navegação.

#### `views/professor/home_professor_view.dart`
Tela principal do professor. Recebe `Map<String, dynamic> usuario`.

| Funcionalidade | Trigger | Rota |
|----------------|---------|------|
| Listar treinos | `initState` | GET `/lerTreinosProfessor/{id}` |
| Criar treino | FAB (`+`) → `AlertDialog` | POST `/cadastrarTreino` |
| Editar treino | Ícone editar na `ListTile` → `AlertDialog` pré-preenchido | PUT `/atualizarTreino` |
| Excluir treino | Ícone lixeira → confirmação | DELETE `/deletarTreino` |
| Alterar dados | Ícone pessoa na `AppBar` → `AlertDialog` | PUT `/atualizarProfessor` |
| Excluir conta | Ícone delete na `AppBar` → confirmação | DELETE `/deletarProfessor` |
| Logoff | Ícone sair na `AppBar` | `Navigator.pushAndRemoveUntil` → `LoginView` |

#### `views/aluno/home_aluno_view.dart`
Tela principal do aluno. Recebe `Map<String, dynamic> usuario`.

| Funcionalidade | Trigger | Rota |
|----------------|---------|------|
| Listar treinos | `initState` | GET `/lerTreinosAluno/{id}` |
| Alterar dados | Ícone pessoa na `AppBar` → `AlertDialog` | PUT `/atualizarAluno` |
| Excluir conta | Ícone delete na `AppBar` → confirmação | DELETE `/deletarAluno` |
| Logoff | Ícone sair na `AppBar` | `Navigator.pushAndRemoveUntil` → `LoginView` |

> O aluno **não pode** criar, editar ou excluir treinos — apenas visualizar.

---

## 3. Android — `AndroidManifest.xml`

**Arquivo:** `android/app/src/main/AndroidManifest.xml`

Adicionados:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

```xml
android:usesCleartextTraffic="true"
```

> Necessário porque o Flask roda em HTTP (não HTTPS). O Android bloqueia tráfego não criptografado por padrão a partir do API 28.

---

## 4. Dependências (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1
```

---

## 5. Fluxo da aplicação

```
LoginView
├── [Professor] → HomeProfessorView (CRUD de Treinos)
├── [Aluno]     → HomeAlunoView     (somente leitura)
├── [Cadastro Professor] → CadastraProfessorView
├── [Cadastro Aluno]     → CadastrarAlunoView
└── [Esqueci senha] → RecuperaSenhaView → TelaNovaSenhaView → LoginView
```

---

## 6. Observações técnicas

- **Queries parametrizadas:** todas as queries usam `%s` com pymysql para evitar SQL Injection.
- **Erro de unicidade:** `pymysql.err.IntegrityError` capturado no cadastro para retornar mensagem amigável quando e-mail já existe.
- **Segurança do treino:** UPDATE e DELETE de treino incluem `AND IdProfessor = %s`, impedindo que um professor altere treinos de outro.
- **Senha:** armazenada em texto puro (conforme escopo mínimo da atividade).
- **Código de recuperação:** variável global `codigo_recuperacao_gerado` — funciona em instância única do servidor (desenvolvimento local).
