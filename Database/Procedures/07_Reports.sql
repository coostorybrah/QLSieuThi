GO
-- Procedure 29: Report Sales By Date
CREATE OR ALTER PROCEDURE sp_Report_SalesByDate
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.SaleId,
        s.CreatedAt,

        e.FullName AS EmployeeName,

        s.CustomerName,
        s.CustomerPhone,

        s.TotalAmount,
        s.Discount,
        s.FinalAmount,
        s.PaymentMethod

    FROM Sales s
    JOIN Employees e ON s.EmployeeId = e.EmployeeId
    WHERE s.CreatedAt BETWEEN @FromDate AND @ToDate
    ORDER BY s.CreatedAt DESC;
END
GO

-- Procedure 30: Report Sale Details
CREATE OR ALTER PROCEDURE sp_Report_SaleDetails
    @SaleId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.SaleId,
        s.CreatedAt,

        p.ProductName,
        sd.Quantity,
        sd.UnitPrice,
        sd.TotalPrice

    FROM Sales s
    JOIN SaleDetails sd ON s.SaleId = sd.SaleId
    JOIN Products p ON sd.ProductId = p.ProductId
    WHERE s.SaleId = @SaleId;
END
GO

-- Procedure 31: Report Supplier Orders
CREATE OR ALTER PROCEDURE sp_Report_SupplierOrders
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        so.SupplierOrderId,
        so.CreatedAt,

        s.SupplierName,
        e.FullName AS EmployeeName,

        so.TotalAmount,
        so.Status

    FROM SupplierOrders so
    JOIN Suppliers s ON so.SupplierId = s.SupplierId
    JOIN Employees e ON so.EmployeeId = e.EmployeeId
    WHERE so.CreatedAt BETWEEN @FromDate AND @ToDate
    ORDER BY so.CreatedAt DESC;
END
GO

-- Procedure 32: Report Supplier Order Details
CREATE OR ALTER PROCEDURE sp_Report_SupplierOrderDetails
    @SupplierOrderId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        so.SupplierOrderId,
        so.CreatedAt,

        p.ProductName,
        sod.Quantity,
        sod.CostPrice,
        sod.TotalPrice

    FROM SupplierOrders so
    JOIN SupplierOrderDetails sod ON so.SupplierOrderId = sod.SupplierOrderId
    JOIN Products p ON sod.ProductId = p.ProductId
    WHERE so.SupplierOrderId = @SupplierOrderId;
END
GO

-- Procedure 33: Report Inventory
CREATE OR ALTER PROCEDURE sp_Report_Inventory
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.ProductId,
        p.ProductName,
        p.Barcode,
        s.SupplierName,
        p.StockQuantity,
        p.Unit,
        p.SellingPrice,
        p.Status
    FROM Products p
    JOIN Suppliers s ON p.SupplierId = s.SupplierId
    ORDER BY p.StockQuantity ASC;
END
GO

-- Procedure 34: Report Low Stock
CREATE OR ALTER PROCEDURE sp_Report_LowStock
    @Threshold INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ProductId,
        ProductName,
        Barcode,
        StockQuantity
    FROM Products
    WHERE StockQuantity <= @Threshold
    ORDER BY StockQuantity ASC;
END
GO

-- Procedure 35: Report Top Selling Products
CREATE OR ALTER PROCEDURE sp_Report_TopSellingProducts
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.ProductId,
        p.ProductName,
        SUM(sd.Quantity) AS TotalSold,
        SUM(sd.TotalPrice) AS Revenue
    FROM SaleDetails sd
    JOIN Sales s ON sd.SaleId = s.SaleId
    JOIN Products p ON sd.ProductId = p.ProductId
    WHERE s.CreatedAt BETWEEN @FromDate AND @ToDate
    GROUP BY p.ProductId, p.ProductName
    ORDER BY TotalSold DESC;
END
GO
