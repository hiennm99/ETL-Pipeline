USE MyStore
GO 
--------------------------------------------------
INSERT INTO production.categories (catId,catName,descrip) VALUES('001', 'Mobile', NULL)
INSERT INTO production.categories (catId,catName,descrip) VALUES('002', 'Laptop', NULL)
INSERT INTO production.categories (catId,catName,descrip) VALUES('003', 'Smartwatch', NULL)
INSERT INTO production.categories (catId,catName,descrip) VALUES('004', 'Tablet', NULL)
----------------------------------------------------------------------------
INSERT INTO production.suppliers (supplierId,supplierName,phoneNum,addr) VALUES ('0001','Samsung','N/A','N/A')
INSERT INTO production.suppliers (supplierId,supplierName,phoneNum,addr) VALUES ('0002','Apple','N/A','N/A')
INSERT INTO production.suppliers (supplierId,supplierName,phoneNum,addr) VALUES ('0003','Xiaomi','N/A','N/A')
INSERT INTO production.suppliers (supplierId,supplierName,phoneNum,addr) VALUES ('0004','Lenovo','N/A','N/A')
INSERT INTO production.suppliers (supplierId,supplierName,phoneNum,addr) VALUES ('0005','Asus','N/A','N/A')
INSERT INTO production.suppliers (supplierId,supplierName,phoneNum,addr) VALUES ('0006','MSI','N/A','N/A')
INSERT INTO production.suppliers (supplierId,supplierName,phoneNum,addr) VALUES ('0007','Dell','N/A','N/A')
----------------------------------------------------------------------------
INSERT INTO production.brands (brandId,brandName,supId,status) VALUES('01','0003',NULL,1)
INSERT INTO production.brands (brandId,brandName,supId,status) VALUES('02','0001',NULL,1)
INSERT INTO production.brands (brandId,brandName,supId,status) VALUES('03','0004',NULL,1)
INSERT INTO production.brands (brandId,brandName,supId,status) VALUES('04','0006',NULL,1)
INSERT INTO production.brands (brandId,brandName,supId,status) VALUES('05','0002',NULL,1)
INSERT INTO production.brands (brandId,brandName,supId,status) VALUES('06','0005',NULL,1)
SELECT * FROM production.brands
------------------------------------------------------------------------------------------------------------
INSERT INTO production.products (productId,productName,brand,category,descrip,cog,salePrice,unit,supplier,isActive) VALUES ('1001','Samsung Galaxy S23 5G 128GB','01','001','N/A',150000000,16390000,'Cai','0001',1)
INSERT INTO production.products (productId,productName,brand,category,descrip,cog,salePrice,unit,supplier,isActive) VALUES ('1002','iPhone 14 Pro Max 128GB','02','001','N/A',26000000,27090000,'Cai','0002',1)
INSERT INTO production.products (productId,productName,brand,category,descrip,cog,salePrice,unit,supplier,isActive) VALUES ('1003','Laptop Lenovo ThinkBook 14s G2 ITL i5 1135G7/8GB/512GB/Win10 (20VA000NVN)','04','002','N/A',17260000,18290000,'Cai','0004',1)
INSERT INTO production.products (productId,productName,brand,category,descrip,cog,salePrice,unit,supplier,isActive) VALUES ('1004','Laptop Asus Gaming TUF Dash F15 FX517ZC i5 12450H/8GB/512GB/4GB RTX3050/144Hz/Win11 (HN077W)','05','002','N/A',20000000,21490000,'Cai','0005',1)
INSERT INTO production.products (productId,productName,brand,category,descrip,cog,salePrice,unit,supplier,isActive) VALUES ('1005','iPad 9 WiFi 64GB ','02','004','N/A',6000000,7990000,'Cai','0002',1)
INSERT INTO production.products (productId,productName,brand,category,descrip,cog,salePrice,unit,supplier,isActive) VALUES ('1006','Xiaomi Redmi Band 2','03','003','N/A',700000,890000,'Cai','0003',1)

-------------------------------------------------------------------------------------------------------------
INSERT INTO production.inventory (productId,inStock) VALUES ('1001',100)
INSERT INTO production.inventory (productId,inStock) VALUES ('1002',200)
INSERT INTO production.inventory (productId,inStock) VALUES ('1003',300)
INSERT INTO production.inventory (productId,inStock) VALUES ('1004',400)
INSERT INTO production.inventory (productId,inStock) VALUES ('1005',500)
INSERT INTO production.inventory (productId,inStock) VALUES ('1006',600)
-------------------------------------------------------------------------------------------------------------
INSERT INTO dept.employees (empId,empName,bod,phoneNum,addr,manager) VALUES ('MR2558','Nguyen Minh Hien',NULL,NULL, NULL, NULL)
INSERT INTO dept.employees (empId,empName,bod,phoneNum,addr,manager) VALUES ('MR2559','Le Van Hieu',NULL,NULL, NULL, 'MR2558')
INSERT INTO dept.employees (empId,empName,bod,phoneNum,addr,manager) VALUES ('MR2560','Pham Van Hai',NULL,NULL, NULL, NULL)

-------------------------------------------------------------------------------------------------------------
INSERT INTO dept.stores (storeId,phoneNum,addr,manager) VALUES ('WH0010',NULL,NULL,'MR2558')
INSERT INTO dept.stores (storeId,phoneNum,addr,manager) VALUES ('WH0012',NULL,NULL,'MR2560')
-------------------------------------------------------------------------------------------------------------
INSERT INTO sales.paymentMethods (methodCode,methodDescrip) VALUES (1,'Cash')
INSERT INTO sales.paymentMethods (methodCode,methodDescrip) VALUES (2,'Credit card')
INSERT INTO sales.paymentMethods (methodCode,methodDescrip) VALUES (3,'Visa debit')
-------------------------------------------------------------------------------------------------------------
INSERT INTO sales.shippingMethods (methodCode,methodDescrip) VALUES (1,'On store')
INSERT INTO sales.shippingMethods (methodCode,methodDescrip) VALUES (2,'COD')
-------------------------------------------------------------------------------------------------------------
INSERT INTO sales.orderStatus (statusCode,statusDescrip) VALUES (0,'Default')
INSERT INTO sales.orderStatus (statusCode,statusDescrip) VALUES (1,'Wait for payment')
INSERT INTO sales.orderStatus (statusCode,statusDescrip) VALUES (2,'Shipping')
INSERT INTO sales.orderStatus (statusCode,statusDescrip) VALUES (-1,'Cancel')
-------------------------------------------------------------------------------------------------------------
