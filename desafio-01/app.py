from flask import Flask

app = Flask(__name__)

@app.route('/')
def inicio():
    return 'Sistema flask funcionando nessa porra!'