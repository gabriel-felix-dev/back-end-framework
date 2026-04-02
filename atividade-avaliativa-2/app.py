from flask import Flask

app = Flask(__name__)

teste = input('Digite algo: ')

@app.route('/')
def inicio():
    return 'Miau'

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')
