from flask import Flask, render_template

app = Flask(__name__)

@app.route('/usuario/<nome>/<int:idade>')
def index(nome, idade):
    return render_template('index.html', nomeUsuario = nome, idadeUsuario = idade)

@app.route('/usuario/<nome>')
def perfil(nome):
    return render_template('perfil.html', nomeUsuario = nome)

@app.route('/listausuarios')
def usuarios():
    lista = ['Arnaldo', 'Vera', 'Reinaldo', 'Igor', 'Tenório']
    return render_template('usuarios.html', listaUsuarios = lista)

if __name__ == "__main__":
    app.run(debug= True)
