USE MyStore
GO 
-------------------------------------------------------------------------------------------------------
---------------- Kiểm tra tồn kho mặt hàng ----------------
CREATE PROCEDURE SP_CheckInventory
	@product_id VARCHAR(20),
	@quantity INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;
	------------------------------------- Phần xử lý -------------------------------------
	------------------ Lấy số lượng hàng tồn kho hiện tại ------------------
	DECLARE @inStock INT
	SET @inStock=(SELECT in_stock FROM production.inventory WHERE product_id=@product_id)
	
	------------------ Kiểm tra số lượng hàng mua có đảm bảo số hàng tồn kho hay không? ------------------
	IF @quantity >@inStock
	BEGIN
	    ROLLBACK TRANSACTION;
		PRINT N'Không đủ số lượng trong kho'
		RETURN;
	END
	--------------------------------------------------------------------------------------
	IF @@ERROR <>0
	BEGIN
		ROLLBACK TRANSACTION
		PRINT N'Có lỗi khi Kiểm tra tồn kho mặt hàng'
		RETURN ;
    END
	COMMIT TRANSACTION;
END
GO

-------------------------------------------------------------------------------------------------------
---------------- Tính item_subtotal cho mặt hàng ----------------
CREATE FUNCTION FN_CalculateItemSubtotal (@amount INT,@price INT)
RETURNS INT
AS
BEGIN
    DECLARE @item_subtotal INT
	SET @item_subtotal=@amount*@price
	RETURN @item_subtotal
END
GO 
-------------------------------------------------------------------------------------------------------
---------------- Tính Subtotal cho đơn hàng ----------------
CREATE FUNCTION FN_CalculateSubtotalOrder (@subtotal_now INT,@item_subtotal INT)
RETURNS INT
AS
BEGIN
    DECLARE @new_subtotal INT
	SET @new_subtotal=@subtotal_now+@item_subtotal
	RETURN @new_subtotal
END
GO 
-------------------------------------------------------------------------------------------------------
---------------- Tính tồn kho mặt hàng ----------------
CREATE FUNCTION FN_CalculateInventory (@inStock_now INT,@quantity INT)
RETURNS INT
AS
BEGIN
    DECLARE @new_inStock INT
	SET @new_inStock=@inStock_now-@quantity
	RETURN @new_inStock
END
GO 

-------------------------------------------------------------------------------------------------------
---------------- Cập nhật tồn kho mặt hàng ----------------
CREATE PROCEDURE SP_UpdateInventory
	@product_id VARCHAR(20),
	@quantity INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;
	------------------------------------- Phần xử lý -------------------------------------
	------------------ Tìm tồn kho hiện tại của mặt hàng ------------------
	DECLARE @inStock_now INT
	SET @inStock_now=(SELECT in_stock FROM production.inventory WHERE product_id=@product_id)

	------------------ Tính tồn kho mới của mặt hàng ------------------
	DECLARE @new_inStock INT
	SET @new_inStock=dbo.FN_CalculateInventory(@inStock_now,@quantity)
	
	------------------ Cập nhật tồn kho mới cho mặt hàng ------------------
	UPDATE production.inventory
	SET in_stock=@new_inStock 
	WHERE product_id=@product_id
	--------------------------------------------------------------------------------------
	IF @@ERROR <>0
    BEGIN
        ROLLBACK TRANSACTION
	PRINT N'Có lỗi khi Cập nhật tồn kho mặt hàng'
	RETURN ;
    END
	COMMIT TRANSACTION;
END
GO

