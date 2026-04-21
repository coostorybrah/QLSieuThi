GO
-- Procedure 15: List Products
CREATE OR ALTER PROCEDURE sp_ListProducts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.ProductId,
        p.ProductName,
        p.Barcode,
        s.SupplierName,
        p.CostPrice,
        p.SellingPrice,
        p.StockQuantity,
        p.Unit,
        p.Status,
        p.CreatedAt
    FROM Products p
    JOIN Suppliers s ON p.SupplierId = s.SupplierId
    ORDER BY p.ProductName;
END
GO

-- Procedure 16: Add Product
CREATE OR ALTER PROCEDURE sp_AddProduct
    @ProductName NVARCHAR(150),
    @Barcode NVARCHAR(50),
    @SupplierId INT,
    @CostPrice DECIMAL(10,2),
    @SellingPrice DECIMAL(10,2),
    @Unit NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate
    IF @ProductName IS NULL OR LTRIM(RTRIM(@ProductName)) = ''
    BEGIN
        RAISERROR (N'Product name is required.', 16, 1);
        RETURN;
    END

    IF @SellingPrice < @CostPrice
    BEGIN
        RAISERROR (N'Selling price must be >= cost price.', 16, 1);
        RETURN;
    END

    -- 2. Prevent duplicate barcode
    IF @Barcode IS NOT NULL AND EXISTS (
        SELECT 1 FROM Products WHERE Barcode = @Barcode
    )
    BEGIN
        RAISERROR (N'Barcode already exists.', 16, 1);
        RETURN;
    END

    -- 3. Insert
    INSERT INTO Products (ProductName, Barcode, SupplierId, CostPrice, SellingPrice, Unit)
    VALUES (@ProductName, @Barcode, @SupplierId, @CostPrice, @SellingPrice, @Unit);

    -- 4. Return created product
    SELECT *
    FROM dbo.fn_GetProductById(SCOPE_IDENTITY());
END
GO

-- Procedure 17: Update Product
CREATE OR ALTER PROCEDURE sp_UpdateProduct
    @ProductId INT,

    @ProductName NVARCHAR(150) = NULL,
    @Barcode NVARCHAR(50) = NULL,
    @SupplierId INT = NULL,
    @CostPrice DECIMAL(10,2) = NULL,
    @SellingPrice DECIMAL(10,2) = NULL,
    @Unit NVARCHAR(50) = NULL,
    @Status BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Check exists
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductId = @ProductId)
    BEGIN
        RAISERROR (N'Product not found.', 16, 1);
        RETURN;
    END

    -- 2. Barcode uniqueness
    IF @Barcode IS NOT NULL AND EXISTS (
        SELECT 1 FROM Products 
        WHERE Barcode = @Barcode AND ProductId <> @ProductId
    )
    BEGIN
        RAISERROR (N'Barcode already exists.', 16, 1);
        RETURN;
    END

    -- 3. Price validation
    IF @CostPrice IS NOT NULL AND @SellingPrice IS NOT NULL
       AND @SellingPrice < @CostPrice
    BEGIN
        RAISERROR (N'Selling price must be >= cost price.', 16, 1);
        RETURN;
    END

    -- 4. PATCH update
    UPDATE Products
    SET
        ProductName = CASE WHEN @ProductName IS NOT NULL THEN @ProductName ELSE ProductName END,
        Barcode     = CASE WHEN @Barcode IS NOT NULL THEN @Barcode ELSE Barcode END,
        SupplierId  = CASE WHEN @SupplierId IS NOT NULL THEN @SupplierId ELSE SupplierId END,
        CostPrice   = CASE WHEN @CostPrice IS NOT NULL THEN @CostPrice ELSE CostPrice END,
        SellingPrice= CASE WHEN @SellingPrice IS NOT NULL THEN @SellingPrice ELSE SellingPrice END,
        Unit        = CASE WHEN @Unit IS NOT NULL THEN @Unit ELSE Unit END,
        Status      = CASE WHEN @Status IS NOT NULL THEN @Status ELSE Status END
    WHERE ProductId = @ProductId;

    -- 5. Return updated product
    SELECT *
    FROM dbo.fn_GetProductById(@ProductId);
END
GO

-- Procedure 18: Get Product By Barcode
CREATE OR ALTER PROCEDURE sp_GetProductByBarcode
    @Barcode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.ProductId,
        p.ProductName,
        p.Barcode,
        p.SellingPrice,
        p.StockQuantity,
        p.Unit,
        p.Status
    FROM Products p
    WHERE p.Barcode = @Barcode
      AND p.Status = 1;
END
GO

-- Procedure 19: Search Products
CREATE OR ALTER PROCEDURE sp_SearchProducts
    @Keyword NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.ProductId,
        p.ProductName,
        p.Barcode,
        s.SupplierName,
        p.SellingPrice,
        p.StockQuantity,
        p.Status
    FROM Products p
    JOIN Suppliers s ON p.SupplierId = s.SupplierId
    WHERE 
        p.ProductName LIKE '%' + @Keyword + '%'
        OR p.Barcode LIKE '%' + @Keyword + '%'
    ORDER BY p.ProductName;
END
GO

-- Procedure 20: Assign Product Category
CREATE OR ALTER PROCEDURE sp_AssignProductCategory
    @ProductId INT,
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM ProductCategories
        WHERE ProductId = @ProductId AND CategoryId = @CategoryId
    )
    BEGIN
        INSERT INTO ProductCategories (ProductId, CategoryId)
        VALUES (@ProductId, @CategoryId);
    END
END
GO

-- Procedure 21: Remove Product Category
CREATE OR ALTER PROCEDURE sp_RemoveProductCategory
    @ProductId INT,
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ProductCategories
    WHERE ProductId = @ProductId AND CategoryId = @CategoryId;
END
GO
