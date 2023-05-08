import pandas as pd
from airflow import DAG
from airflow.operators.python import PythonOperator
from sqlalchemy import create_engine
from datetime import datetime
import os


runTime=datetime.now().strftime("%Y_%m_%d")

default_args={
    'owner':'hiennm99',
    
}
dag=DAG(
    dag_id='ETL',
    default_args=default_args,
    start_date= datetime(2023, 5, 4),
    schedule_interval=None,
    catchup=False
)

def connect_database():
    db_host='171.235.26.162'
    db_user='hiennm99'
    db_pwd='Minhhien1105'
    db_driver='mssql+pyodbc'
    db_database='MyStore'
    
    db_url=f'{db_driver}://{db_user}:{db_pwd}@{db_host}:1433/{db_database}?TrustServerCertificate=yes&driver=ODBC+Driver+18+for+SQL+Server'
    db_engine=create_engine(db_url)
    return db_engine

def connect_datawarehouse():
    dwh_host='171.235.26.162'
    dwh_port=5432
    dwh_user='hiennm99'
    dwh_pwd='Minhhien1105'
    dwh_driver='postgresql'
    dwh_database='hiennm99'
    
    dwh_url=f'{dwh_driver}://{dwh_user}:{dwh_pwd}@{dwh_host}:{dwh_port}/{dwh_database}'
    dwh_engine=create_engine(dwh_url)
    return dwh_engine

def extract_data():
    db_engine=connect_database()
    dwh_engine=connect_datawarehouse()
    
    # Get the last_update record in datawarehouse
    query1=f"""SELECT max(last_update) FROM public.orders"""
    last_update_dwh=pd.read_sql_query(query1,con=dwh_engine)['max'].loc[0].strftime("%Y-%m-%d 23:59:59")
    
    # Get all records which have updatedAt > last_update
    query2=f"""SELECT * FROM cdc.sales_orders_CT WHERE updatedAt >'{last_update_dwh}'"""
    df=pd.read_sql_query(query2,con=db_engine)
        
    print("Extract data from database successfully !!!")
    rawData=f'/opt/airflow/dags/data/raw_{runTime}.parquet'
    df.to_parquet(rawData)

def transform_data():
    rawFilename=f'/opt/airflow/dags/data/raw_{runTime}.parquet'
    df=pd.read_parquet(rawFilename)
    
    #Drop temporate columns
    df=df.drop(columns=['__$start_lsn','__$end_lsn','__$seqval','__$update_mask','__$command_id','createdAt','id'])
    
    #Rename columms with datawarehouse format
    df=df.rename(columns={
        '__$operation':'operation',
        'orderId':'order_id',
        'storeId':'store_id',
        'empId':'emp_id',
        'cusId':'cus_id',
        'totalPayment':'total_payment',
        'paymentMethod':'payment_method',
        'shippingMethod':'shipping_method',
        'orderStatus':'order_status',
        'updatedAt':'last_update',
        }
    )
    
    #Define new records & drop temporate column
    df_new=df.loc[df['operation']==2]
    df_new=df_new.drop(columns=['operation'])
    
    #Define updated records & drop temporate column
    df_old=df.loc[df['operation']==4]
    df_old=df_old.drop(columns=['operation'])
    
    print("Transform data successfully !!!")
    newData=f'/opt/airflow/dags/data/newData_{runTime}.parquet'
    oldData=f'/opt/airflow/dags/data/oldData_{runTime}.parquet'
    df_new.to_parquet(newData)
    df_old.to_parquet(oldData)

def load_data():
    dwh_engine=connect_datawarehouse()
    
    #Upload new records to datawarehouse
    newData=f'/opt/airflow/dags/data/newData_{runTime}.parquet'
    df_new=pd.read_parquet(newData)
    if not df_new.empty:
        df_new.to_sql('orders',con=dwh_engine,if_exists='append',index=False)
        print("Uploaded new records successfully !!!")
    else:
        print("No new records !!!")
    #Update existing records to datawarehouse
    oldData=f'/opt/airflow/dags/data/oldData_{runTime}.parquet'
    df_old=pd.read_parquet(oldData)
    
    if not df_old.empty:
        for row in df_old.iterrows():
            query3=f"""UPDATE orders SET store_id='{row[1]['store_id']}',emp_id='{row[1]['emp_id']}',
                    cus_id='{row[1]['cus_id']}',subtotal={row[1]['subtotal']},tax={row[1]['tax']},
                    discount={row[1]['discount']},total_payment={row[1]['total_payment']},payment_method={row[1]['payment_method']},
                    shipping_method={row[1]['shipping_method']},order_status={row[1]['order_status']},last_update='{row[1]['last_update']}'
            WHERE order_id='{row[1]['order_id']}'"""
            dwh_engine.execute(query3)
        print("Updated old records successfully !!!")
    else:
        print("No old records !!!")
    print("Load data into datawarehouse successfully !!!!")
    

task1=PythonOperator(
    task_id='extract_data',
    python_callable=extract_data,
    dag=dag
)
task2=PythonOperator(
    task_id='transform_data',
    python_callable=transform_data,
    dag=dag
)
task3=PythonOperator(
    task_id='load_data',
    python_callable=load_data,
    dag=dag
)

task1 >> task2 >> task3