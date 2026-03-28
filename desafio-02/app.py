from flask import Flask

app = Flask(__name__)

@app.route('/')
def inicio():
    return 'Bem vindo sistema de testes Flask'

@app.route('/usuario/<nome>')
def saudacao(nome):
    return f"Olá, {nome}! Bem vindo ao sistema de testes do flask!"

if (__name__) == "__main__":
    app.run(debug=True)
