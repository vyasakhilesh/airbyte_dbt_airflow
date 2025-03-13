from setuptools import find_packages, setup

setup(
    name="airbyte-dbt-airflow-postgre",
    packages=find_packages(),
    install_requires=[
        "dbt-postgres",
        "apache-airflow[airbyte]",
        "apache-airflow",
    ],
    extras_require={"dev": ["pytest"]},
)