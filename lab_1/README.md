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

## Install (Docker)
```bash

# install docker
# https://docs.docker.com/desktop/setup/install/mac-install/

# fix docker-compose (mac user)

# https://docs.docker.com/compose/install/

sudo rm /usr/local/bin/docker-compose
sudo ln -s /Applications/Docker.app/Contents/Resources/cli-plugins/docker-compose /usr/local/bin/docker-compose=
```

## Run  (Docker)

```bash

cd lab_1

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

## Endpoint
- http://localhost:8080
	- user: admin
	- password: admin