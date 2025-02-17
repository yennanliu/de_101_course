# Lab 1

```
├── README.md
├── airflow_intro.md
├── dags - ETL code
├── docker-compose.yml - file build airflow app
├── logs - logging files
└── plugins - extra libraries can be import to airflow
```

<details>
<summary>Run via Docker</summary>

## Get the code

```bash
git clone https://github.com/yennanliu/de_101_course.git
```

## Install (Docker)
```bash

# install docker
# https://docs.docker.com/desktop/setup/install/mac-install/
```

## Run  (Docker)

```bash

cd lab_1

chmod +x init.sh

./init.sh

mkdir dags logs plugins

# run
docker-compose up

# restart
docker-compose restart
```

</details>

<details>
<summary>Run via python pkg</summary>

## Install (python pkg)

- https://airflow.apache.org/docs/apache-airflow/stable/installation/index.html
- https://medium.com/@ericfflynn/installing-apache-airflow-with-pip-593717580f86

```bash
pip install "apache-airflow[celery]==2.10.4" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.10.4/constraints-3.8.txt"
```


## Run (python pkg)


</details>


## Dag
- hello_world_dag.py: 基本的dag
- load_conf_dag.py: dag load config file
- local_custom_class_dag.py: dag load class
- task_dep_dag_1.py, task_dep_dag_2.py : task dep demo


## Endpoint
- http://localhost:8080
	- user: airflow
	- password: airflow