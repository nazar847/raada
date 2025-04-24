from flask import Flask, request, jsonify
import sqlite3
import random
import string

app = Flask(__name__)

# Функция для генерации случайного почтового адреса
def generate_email():
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(10)) + "@temp-mail.com"

# Инициализация базы данных
def init_db():
    conn = sqlite3.connect('emails.db')
    c = conn.cursor()
    c.execute('CREATE TABLE IF NOT EXISTS emails (address TEXT, content TEXT)')
    conn.commit()
    conn.close()

# Добавление письма в базу данных
@app.route('/send', methods=['POST'])
def send_email():
    address = request.json['address']
    content = request.json['content']
    conn = sqlite3.connect('emails.db')
    c = conn.cursor()
    c.execute('INSERT INTO emails (address, content) VALUES (?, ?)', (address, content))
    conn.commit()
    conn.close()
    return jsonify({'status': 'success'}), 201

# Получение писем для указанного адреса
@app.route('/receive/<email>', methods=['GET'])
def receive_email(email):
    conn = sqlite3.connect('emails.db')
    c = conn.cursor()
    c.execute('SELECT content FROM emails WHERE address = ?', (email,))
    emails = c.fetchall()
    conn.close()
    return jsonify({'emails': [e[0] for e in emails]})

if __name__ == '__main__':
    init_db()
    app.run(port=5000)
