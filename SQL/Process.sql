USE MyStore
GO 
---------------------------------------------------
create FUNCTION FNC_CalculateItemSubtotal(@unit_price INT,@amount INT)
RETURNs INT
AS
BEGIN
    DECLARE @item_subtotal INT
	SET @item_subtotal=@unit_price*@amount
	RETURN @item_subtotal
END
GO 
-------------------------------------------------
create PROCEDURE SP_InsertItem
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@amount INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	----- Kiểm tra số lượng hàng tồn kho trước thi thêm vào đơn hàng
	DECLARE @inStock INT
	SELECT @inStock=i.inStock FROM production.inventory i
	WHERE i.productId=@product_id

	IF @amount>@inStock
	BEGIN
		----Nếu số lượng hàng tồn kho không đủ thì hủy bỏ giao dịch
		ROLLBACK TRANSACTION
		PRINT N'Số lượng hàng không đủ'
		RETURN;
    END
	
	----- Tính toán itemSubtotal và thêm sản phẩm vào đơn hàng
	DECLARE @product_name VARCHAR(255), @unit_price INT,@item_subtotal INT

	SELECT @product_name=productName, @unit_price=salePrice FROM production.products WHERE productId=@product_id
	SET @item_subtotal=@unit_price*@amount
	
	UPDATE sales.orderDetails
	SET productName=@product_name,unitPrice=@unit_price,itemSubtotal=@item_subtotal
	WHERE orderId=@order_id AND productId=@product_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi thêm sản phẩm'
		RETURN ;
    END
	------ Cập nhật subtotal của đơn hàng
	UPDATE sales.orders
	SET subtotal=subtotal+@item_subtotal
	WHERE orderId=@order_id

	
	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi cập nhật thành tiền'
		RETURN ;
    END

	----- Cập nhật tồn kho
	UPDATE production.inventory
	SET inStock=inStock-@amount
	WHERE productId=@product_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi cập nhật tồn kho sản phẩm'
		RETURN ;
    END

	--- Nếu không có lỗi thì lưu lại các thay đổi
	COMMIT TRANSACTION;
	PRINT N'Cập nhật đơn hàng thành công'
END
GO 
---------------------------------------------------
create PROCEDURE SP_DeleteItem
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@amount INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	-----Cập nhật tồn kho
	UPDATE production.inventory
	SET inStock=inStock+@amount
	WHERE productId=@product_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Cập nhật tồn kho thất bại'
		RETURN;
    END
	
	------ Cập nhật subtotal của đơn hàng
	DECLARE @item_subtotal INT, @unit_price INT
	SET @unit_price=(SELECT salePrice FROM production.products WHERE productId=@product_id)
	SET @item_subtotal=dbo.FNC_CalculateItemSubtotal(@unit_price,@amount)

	UPDATE sales.orders
	SET subtotal=subtotal-@item_subtotal
	WHERE orderId=@order_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Cập nhật gía trị đơn hàng thất bại'
		RETURN;
    END

	---- Ghi vào orderLogs
	DECLARE @mod_date DATETIME=GETDATE()
	DECLARE @mod_by VARCHAR(50)=SYSTEM_USER
	DECLARE @subtotal INT=(SELECT subtotal FROM sales.orders WHERE orderId=@order_id)

	COMMIT TRANSACTION;
	PRINT N'Xóa sản phẩm thành công'
END
GO
---------------------------------------------------
create  PROCEDURE SP_UpdateItem
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@newAmount INT,
	@oldAmount INT
