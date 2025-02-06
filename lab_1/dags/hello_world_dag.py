from airflow import DAG
from airflow.operators.python import PythonOperator
# from airflow.operators.email import PythonOperator
# from airflow.operators.email import SQLExecuteQueryOperator
from datetime import datetime


# Define a Python function for the task
def say_hello():
    print("Hello, Airflow!")

# Define the DAG
with DAG(
    dag_id="hello_world_dag-1",        # Unique ID for the DAG
    start_date=datetime(2021, 1, 1),  # Start date (cannot be in the future)
    schedule_interval="@hourly",    # Run schedule (daily in this case)
    catchup=False,                 # Disable backfilling
) as dag:

    # Define a task using PythonOperator
    hello_task = PythonOperator(
        task_id="say_hello",       # Unique task ID
        python_callable=say_hello # Function to call
    )

    # sql_task = mysql_task = SQLExecuteQueryOperator(
    #     task_id="drop_table_mysql_external_file",
    #     sql="/scripts/drop_table.sql",
    #     dag=dag,
    # )

    # Add more tasks and set dependencies if needed
    # hello_task >> another_task (example for chaining tasks)