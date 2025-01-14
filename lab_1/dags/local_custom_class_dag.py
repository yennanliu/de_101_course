from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from my_custom_class import MyCustomClass  # Import the custom class

# Define a function to instantiate the custom class and run its method
def run_custom_class_method():
    # Instantiate the custom class
    custom_instance = MyCustomClass(name="Airflow User")
    
    # Run the method from the custom class
    custom_instance.greet()

# Define the DAG
with DAG(
    dag_id="local_custom_class_dag",
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,  # Trigger manually
    catchup=False,
) as dag:
    
    # Define the task to run the method
    run_custom_method_task = PythonOperator(
        task_id="run_custom_method_task",
        python_callable=run_custom_class_method,  # Call the function that runs the class method
    )
    
    run_custom_method_task