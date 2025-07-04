from flask import Flask, request, jsonify
from database.config import DATABASE_CONFIG
from database.db_operations import DB
from Auth.password_manager import PasswordManager
import psycopg2
from Auth.authenticator import AuthUser

app = Flask(__name__)
db = DB(DATABASE_CONFIG)
pm = PasswordManager()

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    
    if not data or 'password' not in data:
        return jsonify({"error": "Password is required"}), 400

    password = data['password']
    pm = PasswordManager()
    stored_hashed_password = pm.hash_password("MyS3cureP@ssword!")

    if pm.verify_password(password, stored_hashed_password):
        return jsonify({"authenticated": True}), 200
    else:
        return jsonify({"authenticated": False, "error": "Invalid credentials"}), 401
    


@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    required_fields = ['username', 'user_password', 'first_name', 'last_name', 'email']

    # Validate request
    if not all(data.get(field) for field in required_fields):
        return jsonify({"error": "All fields are required"}), 400

    username = data['username'].lower()
    email = data['email']
    hashed_pw = pm.hash_password(data['user_password'])

    conn = db.get_connection()
    cursor = conn.cursor()

    try:
        # Check if user exists
        cursor.execute(
            "SELECT 1 FROM public.users WHERE username = %s OR user_password = %s OR email= %s",
            (username, hashed_pw , email)
        )
        if cursor.fetchone():
            return jsonify({"error": "User already exists"}), 500

        # Create temp table + insert into it
        cursor.execute("CREATE TEMP TABLE usertemp AS SELECT * FROM public.users WHERE 1=0;")
        cursor.execute("""
            INSERT INTO usertemp (
                user_id, username, user_password, first_name, last_name, email, created_at, updated_at, active
            ) VALUES (0, %s, %s, %s, %s, %s, NOW(), NOW(), TRUE)
        """, (username, hashed_pw, data['first_name'], data['last_name'], email))

        # Call the upsert function
        cursor.execute("SELECT crud_upsert_users(%s, %s);", (1, 'usertemp'))
        conn.commit()

        return jsonify({"message": f"Signup successful for {username}"}), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()


@app.route('/signin', methods=['POST'])
def signin():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    


    auth_user = AuthUser()
    response = auth_user.check_user_login(username, password)

    status_code = response.get("error_code", 200)
    return jsonify(response), status_code



if __name__ == '__main__':
    app.run(debug=True)
