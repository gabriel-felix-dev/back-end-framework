# Prompt para implementação do Flask — Sistema de Academia

## Contexto

Você vai implementar o backend Flask de um Sistema de Academia.
O frontend já está pronto em Flutter. Seu trabalho é fazer o Flask
responder EXATAMENTE no formato que o Flutter espera — qualquer
divergência de chave JSON vai quebrar o app.

---

## Stack obrigatória

- Python + Flask
- pymysql (MySQL)
- Flask-Mail (recuperação de senha)
- import random (código de recuperação)

## Padrão de conexão

```python
import pymysql

def conectaDB():
    return pymysql.connect(
        host='localhost',
        user='root',
        passwd='',
        database='academia'
    )
```

## Padrão de rota

```python
from flask import Flask, request, jsonify
from flask_mail import Mail, Message
import random

app = Flask(__name__)

@app.route('/rota', methods=['POST'])
def minhaRota():
    dados = request.get_json()
    campo = dados["chave"]
    banco = conectaDB()
    cursor = banco.cursor()
    sql = f"INSERT INTO tabela ..."
    try:
        cursor.execute(sql)
        banco.commit()
        response = {"mensagem": "Sucesso", "codigo": 200}
        return jsonify({"response": response}), 200
    except Exception as e:
        response = {"mensagem": "Erro", "codigo": 400, "erro": str(e)}
        return jsonify({"response": response}), 400
    finally:
        banco.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

---

## Banco de dados — 4 tabelas obrigatórias

```sql
CREATE TABLE Plano (
    id   INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50)
);

-- Já pré-populada:
INSERT INTO Plano VALUES
  (1, 'Plano Mensal'),
  (2, 'Plano Trimestral'),
  (3, 'Plano Semestral'),
  (4, 'Plano Anual');

CREATE TABLE Aluno (
    id       INT PRIMARY KEY AUTO_INCREMENT,
    idPlano  INT,
    nome     VARCHAR(100),
    cpf      VARCHAR(14),
    email    VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    senha    VARCHAR(100),
    FOREIGN KEY (idPlano) REFERENCES Plano(id)
);

CREATE TABLE Professor (
    id       INT PRIMARY KEY AUTO_INCREMENT,
    nome     VARCHAR(100),
    cpf      VARCHAR(14),
    email    VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    senha    VARCHAR(100)
);

CREATE TABLE Treino (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    idAluno     INT,
    idProfessor INT,
    titulo      VARCHAR(100),
    descricao   TEXT,
    dataCriacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idAluno)     REFERENCES Aluno(id),
    FOREIGN KEY (idProfessor) REFERENCES Professor(id)
);
```

---

## REGRA CRÍTICA — Formato obrigatório de resposta

O Flutter faz `responseDados["response"]["mensagem"]` em **todas** as rotas.
Todo `return jsonify(...)` deve envolver o dict em `"response"`:

```python
# CORRETO
return jsonify({"response": {"mensagem": "...", "codigo": 200}}), 200

# ERRADO — vai quebrar o Flutter
return jsonify({"mensagem": "...", "codigo": 200}), 200
```

Para rotas GET de lista, o Flutter faz `jsonDecode(body)[0]`, então
a resposta deve ser uma lista com um elemento que é a lista de dicts:

```python
# CORRETO — Flutter faz body[0] para obter a lista
return jsonify([listaDeDicts]), 200

