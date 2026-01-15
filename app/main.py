import socket
from flask import Flask, request, jsonify


app = Flask(__name__)


@app.route('/', methods=['GET'])
def hello_devops():
    return "Hello, DevOps!"


@app.route('/echo', methods=['POST'])
def echo():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No JSON provided"}), 400
    return jsonify(data)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)