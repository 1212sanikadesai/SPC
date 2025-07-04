# backend/database/db_operations.py
import psycopg2

class DB:
    def __init__(self, db_config: dict):
        self.connection = psycopg2.connect(
        user=db_config.get("user"),
        password=db_config.get("password"),
        dbname=db_config.get("dbname", "your_db"),
        host=db_config.get("host", "localhost"),
        port=db_config.get("port", "5432")
    )

    def get_connection(self):
        return self.connection

    def execute_query(self, query):
        cursor = self.connection.cursor()
        cursor.execute(query)
        data = cursor.fetchall()
        cursor.close()
        return data

    def close_connection(self):
        if self.connection:
            self.connection.close()
