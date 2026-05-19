from flask import Flask, redirect, render_template, request, url_for  

app = Flask(__name__)

@app.route('/<int:resultado>')
def index(resultado):
    return render_template('index.html', resultadoOperacoes = resultado)

@app.route('/calcular', methods = ['POST'])
def operacaoCalculadora():
    primeiroValor = request.form['primeironumero']
    segundoValor = request.form['segundonumero']

    operacao = request.form.get('operacao')

    if operacao == 'soma':
        resultado = int(primeiroValor) + int(segundoValor)

    if operacao == 'subtracao':
        resultado = int(primeiroValor) - int(segundoValor)
    
    if operacao == 'multiplicacao':
        resultado = int(primeiroValor) * int(segundoValor)
    
    if operacao == 'divicao':
        resultado = int(primeiroValor) / int(segundoValor)        
    
    return redirect(url_for("index", resultado = resultado)) 

if __name__ == "__main__":
    app.run(debug= True)
