USE MyStore
GO
-----------------------------------------------------------
ALTER TABLE production.inventory
ADD CONSTRAINT FK_product_inventory FOREIGN KEY (productId)
REFERENCES production.products(productId)
-----------------------------------------------------------
ALTER TABLE production.products
ADD CONSTRAINT FK_product_supplier FOREIGN KEY(supplier)
REFERENCES production.suppliers(supplierId)
-----------------------------------------------------------
ALTER TABLE production.products
ADD CONSTRAINT FK_product_category FOREIGN KEY(category)
REFERENCES production.categories(catId)
-----------------------------------------------------------
ALTER TABLE production.products
ADD CONSTRAINT FK_product_brand FOREIGN KEY(brand)
REFERENCES production.brands(brandId)
-----------------------------------------------------------------------------------------------
ALTER TABLE sales.orderDetails
ADD CONSTRAINT FK_order_orderDetails FOREIGN KEY(orderId)
REFERENCES sales.orders(orderId)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_customer FOREIGN KEY(cusId)
REFERENCES sales.customers(cusID)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_payment FOREIGN KEY(paymentMethod)
REFERENCES sales.paymentMethods(methodCode)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_shipping FOREIGN KEY(shippingMethod)
REFERENCES sales.shippingMethods(methodCode)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_status FOREIGN KEY(orderStatus)
REFERENCES sales.orderStatus(statusCode)
-----------------------------------------------------------
ALTER TABLE sales.orderDetails
ADD CONSTRAINT FK_orderDetails_product FOREIGN KEY(productId)
REFERENCES production.products(productId)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_employee FOREIGN KEY(empId)
REFERENCES dept.employees(empId)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_store FOREIGN KEY(storeId)
REFERENCES dept.stores(storeId)

-------------------------------------------------------------------------------------------
ALTER TABLE dept.stores
ADD CONSTRAINT FK_store_employee FOREIGN KEY(manager)
REFERENCES dept.employees(empId)
-----------------------------------------------------------
ALTER TABLE dept.employees
ADD CONSTRAINT FK_employee_manager FOREIGN KEY(manager)
REFERENCES dept.employees(empId)