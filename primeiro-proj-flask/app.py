from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, world!'

@app.route('/sobre')
def sobre():
    return 'Informações institucionais'

@app.route('/contato')
def contato():
    return 'Contato institucionais'

@app.route('/paghtml')
def index():
    return render_template('index.html')

if __name__ == "__main__":
    app.run(debug=True)