# ERRADO
return jsonify(listaDeDicts), 200
```

---

## 15 rotas a implementar

### 1. POST /cadastrarProfessor

**Body recebido:**
```json
{
  "nomeProfessor": "...",
  "cpfProfessor": "...",
  "emailProfessor": "...",
  "telefoneProfessor": "...",
  "senhaProfessor": "..."
}
```

**SQL:** `INSERT INTO Professor`  
**Sucesso 200:** `{"response": {"mensagem": "Cadastrado com sucesso", "codigo": 200}}`  
**Erro 400** se email já existe (IntegrityError): `{"response": {"mensagem": "Email já cadastrado", "codigo": 400}}`

---

### 2. POST /cadastrarAluno

**Body recebido:**
```json
{
  "nomeAluno": "...",
  "cpfAluno": "...",
  "emailAluno": "...",
  "telefoneAluno": "...",
  "senhaAluno": "...",
  "idPlanoFK": 1
}
```

**SQL:** `INSERT INTO Aluno`  
**Sucesso 200 / Erro 400** — mesmo padrão acima.

---

### 3. POST /loginProfessor

**Body recebido:**
```json
{"emailProfessor": "...", "senhaProfessor": "..."}
```

**SQL:** `SELECT id, nome, email, telefone FROM Professor WHERE email = '...' AND senha = '...'`

**Sucesso 200 — campos obrigatórios (Flutter os acessa por chave):**
```json
{
  "response": {
    "mensagem": "Login realizado com sucesso",
    "codigo": 200,
    "usuario": {
      "id": 1,
      "nome": "...",
      "email": "...",
      "telefone": "..."
    }
  }
}
```

**Erro 401:** `{"response": {"mensagem": "E-mail ou senha incorretos", "codigo": 401}}`

---

### 4. POST /loginAluno

**Body recebido:**
```json
{"emailAluno": "...", "senhaAluno": "..."}
```

**SQL:** `SELECT id, nome, email, telefone FROM Aluno WHERE email = '...' AND senha = '...'`  
**Sucesso 200** — mesma estrutura do loginProfessor (chave `"usuario"` com `id`, `nome`, `email`, `telefone`)  
**Erro 401** — mesmo padrão.

---

### 5. POST /recuperaSenha

**Body recebido:**
```json
{"emailUsuario": "..."}
```

**Lógica:**
1. Procura o email na tabela Professor. Se não achar, procura na tabela Aluno.
2. Se não achar em nenhuma: retorna 404.
3. Se achar: gera `codigo_recuperacao = random.randint(100000, 999999)`, salva em variável global e envia por e-mail via Flask-Mail.

**Sucesso 200:** `{"response": {"mensagem": "E-mail de recuperação enviado", "codigo": 200}}`  
**Erro 404:** `{"response": {"mensagem": "E-mail não encontrado", "codigo": 404}}`

**Config Flask-Mail (ajustar credenciais):**
```python
app.config['MAIL_SERVER']   = 'smtp.gmail.com'
app.config['MAIL_PORT']     = 587
app.config['MAIL_USE_TLS']  = True
app.config['MAIL_USERNAME'] = 'seu_email@gmail.com'
app.config['MAIL_PASSWORD'] = 'sua_senha_app'
mail = Mail(app)
```

---

### 6. PUT /atualizaSenha

**Body recebido:**
```json
{
  "emailUsuario": "...",
  "novaSenha": "...",
  "codigoRecuperacao": 123456
}
```

**Lógica:**
1. Verifica se `codigoRecuperacao == codigo_recuperacao_gerado` (variável global).
2. Se correto: procura o email na tabela Professor e atualiza a senha. Se não achar na tabela Professor, atualiza na tabela Aluno.
3. Se código errado: retorna 400.

**Sucesso 200:** `{"response": {"mensagem": "Senha atualizada com sucesso", "codigo": 200}}`  
**Erro 400 (código inválido):** `{"response": {"mensagem": "Código de recuperação inválido", "codigo": 400}}`

---

### 7. GET /lerTreinosProfessor/\<int:idProfessor\>

**Sem body.**  
**SQL:** `SELECT id, idAluno, idProfessor, titulo, descricao FROM Treino WHERE idProfessor = %s`

**Resposta obrigatória — Flutter faz `body[0]` para obter a lista:**
```json
[
  [
    {"id": 1, "idAluno": 2, "idProfessor": 1, "titulo": "...", "descricao": "..."},
    {"id": 2, "idAluno": 3, "idProfessor": 1, "titulo": "...", "descricao": "..."}
  ]
]
```

Monte a lista de dicts manualmente no loop — não use `cursor.fetchall()` direto no jsonify.

---

### 8. GET /lerTreinosAluno/\<int:idAluno\>

**Sem body.**  
**SQL:** `SELECT id, idAluno, idProfessor, titulo, descricao FROM Treino WHERE idAluno = %s`  
**Resposta:** mesmo formato da rota 7 — `[[{...}, {...}]]`

---

### 9. POST /cadastrarTreino

**Body recebido:**
```json
{
  "idAlunoFK": 2,
  "titulo": "...",
  "descricao": "...",
  "idProfessorFK": 1
}
```

**SQL:** `INSERT INTO Treino (idAluno, idProfessor, titulo, descricao) VALUES (%s, %s, %s, %s)`  
(`dataCriacao` é preenchida automaticamente pelo banco)  
**Sucesso 200 / Erro 400** — padrão padrão.

---

### 10. PUT /atualizarTreino

**Body recebido:**
```json
{
  "idTreino": 1,
  "idAlunoFK": 3,
  "titulo": "...",
  "descricao": "...",
  "idProfessorFK": 1
}
```

**SQL:** `UPDATE Treino SET idAluno = %s, titulo = %s, descricao = %s WHERE id = %s AND idProfessor = %s`  
**Sucesso 200 / Erro 400**

---

### 11. DELETE /deletarTreino

**Body recebido:**
```json
{"idTreino": 1, "idProfessorFK": 1}
```

**SQL:** `DELETE FROM Treino WHERE id = %s AND idProfessor = %s`  
**Sucesso 200 / Erro 400**

---

### 12. PUT /atualizarProfessor

**Body recebido:**
```json
{
  "idProfessor": 1,
  "nomeProfessor": "...",
  "telefoneProfessor": "..."
}
```

**SQL:** `UPDATE Professor SET nome = %s, telefone = %s WHERE id = %s`  
**Sucesso 200 / Erro 400**

---

### 13. PUT /atualizarAluno

**Body recebido:**
```json
{
  "idAluno": 1,
  "nomeAluno": "...",
  "telefoneAluno": "..."
}
```

**SQL:** `UPDATE Aluno SET nome = %s, telefone = %s WHERE id = %s`  
**Sucesso 200 / Erro 400**

---

### 14. DELETE /deletarProfessor

**Body recebido:**
```json
{"idProfessor": 1}
```

**SQL:** `DELETE FROM Professor WHERE id = %s`  
**Sucesso 200 / Erro 400**

---

### 15. DELETE /deletarAluno

**Body recebido:**
```json
{"idAluno": 1}
```

**SQL:** `DELETE FROM Aluno WHERE id = %s`  
**Sucesso 200 / Erro 400**

---

## Checklist final antes de testar

- [ ] Todas as respostas têm a chave `"response"` no nível raiz
- [ ] Rotas GET de lista retornam `[[{...}]]` (lista de lista de dicts)
- [ ] Login retorna `"usuario"` com `id`, `nome`, `email`, `telefone`
- [ ] `/recuperaSenha` e `/atualizaSenha` buscam em Professor **e** Aluno
- [ ] `dataCriacao` convertida com `str(r[x])` antes de jsonify (datetime não é serializável)
- [ ] Servidor rodando em `0.0.0.0` para ser acessível pelo dispositivo móvel
- [ ] IP da máquina Flask atualizado em `lib/services/utils.dart` no app Flutter
