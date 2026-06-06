from flask import Flask, jsonify, request
import pymysql 

app = Flask(__name__)

def ConexaoBanco():
    conexaoMySql = pymysql.connect(host='127.0.0.1', port=3307, user='root', password='', database='lanchonetepateta')
    
    return conexaoMySql

@app.route('/cadastrarProduto', methods=['POST'])
def CadastrarProduto():
    dadosRecebidos = request.get_json()

    nomeRecebido = dadosRecebidos['nome']
    precoRecebido = dadosRecebidos['preco']
    quantidadeRecebido = dadosRecebidos['quantidade']
    datahoraRecebido = dadosRecebidos['datahora']

    conexaoMySql = ConexaoBanco()
    cursor = conexaoMySql.cursor()

    sql = f"INSERT INTO produto (nome, preco, quantidade, datahora) VALUES ('{nomeRecebido}', {precoRecebido}, {quantidadeRecebido}, '{datahoraRecebido}');"

    cursor.execute(sql)

    conexaoMySql.commit()
    conexaoMySql.close()

    response = {"mensagem": "Produto cadastado com sucesso", "codigo": 200}

    return jsonify(response)


@app.route('/listarProdutos')
def ListarProdutos():
    conexaoMySql = ConexaoBanco()
    cursor = conexaoMySql.cursor()

    sql = f"SELECT * FROM produto;"

    cursor.execute(sql)
    resultadoQuery = cursor.fetchall()

    conexaoMySql.close()

    listaProdutosJson = []

    for produto in resultadoQuery:
        listaProdutosJson.append({
            "id": produto[0],
            "nome": produto[1],
            "preco": produto[2],
            "quantidade": produto[3],
            "datahora": produto[4]
        })

    return jsonify(listaProdutosJson)

if __name__ == "__main__":
    app.run(debug= True, port=666)
