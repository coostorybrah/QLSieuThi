GO
-- Procedure 8: Create Sale
CREATE OR ALTER PROCEDURE sp_CreateSale
    @EmployeeId INT,
    @CustomerId INT = NULL,
    @CustomerName NVARCHAR(100) = NULL,
    @CustomerPhone NVARCHAR(20) = NULL,
    @PaymentMethod NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate employee
    IF dbo.fn_IsEmployeeActive(@EmployeeId) = 0
       OR dbo.fn_HasPermission(@EmployeeId, 'CREATE_SALE') = 0
    BEGIN
        RAISERROR (N'Invalid employee or no permission.', 16, 1);
        RETURN;
    END

    -- 2. Insert empty sale (totals = 0, will be updated by trigger)
    INSERT INTO Sales (EmployeeId, CustomerId, CustomerName, CustomerPhone, TotalAmount, FinalAmount, PaymentMethod)
    VALUES (@EmployeeId, @CustomerId, @CustomerName, @CustomerPhone, 0, 0, @PaymentMethod);

    -- 3. Return created sale
    SELECT *
    FROM Sales
    WHERE SaleId = SCOPE_IDENTITY();
END
GO

-- Procedure 9: Add Sale Detail
CREATE OR ALTER PROCEDURE sp_AddSaleDetail
    @SaleId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Price DECIMAL(10,2);

    -- 1. Validate input
    IF @Quantity <= 0
    BEGIN
        RAISERROR (N'Quantity must be greater than 0.', 16, 1);
        RETURN;
    END

    -- 2. Get product price
    SELECT @Price = SellingPrice
    FROM Products
    WHERE ProductId = @ProductId AND Status = 1;

    IF @Price IS NULL
    BEGIN
        RAISERROR (N'Invalid or inactive product.', 16, 1);
        RETURN;
    END

    -- 3. Check if product already exists in sale
    IF EXISTS (
        SELECT 1 FROM SaleDetails
        WHERE SaleId = @SaleId AND ProductId = @ProductId
    )
    BEGIN
        -- Update quantity instead
        UPDATE SaleDetails
        SET Quantity = Quantity + @Quantity,
            TotalPrice = (Quantity + @Quantity) * UnitPrice
        WHERE SaleId = @SaleId AND ProductId = @ProductId;
    END
    ELSE
    BEGIN
        -- Insert new row
        INSERT INTO SaleDetails (SaleId, ProductId, Quantity, UnitPrice, TotalPrice)
        VALUES (@SaleId, @ProductId, @Quantity, @Price, @Quantity * @Price);
    END

    -- 4. Return updated sale details
    SELECT *
    FROM SaleDetails
    WHERE SaleId = @SaleId;
END
GO

-- Procedure 10: Update Sale Detail
CREATE OR ALTER PROCEDURE sp_UpdateSaleDetail
    @SaleId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Price DECIMAL(10,2);

    -- 1. Validate quantity
    IF @Quantity < 0
    BEGIN
        RAISERROR (N'Quantity cannot be negative.', 16, 1);
        RETURN;
    END

    -- 2. Remove if quantity = 0
    IF @Quantity = 0
    BEGIN
        DELETE FROM SaleDetails
        WHERE SaleId = @SaleId AND ProductId = @ProductId;

        RETURN;
    END

    -- 3. Get price
    SELECT @Price = SellingPrice
    FROM Products
    WHERE ProductId = @ProductId;

    -- 4. Update
    UPDATE SaleDetails
    SET Quantity = @Quantity,
        TotalPrice = @Quantity * @Price
    WHERE SaleId = @SaleId AND ProductId = @ProductId;

    -- 5. Return updated details
    SELECT *
    FROM SaleDetails
    WHERE SaleId = @SaleId;
END
GO

-- Procedure 11: Remove Sale Detail
CREATE OR ALTER PROCEDURE sp_RemoveSaleDetail
    @SaleId INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM SaleDetails
    WHERE SaleId = @SaleId AND ProductId = @ProductId;

    -- Return remaining items
    SELECT *
    FROM SaleDetails
    WHERE SaleId = @SaleId;
END
GO

-- Procedure 12: Get Sale Details
CREATE OR ALTER PROCEDURE sp_GetSaleDetails
    @SaleId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        sd.SaleDetailId,
        sd.ProductId,
        p.ProductName,
        sd.Quantity,
        sd.UnitPrice,
        sd.TotalPrice
    FROM SaleDetails sd
    JOIN Products p ON sd.ProductId = p.ProductId
    WHERE sd.SaleId = @SaleId;
END
GO

-- Procedure 13: Finalize Sale
CREATE OR ALTER PROCEDURE sp_FinalizeSale
    @SaleId INT,
    @Discount DECIMAL(10,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate sale exists
    IF NOT EXISTS (SELECT 1 FROM Sales WHERE SaleId = @SaleId)
    BEGIN
        RAISERROR (N'Sale not found.', 16, 1);
        RETURN;
    END

    -- 2. Apply discount (totals already maintained by trigger)
    UPDATE Sales
    SET Discount = @Discount,
        FinalAmount = TotalAmount - @Discount
    WHERE SaleId = @SaleId;

    -- 3. Return finalized sale
    SELECT *
    FROM Sales
    WHERE SaleId = @SaleId;
END
GO

-- Procedure 14: Report Invoice
CREATE OR ALTER PROCEDURE sp_ReportInvoice
    @SaleId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.SaleId,
        s.CreatedAt,

        e.FullName AS EmployeeName,

        s.CustomerName,
        s.CustomerPhone,

        p.ProductName,
        sd.Quantity,
        sd.UnitPrice,
        sd.TotalPrice,

        s.TotalAmount,
        s.Discount,
        s.FinalAmount,
        s.PaymentMethod

    FROM Sales s
    JOIN Employees e ON s.EmployeeId = e.EmployeeId
    JOIN SaleDetails sd ON s.SaleId = sd.SaleId
    JOIN Products p ON sd.ProductId = p.ProductId

    WHERE s.SaleId = @SaleId;
END
GO
