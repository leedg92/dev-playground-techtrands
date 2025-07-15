from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

def print_hello():
    print('hello, world')

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=1)
}

dag = DAG(
    'hello_world_dag',
    default_args=default_args,
    description='간단한 Hello World DAG',
    schedule_interval='* * * * *',  # 1분마다 실행
    catchup=False
)

hello_task = PythonOperator(
    task_id='print_hello',
    python_callable=print_hello,
    dag=dag
)
