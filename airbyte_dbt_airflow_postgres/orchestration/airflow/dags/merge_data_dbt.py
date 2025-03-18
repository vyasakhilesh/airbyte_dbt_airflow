import pendulum, os

from datetime import timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.trigger_rule import TriggerRule

DBT_DIR = "/opt/airflow/dbt_project"

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': pendulum.today('UTC').add(days=-1),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    }


with DAG(
    dag_id='T_DAG_DBT',
    default_args=default_args,
    schedule=None,
    ) as dag:

   start_pipeline_task = EmptyOperator(task_id="start_pipeline")
   end_pipeline_task = EmptyOperator(task_id="end_pipeline")

   
   run_dbt_check_task = BashOperator(
       task_id='run_dbt_precheck',
       bash_command='pwd && dbt debug && dbt list',
       cwd=DBT_DIR,
       trigger_rule=TriggerRule.ALL_SUCCESS,  # Execute only if all upstream tasks are successful.
    )

   run_dbt_model_task = BashOperator(
       task_id='run_dbt_model',
       bash_command='dbt run',
       cwd=DBT_DIR,
       trigger_rule=TriggerRule.ALL_SUCCESS,  # Ensure all checks pass before running models.
    )

   start_pipeline_task \
    >> [run_dbt_check_task] \
        >> run_dbt_model_task >> end_pipeline_task
