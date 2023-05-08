USE MyProject
GO 
--------------------------------------
ALTER PROCEDURE SP_GenerateProductId
	@id INT
AS 
BEGIN
    DECLARE @productId VARCHAR(20)
	SET @productId='00'+CAST(@id AS VARCHAR(5))
	
	UPDATE production.productInfor
	SET productId=@productId WHERE id=@id

	INSERT INTO production.inventory
	(
	    productId,
	    inStock
	)
	VALUES
	(   @productId,    -- productId - varchar(20)
	    DEFAULT -- inStock - int
	    )
END
GO 
--------------------------------------
CREATE TRIGGER TG_GenerateProductID
ON production.productInfor
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @id INT
	SET @id=(SELECT i.id FROM Inserted i)
	EXEC dbo.SP_GenerateProductId @id = @id -- int
END
GO 
--------------------------------------
CREATE PROCEDURE SP_GenerateOrderId
	@id INT,
	@store_id VARCHAR(20)
AS
BEGIN
    DECLARE @orderId VARCHAR(20)
	SET @orderId=@store_id+'000'+CAST(@id AS VARCHAR(5))
	UPDATE sales.orders 
	SET orderId=@orderId WHERE id=@id
END
GO 
--------------------------------------
CREATE TRIGGER TG_GenerateOrderId
ON sales.orders
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @order_id VARCHAR(20)
	DECLARE @id INT
	DECLARE @store_id VARCHAR(20)
	SELECT @id=i.id,@store_id=i.storeId FROM Inserted AS i

	EXEC dbo.SP_GenerateOrderId @id = @id,       -- int
	                            @store_id = @store_id -- varchar(20)
END
GO 
