import json
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from pathlib import Path

# Define a Python function to load config and execute a task
def load_config_and_execute(**kwargs):
    # Load the configuration file
    config_path = Path(__file__).parent / "config.json"
    with open(config_path, "r") as f:
        config = json.load(f)

    # Use the config in your task
    print(f"Parameter 1: {config['param1']}")
    print(f"Parameter 2: {config['param2']}")

# Define the DAG
with DAG(
    dag_id="load_conf_dag",
    start_date=datetime(2023, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:

    # Define a PythonOperator task to load the config and print values
    load_config_task = PythonOperator(
        task_id="load_config_task",
        python_callable=load_config_and_execute
    )

# You can chain this task with others if needed