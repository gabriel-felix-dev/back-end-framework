from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/usuario/')
def Usuario():
    return render_template('Usuario.html')

@app.route('/usuario/<nome>')
def UsuarioNome(nome):
    return render_template('UsuarioNome.html', nomeUsuario=nome)

@app.route('/soma/<int:a>/<int:b>')
def Soma(a, b):
    resultado = int(a) + int(b);
    return render_template('Soma.html', valor1 = a, valor2 = b, resultadoSoma = resultado)

@app.route('/paridade/<int:a>')
def Paridade(a):
    if a % 2 == 0:
        return render_template('Paridade.html', valor1 = a, paridade = "PAR")
    
    if a % 2 != 0:
        return render_template('Paridade.html', valor1 = a, paridade = "IMPAR")

if __name__ == "__main__":
    app.run(debug= True)