-------------------------------------------------------------------------------------------------------
---------------- Quy trình thêm mặt hàng mới ----------------
ALTER PROCEDURE SP_InsertItem
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@ins_amount INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;
	------------------------------------- Phần xử lý -------------------------------------
	------------------ Kiểm tra tồn kho của mặt hàng ------------------
	EXEC dbo.SP_CheckInventory @product_id = @product_id, -- varchar(20)
	                           @quantity = @ins_amount     -- int

	------------------ Lấy tên và giá bán của mặt hàng ------------------
	DECLARE @product_name NVARCHAR(255),@price INT
	SELECT @product_name=name,@price=sale_price FROM production.products WHERE id=@product_id

	------------------ Tính item_subtotal của mặt hàng ------------------
	DECLARE @item_subtotal INT
	SET @item_subtotal=dbo.FN_CalculateItemSubtotal(@ins_amount,@price)

	------------------ Cập nhật Tên và item_subtotal cho mặt hàng ------------------
	UPDATE sales.orderDetail
	SET product_name=@product_name,unit_price=@price,item_subtotal=@item_subtotal,created_at=GETDATE(),updated_at=GETDATE()
	WHERE order_id=@order_id AND product_id=@product_id

	------------------ Tính & Cập nhật subtotal của đơn hàng ------------------
	------ Tìm Subtotal hiện tại của đơn hàng ------
	DECLARE @subtotal_now INT
	SET @subtotal_now=(SELECT subtotal FROM sales.orders WHERE id=@order_id)
	------ Tính Subtotal mới của đơn hàng ------
	DECLARE @new_subtotal INT
	SET @new_subtotal=dbo.FN_CalculateSubtotalOrder(@subtotal_now,@item_subtotal)
	------ Cập nhật Subtotal mới cho đơn hàng ------
	UPDATE sales.orders
	SET subtotal=@new_subtotal,updated_at=GETDATE()
	WHERE id=@order_id

	------------------ Cập nhật tồn kho của mặt hàng ------------------
	EXEC dbo.SP_UpdateInventory @product_id = @product_id, -- varchar(20)
	                            @quantity = @ins_amount     -- int
	
	--------------------------------------------------------------------------------------
	IF @@ERROR <>0
    BEGIN
        ROLLBACK TRANSACTION
	PRINT N'Có lỗi khi Thêm mặt hàng mới'
	RETURN ;
    END
	COMMIT TRANSACTION;
END
GO

-------------------------------------------------------------------------------------------------------
---------------- Quy trình xóa mặt hàng ----------------
ALTER PROCEDURE SP_DeleteItem
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@del_amount INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;
	------------------------------------- Phần xử lý -------------------------------------
	------------------ Lấy giá bán của mặt hàng ------------------
	DECLARE @price INT
	SELECT @price=sale_price FROM production.products WHERE id=@product_id

	------------------ Tính item_subtotal bị xóa ------------------
	DECLARE @item_subtotal INT,@d_amount INT
	SET @d_amount=0-@del_amount
	SET @item_subtotal=dbo.FN_CalculateItemSubtotal(@d_amount,@price)

	------------------ Tính & Cập nhật subtotal của đơn hàng ------------------
	------ Tìm Subtotal hiện tại của đơn hàng ------
	DECLARE @subtotal_now INT
	SET @subtotal_now=(SELECT subtotal FROM sales.orders WHERE id=@order_id)
	------ Tính Subtotal mới của đơn hàng ------
	DECLARE @new_subtotal INT
	SET @new_subtotal=dbo.FN_CalculateSubtotalOrder(@subtotal_now,@item_subtotal)
	------ Cập nhật Subtotal mới cho đơn hàng ------
	UPDATE sales.orders
	SET subtotal=@new_subtotal,updated_at=GETDATE()
	WHERE id=@order_id

	------------------ Cập nhật tồn kho của mặt hàng ------------------
	EXEC dbo.SP_UpdateInventory @product_id = @product_id, -- varchar(20)
	                            @quantity = @d_amount     -- int
	
	--------------------------------------------------------------------------------------
	IF @@ERROR <>0
    BEGIN
        ROLLBACK TRANSACTION
	PRINT N'Có lỗi khi Xóa mặt hàng'
	RETURN ;
    END
	COMMIT TRANSACTION;
END
GO
-------------------------------------------------------------------------------------------------------
---------------- Quy trình Cập nhật số lượng mặt hàng ----------------
ALTER PROCEDURE SP_UpdateItem
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@ins_amount INT,
	@del_amount INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;
	------------------------------------- Phần xử lý -------------------------------------
	------------------ Kiểm tra tồn kho trước khi thay đổi số lượng mặt hàng ------------------
	------ Cộng tồn kho số lượng bị xóa ------
	DECLARE @d_amount INT
	SET @d_amount=0-@del_amount

	EXEC dbo.SP_UpdateInventory @product_id = @product_id, -- varchar(20)
	                            @quantity = @d_amount     -- int
	------ Kiểm tra tồn kho số lượng mới ------
	EXEC dbo.SP_CheckInventory @product_id = @product_id, -- varchar(20)
	                           @quantity = @ins_amount     -- int

	------------------ Lấy giá bán của mặt hàng ------------------
	DECLARE @price INT
	SELECT @price=sale_price FROM production.products WHERE id=@product_id

	------------------ Tính item_subtotal cũ ------------------
	DECLARE @old_item_subtotal INT
	SET @old_item_subtotal=dbo.FN_CalculateItemSubtotal(@d_amount,@price)

	------------------ Tính item_subtotal mới ------------------
	DECLARE @new_item_subtotal INT
	SET @new_item_subtotal=dbo.FN_CalculateItemSubtotal(@ins_amount,@price)

	------------------ Cập nhật item_subtotal mới ------------------
	UPDATE sales.orderDetail
	SET item_subtotal=@new_item_subtotal,updated_at=GETDATE()
	WHERE order_id=@order_id AND product_id=@product_id

	------------------ Tính & Cập nhật subtotal của đơn hàng ------------------
	------ Tìm Subtotal hiện tại của đơn hàng ------
	DECLARE @subtotal_now INT
	SET @subtotal_now=(SELECT subtotal FROM sales.orders WHERE id=@order_id)

	------ Tính chênh lệch giữa 2 subtotal ------
	DECLARE @subtotal_ INT
	SET @subtotal_=@new_item_subtotal+@old_item_subtotal
	------ Tính subtotal mới ------
	DECLARE @new_subtotal INT
	SET @new_subtotal=@subtotal_now+@subtotal_
	------ Cập nhật subtotal mới ------
	UPDATE sales.orders
	SET subtotal=@subtotal_now+@subtotal_,updated_at=GETDATE()
	WHERE id=@order_id

	------------------ Cập nhật tồn kho của mặt hàng ------------------
	EXEC dbo.SP_UpdateInventory @product_id = @product_id, -- varchar(20)
	                            @quantity = @ins_amount     -- int
	--------------------------------------------------------------------------------------
	IF @@ERROR <>0
    BEGIN
        ROLLBACK TRANSACTION
	PRINT N'Có lỗi khi Cập nhật tồn kho mặt hàng'
	RETURN ;
    END
	COMMIT TRANSACTION;
