# Relatório de Alterações — Projeto Final Back-End

**Data:** 10/06/2026  
**Arquivo principal:** `app.py`  
**Branch:** `feat/projeto-final`

---

## 1. Dependências

### 1.1 Bibliotecas instaladas

| Biblioteca | Versão | Motivo |
|---|---|---|
| `Flask-Mail` | 0.10.0 | Ausente no ambiente; necessária para envio de e-mail |
| `Flask-Cors` | 6.0.5 | Adicionada para permitir requisições do app mobile |

### 1.2 Arquivo `requirements.txt` (criado)

```
Flask==3.1.3
PyMySQL==1.2.0
Flask-Mail==0.10.0
Flask-Cors==6.0.5
```

---

## 2. Configuração Geral (`app.py`)

### 2.1 Imports adicionados

```python
# ANTES
from flask import Flask, request, jsonify
from flask_mail import Mail, Message

# DEPOIS
from flask import Flask, request, jsonify
from flask_cors import CORS          # adicionado
from flask_mail import Mail, Message
```

### 2.2 CORS habilitado

```python
# ADICIONADO
CORS(app)
```

Necessário para que o app Flutter consiga fazer requisições ao servidor local.

### 2.3 Configuração do Flask-Mail movida para o topo

```python
# ANTES — configurado dentro da rota /recuperaSenha a cada requisição
def recuperaSenha():
    ...
    app.config['MAIL_SERVER']   = 'smtp.gmail.com'
    app.config['MAIL_PORT']     = 587
    app.config['MAIL_USE_TLS']  = True
    app.config['MAIL_USERNAME'] = 'seu_email@gmail.com'
    app.config['MAIL_PASSWORD'] = 'sua_senha_app'
    mail = Mail(app)

# DEPOIS — configurado uma única vez na inicialização da aplicação
app.config['MAIL_SERVER']   = 'smtp.gmail.com'
app.config['MAIL_PORT']     = 587
app.config['MAIL_USE_TLS']  = True
app.config['MAIL_USERNAME'] = 'felixg758@gmail.com'
app.config['MAIL_PASSWORD'] = 'wuvk rqqj gatv pugg'   # Senha de App do Gmail
mail = Mail(app)
```

### 2.4 Host do banco de dados

```python
# ANTES
host='localhost'

# DEPOIS
host='127.0.0.1'
```

### 2.5 Nome do banco de dados

```python
# ANTES
database='ProjetoJoseph'

# DEPOIS
database='projetojoseph'   # corrigido para minúsculas (case-sensitive no MySQL)
```

---

## 3. Módulo Professor

### 3.1 `/loginProfessor` — campo `cpf` adicionado ao retorno

```python
# ANTES
sql = "SELECT Id, Nome, Email, Telefone FROM Professor WHERE ..."
"usuario": { "id": ..., "nome": ..., "email": ..., "telefone": ... }

# DEPOIS
sql = "SELECT Id, Nome, Email, Telefone, Cpf FROM Professor WHERE ..."
"usuario": { "id": ..., "nome": ..., "email": ..., "telefone": ..., "cpf": ... }
```

### 3.2 `/atualizarProfessor` — campos `email` e `senha` incluídos na atualização

```python
# ANTES — atualizava somente Nome e Telefone
sql = "UPDATE Professor SET Nome = %s, Telefone = %s WHERE Id = %s"

# DEPOIS — atualiza Nome, Telefone e Email; Senha é opcional
if nova_senha:
    sql = "UPDATE Professor SET Nome = %s, Telefone = %s, Email = %s, Senha = %s WHERE Id = %s"
else:
    sql = "UPDATE Professor SET Nome = %s, Telefone = %s, Email = %s WHERE Id = %s"
```

### 3.3 `/alterarSenhaProfessor` — rota nova (`PUT`)

Rota adicionada para alterar a senha confirmando a senha atual antes:

```
PUT /alterarSenhaProfessor
Body: { "idProfessor", "senhaAtual", "novaSenha" }
```

### 3.4 `/deletarProfessor` — proteção contra exclusão com treinos vinculados

```python
# ANTES — deletava diretamente
cursor.execute("DELETE FROM Professor WHERE Id = %s", (idProfessor,))

# DEPOIS — verifica treinos vinculados antes de deletar
cursor.execute("SELECT COUNT(*) FROM Treino WHERE IdProfessor = %s", (idProfessor,))
if cursor.fetchone()[0] > 0:
    return jsonify({"response": {"mensagem": "Você é responsável por treinos cadastrados e não pode ser excluído.", ...}}), 400
cursor.execute("DELETE FROM Professor WHERE Id = %s", (idProfessor,))
```

---

## 4. Módulo Aluno

### 4.1 `/loginAluno` — campo `cpf` adicionado ao retorno

Mesma correção aplicada ao Professor (item 3.1).

### 4.2 `/atualizarAluno` — campos `email`, `idPlano` e `senha` incluídos na atualização

