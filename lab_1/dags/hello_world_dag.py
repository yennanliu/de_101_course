from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

# Define a Python function for the task
def say_hello():
    print("Hello, Airflow!")

# Define the DAG
with DAG(
    dag_id="hello_world_dag",        # Unique ID for the DAG
    start_date=datetime(2023, 1, 1),  # Start date (cannot be in the future)
    schedule_interval="@daily",    # Run schedule (daily in this case)
    catchup=False,                 # Disable backfilling
) as dag:

    # Define a task using PythonOperator
    hello_task = PythonOperator(
        task_id="say_hello",       # Unique task ID
        python_callable=say_hello # Function to call
    )

    # Add more tasks and set dependencies if needed
    # hello_task >> another_task (example for chaining tasks)