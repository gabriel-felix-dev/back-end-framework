from flask import Flask, render_template, request  

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/metodoGET', methods = ['GET'])
def get_resource():
    metodo = request.method
    return f"O método escolhido foi: {metodo}"

@app.route('/metodoPOST', methods= ['POST'])
def post_resource():
    metodo = request.method
    return f"O método escolhido foi: {metodo}"

@app.route('/metodoPUT', methods = ['POST', 'PUT'])
def put_resource():
    metodo = request.form.get('_method')
    return f"O método escolhido foi: {metodo}"

@app.route('/metodoDELETE', methods = ['POST', 'DELETE'])
def delete_resource():
    metodo = request.form.get('_method')
    return f"O método escolhido foi: {metodo}"

if __name__ == "__main__":
    app.run(debug= True)
