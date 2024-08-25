from flask import Flask

app = Flask(__name__)

@app.route('/hello', methods=['GET'])
def hello_world():
    return 'Hello, from all setup done!'

if __name__ == '__main__':
    app.run()