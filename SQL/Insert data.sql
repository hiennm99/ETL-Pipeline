USE MyStore
GO 
--------------------------------------------------
INSERT INTO production.categories (id,name,description) VALUES('TMH', N'Chăm sóc Tai Mũi Họng', NULL)
INSERT INTO production.categories (id,name,description) VALUES('PN', N'Chăm sóc sức khỏe Phụ nữ', NULL)
INSERT INTO production.categories (id,name,description) VALUES('EMBE', N'Chăm sóc sức khỏe Bé', NULL)
select * from production.categories
----------------------------------------------------------------------------
INSERT INTO production.suppliers (id,name,phone_number,address) VALUES ('MERAP',N'Công ty cổ phần tập đoàn Merap','0888333489',N'Hung Yen')
INSERT INTO production.suppliers (id,name,phone_number,address) VALUES ('OTHER',N'Đơn vị khác','N/A','N/A')
select * from production.suppliers
----------------------------------------------------------------------------
INSERT INTO production.brands (id,name,supplier,status) VALUES('MR','Merap Group','MERAP',1)
INSERT INTO production.brands (id,name,supplier,status) VALUES('OT',N'Khác',NULL,1)
SELECT * FROM production.brands
------------------------------------------------------------------------------------------------------------
INSERT INTO production.products (id,name,brand,category,description,cog,sale_price,unit,supplier,is_active) VALUES ('PROD001',N'MEDORAL ACTIVE 10ml','MR','TMH','N/A',40000,45000,'Lo','MERAP',1)
INSERT INTO production.products (id,name,brand,category,description,cog,sale_price,unit,supplier,is_active) VALUES ('PROD002',N'XISAT 75ml','MR','TMH','N/A',27000,30000,'Chai','MERAP',1)
INSERT INTO production.products (id,name,brand,category,description,cog,sale_price,unit,supplier,is_active) VALUES ('PROD003',N'XYPENAT 30ml','MR','TMH','N/A',350000,37200,'Lo','MERAP',1)
INSERT INTO production.products (id,name,brand,category,description,cog,sale_price,unit,supplier,is_active) VALUES ('PROD004',N'SHEMA 200ml','MR','PN','N/A',34000,40000,'Chai','MERAP',1)
INSERT INTO production.products (id,name,brand,category,description,cog,sale_price,unit,supplier,is_active) VALUES ('PROD005',N'SHEMA BABY 50ml','MR','PN','N/A',55000,60000,'Chai','MERAP',1)
INSERT INTO production.products (id,name,brand,category,description,cog,sale_price,unit,supplier,is_active) VALUES ('PROD006',N'XISAT BABY 15ml','MR','EMBE','N/A',7000,9000,'Chai','MERAP',1)
select * from production.products
-------------------------------------------------------------------------------------------------------------
INSERT INTO production.inventory (product_id,in_stock) VALUES ('PROD001',200)
INSERT INTO production.inventory (product_id,in_stock) VALUES ('PROD002',200)
INSERT INTO production.inventory (product_id,in_stock) VALUES ('PROD003',200)
INSERT INTO production.inventory (product_id,in_stock) VALUES ('PROD004',100)
INSERT INTO production.inventory (product_id,in_stock) VALUES ('PROD005',100)
INSERT INTO production.inventory (product_id,in_stock) VALUES ('PROD006',50)
select * from production.inventory
-------------------------------------------------------------------------------------------------------------
INSERT INTO dept.employees (id,name,bod,phone_number,address,manager) VALUES ('MR2558','Nguyen Minh Hien',NULL,NULL, NULL, NULL)
INSERT INTO dept.employees (id,name,bod,phone_number,address,manager) VALUES ('MR2559','Le Van Hieu',NULL,NULL, NULL, 'MR2558')
INSERT INTO dept.employees (id,name,bod,phone_number,address,manager) VALUES ('MR2560','Pham Van Hai',NULL,NULL, NULL, NULL)
-------------------------------------------------------------------------------------------------------------
INSERT INTO dept.stores (id,phone_number,address,manager) VALUES ('WH0010',NULL,NULL,'MR2558')
INSERT INTO dept.stores (id,phone_number,address,manager) VALUES ('WH0012',NULL,NULL,'MR2560')
-------------------------------------------------------------------------------------------------------------
INSERT INTO sales.paymentMethod (code,description) VALUES (1,'Cash')
INSERT INTO sales.paymentMethod (code,description) VALUES (2,'Credit card')
INSERT INTO sales.paymentMethod (code,description) VALUES (3,'Visa debit')
-------------------------------------------------------------------------------------------------------------
INSERT INTO sales.shippingMethod (code,description) VALUES (1,'On store')
INSERT INTO sales.shippingMethod (code,description) VALUES (2,'COD')
-------------------------------------------------------------------------------------------------------------
INSERT INTO sales.orderStatus (code,description) VALUES (0,'Default')
INSERT INTO sales.orderStatus (code,description) VALUES (1,'Wait for payment')
INSERT INTO sales.orderStatus (code,description) VALUES (2,'Shipping')
INSERT INTO sales.orderStatus (code,description) VALUES (-1,'Cancel')
-------------------------------------------------------------------------------------------------------------