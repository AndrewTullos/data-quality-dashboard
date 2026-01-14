import psycopg2
from psycopg2 import Error

def get_connection():
   try:
      connection = psycopg2.connect(
            host="localhost",
            database="data_quality_project",
            user="drew",
            password="guitar"
      )
      return connection
   except Error as e:
      print(f"Error connecting to PostgreSQL: {e}")
      return None

def test_connection():
   conn = get_connection()
   if conn:
      print("Database connection successful!")
      conn.close()
      return True
   else:
      print("Database connection failed!")
      return False

# Test when running this file directly
if __name__ == "__main__":
   test_connection()