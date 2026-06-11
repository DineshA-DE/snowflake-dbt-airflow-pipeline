from datetime import datetime
from airflow.decorators import dag
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# Snowflake connection config
profile_config = ProfileConfig(
    profile_name="tpch_pipeline",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_conn",
        profile_args={
            "database": "AIRBNB_PROJECT",
            "schema": "DEV_STAGING",
            "warehouse": "COMPUTE_WH",
            "role": "DBT_ROLE",
        }
    )
)

@dag(
    dag_id="dbt_snowflake_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["dbt", "snowflake", "tpch"]
)
def dbt_pipeline():
    DbtTaskGroup(
        group_id="dbt_tpch",
        project_config=ProjectConfig("/usr/local/airflow/include/dbt"),
        profile_config=profile_config,
        execution_config=ExecutionConfig(
            dbt_executable_path="/usr/local/airflow/dbt_venv/bin/dbt"
        )
    )

dbt_pipeline()