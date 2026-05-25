from flask import Flask, jsonify, request
import pymysql 

app = Flask(__name__)

def ConexaoBanco():
    conexaoMySql = pymysql.connect(host='127.0.0.1', port=3307, user='root', password='', database='bancoexemplo')
    return conexaoMySql

@app.route('/')
def Index():
    conexaoMySql = ConexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = "SELECT * FROM funcionario"
    cursor.execute(sql)

    resultadoQuery = cursor.fetchall()
    conexaoMySql.close()

    listaFuncionariosJson = []

    for funcionario in resultadoQuery:
        listaFuncionariosJson.append({
            "nomaFuncionario":funcionario[1]
        })

    return jsonify(listaFuncionariosJson)

@app.route('/cadastrarfuncionario', methods=['POST'])
def CadastrarFuncionario():
    dadosRecebidos = request.get_json()

    nome = str(dadosRecebidos['nomeFuncionario'])

    conexaoMySql = ConexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = f"INSERT INTO funcionario (nome) VALUES ('{nome}');"

    cursor.execute(sql)

    conexaoMySql.commit()
    conexaoMySql.close()

    response = {'mensagem': 'Cadastro realizado', 'codigo':200}

    return jsonify(response)

@app.route('/atualizarfuncionario', methods=['PUT'])
def AtualizarFuncionario():
    dadosRecebidos = request.get_json()

    idRecebido = dadosRecebidos['id']
    nomeRecebido = dadosRecebidos['nomeFuncionario']

    conexaoMySql = ConexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = f"UPDATE funcionario SET nome = '{nomeRecebido}' WHERE id_func = {idRecebido};"

    cursor.execute(sql)

    conexaoMySql.commit()
    conexaoMySql.close()

    response = {'mensagem': 'Atualização realizada', 'codigo':200}

    return jsonify(response)

@app.route('/deletarfuncionario', methods=['DELETE'])
def DeletarFuncionario():
    dadosRecebidos = request.get_json()

    idRecebido = dadosRecebidos['id']

    conexaoMySql = ConexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = f"DELETE FROM funcionario WHERE id_func = {idRecebido}"

    cursor.execute(sql)

    conexaoMySql.commit()
    conexaoMySql.close()

    response = {'mensagem': 'Usuário deletado', 'codigo': 200}

    return jsonify(response)

if __name__ == "__main__":
    app.run(debug= True)