```python
# ANTES — atualizava somente Nome e Telefone
sql = "UPDATE Aluno SET Nome = %s, Telefone = %s WHERE Id = %s"

# DEPOIS — atualiza Nome, Telefone, Email e IdPlano; Senha é opcional
if nova_senha:
    sql = "UPDATE Aluno SET Nome = %s, Telefone = %s, Email = %s, Senha = %s, IdPlano = %s WHERE Id = %s"
else:
    sql = "UPDATE Aluno SET Nome = %s, Telefone = %s, Email = %s, IdPlano = %s WHERE Id = %s"
```

### 4.3 `/alterarSenhaAluno` — rota nova (`PUT`)

```
PUT /alterarSenhaAluno
Body: { "idAluno", "senhaAtual", "novaSenha" }
```

### 4.4 `/deletarAluno` — proteção contra exclusão com treinos vinculados

```python
# ANTES — deletava diretamente
cursor.execute("DELETE FROM Aluno WHERE Id = %s", (idAluno,))

# DEPOIS — verifica treinos vinculados antes de deletar
cursor.execute("SELECT COUNT(*) FROM Treino WHERE IdAluno = %s", (idAluno,))
if cursor.fetchone()[0] > 0:
    return jsonify({"response": {"mensagem": "Você possui treinos vinculados à sua conta e não pode ser excluído.", ...}}), 400
cursor.execute("DELETE FROM Aluno WHERE Id = %s", (idAluno,))
```

---

## 5. Módulo Recuperação de Senha

### 5.1 `/recuperaSenha` — `sender` corrigido

```python
# ANTES — e-mail remetente hardcoded
msg = Message("Recuperação de Senha", sender="seu_email@gmail.com", recipients=[email])

# DEPOIS — usa a configuração centralizada
msg = Message("Recuperação de Senha", sender=app.config['MAIL_USERNAME'], recipients=[email])
```

### 5.2 `/atualizaSenha` — comparação de tipo corrigida

```python
# ANTES — comparação falhava quando o app enviava o código como string
if codigoRecebido != codigo_recuperacao_gerado:

# DEPOIS — conversão explícita para int garante a comparação correta
if int(codigoRecebido) != codigo_recuperacao_gerado:
```

### 5.3 `/atualizaSenha` — código zerado após uso

```python
# ADICIONADO após atualizar a senha com sucesso
codigo_recuperacao_gerado = None
```

Evita que o mesmo código seja reutilizado para múltiplas trocas de senha.

---

## 6. Módulo Treino

### 6.1 `/lerAlunos` — rota nova (`GET`)

```
GET /lerAlunos
Retorno: lista com id, nome, email e telefone de todos os alunos
```

Necessária para o professor selecionar um aluno ao cadastrar um treino.

### 6.2 `/lerTreinosAluno` — JOIN com tabela Professor adicionado

```python
# ANTES — retornava apenas dados do Treino
sql = "SELECT Id, IdAluno, IdProfessor, Titulo, Descricao FROM Treino WHERE IdAluno = %s"

# DEPOIS — inclui o nome do professor responsável pelo treino
sql = """
    SELECT t.Id, t.IdAluno, t.IdProfessor, t.Titulo, t.Descricao, p.Nome
    FROM Treino t
    JOIN Professor p ON t.IdProfessor = p.Id
    WHERE t.IdAluno = %s
"""
# campo "nomeProfessor" adicionado ao objeto de retorno
```

---

## 7. Rotas — Resumo Final

| Rota | Método | Módulo | Status |
|---|---|---|---|
| `/cadastrarProfessor` | POST | Professor | Existia |
| `/loginProfessor` | POST | Professor | Atualizado |
| `/atualizarProfessor` | PUT | Professor | Atualizado |
| `/alterarSenhaProfessor` | PUT | Professor | **Novo** |
| `/deletarProfessor` | DELETE | Professor | Atualizado |
| `/cadastrarAluno` | POST | Aluno | Existia |
| `/loginAluno` | POST | Aluno | Atualizado |
| `/atualizarAluno` | PUT | Aluno | Atualizado |
| `/alterarSenhaAluno` | PUT | Aluno | **Novo** |
| `/deletarAluno` | DELETE | Aluno | Atualizado |
| `/lerAlunos` | GET | Aluno | **Novo** |
| `/recuperaSenha` | POST | Recuperação | Atualizado |
| `/atualizaSenha` | PUT | Recuperação | Atualizado |
| `/lerTreinosProfessor/<id>` | GET | Treino | Existia |
| `/lerTreinosAluno/<id>` | GET | Treino | Atualizado |
| `/cadastrarTreino` | POST | Treino | Existia |
| `/atualizarTreino` | PUT | Treino | Existia |
| `/deletarTreino` | DELETE | Treino | Existia |

---

## 8. Pendência identificada

As rotas `/lerTreinosProfessor`, `/lerTreinosAluno` e `/lerAlunos` ainda retornam **lista aninhada** (`[[...]]`) em vez de lista simples (`[...]`):

```python
# INCORRETO (linhas 374, 404, 427)
return jsonify([listaTreinos]), 200

# CORRETO
return jsonify(listaTreinos), 200
```

Isso pode causar falha ao desserializar a resposta no app Flutter. Verifique se o front-end já trata esse formato antes de corrigir.
