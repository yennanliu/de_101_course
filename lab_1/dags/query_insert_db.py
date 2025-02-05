from airflow import DAG
from airflow.providers.mysql.hooks.mysql import MySqlHook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from datetime import datetime
import pandas as pd

# DAG Configuration
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
}

dag = DAG(
    'db_transfer_pipeline',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
)

def extract_data(**kwargs):
    """Extract data from Database A (MySQL)"""
    mysql_hook = MySqlHook(mysql_conn_id='db_a_conn')
    sql_query = "SELECT id, name, age, salary FROM employees WHERE active = 1"
    df = mysql_hook.get_pandas_df(sql_query)
    return df.to_json()  # Pass data to the next task via XCom

def transform_data(**kwargs):
    """Perform data transformations"""
    ti = kwargs['ti']
    json_data = ti.xcom_pull(task_ids='extract_data')
    df = pd.read_json(json_data)

    # Example Transformations
    df['name'] = df['name'].str.upper()  # Convert names to uppercase
    df['age'] = df['age'] + 1  # Increase age by 1
    df['salary'] = df['salary'] * 1.1  # Increase salary by 10%

    return df.to_json()  # Pass transformed data to the next task

def load_data(**kwargs):
    """Insert transformed data into Database B (PostgreSQL)"""
    ti = kwargs['ti']
    json_data = ti.xcom_pull(task_ids='transform_data')
    df = pd.read_json(json_data)

    # Convert dataframe to list of tuples for insertion
    data_tuples = list(df.itertuples(index=False, name=None))

    # Insert Query
    insert_query = """
    INSERT INTO employees_transformed (id, name, age, salary)
    VALUES (%s, %s, %s, %s)
    ON CONFLICT (id) DO UPDATE 
    SET name = EXCLUDED.name, age = EXCLUDED.age, salary = EXCLUDED.salary;
    """

    # Use PostgresHook to insert data
    postgres_hook = PostgresHook(postgres_conn_id='db_b_conn')
    postgres_hook.run(insert_query, parameters=data_tuples)

# Define DAG Tasks
extract_task = PythonOperator(
    task_id='extract_data',
    python_callable=extract_data,
    provide_context=True,
    dag=dag
)

transform_task = PythonOperator(
    task_id='transform_data',
    python_callable=transform_data,
    provide_context=True,
    dag=dag
)

load_task = PythonOperator(
    task_id='load_data',
    python_callable=load_data,
    provide_context=True,
    dag=dag
)

# Task Dependencies
extract_task >> transform_task >> load_task