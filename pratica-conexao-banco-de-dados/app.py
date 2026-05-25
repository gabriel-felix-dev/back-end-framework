from flask import Flask, redirect, render_template, request
import pymysql 

app = Flask(__name__)

def conectDB():
    db = pymysql.connect(host='localhost', port=3307, user='root', password='', database='banco_funcionarios')
    return db

@app.route('/') # -> Página inicial
def index():
    bdConectado = conectDB()
    cursor = bdConectado.cursor()
    sql = "SELECT * FROM funcionario;"
    cursor.execute(sql)
    resultado = cursor.fetchall()
    print(resultado)

    bdConectado.close()

    return render_template('index.html', resultDB = resultado)

@app.route('/cadastrarFuncionario', methods=['POST'])
def cadFunc():
    nomeRecebido = request.form['nome']
    telefoneRecebido = request.form['telefone']
    bdConectado = conectDB()
    cursor = bdConectado.cursor()
    sql = f"INSERT INTO funcionario(nome, telefone) VALUES ('{nomeRecebido}','{telefoneRecebido}');"
    cursor.execute(sql)
    bdConectado.commit()
    bdConectado.close()

    return redirect('/')

@app.route('/atualizarfuncionario', methods=['POST'])
def atualizaFunc():
    idRecebido = request.form['id']
    nomeRecebido = request.form['nome']
    telefoneRecebido = request.form['telefone']

    print('#'*10)
    print(idRecebido)
    print(nomeRecebido)
    print(telefoneRecebido)
    print('#'*10)

    bdConectado = conectDB()
    cursor = bdConectado.cursor()
    sql = f"UPDATE funcionario SET nome = '{nomeRecebido}', telefone = '{telefoneRecebido}' WHERE id_func = {idRecebido};"
    cursor.execute(sql)
    bdConectado.commit()
    bdConectado.close()
    
    return redirect('/')

@app.route('/removerFuncionario', methods=['POST'])
def deletarFunc():
    idFunc = request.form['id']
    bdConectado = conectDB()
    cursor = bdConectado.cursor()
    sql = f"DELETE FROM funcionario WHERE id_func = {idFunc};"
    cursor.execute(sql)
    bdConectado.commit()
    bdConectado.close()

    return redirect('/')

@app.route('/pesquisarFuncionario', methods=['POST'])
def pesquisarFunc():
    pesquisa = request.form['pesquisa']
    bdConectado = conectDB()
    cursor = bdConectado.cursor()
    sql = f"SELECT * FROM funcionario WHERE id_func = '{pesquisa}' OR nome LIKE '%{pesquisa}%';"
    cursor.execute(sql)
    resultado = cursor.fetchall()
    print(resultado)
    return render_template('index.html', resultDB = resultado)

if __name__ == '__main__':
    app.run(debug= True, port= 8000)
