use MyStore
go

EXECUTE sys.sp_cdc_enable_db;

EXECUTE sys.sp_cdc_enable_table  
    @source_schema = N'sales',  
    @source_name = N'orders',
    @role_name = N'hiennm99' 

EXECUTE sys.sp_cdc_enable_table  
    @source_schema = N'sales',  
    @source_name = N'orderDetails',
    @role_name = N'hiennm99'
	
EXECUTE sys.sp_cdc_enable_table  
    @source_schema = N'production',  
    @source_name = N'products',
    @role_name = N'hiennm99'

EXECUTE sys.sp_cdc_enable_table  
    @source_schema = N'production',  
    @source_name = N'inventory',
    @role_name = N'hiennm99'

SELECT * FROM cdc.sales_orders_CT 
SELECT * FROM cdc.sales_orderDetails_CT 