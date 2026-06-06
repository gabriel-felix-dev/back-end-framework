from flask import Flask, jsonify
from flask_cors import CORS
import pymysql 

app = Flask(__name__)
CORS(app)

# TODO - instlar o flask cors -> pip install flask-cors -> após a instalação, colocar CORS(app) para liberar a requisição de segurança externa
# TODO - criar rota de pesquisar nome
# TODO - criar rota de cadastro de funcionario
# TODO - criar rota de att func
# TODO - criar rota para remover func

def ConexaoBanco():
    conexaoMySQL = pymysql.connect(host='127.0.0.1', port=3307, user='root', password='', database='banco_funcionarios')
    return conexaoMySQL

@app.route('/')
def Home():
    conexaoMySql = ConexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = f"SELECT * FROM funcionario;"
    cursor.execute(sql)

    resultadoConsulta = cursor.fetchall()

    funcionarios = []

    for funcionario in resultadoConsulta:
        funcionarios.append({
            "idFuncionario": funcionario[0],
            "nomeFuncionario": funcionario[1]
        })

    return jsonify(funcionarios)

if __name__ == "__main__":
    app.run(debug= True, port=5000)
