from flask import Flask, redirect, render_template, url_for, request

app = Flask(__name__)

listaUsuarios = []

@app.route('/')
def login():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def validarLogin():
    nome = request.form.get('nome')
    cargo = request.form.get('cargo')
    if nome in listaUsuarios:
        if cargo == "admin":
            return redirect(url_for("homeAdmin", nome=nome))
        else:
            return redirect(url_for("homeAuxiliar", nome=nome))
    else:
        return redirect(url_for("login"))

@app.route('/cadastro')
def cadastro():
    return render_template('cadastro.html')

@app.route('/homeAdmin/<nome>')
def homeAdmin(nome):
    return render_template('homeAdmin.html', nomeUsuario = nome)

@app.route('/homeComun/<nome>')
def homeAuxiliar(nome):
    return render_template('homeAuxiliar.html', nomeUsuario = nome)

@app.route('/cadastrousuario', methods=['POST'])
def cadastroUsuario():
    nome = request.form.get('nome')
    listaUsuarios.append(nome)
    return redirect(url_for("login"))

if __name__ == "__main__":
    app.run(debug= True)
