from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.bash import BashOperator
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
    #t2 = DummyOperator(task_id="task_2")
    t2 = BashOperator(
    task_id="sleep",
    depends_on_past=False,
    bash_command="sleep 5",
    retries=3,
    )
    t3 = DummyOperator(task_id="task_3")
    t4 = DummyOperator(task_id="task_4")
    t5 = DummyOperator(task_id="task_5")
    t6 = DummyOperator(task_id="task_6")
    
    # Define dependencies
    t1 >> t2 >> t3  # Task 1 -> Task 2 -> Task 3
    # t3 is t4's upstream
    # t4 is t3's downstream
    # t4.set_upstream(t3)
    # t3.set_downstream(t4)
    t3 >> t4  # Task 3 -> Task 4
    t2 >> t5  # Task 2 -> Task 5
    t5 >> t6

    # sub tasks = [t2, t3, t4]
    # how to setup their parent task (t1) at once ?
    # t1 >> t2
    # t1 >> t3
    # t1 >> t4
    # t1.setdownstream([t1, t2, t4])
    