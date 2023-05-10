USE MyStore
GO
-----------------------------------------------------------
ALTER TABLE production.inventory
ADD CONSTRAINT FK_product_inventory FOREIGN KEY (product_id)
REFERENCES production.products(id)
-----------------------------------------------------------
ALTER TABLE production.products
ADD CONSTRAINT FK_product_supplier FOREIGN KEY(supplier)
REFERENCES production.suppliers(id)
-----------------------------------------------------------
ALTER TABLE production.products
ADD CONSTRAINT FK_product_category FOREIGN KEY(category)
REFERENCES production.categories(id)
-----------------------------------------------------------
ALTER TABLE production.products
ADD CONSTRAINT FK_product_brand FOREIGN KEY(brand)
REFERENCES production.brands(id)
-----------------------------------------------------------------------------------------------
ALTER TABLE sales.orderDetail
ADD CONSTRAINT FK_order_orderDetail FOREIGN KEY(order_id)
REFERENCES sales.orders(id)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_customer FOREIGN KEY(customer)
REFERENCES sales.customers(id)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_payment FOREIGN KEY(payment_method)
REFERENCES sales.paymentMethod(code)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_shipping FOREIGN KEY(shipping_method)
REFERENCES sales.shippingMethod(code)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_status FOREIGN KEY(status)
REFERENCES sales.orderStatus(code)
-----------------------------------------------------------
ALTER TABLE sales.orderDetail
ADD CONSTRAINT FK_orderDetail_product FOREIGN KEY(product_id)
REFERENCES production.products(id)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_employee FOREIGN KEY(employee)
REFERENCES dept.employees(id)
-----------------------------------------------------------
ALTER TABLE sales.orders
ADD CONSTRAINT FK_order_store FOREIGN KEY(store)
REFERENCES dept.stores(id)

-------------------------------------------------------------------------------------------
ALTER TABLE dept.stores
ADD CONSTRAINT FK_store_employee FOREIGN KEY(manager)
REFERENCES dept.employees(id)
-----------------------------------------------------------
ALTER TABLE dept.employees
ADD CONSTRAINT FK_employee_manager FOREIGN KEY(manager)
REFERENCES dept.employees(id)