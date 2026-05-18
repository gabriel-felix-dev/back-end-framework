from flask import Flask, redirect, render_template, request, url_for 

app = Flask(__name__)

listaProdutos = []

@app.route('/')
def index():
    return render_template('index.html', produtos = listaProdutos)

@app.route('/addprodutos', methods = ['POST'])
def addProduto():
    nomeProduto = request.form['nomeproduto']
    listaProdutos.append(nomeProduto)

    return redirect(url_for('index'))

@app.route('/updateprodutos', methods = ['POST'])
def updateProduto():
    nomeNovo = request.form['nomenovo']
    nomeAnterior = request.form['nomeanterior']
    listaProdutos = [listaProdutos.index(nomeAnterior)] = nomeNovo

    return redirect(url_for('index'))

@app.route('/deletaprodutos', methods = ['POST'])
def deleteProduto():
    return

# TODO: Terminar a função deletar e finalizar a index

if __name__ == "__main__":
    app.run(debug= True)
