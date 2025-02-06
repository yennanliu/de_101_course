from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from datetime import datetime

# https://airflow.apache.org/docs/apache-airflow/stable/tutorial/fundamentals.html#tasks

def say_hello():
    return 'say_hello'

# Define the DAG
with DAG(
    dag_id="task_dep_dag_2",
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,  # Trigger manually
    catchup=False,
) as dag:
    
    # Define tasks
    t1 = DummyOperator(task_id="task_1")
    t2 = DummyOperator(task_id="task_2")
    t3 = DummyOperator(task_id="task_3")
    # t4 = DummyOperator(task_id="task_4")
    # t5 = DummyOperator(task_id="task_5")
    t6 = PythonOperator(
        task_id="say_hello",       # Unique task ID
        python_callable=say_hello # Function to call
    )
    
    # Define dependencies
    #t1.set_downstream([t2, t3])
    t1 >> [t2, t3]
    t2 >> t6
    t1 >> t6
    #[t2, t3] << t1