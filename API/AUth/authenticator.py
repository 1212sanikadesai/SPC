from database.db_operations import DB
from config import DATABASE_CONFIG
from Auth.password_manager import PasswordManager
import psycopg2.extras

class AuthUser:
    def __init__(self):
        self.db = DB(DATABASE_CONFIG)
        self.password_manager = PasswordManager()

    def check_user_login(self, username, password):
        if not username or not password:
            return {"message": "Username or password missing", "error_code": 400}

        try:
            query = f"SELECT user_password, active FROM users WHERE username = '{username}';"
            result = self.db.execute_query(query)  # uses parameterized query

            if not result:
                return {"message": f"User {username} does not exist", "error_code": 404}

            hashed_password = result[0][0]
            is_active = result[0][1]

            if not self.password_manager.verify_password(password, hashed_password):
                return {"message": "Invalid password", "error_code": 401}

            if not is_active:
                return {"message": "User is not active", "error_code": 403}

            return {"message": "Login successful", "username": username}

        except Exception as e:
            return {"message": f"Internal server error: {str(e)}", "error_code": 500}
        

