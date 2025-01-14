from airflow import DAG
from airflow.operators.dummy import DummyOperator
from datetime import datetime

# https://airflow.apache.org/docs/apache-airflow/stable/tutorial/fundamentals.html#tasks

# Define the DAG
with DAG(
    dag_id="task_dep_dag_1",
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,  # Trigger manually
    catchup=False,
) as dag:
    
    # Define tasks
    t1 = DummyOperator(task_id="task_1")
    t2 = DummyOperator(task_id="task_2")
    t3 = DummyOperator(task_id="task_3")
    t4 = DummyOperator(task_id="task_4")
    t5 = DummyOperator(task_id="task_5")
    t6 = DummyOperator(task_id="task_6")
    
    # Define dependencies
    t1 >> t2 >> t3  # Task 1 -> Task 2 -> Task 3
    t3 >> t4  # Task 3 -> Task 4
    t2 >> t5  # Task 2 -> Task 5
    t5 >> t6