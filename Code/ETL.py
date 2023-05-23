import pandas as pd
from configparser import ConfigParser
from sqlalchemy import create_engine
from datetime import datetime

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
        query1=f"""SELECT MAX(updated_at) as last_update FROM public.d_updatelogs WHERE tbl_name='f_orders'"""
        dwh_data=pd.read_sql_query(query1,con=dwh_engine)
        
    except Exception as e:
        print(e)
    
    if not dwh_data.empty:
        last_update_dwh=dwh_data['last_update'][0].strftime("%Y-%m-%d %H:%M:%S")
        # Get all records which have updated_at > last_update
        try:
            query2=f"""SELECT * FROM sales.orders WHERE updated_at <='{last_update_dwh}'"""
            df=pd.read_sql_query(query2,con=db_engine)
        except Exception as e:
            print(e)
    else:
        last_update_dwh=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
    print("Extract data from database successfully !!!")
    rawData=f'raw_{runTime}.parquet'
    df.to_parquet(rawData)

def remove_duplicates(dataframe,columns):
    dataframe=dataframe.sort_values(columns,ascending=False)
    dataframe=dataframe.drop_duplicates(subset=columns,keep='first')
    return dataframe

def handle_missing_values(dataframe,fill_values):
    return dataframe.fillna(fill_values)

def define_record_type(extracted_data):
    dwh_engine=connect_datawarehouse()
    
    # Get all records existing in datawarehouse
    existing_data = pd.read_sql('SELECT * FROM f_orders', con=dwh_engine)
    
    # So sánh dữ liệu mới với dữ liệu đã tồn tại
    existing_records = pd.merge(existing_data, extracted_data, on='id', how='inner')
    new_records = extracted_data[~extracted_data['id'].isin(existing_data['id'])]
    old_records = extracted_data[extracted_data['id'].isin(existing_data['id'])]
    return new_records,old_records

def transform_data():
    rawFilename=f'raw_{runTime}.parquet'
    raw_data=pd.read_parquet(rawFilename)
    
    ## Drop column 'id'
    raw_data=raw_data.drop(columns=['no'])
    
    ## Drop duplicate values
    # Remove duplicates
    transformed_data =remove_duplicates(dataframe=raw_data,columns='id')

    # Handle missing values
    transformed_data=handle_missing_values(dataframe=transformed_data,fill_values='N/A')
    
    print("Transform data successfully !!!")
    transformed_data.to_parquet(f'transformed_{runTime}.parquet')

def load_data():
    dwh_engine=connect_datawarehouse()
    
    # Get transformed data
    transformed_data=pd.read_parquet(f"transformed_{runTime}.parquet",engine='fastparquet')
    # Number of transformed records
    transformed_count=transformed_data.shape[0]
    
    # Define new records & old records
    new_records,old_records=define_record_type(transformed_data)
    #Number of new records
    new_count=new_records.shape[0]
    #Number of old records
    old_count=old_records.shape[0]
    
    # Insert new records
    if new_count>0:
        new_records['created_at']=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        new_records['updated_at']=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        new_records.to_sql('f_orders', con=dwh_engine, if_exists='append', index=False)
        
        print(f"Insert {new_count} new records successfully!!!")
    
    # Get number of inserted record successfully
    query=f"""SELECT COUNT(*) FROM f_orders"""
    result=dwh_engine.execute(query)
    inserted_count = result.fetchone()[0]
    inserted_count=inserted_count-old_count
    
    # Update old records
    updated_count=0
    if old_count>0:
        for row in old_records.iterrows():
            try:
                id=f"'{row[1]['id']}'"
                store=f"'{row[1]['store']}'"
                employee=f"'{row[1]['employee']}'"
                customer=f"'{row[1]['customer']}'"
                subtotal=row[1]['subtotal']
                tax=row[1]['tax']
                discount=row[1]['discount']
                total_payment=row[1]['total_payment']
                payment_method=row[1]['payment_method']
                shipping_method=row[1]['shipping_method']
                status=row[1]['status']
                updated_at=f"""'{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}'"""
                query3=f"""UPDATE f_orders SET store={store}, employee={employee}, customer={customer},
                                            subtotal={subtotal}, tax={tax}, discount={discount},
                                            total_payment={total_payment}, payment_method={payment_method},
                                            shipping_method={shipping_method}, status={status}, updated_at={updated_at}
                        WHERE id={id}"""
                dwh_engine.execute(query3)
                updated_count+=1
            except Exception as e:
                print(e)
        print("Updated old records successfully !!!")
    
    # Number of loaded records
    loaded_count=inserted_count+updated_count
    
    if loaded_count==transform_data:
        print("All records loaded successfully!!!")
        
    print("Load data into datawarehouse successfully !!!!")
    
if __name__ == '__main__':
    config=ConfigParser()
    config.read('config.ini')
    runTime=datetime.now().strftime("%Y_%m_%d")
    extract_data()
    transform_data()
    load_data()