AS
BEGIN
	SET NOCOUNT ON;
    BEGIN TRANSACTION
	---- Trả số lượng sản phẩm cũ về kho để cập nhật hàng còn lại trong kho
	UPDATE production.inventory
	SET inStock=inStock+@oldAmount
	WHERE productId=@product_id

	IF @@ERROR<>0
	BEGIN
	    ROLLBACK TRANSACTION
		PRINT 'Có lỗi khi cập nhật kho '
		RETURN;
	END

	----- Kiểm tra số lượng hàng tồn kho trước khi cập nhật số lượng mới
	DECLARE @inStock INT
	SELECT @inStock=i.inStock FROM production.inventory i
	WHERE i.productId=@product_id

	IF @newAmount>@inStock
	BEGIN
		----Nếu số lượng hàng tồn kho không đủ thì hủy bỏ giao dịch
		ROLLBACK TRANSACTION
		PRINT N'Số lượng hàng không đủ'
		RETURN;
    END

	------ Cập nhật item_subtotal của sản phẩm
	DECLARE @new_item_subtotal INT, @unit_price INT
	SELECT @unit_price=salePrice FROM production.products WHERE productId=@product_id
	SET @new_item_subtotal=dbo.FNC_CalculateItemSubtotal(@unit_price,@newAmount)

	UPDATE sales.orderDetails
	SET itemSubtotal=@new_item_subtotal WHERE productId=@product_id AND orderId=@order_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi cập nhật thành tiền sản phẩm'
		RETURN ;
    END
	----- Cập nhật subtotal của đơn hàng
	DECLARE @old_item_subtotal INT
	SET @old_item_subtotal=dbo.FNC_CalculateItemSubtotal(@unit_price,@oldAmount)

	UPDATE sales.orders
	SET subtotal=subtotal-@old_item_subtotal+@new_item_subtotal
	WHERE orderId=@order_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi cập nhật thành tiền'
		RETURN ;
    END
	----- Cập nhật tồn kho
	UPDATE production.inventory
	SET inStock=inStock-@newAmount
	WHERE productId=@product_id

	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi cập nhật tồn kho sản phẩm'
		RETURN ;
    END

	---- Ghi vào orderLogs
	DECLARE @mod_date DATETIME=GETDATE()
	DECLARE @mod_by VARCHAR(50)=SYSTEM_USER
	DECLARE @subtotal INT=(SELECT subtotal FROM sales.orders WHERE orderId=@order_id)

	--- Nếu không có lỗi thì lưu lại các thay đổi
	COMMIT TRANSACTION;
	PRINT N'Cập nhật số lượng sản phẩm thành công'
END
GO 
---------------------------------------------------
create PROCEDURE SP_CheckOrderAction
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@insAmount INT=0, 
	@delAmount INT=0,
	@action_type VARCHAR(3)
AS
BEGIN
	SET NOCOUNT ON;
    IF @action_type='ins'
	BEGIN
		EXEC dbo.SP_InsertItem @order_id = @order_id,   -- varchar(20)
		                       @product_id = @product_id, -- varchar(20)
		                       @amount = @insAmount       -- int
    END
	ELSE IF @action_type='del'
	BEGIN
		EXEC dbo.SP_DeleteItem @order_id = @order_id,    -- varchar(20)
		                       @product_id = @product_id,  -- varchar(20)
		                       @amount = @delAmount       -- int
    END
	ELSE 
	BEGIN
	    EXEC dbo.SP_UpdateItem @order_id = @order_id,   -- varchar(20)
	                           @product_id = @product_id, -- varchar(20)
	                           @newAmount = @insAmount,   -- int
	                           @oldAmount = @delAmount    -- int
	END
END
GO 
---------------------------------------------------
CREATE TRIGGER TG_UpdateOrderDetail
ON sales.orderDetails
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @order_id VARCHAR(20), @product_id VARCHAR(20), @product_name VARCHAR(20), @insAmount INT=0,@delAmount INT=0, @unit_price INT
	DECLARE @action_type VARCHAR(3)

	IF EXISTS(SELECT * FROM Inserted)
	BEGIN
		IF EXISTS(SELECT * FROM Deleted)
		BEGIN
			SELECT @order_id=i.orderId,@product_id=i.productId,@insAmount=i.amount FROM Inserted i
			SELECT @delAmount=d.amount FROM Deleted d
			SET @action_type='upd'
        END
		ELSE
        BEGIN
			SELECT @order_id=i.orderId,@product_id=i.productId,@insAmount=i.amount FROM Inserted i
            SET @action_type='ins'
        END
    END
	ELSE
    BEGIN
		SELECT @order_id=d.orderId,@product_id=d.productId,@delAmount=d.amount FROM Deleted d
        SET @action_type='del'
    END

	EXEC dbo.SP_CheckOrderAction @order_id = @order_id,     -- varchar(20)
	                             @product_id = @product_id,   -- varchar(20)
	                             @insAmount = @insAmount,     -- int
	                             @delAmount = @delAmount,    -- int
	                             @action_type =@action_type    -- varchar(3)
	
END
GO 