import pendulum, os

from datetime import timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.sensors.python import PythonSensor

from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.providers.airbyte.sensors.airbyte import AirbyteJobSensor
from airflow.providers.airbyte.hooks.airbyte import AirbyteHook
from airflow.utils.trigger_rule import TriggerRule



AIRFLOW_AIRBYTE_CONN_ID = os.getenv("AIRFLOW_AIRBYTE_CONN") # The name of the Airflow connection to get connection information for Airbyte.
# AIRBYTE_CONNECTION_ID = os.getenv("AIRBYTE_CONN_ID") # the Airbyte ConnectionId UUID between a source and destination.
# DBT_DIR = "/opt/airflow/dbt_project"
AIRBYTE_CONNECTION_ID = "b26a075c-2349-4a36-977c-0243f806d6c4"

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': pendulum.today('UTC').add(days=-1),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    }

def check_airbyte_health():
    airbyte_hook = AirbyteHook(airbyte_conn_id=AIRFLOW_AIRBYTE_CONN_ID)
    is_healthy, message = airbyte_hook.test_connection()
    print(message)
    return is_healthy

with DAG(
    dag_id='EL_DAG_Postgres_2_Qdrant',
    default_args=default_args,
    schedule=None,
    ) as dag:

   start_pipeline_task = EmptyOperator(task_id="start_pipeline")
   end_pipeline_task = EmptyOperator(task_id="end_pipeline")

   airbyte_precheck_task = PythonSensor(
        task_id="check_airbyte_health",
        poke_interval=10,
        timeout=3600,
        mode="poke",
        python_callable=check_airbyte_health,
    )
   
   trigger_airbyte_sync_task = AirbyteTriggerSyncOperator(
       task_id='airbyte_trigger_sync',
       airbyte_conn_id=AIRFLOW_AIRBYTE_CONN_ID,
       connection_id=AIRBYTE_CONNECTION_ID,
       asynchronous=True
   )

   wait_for_sync_completion_task = AirbyteJobSensor(
       task_id='airbyte_check_sync',
       airbyte_conn_id=AIRFLOW_AIRBYTE_CONN_ID,
       airbyte_job_id=trigger_airbyte_sync_task.output,
       trigger_rule=TriggerRule.ALL_SUCCESS,  # Only proceed if the sync task is successful.
    )

   start_pipeline_task >> airbyte_precheck_task >> trigger_airbyte_sync_task \
    >> [wait_for_sync_completion_task] \
        >> end_pipeline_task