USE MyStore
GO
------------------------------------------------------------------------------------------
ALTER PROCEDURE SP_CheckInventory
	@prod_id VARCHAR(20),
	@qty INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;
	DECLARE @inStock INT
	SET @inStock=(SELECT in_stock FROM production.inventory WHERE product_id=@prod_id)

	IF @qty>@inStock
	BEGIN
		----Nếu số lượng hàng tồn kho không đủ thì hủy bỏ giao dịch
		ROLLBACK TRANSACTION
		PRINT N'Số lượng hàng không đủ'
		RETURN;
    END

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi kiểm tra tồn kho của sản phẩm'
		RETURN ;
    END

	COMMIT TRANSACTION;
END
GO
--------------------------------------------------------------------------------------------
ALTER PROCEDURE SP_UpdateInventory
	@prod_id VARCHAR(20),
	@qty INT
AS
BEGIN
    SET NOCOUNT ON
	BEGIN TRANSACTION; 
	DECLARE @old_inStock INT
	SET @old_inStock=(SELECT in_stock FROM production.inventory WHERE product_id=@prod_id)
	
	DECLARE @new_inStock INT
	SET @new_inStock=@old_inStock-@qty

	UPDATE production.inventory
	SET in_stock=@new_inStock
	WHERE product_id=@prod_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi kiểm tra tồn kho của sản phẩm'
		RETURN ;
    END

	COMMIT TRANSACTION;
END
GO
--------------------------------------------------------------------------------------------
ALTER PROCEDURE SP_UpdateItemDetail
	@ord_id VARCHAR(20),
	@prod_id VARCHAR(20),
	@qty INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;

	---- Lấy tên sản phẩm và giá tiền từ bảng Products ----
	DECLARE @prod_name NVARCHAR(255),@price INT
	SELECT @prod_name=name,@price=sale_price FROM production.products WHERE id=@prod_id

	---- Tính thành tiền của sản phẩm ----
	DECLARE @itemSubtotal INT
	SET @itemSubtotal=@price*@qty

	---- Cập nhật những thông tin trên vào bảng orderDetail ----
	UPDATE sales.orderDetail
	SET product_name=@prod_name,unit_price=@price,item_subtotal=@itemSubtotal,updated_at=GETDATE()
	WHERE order_id=@ord_id AND product_id=@prod_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi lấy thông tin của sản phẩm'
		RETURN ;
    END

	COMMIT TRANSACTION;
END
GO 
------------------------------------------------------------------------------
CREATE TRIGGER TG_UpdateOrderDetail
ON sales.orderDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
	----- Kiểm tra tồn kho sản phẩm -----
	DECLARE @productId VARCHAR(20), @quantity INT
	SELECT @productId=i.product_id,@quantity=i.amount FROM Inserted i
	EXEC dbo.SP_CheckInventory @prod_id = @productId, -- varchar(20)
	                           @qty = @quantity       -- int

	----- Nếu sản phẩm còn hàng thì cập nhật tồn kho mới -----
	EXEC dbo.SP_UpdateInventory @prod_id = @productId, -- varchar(20)
	                            @qty = @quantity       -- int

	----- Bổ sung thông tin sản phẩm ------
	DECLARE @orderId VARCHAR(20), @amount INT
	SELECT @orderId=i.order_id, @amount=i.amount FROM Inserted i
	EXEC dbo.SP_UpdateItemDetail @ord_id = @orderId,  -- varchar(20)
	                             @prod_id = @productId, -- varchar(20)
	                             @qty = @amount       -- int
END
GO 
------------------------------------------------------------------------------
INSERT INTO sales.orders
(
    id,
    store,
    employee,
    customer,
    subtotal,
    tax,
    discount,
    total_payment,
    payment_method,
    shipping_method,
    status,
    created_at,
    updated_at
)
VALUES
(   'ORD001',      -- id - varchar(20)
    'WH0010',    -- store - varchar(20)
    'MR2558',    -- employee - varchar(20)
    NULL,    -- customer - varchar(20)
    DEFAULT, -- subtotal - int
    DEFAULT, -- tax - int
    DEFAULT, -- discount - int
    DEFAULT, -- total_payment - int
    1,    -- payment_method - int
    1,    -- shipping_method - int
    DEFAULT, -- status - int
    GETDATE(),    -- created_at - datetime
    GETDATE()   -- updated_at - datetime
    )
------------------------------------------------------------------------------
INSERT INTO sales.orderDetail
(
    order_id,
    product_id,
    product_name,
    amount,
    unit_price,
    item_subtotal,
    created_at,
    updated_at
)
VALUES
(   'ORD001',    -- order_id - varchar(20)
    'PROD006',    -- product_id - varchar(20)
    NULL,    -- product_name - varchar(20)
    25, -- amount - int
    DEFAULT, -- unit_price - int
    DEFAULT, -- item_subtotal - int
    NULL,    -- created_at - datetime
    NULL     -- updated_at - datetime
    )
SELECT * FROM sales.orderDetail
SELECT * FROM production.inventory