END
GO

-------------------------------------------------------------------------------------------------------------------------
---------------- Kiểm tra hành động ----------------
ALTER PROCEDURE SP_CheckActionType
	@action_type INT,
	@order_id VARCHAR(20),
	@product_id VARCHAR(20),
	@ins_amount INT,
	@del_amount INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;
	------------------------------------- Phần xử lý -------------------------------------
	IF @action_type=1
	BEGIN
		PRINT N'Thêm mặt hàng mới'
		EXEC dbo.SP_InsertItem @order_id = @order_id,   -- varchar(20)
		                       @product_id = @product_id, -- varchar(20)
		                       @ins_amount = @ins_amount   -- int
	
	END
	ELSE IF @action_type=2
	BEGIN
	    PRINT N'Xóa mặt hàng'
		EXEC dbo.SP_DeleteItem @order_id = @order_id,   -- varchar(20)
		                       @product_id = @product_id, -- varchar(20)
		                       @del_amount = @del_amount   -- int
		
	END
	ELSE IF @action_type=3
	BEGIN
	    PRINT N'Cập nhật số lượng mặt hàng'
		EXEC dbo.SP_UpdateItem @order_id = @order_id,   -- varchar(20)
		                       @product_id = @product_id, -- varchar(20)
		                       @ins_amount = @ins_amount,  -- int
		                       @del_amount = @del_amount   -- int
		
	END
	--------------------------------------------------------------------------------------
	IF @@ERROR <>0
    BEGIN
        ROLLBACK TRANSACTION
	PRINT N'Có lỗi khi kiểm tra hành động'
	RETURN ;
    END
	COMMIT TRANSACTION;
END
GO

-------------------------------------------------------------------------------------------------------------------------
---------------- Tọa trigger cho bảng orderDetail ----------------
CREATE TRIGGER TG_DefineActionType
ON sales.orderDetail
AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	------------------ ? ------------------
	DECLARE @action_type INT,@order_id VARCHAR(20),@product_id VARCHAR(20), @ins_amount INT=0,@del_amount INT =0
	------------------ ? ------------------
	IF EXISTS(SELECT product_id FROM Inserted)
	BEGIN
		------ Hành động Update ------
	    IF EXISTS(SELECT product_id FROM Deleted)
		BEGIN
		    SET @action_type=3
			SELECT	@del_amount=d.amount FROM Deleted d
			SELECT	@order_id=i.order_id, @product_id=i.product_id,@ins_amount=i.amount FROM Inserted i
		END
		------ Hành động Insert ------
		ELSE
        BEGIN
            SET @action_type=1
			SELECT	@order_id=i.order_id, @product_id=i.product_id,@ins_amount=i.amount FROM Inserted i
        END
	END
	------ Hành động Delete ------
	ELSE
	BEGIN
	    SET @action_type=2
		SELECT	@order_id=d.order_id, @product_id=d.product_id,@del_amount=d.amount FROM Deleted d
	END
	
	------------------ Chạy quy trình kiểm tra hành động ------------------
	EXEC dbo.SP_CheckActionType @action_type = @action_type, -- int
	                            @order_id = @order_id,   -- varchar(20)
	                            @product_id = @product_id, -- varchar(20)
	                            @ins_amount = @ins_amount,  -- int
	                            @del_amount = @del_amount   -- int
END
GO 
