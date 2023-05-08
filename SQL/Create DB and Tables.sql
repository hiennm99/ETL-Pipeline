CREATE DATABASE MyStore
GO 
-----------------------------------------
USE MyStore
GO 
-----------------------------------------
CREATE SCHEMA production
GO 
CREATE SCHEMA sales
GO 
CREATE SCHEMA dept
GO 
-----------------------------------------
CREATE TABLE production.products (
	id INT IDENTITY(1,1),
	productId VARCHAR(20) PRIMARY KEY,
	productName VARCHAR(255),
	brand VARCHAR(20),
	category VARCHAR(20),
	descrip VARCHAR(255),
	cog INT DEFAULT 0,     -------- Giá nhập
	salePrice INT DEFAULT 0, ------ Giá bán
	unit VARCHAR(20), ------------- Đơn vị tính
	supplier VARCHAR(20),
	isActive INT DEFAULT 1 ------ 1 là trạng thái mặc định là đang bán
);
-----------------------------------------
CREATE TABLE production.categories(
	id INT IDENTITY(1,1),
	catId VARCHAR(20) PRIMARY KEY,
	catName VARCHAR(50),
	descrip VARCHAR(255)
);
GO
-----------------------------------------
CREATE TABLE production.brands(
	id INT IDENTITY(1,1),
	brandId VARCHAR(20) PRIMARY KEY,
	brandName VARCHAR(50),
	supId VARCHAR(20), --------- supplier ID
	status INT         --------- Tình trạng brand
);
GO 
-----------------------------------------
CREATE TABLE production.inventory (
	id INT IDENTITY(1,1),
	productId VARCHAR(20) PRIMARY KEY,
	inStock INT DEFAULT 0
);
GO 
-----------------------------------------
CREATE TABLE production.suppliers(
	id INT IDENTITY(1,1),
	supplierId VARCHAR(20) PRIMARY KEY,
	supplierName VARCHAR(50),
	phoneNum VARCHAR(12),
	addr VARCHAR(255),
);
GO 
-----------------------------------------
CREATE TABLE production.inventoryLogs (
	id INT IDENTITY(1,1),
	productId VARCHAR(20),
	eventType VARCHAR(20),
	quantity INT,
	eventDate DATETIME,
	eventBy VARCHAR(50)
);
-----------------------------------------
CREATE TABLE sales.orders(
	id INT IDENTITY(1,1),
	orderId VARCHAR(20) PRIMARY KEY,
	storeId VARCHAR(20),
	empId VARCHAR(20),
	cusId VARCHAR(20),
	subtotal INT DEFAULT 0,
	tax INT DEFAULT 0,
	discount INT DEFAULT 0,
	totalPayment INT DEFAULT 0,
	paymentMethod INT, 
	shippingMethod INT,
	orderStatus INT DEFAULT 0, ----- 0 là trạng thái chưa xác định/đơn mới
	createdAt DATETIME,
	updatedAt DATETIME
);
GO 
----------------------------------------
CREATE TABLE sales.orderStatus (
	id INT IDENTITY(1,1),
	statusCode INT PRIMARY KEY,
	statusDescrip VARCHAR(50)
);
----------------------------------------
CREATE TABLE sales.orderDetails(
	id INT IDENTITY(1,1) PRIMARY KEY,
	orderId VARCHAR(20),
	productId VARCHAR(20),
	productName VARCHAR(20),
	amount INT DEFAULT 1,
	unitPrice INT DEFAULT 0,
	itemSubtotal INT DEFAULT 0,
	createdAt DATETIME,
	updatedAt DATETIME
);
GO 
----------------------------------------
CREATE TABLE sales.paymentMethods(
	id INT IDENTITY(1,1),
	methodCode INT PRIMARY KEY,
	methodDescrip VARCHAR(50),
);
GO 
----------------------------------------
CREATE TABLE sales.shippingMethods(
	id INT IDENTITY(1,1),
	methodCode INT PRIMARY KEY,
	methodDescrip VARCHAR(50),
);
GO
----------------------------------------
CREATE TABLE sales.customers(
	id INT IDENTITY(1,1),
	cusID VARCHAR(20) PRIMARY KEY,
	phoneNum VARCHAR(20),
	addr VARCHAR(255)
);
GO 
----------------------------------------
CREATE TABLE sales.orderLogs (
	id INT IDENTITY(1,1),
	orderId VARCHAR(20),
	productId VARCHAR(20),
	amount INT,
	price INT,
	totalPrice INT,
	orderStatus INT,
	modDate DATETIME,
	modBy VARCHAR(50),
	note VARCHAR(255)
);
GO 
----------------------------------------
CREATE TABLE dept.stores(
	id INT IDENTITY(1,1),
	storeId VARCHAR(20) PRIMARY KEY,
	phoneNum VARCHAR(12),
	addr VARCHAR(255),
	manager VARCHAR(20)
);

----------------------------------------
CREATE TABLE dept.employees(
	id INT IDENTITY(1,1),
	empId VARCHAR(20) PRIMARY KEY,
	empName VARCHAR(255),
	bod DATE,
	phoneNum VARCHAR(12),
	addr VARCHAR(255),
	manager VARCHAR(20)
);



