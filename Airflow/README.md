Data Engineer Task : The setup for the data pipeline of a basic data warehouse using Docker and Apache Airflow. 
---
## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

- Clone this repo
- Install the prerequisites
- Run the service
- Check http://localhost:5884
- Trigger DAG for transferring the content of Source Database X to Target Database Y
- Inspect Database 
- Done! :tada:

### Prerequisites

- Install [Docker](https://www.docker.com/)
- Install [Docker Compose] (abc)

### Usage

1. Clone the project to local machine and go to folder

```
git clone https://github.com/hiennm99/ETL-Pipeline.git
cd Airflow/
```

2. Run following command to setup Airflow service with Docker, setup postgres database and add database connection in Airflow. Remember!! At least 4.0GB Memory required in Docker to setup Airflow.

```
- Create specific network for Airflow
docker create network my-network

- Init Airflow environment 
mkdir -p ./dags ./logs ./plugins
echo -e "AIRFLOW_UID=$(id -u)" > .env

- Init Airflow containers
docker-compose up airflow-init 

- Start Airflow containers
docker-compose up -d


3. Note: The postgres database airflow will use port at 5433, source postgres database will use port at 5434 and target postgres database will use port at 5435. If these port is being used, please change it to a different port in `docker-compose.yaml` postgres service.

Check http://localhost:5884/

### Tigger DAG

- Trigger DAG manually via Airflow webserver at localhost:5884 
- DAG name `ETL.py`

### Connect databases: You can setup database connection via Airflow Web UI: 

## Other Notes

### What I have completed
1. Setup complete data pipeline using Docker and Airflow with local development Setup script
2. Init two postgres database in docker-compose setup.
3. Add database connection through Airflow Web UI.
4. Using python library sqlalchemy in Airflow to connect and transfer data between two database.

### What can be improved
1. Write unit test for database back-end
2. Check Data quality before loading to new database
3. Build service health check for ingesting data (grafana, etc.)

## Credits

- [Apache Airflow Docker](https://airflow.apache.org/docs/apache-airflow/stable/start/docker.html)