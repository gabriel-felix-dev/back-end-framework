from flask import Flask, redirect, render_template, request, url_for
import pymysql 

app = Flask(__name__)

def conexaoBanco():
    conexaoMySql = pymysql.connect(host='127.0.0.1', port=3307, user='root', password='', database='lojainformatica')

    return conexaoMySql

@app.route('/')
def index():
    conexaoMySql = conexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = "SELECT * FROM produto;"
    cursor.execute(sql)
    resultadoQuery = cursor.fetchall()
    conexaoMySql.close()

    return render_template('index.html', resultadoConsulta = resultadoQuery)

@app.route('/telacadastrarproduto')
def telaCadastrarProduto():
    return render_template('cadastrarProduto.html')

@app.route('/cadastrarproduto', methods=['POST'])
def cadastrarProduto():
    nomeRecebido = request.form['nome']
    precoRecebido = request.form['preco']
    quantidadeRecebida = request.form['quantidade']
    descricaoRecebida = request.form['descricao']

    conexaoMySql = conexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = f"INSERT INTO produto (nome, preco, quantidade, descricao) VALUES ('{nomeRecebido}','{precoRecebido}','{quantidadeRecebida}','{descricaoRecebida}');"
    cursor.execute(sql)
    conexaoMySql.commit()
    conexaoMySql.close()

    return redirect(url_for('index'))

@app.route('/telaeditarproduto')
def telaEditarProduto():
    return render_template('editarProduto.html')

@app.route('/editarproduto', methods=['POST'])
def editarProduto():
    idRecebido = request.form['id']
    nomeRecebido = request.form['nome']
    precoRecebido = request.form['preco']
    quantidadeRecebido = request.form['quantidade']
    descricaoRecebido = request.form['descricao']

    conexaoMySql = conexaoBanco()
    cursor = conexaoMySql.cursor()
    sql = f"UPDATE produto SET nome ='{nomeRecebido}', preco='{precoRecebido}', quantidade='{quantidadeRecebido}', descricao='{descricaoRecebido}' WHERE id='{idRecebido}';"
    cursor.execute(sql)
    conexaoMySql.commit()
    conexaoMySql.close()

    return redirect(url_for('index'))

@app.route('/telaexcluirproduto')
def telaExcluirProduto():
    return render_template('excluirProduto.html')

@app.route('/excluirproduto', methods=['POST'])
def excluirProduto():
    idRecebido = request.form['id']

    conexaoMySql = conexaoBanco()
    cursor = conexaoMySql.cursor()

    sql =f"DELETE FROM produto WHERE Id='{idRecebido}';"

    cursor.execute(sql)
    conexaoMySql.commit()
    conexaoMySql.close()

    return redirect(url_for('index'))

@app.route('/telapesquisarproduto')
def telaPesquisarProduto():
    return render_template('pesquisarProduto.html')

@app.route('/pesquisarproduto', methods=['POST'])
def pesquisarProduto():
    dadoRecebido = request.form['pesquisa']
    
    conexaoMySql = conexaoBanco()
    cursor = conexaoMySql.cursor()

    sql =f"SELECT * FROM produto WHERE Id = '{dadoRecebido}' OR nome LIKE '%{dadoRecebido}%';"

    cursor.execute(sql)

    resultadoQuery = cursor.fetchall()

    return render_template('index.html', resultadoConsulta = resultadoQuery)

if __name__ == "__main__":
    app.run(debug=True)
