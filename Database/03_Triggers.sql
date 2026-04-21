--=================================================================================================================--
----------------------------------------------------- TRIGGERS ------------------------------------------------------
--=================================================================================================================--

GO
-- Trigger 1: Handle sale detail changes (insert, update, delete)
CREATE OR ALTER TRIGGER trg_SaleDetails_Stock
ON SaleDetails
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Calculate quantity changes (delta)
    DECLARE @Changes TABLE (
        ProductId INT,
        DeltaQty INT
    );

    INSERT INTO @Changes (ProductId, DeltaQty)
    SELECT 
        COALESCE(i.ProductId, d.ProductId),
        SUM(ISNULL(i.Quantity, 0) - ISNULL(d.Quantity, 0))
    FROM inserted i
    FULL JOIN deleted d ON i.ProductId = d.ProductId
    GROUP BY COALESCE(i.ProductId, d.ProductId);

    -- 2. Prevent negative stock (only when reducing stock)
    IF EXISTS (
        SELECT 1
        FROM @Changes c
        JOIN Products p ON p.ProductId = c.ProductId
        WHERE c.DeltaQty > 0
          AND p.StockQuantity < c.DeltaQty
    )
    BEGIN
        RAISERROR (N'Not enough stock.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Update stock based on delta
    UPDATE p
    SET p.StockQuantity = p.StockQuantity - c.DeltaQty
    FROM Products p
    JOIN @Changes c ON p.ProductId = c.ProductId
    WHERE c.DeltaQty <> 0;

    -- 4. Log inventory transactions (net change only)
    INSERT INTO InventoryTransactions (ProductId, Quantity, TransactionType, ReferenceType, ReferenceId)
    SELECT 
        c.ProductId,
        -c.DeltaQty,
        'Sale',
        'Sale',
        MIN(COALESCE(i.SaleId, d.SaleId))
    FROM @Changes c
    LEFT JOIN inserted i ON i.ProductId = c.ProductId
    LEFT JOIN deleted d ON d.ProductId = c.ProductId
    WHERE c.DeltaQty <> 0
    GROUP BY c.ProductId, c.DeltaQty;
END
GO
-- Trigger 2: Handle supplier order detail insert (increase stock + log)
CREATE OR ALTER TRIGGER trg_SupplierOrder_Stock
ON SupplierOrderDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Increase stock for received products
    UPDATE p
    SET p.StockQuantity = p.StockQuantity + i.TotalQty
    FROM Products p
    JOIN (
        SELECT ProductId, SUM(Quantity) AS TotalQty
        FROM inserted
        GROUP BY ProductId
    ) i ON p.ProductId = i.ProductId;

    -- 2. Log inventory transactions for import
    INSERT INTO InventoryTransactions (ProductId, Quantity, TransactionType, ReferenceType, ReferenceId)
    SELECT ProductId, SUM(Quantity), 'Import', 'SupplierOrder', MIN(SupplierOrderId)
    FROM inserted
    GROUP BY ProductId;
END
GO


-- Trigger 3: Update sale totals after sale detail changes
CREATE OR ALTER TRIGGER trg_UpdateSaleTotals
ON SaleDetails
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Recalculate total and final amounts for affected sales
    UPDATE s
    SET 
        s.TotalAmount = ISNULL((
            SELECT SUM(TotalPrice)
            FROM SaleDetails sd
            WHERE sd.SaleId = s.SaleId
        ), 0),

        s.FinalAmount = ISNULL((
            SELECT SUM(TotalPrice)
            FROM SaleDetails sd
            WHERE sd.SaleId = s.SaleId
        ), 0) - s.Discount

    FROM Sales s
    WHERE s.SaleId IN (
        SELECT SaleId FROM inserted
        UNION
        SELECT SaleId FROM deleted
    );
END
GO

-- Trigger 4: Audit employee updates
CREATE OR ALTER TRIGGER trg_Employees_Audit
ON Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ChangedBy INT = CAST(SESSION_CONTEXT(N'UserId') AS INT);

    -- Only log changed fields
    INSERT INTO EmployeeAuditLogs (EmployeeId, ChangedBy, FieldName, OldValue, NewValue)
    SELECT d.EmployeeId, @ChangedBy, v.FieldName, v.OldValue, v.NewValue
    FROM inserted i
    JOIN deleted d ON i.EmployeeId = d.EmployeeId
    CROSS APPLY (
        VALUES
        ('FullName', CAST(d.FullName AS NVARCHAR(255)), CAST(i.FullName AS NVARCHAR(255))),
        ('Phone',    CAST(d.Phone    AS NVARCHAR(255)), CAST(i.Phone    AS NVARCHAR(255))),
        ('Email',    CAST(d.Email    AS NVARCHAR(255)), CAST(i.Email    AS NVARCHAR(255))),
        ('Address',  CAST(d.Address  AS NVARCHAR(255)), CAST(i.Address  AS NVARCHAR(255))),
        ('Username', CAST(d.Username AS NVARCHAR(255)), CAST(i.Username AS NVARCHAR(255))),
        ('Status',   CAST(d.Status   AS NVARCHAR(255)), CAST(i.Status   AS NVARCHAR(255)))
    ) v(FieldName, OldValue, NewValue)
    WHERE ISNULL(v.OldValue, '') <> ISNULL(v.NewValue, '');

    -- Handle Role change separately (convert ID -> Name)
    INSERT INTO EmployeeAuditLogs (EmployeeId, ChangedBy, FieldName, OldValue, NewValue)
    SELECT 
        d.EmployeeId,
        @ChangedBy,
        'Role',
        rOld.RoleName,
        rNew.RoleName
    FROM inserted i
    JOIN deleted d ON i.EmployeeId = d.EmployeeId
    LEFT JOIN Roles rOld ON d.RoleId = rOld.RoleId
    LEFT JOIN Roles rNew ON i.RoleId = rNew.RoleId
    WHERE ISNULL(d.RoleId, -1) <> ISNULL(i.RoleId, -1);
END
GO

-- Trigger 5: Update supplier order totals
CREATE OR ALTER TRIGGER trg_UpdateSupplierOrderTotal
ON SupplierOrderDetails
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE so
    SET so.TotalAmount = ISNULL((
        SELECT SUM(TotalPrice)
        FROM SupplierOrderDetails sod
        WHERE sod.SupplierOrderId = so.SupplierOrderId
    ), 0)
    FROM SupplierOrders so
    WHERE so.SupplierOrderId IN (
        SELECT SupplierOrderId FROM inserted
        UNION
        SELECT SupplierOrderId FROM deleted
    );
END
GO
