from flask import request, jsonify
import psycopg2
import os

def register_routes(app):
    @app.route('/', methods=['GET'])
    def root():
        return 'Hooray! The API works.', 200

    @app.route('/courses', methods=['GET'])
    def get_courses():
        conn = connect_db()
        cur = conn.cursor()
        cur.execute('SELECT id, name, credits FROM courses')
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify([{'id': r[0], 'name': r[1], 'credits': r[2]} for r in rows])

    @app.route('/register', methods=['POST'])
    def register_course():
        data = request.get_json()
        student = data.get('student')
        course_id = data.get('course_id')

        conn = connect_db()
        cur = conn.cursor()
        cur.execute('INSERT INTO registrations (student, course_id) VALUES (%s, %s)', (student, course_id))
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Registration successful'}), 201

def connect_db():
    return psycopg2.connect(
        dbname=os.getenv('POSTGRES_DB'),
        user=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD'),
        host='db'
    )

