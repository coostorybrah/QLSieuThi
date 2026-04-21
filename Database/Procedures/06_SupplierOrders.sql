GO
-- Procedure 22: Create Supplier Order
CREATE OR ALTER PROCEDURE sp_CreateSupplierOrder
    @SupplierId INT,
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate employee
    IF dbo.fn_IsEmployeeActive(@EmployeeId) = 0
    BEGIN
        RAISERROR (N'Invalid employee.', 16, 1);
        RETURN;
    END

    -- 2. Validate supplier
    IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId AND Status = 1)
    BEGIN
        RAISERROR (N'Invalid supplier.', 16, 1);
        RETURN;
    END

    -- 3. Insert order (default Pending)
    INSERT INTO SupplierOrders (SupplierId, EmployeeId, TotalAmount, Status)
    VALUES (@SupplierId, @EmployeeId, 0, 'Pending');

    -- 4. Return created order
    SELECT *
    FROM SupplierOrders
    WHERE SupplierOrderId = SCOPE_IDENTITY();
END
GO

-- Procedure 23: Add Supplier Order Detail
CREATE OR ALTER PROCEDURE sp_AddSupplierOrderDetail
    @SupplierOrderId INT,
    @ProductId INT,
    @Quantity INT,
    @CostPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate quantity
    IF @Quantity <= 0
    BEGIN
        RAISERROR (N'Quantity must be greater than 0.', 16, 1);
        RETURN;
    END

    -- 2. Validate order status
    IF NOT EXISTS (
        SELECT 1 FROM SupplierOrders 
        WHERE SupplierOrderId = @SupplierOrderId AND Status = 'Pending'
    )
    BEGIN
        RAISERROR (N'Order not found or not editable.', 16, 1);
        RETURN;
    END

    -- 3. Insert detail (trigger will increase stock)
    INSERT INTO SupplierOrderDetails (SupplierOrderId, ProductId, Quantity, CostPrice, TotalPrice)
    VALUES (@SupplierOrderId, @ProductId, @Quantity, @CostPrice, @Quantity * @CostPrice);

    -- 4. Return updated details
    SELECT *
    FROM SupplierOrderDetails
    WHERE SupplierOrderId = @SupplierOrderId;
END
GO

-- Procedure 24: Update Supplier Order Detail
CREATE OR ALTER PROCEDURE sp_UpdateSupplierOrderDetail
    @SupplierOrderId INT,
    @ProductId INT,
    @Quantity INT,
    @CostPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate order
    IF NOT EXISTS (
        SELECT 1 FROM SupplierOrders 
        WHERE SupplierOrderId = @SupplierOrderId AND Status = 'Pending'
    )
    BEGIN
        RAISERROR (N'Order not editable.', 16, 1);
        RETURN;
    END

    -- 2. If quantity = 0 → delete
    IF @Quantity = 0
    BEGIN
        DELETE FROM SupplierOrderDetails
        WHERE SupplierOrderId = @SupplierOrderId AND ProductId = @ProductId;

        RETURN;
    END

    -- 3. Update
    UPDATE SupplierOrderDetails
    SET 
        Quantity = @Quantity,
        CostPrice = @CostPrice,
        TotalPrice = @Quantity * @CostPrice
    WHERE SupplierOrderId = @SupplierOrderId AND ProductId = @ProductId;

    -- 4. Return updated
    SELECT *
    FROM SupplierOrderDetails
    WHERE SupplierOrderId = @SupplierOrderId;
END
GO

-- Procedure 25: Remove Supplier Order Detail
CREATE OR ALTER PROCEDURE sp_RemoveSupplierOrderDetail
    @SupplierOrderId INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM SupplierOrderDetails
    WHERE SupplierOrderId = @SupplierOrderId AND ProductId = @ProductId;

    SELECT *
    FROM SupplierOrderDetails
    WHERE SupplierOrderId = @SupplierOrderId;
END
GO

-- Procedure 26: Get Supplier Order Details
CREATE OR ALTER PROCEDURE sp_GetSupplierOrderDetails
    @SupplierOrderId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        sod.SupplierDetailId,
        sod.ProductId,
        p.ProductName,
        sod.Quantity,
        sod.CostPrice,
        sod.TotalPrice
    FROM SupplierOrderDetails sod
    JOIN Products p ON sod.ProductId = p.ProductId
    WHERE sod.SupplierOrderId = @SupplierOrderId;
END
GO

-- Procedure 27: Update Supplier Order Status
CREATE OR ALTER PROCEDURE sp_UpdateSupplierOrderStatus
    @SupplierOrderId INT,
    @Status NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate status
    IF @Status NOT IN ('Pending','Completed','Cancelled')
    BEGIN
        RAISERROR (N'Invalid status.', 16, 1);
        RETURN;
    END

    -- 2. Update
    UPDATE SupplierOrders
    SET Status = @Status
    WHERE SupplierOrderId = @SupplierOrderId;

    -- 3. Return updated order
    SELECT *
    FROM SupplierOrders
    WHERE SupplierOrderId = @SupplierOrderId;
END
GO

-- Procedure 28: List Supplier Orders
CREATE OR ALTER PROCEDURE sp_ListSupplierOrders
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        so.SupplierOrderId,
        s.SupplierName,
        e.FullName AS EmployeeName,
        so.TotalAmount,
        so.Status,
        so.CreatedAt
    FROM SupplierOrders so
    JOIN Suppliers s ON so.SupplierId = s.SupplierId
    JOIN Employees e ON so.EmployeeId = e.EmployeeId
    ORDER BY so.CreatedAt DESC;
END
GO
