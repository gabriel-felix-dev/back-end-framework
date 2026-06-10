from flask import Flask, request, jsonify
from flask_mail import Mail, Message
import pymysql
import random

app = Flask(__name__)

codigo_recuperacao_gerado = None

def conectaDB():
    return pymysql.connect(
        host='localhost',
        port=3307,
        user='root',
        password='',
        database='ProjetoJoseph'
    )

# ========================
# PROFESSOR
# ========================

@app.route('/cadastrarProfessor', methods=['POST'])
def cadastrarProfessor():
    dados    = request.get_json()
    nome     = dados["nomeProfessor"]
    cpf      = dados["cpfProfessor"]
    email    = dados["emailProfessor"]
    telefone = dados["telefoneProfessor"]
    senha    = dados["senhaProfessor"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "INSERT INTO Professor (Nome, Cpf, Email, Telefone, Senha) VALUES (%s, %s, %s, %s, %s)"
    try:
        cursor.execute(sql, (nome, cpf, email, telefone, senha))
        banco.commit()
        return jsonify({"response": {"mensagem": "Cadastrado com sucesso", "codigo": 200}}), 200
    except pymysql.err.IntegrityError:
        return jsonify({"response": {"mensagem": "Email já cadastrado", "codigo": 400}}), 400
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao cadastrar", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/loginProfessor', methods=['POST'])
def loginProfessor():
    dados = request.get_json()
    email = dados["emailProfessor"]
    senha = dados["senhaProfessor"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "SELECT Id, Nome, Email, Telefone FROM Professor WHERE Email = %s AND Senha = %s"
    try:
        cursor.execute(sql, (email, senha))
        resultado = cursor.fetchone()
        if resultado:
            return jsonify({"response": {
                "mensagem": "Login realizado com sucesso",
                "codigo": 200,
                "usuario": {
                    "id": resultado[0],
                    "nome": resultado[1],
                    "email": resultado[2],
                    "telefone": resultado[3]
                }
            }}), 200
        else:
            return jsonify({"response": {"mensagem": "E-mail ou senha incorretos", "codigo": 401}}), 401
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao realizar login", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/atualizarProfessor', methods=['PUT'])
def atualizarProfessor():
    dados       = request.get_json()
    idProfessor = dados["idProfessor"]
    nome        = dados["nomeProfessor"]
    telefone    = dados["telefoneProfessor"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "UPDATE Professor SET Nome = %s, Telefone = %s WHERE Id = %s"
    try:
        cursor.execute(sql, (nome, telefone, idProfessor))
        banco.commit()
        return jsonify({"response": {"mensagem": "Atualizado com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao atualizar", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/deletarProfessor', methods=['DELETE'])
def deletarProfessor():
    dados       = request.get_json()
    idProfessor = dados["idProfessor"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "DELETE FROM Professor WHERE Id = %s"
    try:
        cursor.execute(sql, (idProfessor,))
        banco.commit()
        return jsonify({"response": {"mensagem": "Deletado com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao deletar", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


# ========================
# ALUNO
# ========================

@app.route('/cadastrarAluno', methods=['POST'])
def cadastrarAluno():
    dados    = request.get_json()
    nome     = dados["nomeAluno"]
    cpf      = dados["cpfAluno"]
    email    = dados["emailAluno"]
    telefone = dados["telefoneAluno"]
    senha    = dados["senhaAluno"]
    idPlano  = dados["idPlanoFK"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "INSERT INTO Aluno (IdPlano, Nome, Cpf, Email, Telefone, Senha) VALUES (%s, %s, %s, %s, %s, %s)"
    try:
        cursor.execute(sql, (idPlano, nome, cpf, email, telefone, senha))
        banco.commit()
        return jsonify({"response": {"mensagem": "Cadastrado com sucesso", "codigo": 200}}), 200
    except pymysql.err.IntegrityError:
        return jsonify({"response": {"mensagem": "Email já cadastrado", "codigo": 400}}), 400
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao cadastrar", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/loginAluno', methods=['POST'])
def loginAluno():
    dados = request.get_json()
    email = dados["emailAluno"]
    senha = dados["senhaAluno"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "SELECT Id, Nome, Email, Telefone FROM Aluno WHERE Email = %s AND Senha = %s"
    try:
        cursor.execute(sql, (email, senha))
        resultado = cursor.fetchone()
        if resultado:
            return jsonify({"response": {
                "mensagem": "Login realizado com sucesso",
                "codigo": 200,
                "usuario": {
                    "id": resultado[0],
                    "nome": resultado[1],
                    "email": resultado[2],
                    "telefone": resultado[3]
                }
            }}), 200
        else:
            return jsonify({"response": {"mensagem": "E-mail ou senha incorretos", "codigo": 401}}), 401
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao realizar login", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/atualizarAluno', methods=['PUT'])
def atualizarAluno():
    dados    = request.get_json()
    idAluno  = dados["idAluno"]
    nome     = dados["nomeAluno"]
    telefone = dados["telefoneAluno"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "UPDATE Aluno SET Nome = %s, Telefone = %s WHERE Id = %s"
    try:
        cursor.execute(sql, (nome, telefone, idAluno))
        banco.commit()
        return jsonify({"response": {"mensagem": "Atualizado com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao atualizar", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/deletarAluno', methods=['DELETE'])
def deletarAluno():
    dados   = request.get_json()
    idAluno = dados["idAluno"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "DELETE FROM Aluno WHERE Id = %s"
    try:
        cursor.execute(sql, (idAluno,))
        banco.commit()
        return jsonify({"response": {"mensagem": "Deletado com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao deletar", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


# ========================
# RECUPERAÇÃO DE SENHA
# ========================

@app.route('/recuperaSenha', methods=['POST'])
def recuperaSenha():
    global codigo_recuperacao_gerado

    dados = request.get_json()
    email = dados["emailUsuario"]

    banco  = conectaDB()
    cursor = banco.cursor()

    cursor.execute("SELECT Email FROM Professor WHERE Email = %s", (email,))
    resultado = cursor.fetchone()
    if not resultado:
        cursor.execute("SELECT Email FROM Aluno WHERE Email = %s", (email,))
        resultado = cursor.fetchone()

    banco.close()

    if not resultado:
        return jsonify({"response": {"mensagem": "E-mail não encontrado", "codigo": 404}}), 404

    try:
        app.config['MAIL_SERVER']   = 'smtp.gmail.com'
        app.config['MAIL_PORT']     = 587
        app.config['MAIL_USE_TLS']  = True
        app.config['MAIL_USERNAME'] = 'seu_email@gmail.com'
        app.config['MAIL_PASSWORD'] = 'sua_senha_app'
        mail = Mail(app)

        codigo_recuperacao_gerado = random.randint(100000, 999999)
        msg      = Message("Recuperação de Senha", sender="seu_email@gmail.com", recipients=[email])
        msg.body = f"Seu código de recuperação é: {codigo_recuperacao_gerado}"
        mail.send(msg)

        return jsonify({"response": {"mensagem": "E-mail de recuperação enviado", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao enviar e-mail", "codigo": 400, "erro": str(e)}}), 400


@app.route('/atualizaSenha', methods=['PUT'])
def atualizaSenha():
    global codigo_recuperacao_gerado

    dados          = request.get_json()
    email          = dados["emailUsuario"]
    novaSenha      = dados["novaSenha"]
    codigoRecebido = dados["codigoRecuperacao"]

    if codigoRecebido != codigo_recuperacao_gerado:
        return jsonify({"response": {"mensagem": "Código de recuperação inválido", "codigo": 400}}), 400

    banco  = conectaDB()
    cursor = banco.cursor()
    try:
        cursor.execute("UPDATE Professor SET Senha = %s WHERE Email = %s", (novaSenha, email))
        if cursor.rowcount == 0:
            cursor.execute("UPDATE Aluno SET Senha = %s WHERE Email = %s", (novaSenha, email))
        banco.commit()
        return jsonify({"response": {"mensagem": "Senha atualizada com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao atualizar senha", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


# ========================
# TREINO
# ========================

@app.route('/lerTreinosProfessor/<int:idProfessor>', methods=['GET'])
def lerTreinosProfessor(idProfessor):
    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "SELECT Id, IdAluno, IdProfessor, Titulo, Descricao FROM Treino WHERE IdProfessor = %s"
    try:
        cursor.execute(sql, (idProfessor,))
        rows = cursor.fetchall()
        listaTreinos = []
        for r in rows:
            listaTreinos.append({
                "id": r[0],
                "idAluno": r[1],
                "idProfessor": r[2],
                "titulo": r[3],
                "descricao": r[4]
            })
        return jsonify([listaTreinos]), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao buscar treinos", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/lerTreinosAluno/<int:idAluno>', methods=['GET'])
def lerTreinosAluno(idAluno):
    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "SELECT Id, IdAluno, IdProfessor, Titulo, Descricao FROM Treino WHERE IdAluno = %s"
    try:
        cursor.execute(sql, (idAluno,))
        rows = cursor.fetchall()
        listaTreinos = []
        for r in rows:
            listaTreinos.append({
                "id": r[0],
                "idAluno": r[1],
                "idProfessor": r[2],
                "titulo": r[3],
                "descricao": r[4]
            })
        return jsonify([listaTreinos]), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao buscar treinos", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/cadastrarTreino', methods=['POST'])
def cadastrarTreino():
    dados       = request.get_json()
    idAluno     = dados["idAlunoFK"]
    titulo      = dados["titulo"]
    descricao   = dados["descricao"]
    idProfessor = dados["idProfessorFK"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "INSERT INTO Treino (IdAluno, IdProfessor, Titulo, Descricao) VALUES (%s, %s, %s, %s)"
    try:
        cursor.execute(sql, (idAluno, idProfessor, titulo, descricao))
        banco.commit()
        return jsonify({"response": {"mensagem": "Cadastrado com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao cadastrar treino", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/atualizarTreino', methods=['PUT'])
def atualizarTreino():
    dados       = request.get_json()
    idTreino    = dados["idTreino"]
    idAluno     = dados["idAlunoFK"]
    titulo      = dados["titulo"]
    descricao   = dados["descricao"]
    idProfessor = dados["idProfessorFK"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "UPDATE Treino SET IdAluno = %s, Titulo = %s, Descricao = %s WHERE Id = %s AND IdProfessor = %s"
    try:
        cursor.execute(sql, (idAluno, titulo, descricao, idTreino, idProfessor))
        banco.commit()
        return jsonify({"response": {"mensagem": "Atualizado com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao atualizar treino", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


@app.route('/deletarTreino', methods=['DELETE'])
def deletarTreino():
    dados       = request.get_json()
    idTreino    = dados["idTreino"]
    idProfessor = dados["idProfessorFK"]

    banco  = conectaDB()
    cursor = banco.cursor()
    sql    = "DELETE FROM Treino WHERE Id = %s AND IdProfessor = %s"
    try:
        cursor.execute(sql, (idTreino, idProfessor))
        banco.commit()
        return jsonify({"response": {"mensagem": "Deletado com sucesso", "codigo": 200}}), 200
    except Exception as e:
        return jsonify({"response": {"mensagem": "Erro ao deletar treino", "codigo": 400, "erro": str(e)}}), 400
    finally:
        banco.close()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
