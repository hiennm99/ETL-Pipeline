import pandas as pd
from configparser import ConfigParser
from sqlalchemy import create_engine
import datetime
import os

def connect_database():
    db_host=config['DB']['hostname']
    db_user=config['DB']['user']
    db_pwd=config['DB']['password']
    db_driver=config['DB']['driver']
    db_database=config['DB']['database']
    
    db_url=f'{db_driver}://{db_user}:{db_pwd}@{db_host}/{db_database}?driver=ODBC+Driver+17+for+SQL+Server'
    db_engine=create_engine(db_url)
    return db_engine

def connect_datawarehouse():
    dwh_host=config['DWH']['hostname']
    dwh_port=config['DWH']['port']
    dwh_user=config['DWH']['user']
    dwh_pwd=config['DWH']['password']
    dwh_driver=config['DWH']['driver']
    dwh_database=config['DWH']['database']
    
    dwh_url=f'{dwh_driver}://{dwh_user}:{dwh_pwd}@{dwh_host}:{dwh_port}/{dwh_database}'
    dwh_engine=create_engine(dwh_url)
    return dwh_engine

def extract_data():
    db_engine=connect_database()
    dwh_engine=connect_datawarehouse()
    
    # Get the last_update record in datawarehouse
    try:
        query1=f"""SELECT last_update FROM public.orders"""
        dwh_data=pd.read_sql_query(query1,con=dwh_engine)
        
    except Exception as e:
        print(e)
    
    if not dwh_data.empty:
        last_update_dwh=dwh_data['last_update'].max().strftime("%Y-%m-%d")
        # Get all records which have updatedAt > last_update
        try:
            query2=f"""SELECT * FROM cdc.sales_orders_CT WHERE updatedAt >='{last_update_dwh}'"""
            df=pd.read_sql_query(query2,con=db_engine)
        except Exception as e:
            print(e)
    else:
        # Get all records from database
        try:
            query2=f"""SELECT * FROM cdc.sales_orders_CT"""
            df=pd.read_sql_query(query2,con=db_engine)
        except Exception as e:
            print(e)      
            
    print("Extract data from database successfully !!!")
    rawData=f'raw_{runTime}.parquet'
    df.to_parquet(rawData)

def transform_data():
    rawFilename=f'raw_{runTime}.parquet'
    df=pd.read_parquet(rawFilename)
    
    #Drop temporate columns
    df=df.drop(columns=['__$start_lsn','__$end_lsn','__$seqval','__$update_mask','__$command_id','id','createdAt'])
    
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
    newData=f'newData_{runTime}.parquet'
    oldData=f'oldData_{runTime}.parquet'
    df_new.to_parquet(newData)
    df_old.to_parquet(oldData)

def load_data():
    dwh_engine=connect_datawarehouse()
    
    #Upload new records to datawarehouse
    newData=f'newData_{runTime}.parquet'
    df_new=pd.read_parquet(newData)
    if not df_new.empty:
        try:
            df_new.to_sql('orders',con=dwh_engine,if_exists='append',index=False)
            print("Uploaded new records successfully !!!")
        except Exception as e:
            print(e)
    else:
        print("No new records !!!")
    #Update existing records to datawarehouse
    oldData=f'oldData_{runTime}.parquet'
    df_old=pd.read_parquet(oldData)
    
    if not df_old.empty:
        for row in df_old.iterrows():
            try:
                query3=f"""UPDATE orders SET store_id='{row[1]['store_id']}',emp_id='{row[1]['emp_id']}',
                        cus_id='{row[1]['cus_id']}',subtotal={row[1]['subtotal']},tax={row[1]['tax']},
                        discount={row[1]['discount']},total_payment={row[1]['total_payment']},payment_method={row[1]['payment_method']},
                        shipping_method={row[1]['shipping_method']},order_status={row[1]['order_status']},last_update='{row[1]['last_update']}'
                WHERE order_id='{row[1]['order_id']}'"""
                dwh_engine.execute(query3)
            except Exception as e:
                print(e)
        print("Updated old records successfully !!!")
    else:
        print("No old records !!!")
        
    print("Load data into datawarehouse successfully !!!!")
    
if __name__ == '__main__':
    config=ConfigParser()
    config.read('config.ini')
    runTime=datetime.datetime.now().strftime("%Y_%m_%d")
    extract_data()
    transform_data()
    load_data()