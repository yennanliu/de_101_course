from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import sqlalchemy

# Define a function to read data from the Airflow metadata database
def read_airflow_db():
    # Database connection string
    # username: username, password: password
    db_url = "postgresql+psycopg2://username:password@localhost:5432/airflow"
    
    # Create a connection to the database
    engine = sqlalchemy.create_engine(db_url)
    connection = engine.connect()

    query_1 = "SELECT 1;"
    result_1 = connection.execute(query_1)
    rows_1 = result_1.fetchall()
    for x in rows_1:
        print(f"res = {x}")

    # Example query: Read the first 10 rows from the dag table
    query = "SELECT dag_id, is_active, is_paused FROM dag LIMIT 10;"
    result = connection.execute(query)
    
    # Process and print the results
    rows = result.fetchall()
    for row in rows:
        print(f"DAG ID: {row['dag_id']}, Active: {row['is_active']}, Paused: {row['is_paused']}")
    
    # Close the connection
    connection.close()

# Define the DAG
with DAG(
    dag_id="query_db_dag",
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,  # Trigger manually
    catchup=False,
) as dag:
    
    # Define the task to read from the database
    read_db_task = PythonOperator(
        task_id="read_airflow_backend",
        python_callable=read_airflow_db,
    )
    
    read_db_task