USE master
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'QLSieuThiDB')
BEGIN
    ALTER DATABASE QLSieuThiDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLSieuThiDB;
END
GO

CREATE DATABASE QLSieuThiDB
GO

USE QLSieuThiDB
GO

--================================================================================================================--
------------------------------------------------------ TABLES ------------------------------------------------------
--================================================================================================================--

-- EMPLOYEE ROLES (admin, cashier, manager)
CREATE TABLE Roles (
    RoleId INT IDENTITY PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

-- EMPLOYEES
CREATE TABLE Employees (
    EmployeeId INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100) UNIQUE,
    Address NVARCHAR(255),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password VARBINARY(64) NOT NULL,
    RoleId INT NOT NULL,
    Status BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);

-- EMPLOYEE AUDIT LOG
CREATE TABLE EmployeeAuditLogs (
    AuditId INT IDENTITY PRIMARY KEY,
    EmployeeId INT NOT NULL,
    ChangedBy INT NULL,

    FieldName NVARCHAR(50),
    OldValue NVARCHAR(255),
    NewValue NVARCHAR(255),

    ChangedAt DATETIME DEFAULT GETDATE()
);
GO

-- CUSTOMERS
CREATE TABLE Customers (
    CustomerId INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(100) NULL, -- optional info
    Phone NVARCHAR(20) NOT NULL UNIQUE,
    Email NVARCHAR(100) NULL UNIQUE, -- optional info
    Address NVARCHAR(255) NULL, -- optional info
    LoyaltyPoints INT DEFAULT 0,
    Status BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- SUPPLIERS
CREATE TABLE Suppliers (
    SupplierId INT IDENTITY PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    Status BIT DEFAULT 1
);

-- CATEGORIES
CREATE TABLE Categories (
    CategoryId INT IDENTITY PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255)
);

-- PRODUCTS
CREATE TABLE Products (
    ProductId INT IDENTITY PRIMARY KEY,
    ProductName NVARCHAR(150) NOT NULL,
    Barcode NVARCHAR(50) UNIQUE,
    SupplierId INT NOT NULL,
    CostPrice DECIMAL(10,2) NOT NULL,
    SellingPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    Unit NVARCHAR(50),
    Status BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)
);

-- PRODUCT-CATEGORY
CREATE TABLE ProductCategories (
    ProductId INT NOT NULL,
    CategoryId INT NOT NULL,
    PRIMARY KEY (ProductId, CategoryId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);

-- SALES
CREATE TABLE Sales (
    SaleId INT IDENTITY PRIMARY KEY,
    EmployeeId INT NOT NULL,
    CustomerId INT NULL,
    CustomerName NVARCHAR(100),
    CustomerPhone NVARCHAR(20),
    TotalAmount DECIMAL(12,2) NOT NULL,
    Discount DECIMAL(10,2) DEFAULT 0,
    FinalAmount DECIMAL(12,2) NOT NULL,
    PaymentMethod NVARCHAR(50),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

-- SALE DETAILS
CREATE TABLE SaleDetails (
    SaleDetailId INT IDENTITY PRIMARY KEY,
    SaleId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (SaleId) REFERENCES Sales(SaleId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- SUPPLIER ORDERS
CREATE TABLE SupplierOrders (
    SupplierOrderId INT IDENTITY PRIMARY KEY,
    SupplierId INT NOT NULL,
    EmployeeId INT NOT NULL,
    TotalAmount DECIMAL(12,2),
    Status NVARCHAR(20) CHECK (Status IN ('Pending','Completed','Cancelled')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
);

-- SUPPLIER ORDER DETAILS
CREATE TABLE SupplierOrderDetails (
    SupplierDetailId INT IDENTITY PRIMARY KEY,
    SupplierOrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    CostPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (SupplierOrderId) REFERENCES SupplierOrders(SupplierOrderId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- INVENTORY TRANSACTIONS
CREATE TABLE InventoryTransactions (
    TransactionId INT IDENTITY PRIMARY KEY,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    TransactionType NVARCHAR(50),
    ReferenceType NVARCHAR(50),
    ReferenceId INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);
GO

--=================================================================================================================--
------------------------------------------------------ INDEXES ------------------------------------------------------
--=================================================================================================================--

-- Employees
CREATE INDEX idx_employee_role ON Employees(RoleId);

-- Products
CREATE INDEX idx_product_supplier ON Products(SupplierId);

-- ProductCategories
CREATE INDEX idx_productcategories_category ON ProductCategories(CategoryId);

-- Sales
CREATE INDEX idx_sales_employee ON Sales(EmployeeId);
CREATE INDEX idx_sales_customer ON Sales(CustomerId);

-- SaleDetails
CREATE INDEX idx_saledetails_sale ON SaleDetails(SaleId);
CREATE INDEX idx_saledetails_product ON SaleDetails(ProductId);

-- SupplierOrders
CREATE INDEX idx_supplierorders_supplier ON SupplierOrders(SupplierId);
CREATE INDEX idx_supplierorders_employee ON SupplierOrders(EmployeeId);

-- SupplierOrderDetails
CREATE INDEX idx_supplierorderdetails_order ON SupplierOrderDetails(SupplierOrderId);
CREATE INDEX idx_supplierorderdetails_product ON SupplierOrderDetails(ProductId);

GO

--=================================================================================================================--
----------------------------------------------------- FUNCTIONS -----------------------------------------------------
--=================================================================================================================--

GO

-- Function 0: Hash Password
CREATE OR ALTER FUNCTION fn_HashPassword(@Password NVARCHAR(255))
RETURNS VARBINARY(64)
AS
BEGIN
    RETURN HASHBYTES('SHA2_256', @Password);
END
GO

-- Function 1: Get Employee By ID
CREATE OR ALTER FUNCTION fn_GetEmployeeById(@EmployeeId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        e.EmployeeId,
        e.FullName,
        e.Phone,
        e.Email,
        e.Address,
        e.Username,
        e.Status,
        e.CreatedAt,
        r.RoleName
    FROM Employees e
    JOIN Roles r ON e.RoleId = r.RoleId
    WHERE e.EmployeeId = @EmployeeId
);
GO


-- Function 2: Get Customer By ID
CREATE OR ALTER FUNCTION fn_GetCustomerById(@CustomerId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Customers
    WHERE CustomerId = @CustomerId
);
GO


-- Function 3: Get Role Name by ID
CREATE OR ALTER FUNCTION fn_GetUserRole(@UserId INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Role NVARCHAR(50);

    SELECT @Role = r.RoleName
    FROM Employees e
    JOIN Roles r ON e.RoleId = r.RoleId
    WHERE e.EmployeeId = @UserId;

    RETURN @Role;
END
GO


-- Function 4: Generic Role Check
CREATE OR ALTER FUNCTION fn_HasRole
(
    @UserId INT,
    @RoleName NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM Employees e
        JOIN Roles r ON e.RoleId = r.RoleId
        WHERE e.EmployeeId = @UserId
          AND r.RoleName = @RoleName
    )
        SET @Result = 1;

    RETURN @Result;
END
GO


-- Function 5: Check Login Validity
CREATE OR ALTER FUNCTION fn_IsValidLogin
(
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM Employees
        WHERE Username = @Username
          AND Password = dbo.fn_HashPassword(@Password)
          AND Status = 1
    )
        SET @Result = 1;

    RETURN @Result;
END
GO


-- Function 6: Check if Employee is Active
CREATE OR ALTER FUNCTION fn_IsEmployeeActive(@UserId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM Employees
        WHERE EmployeeId = @UserId
          AND Status = 1
    )
        SET @Result = 1;

    RETURN @Result;
END
GO


-- Function 7: Get Employee ID By Username
CREATE OR ALTER FUNCTION fn_GetEmployeeIdByUsername(@Username NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @Id INT;

    SELECT @Id = EmployeeId
    FROM Employees
    WHERE Username = @Username;

    RETURN @Id;
END
GO


-- Function 8: Permission Check
CREATE OR ALTER FUNCTION fn_HasPermission
(
    @UserId INT,
    @Permission NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Role NVARCHAR(50);
    DECLARE @Result BIT = 0;

    SELECT @Role = r.RoleName
    FROM Employees e
    JOIN Roles r ON e.RoleId = r.RoleId
    WHERE e.EmployeeId = @UserId;

    -- Centralized permission logic
    SET @Result =
        CASE 
            WHEN @Permission = 'MANAGE_PRODUCTS' 
                 AND @Role IN ('Admin', 'Manager') THEN 1

            WHEN @Permission = 'CREATE_SALE' 
                 AND @Role IN ('Admin', 'Cashier') THEN 1

            WHEN @Permission = 'MANAGE_EMPLOYEES' 
                 AND @Role = 'Admin' THEN 1

            ELSE 0
        END;

    RETURN @Result;
END
GO

-- Function 9: Get role id by name
CREATE OR ALTER FUNCTION fn_GetRoleIdByName(@RoleName NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @RoleId INT;

    SELECT @RoleId = RoleId
    FROM Roles
    WHERE RoleName = @RoleName;

    RETURN @RoleId;
END
GO

-- Function 10: Check username availability
CREATE OR ALTER FUNCTION fn_IsUsernameTaken(@Username NVARCHAR(50))
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF EXISTS (
        SELECT 1 FROM Employees WHERE Username = @Username
    )
        SET @Result = 1;

    RETURN @Result;
END
GO

-- Function 11: Check permission for role creating
CREATE OR ALTER FUNCTION fn_CanCreateRole
(
    @CurrentRole NVARCHAR(50),
    @NewRole NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF @CurrentRole = 'Admin'
        SET @Result = 1;
    ELSE IF @CurrentRole = 'Manager' AND @NewRole = 'Cashier'
        SET @Result = 1;

    RETURN @Result;
END
GO

-- Function 12: Get Product With Details
CREATE OR ALTER FUNCTION fn_GetProductById(@ProductId INT)
RETURNS TABLE
AS
RETURN
(
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
    WHERE p.ProductId = @ProductId
);
GO

-- Function 13: Get Product Categories
CREATE OR ALTER FUNCTION fn_GetProductCategories(@ProductId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT c.CategoryName
    FROM ProductCategories pc
    JOIN Categories c ON pc.CategoryId = c.CategoryId
    WHERE pc.ProductId = @ProductId
);
GO

-- Function 14: Get Category Id by name
CREATE OR ALTER FUNCTION fn_GetCategoryIdByName(@CategoryName NVARCHAR(100))
RETURNS INT
AS
BEGIN
    DECLARE @Id INT;

    SELECT @Id = CategoryId
    FROM Categories
    WHERE CategoryName = @CategoryName;

    RETURN @Id;
END
GO

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

-- Procedure 1: Login Employee
CREATE OR ALTER PROCEDURE sp_LoginEmployee
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId INT;

    -- Validate login
    IF dbo.fn_IsValidLogin(@Username, @Password) = 0
    BEGIN
        RAISERROR (N'Invalid username or password.', 16, 1);
        RETURN;
    END

    -- Get user ID
    SET @UserId = dbo.fn_GetEmployeeIdByUsername(@Username);

    -- Return full employee info using function
    SELECT *
    FROM dbo.fn_GetEmployeeById(@UserId);
END
GO

GO
-- Procedure 2: Get Employee
CREATE OR ALTER PROCEDURE sp_GetEmployee
    @CurrentUserId INT,
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Permission check
    IF dbo.fn_HasPermission(@CurrentUserId, 'MANAGE_EMPLOYEES') = 0
    BEGIN
        RAISERROR (N'You do not have permission.', 16, 1);
        RETURN;
    END

    SELECT *
    FROM dbo.fn_GetEmployeeById(@EmployeeId);
END
GO

-- Procedure 4: Add Employee
CREATE OR ALTER PROCEDURE sp_AddEmployee
    @CurrentUserId INT,

    @FullName NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),

    @Username NVARCHAR(50),
    @Password NVARCHAR(255),

    @NewRoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentRole NVARCHAR(50);
    DECLARE @NewRoleId INT;

    -- 1. Validate current user
    IF dbo.fn_IsEmployeeActive(@CurrentUserId) = 0
    BEGIN
        RAISERROR (N'Invalid or inactive user.', 16, 1);
        RETURN;
    END

    -- 2. Get current role
    SET @CurrentRole = dbo.fn_GetUserRole(@CurrentUserId);

    -- 3. Validate new role
    SET @NewRoleId = dbo.fn_GetRoleIdByName(@NewRoleName);

    IF @NewRoleId IS NULL
    BEGIN
        RAISERROR (N'Invalid role name.', 16, 1);
        RETURN;
    END

    -- 4. Permission check
    IF dbo.fn_CanCreateRole(@CurrentRole, @NewRoleName) = 0
    BEGIN
        RAISERROR (N'You do not have permission to create this role.', 16, 1);
        RETURN;
    END

    -- 5. Username validation
    IF dbo.fn_IsUsernameTaken(@Username) = 1
    BEGIN
        RAISERROR (N'Username already exists.', 16, 1);
        RETURN;
    END

    -- 6. Password quality check
    IF LEN(@Password) < 4
    BEGIN
        RAISERROR (N'Password too short.', 16, 1);
        RETURN;
    END

    -- 7. Insert employee
    INSERT INTO Employees (FullName, Phone, Email, Address, RoleId, Username, Password)
    VALUES (@FullName, @Phone, @Email, @Address, @NewRoleId, @Username, dbo.fn_HashPassword(@Password));

    -- 8. Return created employee
    SELECT *
    FROM dbo.fn_GetEmployeeById(SCOPE_IDENTITY());
END
GO

-- Procedure 6: Update Employee (PATCH style)
CREATE OR ALTER PROCEDURE sp_UpdateEmployee
    @CurrentUserId INT,
    @EmployeeId INT,

    @FullName NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL,

    @Username NVARCHAR(50) = NULL,
    @Password NVARCHAR(255) = NULL,

    @NewRoleName NVARCHAR(50) = NULL,
    @Status BIT = NULL
AS
BEGIN
    EXEC sp_set_session_context @key = N'UserId', @value = @CurrentUserId;
    SET NOCOUNT ON;

    DECLARE @CurrentRole NVARCHAR(50),
            @NewRoleId INT = NULL;

    -- 1. No-op check
    IF @FullName IS NULL AND @Phone IS NULL AND @Email IS NULL AND @Address IS NULL
       AND @Username IS NULL AND @Password IS NULL
       AND @NewRoleName IS NULL AND @Status IS NULL
    BEGIN
        RAISERROR (N'No fields to update.', 16, 1);
        RETURN;
    END

    -- 2. Validate user + permission
    IF dbo.fn_IsEmployeeActive(@CurrentUserId) = 0
       OR dbo.fn_HasPermission(@CurrentUserId, 'MANAGE_EMPLOYEES') = 0
    BEGIN
        RAISERROR (N'Invalid user or insufficient permission.', 16, 1);
        RETURN;
    END

    -- 3. Check employee exists
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId)
    BEGIN
        RAISERROR (N'Employee not found.', 16, 1);
        RETURN;
    END

    -- 4. Prevent self role/status change
    IF @EmployeeId = @CurrentUserId
       AND (@NewRoleName IS NOT NULL OR @Status IS NOT NULL)
    BEGIN
        RAISERROR (N'Cannot change your own role or status.', 16, 1);
        RETURN;
    END

    -- 5. Get role
    SET @CurrentRole = dbo.fn_GetUserRole(@CurrentUserId);

    -- 6. Role validation
    IF @NewRoleName IS NOT NULL
    BEGIN
        SET @NewRoleId = dbo.fn_GetRoleIdByName(@NewRoleName);

        IF @NewRoleId IS NULL
           OR dbo.fn_CanCreateRole(@CurrentRole, @NewRoleName) = 0
        BEGIN
            RAISERROR (N'Invalid or unauthorized role.', 16, 1);
            RETURN;
        END
    END

    -- 7. Uniqueness checks
    IF (@Username IS NOT NULL AND EXISTS (
            SELECT 1 FROM Employees WHERE Username = @Username AND EmployeeId <> @EmployeeId
        ))
       OR (@Email IS NOT NULL AND EXISTS (
            SELECT 1 FROM Employees WHERE Email = @Email AND EmployeeId <> @EmployeeId
        ))
    BEGIN
        RAISERROR (N'Username or email already exists.', 16, 1);
        RETURN;
    END

    -- 8. Password validation
    IF @Password IS NOT NULL AND LEN(@Password) < 4
    BEGIN
        RAISERROR (N'Password too short.', 16, 1);
        RETURN;
    END

    -- 9. PATCH update (NULL-safe)
    UPDATE Employees
    SET
        FullName = CASE WHEN @FullName IS NOT NULL THEN @FullName ELSE FullName END,
        Phone    = CASE WHEN @Phone IS NOT NULL THEN @Phone ELSE Phone END,
        Email    = CASE WHEN @Email IS NOT NULL THEN @Email ELSE Email END,
        Address  = CASE WHEN @Address IS NOT NULL THEN @Address ELSE Address END,
        Username = CASE WHEN @Username IS NOT NULL THEN @Username ELSE Username END,
        Password = CASE 
                        WHEN @Password IS NOT NULL 
                        THEN dbo.fn_HashPassword(@Password)
                        ELSE Password
                   END,
        RoleId   = CASE WHEN @NewRoleId IS NOT NULL THEN @NewRoleId ELSE RoleId END,
        Status   = CASE WHEN @Status IS NOT NULL THEN @Status ELSE Status END
    WHERE EmployeeId = @EmployeeId;

    -- 10. Return result
    SELECT * FROM dbo.fn_GetEmployeeById(@EmployeeId);
END
GO

-- Procedure 7: Get Employee Audit History
CREATE OR ALTER PROCEDURE sp_GetEmployeeAuditHistory
    @EmployeeId INT,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate employee exists
    IF NOT EXISTS (
        SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        RAISERROR (N'Employee not found.', 16, 1);
        RETURN;
    END

    -- 2. Return audit history
    SELECT 
        a.AuditId,
        a.EmployeeId,

        e.FullName AS EmployeeName,

        a.FieldName,
        a.OldValue,
        a.NewValue,

        a.ChangedBy,
        cb.FullName AS ChangedByName,

        a.ChangedAt
    FROM EmployeeAuditLogs a
    LEFT JOIN Employees e ON a.EmployeeId = e.EmployeeId
    LEFT JOIN Employees cb ON a.ChangedBy = cb.EmployeeId
    WHERE a.EmployeeId = @EmployeeId
      AND (@FromDate IS NULL OR a.ChangedAt >= @FromDate)
      AND (@ToDate IS NULL OR a.ChangedAt <= @ToDate)
    ORDER BY a.ChangedAt DESC;
END
GO

GO
-- Procedure 3: Get Customer
CREATE OR ALTER PROCEDURE sp_GetCustomer
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.fn_GetCustomerById(@CustomerId);
END
GO

USE QLSieuThiDB
GO

-- -----------------------------------------------------------------------
-- sp_GetAllCustomers
--   Returns every customer ordered by CustomerId.
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GetAllCustomers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CustomerId,
        FullName,
        Phone,
        Email,
        Address,
        LoyaltyPoints,
        Status,
        CreatedAt
    FROM Customers
    ORDER BY CustomerId;
END
GO


-- -----------------------------------------------------------------------
-- sp_UpdateCustomer  (PATCH update — only supplied fields are changed)
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_UpdateCustomer
    @CustomerId INT,
    @FullName   NVARCHAR(100),
    @Phone      NVARCHAR(20),
    @Email      NVARCHAR(100),
    @Address    NVARCHAR(255),
    @Status     BIT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Guard: customer must exist
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerId = @CustomerId)
    BEGIN
        RAISERROR (N'Customer not found.', 16, 1);
        RETURN;
    END

    -- 2. No-op guard
    IF @FullName IS NULL AND @Phone IS NULL AND @Email IS NULL
       AND @Address IS NULL AND @Status IS NULL
    BEGIN
        RAISERROR (N'No fields to update.', 16, 1);
        RETURN;
    END

    -- 3. Duplicate phone check (exclude self)
    IF @Phone IS NOT NULL AND EXISTS (
        SELECT 1 FROM Customers
        WHERE Phone = @Phone AND CustomerId <> @CustomerId
    )
    BEGIN
        RAISERROR (N'Phone number already used by another customer.', 16, 1);
        RETURN;
    END

    -- 4. Duplicate email check (exclude self)
    IF @Email IS NOT NULL AND EXISTS (
        SELECT 1 FROM Customers
        WHERE Email = @Email AND CustomerId <> @CustomerId
    )
    BEGIN
        RAISERROR (N'Email address already used by another customer.', 16, 1);
        RETURN;
    END

    -- 5. PATCH update
    UPDATE Customers
    SET
        FullName = CASE WHEN @FullName IS NOT NULL THEN @FullName ELSE FullName END,
        Phone    = CASE WHEN @Phone    IS NOT NULL THEN @Phone    ELSE Phone    END,
        Email    = CASE WHEN @Email    IS NOT NULL THEN @Email    ELSE Email    END,
        Address  = CASE WHEN @Address  IS NOT NULL THEN @Address  ELSE Address  END,
        Status   = CASE WHEN @Status   IS NOT NULL THEN @Status   ELSE Status   END
    WHERE CustomerId = @CustomerId;

    -- 6. Return updated row
    SELECT
        CustomerId,
        FullName,
        Phone,
        Email,
        Address,
        LoyaltyPoints,
        Status,
        CreatedAt
    FROM Customers
    WHERE CustomerId = @CustomerId;
END
GO


-- -----------------------------------------------------------------------
-- sp_DeleteCustomer  (soft delete — sets Status = 0)
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_DeleteCustomer
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Guard: must exist
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerId = @CustomerId)
    BEGIN
        RAISERROR (N'Customer not found.', 16, 1);
        RETURN;
    END

    -- 2. Guard: already inactive
    IF EXISTS (SELECT 1 FROM Customers WHERE CustomerId = @CustomerId AND Status = 0)
    BEGIN
        RAISERROR (N'Customer is already inactive.', 16, 1);
        RETURN;
    END

    -- 3. Soft delete
    UPDATE Customers
    SET Status = 0
    WHERE CustomerId = @CustomerId;

    -- 4. Return deactivated row
    SELECT
        CustomerId,
        FullName,
        Phone,
        Email,
        Address,
        LoyaltyPoints,
        Status,
        CreatedAt
    FROM Customers
    WHERE CustomerId = @CustomerId;
END
GO


-- -----------------------------------------------------------------------
-- sp_SearchCustomersByStatus
--   Returns customers filtered by Status (1 = active, 0 = inactive).
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_SearchCustomersByStatus
    @Status BIT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CustomerId,
        FullName,
        Phone,
        Email,
        Address,
        LoyaltyPoints,
        Status,
        CreatedAt
    FROM Customers
    WHERE Status = @Status
    ORDER BY CustomerId;
END
GO

-- Procedure 5: Add Customer
CREATE OR ALTER PROCEDURE sp_AddCustomer
    @Phone NVARCHAR(20),

    @FullName NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Basic validation (optional but useful)
    IF @Phone IS NULL OR LTRIM(RTRIM(@Phone)) = ''
    BEGIN
        RAISERROR (N'Phone number is required.', 16, 1);
        RETURN;
    END

    -- 2. Prevent duplicate phone (since you indexed it)
    IF EXISTS (
        SELECT 1 FROM Customers WHERE Phone = @Phone
    )
    BEGIN
        RAISERROR (N'Phone number already exists.', 16, 1);
        RETURN;
    END

    -- 3. Insert customer
    INSERT INTO Customers (Phone, FullName, Email, Address)
    VALUES (@Phone, @FullName, @Email, @Address);

    -- 4. Return created customer
    SELECT *
    FROM dbo.fn_GetCustomerById(SCOPE_IDENTITY());
END
GO

GO
-- Procedure 15: List Products
CREATE OR ALTER PROCEDURE sp_ListProduct
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.ProductId,
        p.ProductName,
        p.Barcode,
        s.SupplierName,
        s.SupplierId,
        p.CostPrice,
        p.SellingPrice,
        p.StockQuantity,
        p.Unit,
        p.Status,
        p.CreatedAt
    FROM Products p
    JOIN Suppliers s ON p.SupplierId = s.SupplierId
    ORDER BY p.ProductId;
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
CREATE OR ALTER PROCEDURE sp_Report_Invoice
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

--==========================================================================--
--  SUPPLIER CRUD STORED PROCEDURES
--  Table  : Suppliers (SupplierId, SupplierName, Phone, Email, Address, Status)
--  Pattern: matches existing project conventions (PATCH update, RAISERROR,
--           SET NOCOUNT ON, returns affected row after every write)
--==========================================================================--


-- -----------------------------------------------------------------------
-- sp_GetAllSuppliers
--   Returns every supplier.
--   Pass @ActiveOnly = 1 to filter out deactivated suppliers (Status = 0).
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GetAllSuppliers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SupplierId,
        SupplierName,
        Phone,
        Email,
        Address,
        Status
    FROM Suppliers
    ORDER BY SupplierId;
END
GO


CREATE OR ALTER PROCEDURE sp_GetSupplierById
    @SupplierId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Guard: must exist
    IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId)
    BEGIN
        RAISERROR (N'Supplier not found.', 16, 1);
        RETURN;
    END

    SELECT
        SupplierId,
        SupplierName,
        Phone,
        Email,
        Address,
        Status
    FROM Suppliers
    WHERE SupplierId = @SupplierId;
END
GO


CREATE OR ALTER PROCEDURE sp_SearchSuppliersbystatus
    @Status bit
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SupplierId,
        SupplierName,
        Phone,
        Email,
        Address,
        Status
    FROM Suppliers
    WHERE
        @Status = Status
    ORDER BY SupplierId;
END
GO


CREATE OR ALTER PROCEDURE sp_AddSupplier
    @SupplierName NVARCHAR(100),
    @Phone        NVARCHAR(20)  = NULL,
    @Email        NVARCHAR(100) = NULL,
    @Address      NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Required field
    IF @SupplierName IS NULL OR LTRIM(RTRIM(@SupplierName)) = ''
    BEGIN
        RAISERROR (N'Supplier name is required.', 16, 1);
        RETURN;
    END

    -- 2. Duplicate phone check
    IF @Phone IS NOT NULL AND EXISTS (
        SELECT 1 FROM Suppliers WHERE Phone = @Phone
    )
    BEGIN
        RAISERROR (N'Phone number already exists.', 16, 1);
        RETURN;
    END

    -- 3. Duplicate email check
    IF @Email IS NOT NULL AND EXISTS (
        SELECT 1 FROM Suppliers WHERE Email = @Email
    )
    BEGIN
        RAISERROR (N'Email address already exists.', 16, 1);
        RETURN;
    END

    -- 4. Insert
    INSERT INTO Suppliers (SupplierName, Phone, Email, Address)
    VALUES (@SupplierName, @Phone, @Email, @Address);

    -- 5. Return created row
    SELECT
        SupplierId,
        SupplierName,
        Phone,
        Email,
        Address,
        Status
    FROM Suppliers
    WHERE SupplierId = SCOPE_IDENTITY();
END
GO


CREATE OR ALTER PROCEDURE sp_UpdateSupplier
    @SupplierId   INT,
    @SupplierName NVARCHAR(100) = NULL,
    @Phone        NVARCHAR(20)  = NULL,
    @Email        NVARCHAR(100) = NULL,
    @Address      NVARCHAR(255) = NULL,
    @Status       BIT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Guard: supplier must exist
    IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId)
    BEGIN
        RAISERROR (N'Supplier not found.', 16, 1);
        RETURN;
    END

    -- 2. No-op guard
    IF @SupplierName IS NULL AND @Phone IS NULL AND @Email IS NULL
       AND @Address IS NULL AND @Status IS NULL
    BEGIN
        RAISERROR (N'No fields to update.', 16, 1);
        RETURN;
    END

    -- 3. Duplicate phone check (exclude self)
    IF @Phone IS NOT NULL AND EXISTS (
        SELECT 1 FROM Suppliers
        WHERE Phone = @Phone AND SupplierId <> @SupplierId
    )
    BEGIN
        RAISERROR (N'Phone number already used by another supplier.', 16, 1);
        RETURN;
    END

    -- 4. Duplicate email check (exclude self)
    IF @Email IS NOT NULL AND EXISTS (
        SELECT 1 FROM Suppliers
        WHERE Email = @Email AND SupplierId <> @SupplierId
    )
    BEGIN
        RAISERROR (N'Email address already used by another supplier.', 16, 1);
        RETURN;
    END

    -- 5. Cannot deactivate a supplier that still has active products
    IF @Status = 0 AND EXISTS (
        SELECT 1 FROM Products
        WHERE SupplierId = @SupplierId AND Status = 1
    )
    BEGIN
        RAISERROR (N'Cannot deactivate a supplier that has active products.', 16, 1);
        RETURN;
    END

    -- 6. PATCH update (NULL-safe, same pattern as sp_UpdateEmployee)
    UPDATE Suppliers
    SET
        SupplierName = CASE WHEN @SupplierName IS NOT NULL THEN @SupplierName ELSE SupplierName END,
        Phone        = CASE WHEN @Phone        IS NOT NULL THEN @Phone        ELSE Phone        END,
        Email        = CASE WHEN @Email        IS NOT NULL THEN @Email        ELSE Email        END,
        Address      = CASE WHEN @Address      IS NOT NULL THEN @Address      ELSE Address      END,
        Status       = CASE WHEN @Status       IS NOT NULL THEN @Status       ELSE Status       END
    WHERE SupplierId = @SupplierId;

    -- 7. Return updated row
    SELECT
        SupplierId,
        SupplierName,
        Phone,
        Email,
        Address,
        Status
    FROM Suppliers
    WHERE SupplierId = @SupplierId;
END
GO


-- -----------------------------------------------------------------------
-- sp_DeleteSupplier   (soft delete — sets Status = 0)
--   Hard-deleting a supplier would break FK references in Products and
--   SupplierOrders, so we deactivate instead, matching the Status pattern
--   used across Employees, Products, and Customers.
--   Returns the deactivated supplier row so the form can refresh the grid.
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_DeleteSupplier
    @SupplierId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Guard: must exist
    IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId)
    BEGIN
        RAISERROR (N'Supplier not found.', 16, 1);
        RETURN;
    END

    -- 2. Guard: already inactive
    IF EXISTS (SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId AND Status = 0)
    BEGIN
        RAISERROR (N'Supplier is already inactive.', 16, 1);
        RETURN;
    END

    -- 3. Block delete if supplier has active products
    IF EXISTS (
        SELECT 1 FROM Products
        WHERE SupplierId = @SupplierId AND Status = 1
    )
    BEGIN
        RAISERROR (N'Cannot delete a supplier that has active products. Deactivate the products first.', 16, 1);
        RETURN;
    END

    -- 4. Soft delete
    UPDATE Suppliers
    SET Status = 0
    WHERE SupplierId = @SupplierId;

    -- 5. Return deactivated row
    SELECT
        SupplierId,
        SupplierName,
        Phone,
        Email,
        Address,
        Status
    FROM Suppliers
    WHERE SupplierId = @SupplierId;
END
GO


-- -----------------------------------------------------------------------
-- sp_RestoreSupplier   (undo soft delete — sets Status = 1)
--   Mirrors sp_DeleteSupplier; lets the WinForm "Restore" button reactivate
--   a previously deactivated supplier without re-entering all data.
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_RestoreSupplier
    @SupplierId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Guard: must exist
    IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId)
    BEGIN
        RAISERROR (N'Supplier not found.', 16, 1);
        RETURN;
    END

    -- 2. Guard: already active
    IF EXISTS (SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId AND Status = 1)
    BEGIN
        RAISERROR (N'Supplier is already active.', 16, 1);
        RETURN;
    END

    -- 3. Reactivate
    UPDATE Suppliers
    SET Status = 1
    WHERE SupplierId = @SupplierId;

    -- 4. Return restored row
    SELECT
        SupplierId,
        SupplierName,
        Phone,
        Email,
        Address,
        Status
    FROM Suppliers
    WHERE SupplierId = @SupplierId;
END
GO


--==========================================================================--
--  QUICK SMOKE TESTS  (comment out before deploying to production)
--==========================================================================--
/*
-- 1. List all (includes the 2 seeded suppliers)
EXEC sp_GetAllSuppliers;

-- 2. Active only
EXEC sp_GetAllSuppliers @ActiveOnly = 1;

-- 3. Get by ID
EXEC sp_GetSupplierById @SupplierId = 1;

-- 4. Search
EXEC sp_SearchSuppliers @Keyword = N'Coca';

-- 5. Add new
EXEC sp_AddSupplier
    @SupplierName = N'New Fresh Supplier',
    @Phone        = '0999000001',
    @Email        = 'newfresh@example.com',
    @Address      = N'123 Test Street, Ha Noi';

-- 6. Update (PATCH — only name and address change)
EXEC sp_UpdateSupplier
    @SupplierId   = 3,
    @SupplierName = N'New Fresh Supplier (Updated)',
    @Address      = N'456 New Road, Ha Noi';

-- 7. Soft delete
EXEC sp_DeleteSupplier @SupplierId = 3;

-- 8. Restore
EXEC sp_RestoreSupplier @SupplierId = 3;

-- 9. Error cases
EXEC sp_AddSupplier @SupplierName = '';                   -- required field
EXEC sp_AddSupplier @SupplierName = N'X', @Phone = '0988888888'; -- dup phone
EXEC sp_GetSupplierById @SupplierId = 9999;               -- not found
EXEC sp_UpdateSupplier  @SupplierId = 1;                  -- no fields
*/
-- -----------------------------------------------------------------------
-- sp_GetAllEmployees
--   Returns all employees with their role name.
--   Used to populate the DataGridView and ComboBox on FrmEmployees.
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GetAllEmployees
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.FullName,
        e.Phone,
        e.Email,
        e.Address,
        e.Username,
        r.RoleName,
        e.Status,
        e.CreatedAt
    FROM Employees e
    JOIN Roles r ON e.RoleId = r.RoleId
    ORDER BY e.EmployeeId;
END
GO


-- -----------------------------------------------------------------------
-- sp_GetAllRoles
--   Returns every role — used to populate the Role ComboBox on FrmEmployees.
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GetAllRoles
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RoleId, RoleName
    FROM Roles
    ORDER BY RoleId;
END
GO


-- -----------------------------------------------------------------------
-- sp_DeleteEmployee  (soft delete — sets Status = 0)
--   Mirrors the pattern of sp_DeleteSupplier / sp_DeleteCustomer.
--   Requires the calling user to have MANAGE_EMPLOYEES permission
--   and prevents an admin from deactivating themselves.
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_DeleteEmployee
    @CurrentUserId INT,
    @EmployeeId    INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Permission check
    IF dbo.fn_IsEmployeeActive(@CurrentUserId) = 0
       OR dbo.fn_HasPermission(@CurrentUserId, 'MANAGE_EMPLOYEES') = 0
    BEGIN
        RAISERROR (N'You do not have permission to delete employees.', 16, 1);
        RETURN;
    END

    -- 2. Guard: target must exist
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId)
    BEGIN
        RAISERROR (N'Employee not found.', 16, 1);
        RETURN;
    END

    -- 3. Prevent self-deactivation
    IF @EmployeeId = @CurrentUserId
    BEGIN
        RAISERROR (N'You cannot deactivate your own account.', 16, 1);
        RETURN;
    END

    -- 4. Guard: already inactive
    IF EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId AND Status = 0)
    BEGIN
        RAISERROR (N'Employee is already inactive.', 16, 1);
        RETURN;
    END

    -- 5. Soft delete
    UPDATE Employees
    SET Status = 0
    WHERE EmployeeId = @EmployeeId;

    -- 6. Return deactivated row
    SELECT * FROM dbo.fn_GetEmployeeById(@EmployeeId);
END
GO


-- -----------------------------------------------------------------------
-- sp_SearchEmployeesByStatus
--   Returns employees filtered by Status (1 = active, 0 = inactive).
-- -----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_SearchEmployeesByStatus
    @Status BIT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeId,
        e.FullName,
        e.Phone,
        e.Email,
        e.Address,
        e.Username,
        r.RoleName,
        e.Status,
        e.CreatedAt
    FROM Employees e
    JOIN Roles r ON e.RoleId = r.RoleId
    WHERE e.Status = @Status
    ORDER BY e.EmployeeId;
END
GO

GO
-- Procedure 2: Get Employee
CREATE OR ALTER PROCEDURE sp_GetEmployee
    @CurrentUserId INT,
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Permission check
    IF dbo.fn_HasPermission(@CurrentUserId, 'MANAGE_EMPLOYEES') = 0
    BEGIN
        RAISERROR (N'You do not have permission.', 16, 1);
        RETURN;
    END

    SELECT *
    FROM dbo.fn_GetEmployeeById(@EmployeeId);
END
GO

-- Procedure 4: Add Employee
CREATE OR ALTER PROCEDURE sp_AddEmployee
    @CurrentUserId INT,

    @FullName NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),

    @Username NVARCHAR(50),
    @Password NVARCHAR(255),

    @NewRoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentRole NVARCHAR(50);
    DECLARE @NewRoleId INT;

    -- 1. Validate current user
    IF dbo.fn_IsEmployeeActive(@CurrentUserId) = 0
    BEGIN
        RAISERROR (N'Invalid or inactive user.', 16, 1);
        RETURN;
    END

    -- 2. Get current role
    SET @CurrentRole = dbo.fn_GetUserRole(@CurrentUserId);

    -- 3. Validate new role
    SET @NewRoleId = dbo.fn_GetRoleIdByName(@NewRoleName);

    IF @NewRoleId IS NULL
    BEGIN
        RAISERROR (N'Invalid role name.', 16, 1);
        RETURN;
    END

    -- 4. Permission check
    IF dbo.fn_CanCreateRole(@CurrentRole, @NewRoleName) = 0
    BEGIN
        RAISERROR (N'You do not have permission to create this role.', 16, 1);
        RETURN;
    END

    -- 5. Username validation
    IF dbo.fn_IsUsernameTaken(@Username) = 1
    BEGIN
        RAISERROR (N'Username already exists.', 16, 1);
        RETURN;
    END

    -- 6. Password quality check
    IF LEN(@Password) < 4
    BEGIN
        RAISERROR (N'Password too short.', 16, 1);
        RETURN;
    END

    -- 7. Insert employee
    INSERT INTO Employees (FullName, Phone, Email, Address, RoleId, Username, Password)
    VALUES (@FullName, @Phone, @Email, @Address, @NewRoleId, @Username, dbo.fn_HashPassword(@Password));

    -- 8. Return created employee
    SELECT *
    FROM dbo.fn_GetEmployeeById(SCOPE_IDENTITY());
END
GO

-- Procedure 6: Update Employee (PATCH style)
CREATE OR ALTER PROCEDURE sp_UpdateEmployee
    @CurrentUserId INT,
    @EmployeeId INT,

    @FullName NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL,

    @Username NVARCHAR(50) = NULL,
    @Password NVARCHAR(255) = NULL,

    @NewRoleName NVARCHAR(50) = NULL,
    @Status BIT = NULL
AS
BEGIN
    EXEC sp_set_session_context @key = N'UserId', @value = @CurrentUserId;
    SET NOCOUNT ON;

    DECLARE @CurrentRole NVARCHAR(50),
            @NewRoleId INT = NULL;

    -- 1. No-op check
    IF @FullName IS NULL AND @Phone IS NULL AND @Email IS NULL AND @Address IS NULL
       AND @Username IS NULL AND @Password IS NULL
       AND @NewRoleName IS NULL AND @Status IS NULL
    BEGIN
        RAISERROR (N'No fields to update.', 16, 1);
        RETURN;
    END

    -- 2. Validate user + permission
    IF dbo.fn_IsEmployeeActive(@CurrentUserId) = 0
       OR dbo.fn_HasPermission(@CurrentUserId, 'MANAGE_EMPLOYEES') = 0
    BEGIN
        RAISERROR (N'Invalid user or insufficient permission.', 16, 1);
        RETURN;
    END

    -- 3. Check employee exists
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId)
    BEGIN
        RAISERROR (N'Employee not found.', 16, 1);
        RETURN;
    END

    -- 4. Prevent self role/status change
    IF @EmployeeId = @CurrentUserId
       AND (@NewRoleName IS NOT NULL OR @Status IS NOT NULL)
    BEGIN
        RAISERROR (N'Cannot change your own role or status.', 16, 1);
        RETURN;
    END

    -- 5. Get role
    SET @CurrentRole = dbo.fn_GetUserRole(@CurrentUserId);

    -- 6. Role validation
    IF @NewRoleName IS NOT NULL
    BEGIN
        SET @NewRoleId = dbo.fn_GetRoleIdByName(@NewRoleName);

        IF @NewRoleId IS NULL
           OR dbo.fn_CanCreateRole(@CurrentRole, @NewRoleName) = 0
        BEGIN
            RAISERROR (N'Invalid or unauthorized role.', 16, 1);
            RETURN;
        END
    END

    -- 7. Uniqueness checks
    IF (@Username IS NOT NULL AND EXISTS (
            SELECT 1 FROM Employees WHERE Username = @Username AND EmployeeId <> @EmployeeId
        ))
       OR (@Email IS NOT NULL AND EXISTS (
            SELECT 1 FROM Employees WHERE Email = @Email AND EmployeeId <> @EmployeeId
        ))
    BEGIN
        RAISERROR (N'Username or email already exists.', 16, 1);
        RETURN;
    END

    -- 8. Password validation
    IF @Password IS NOT NULL AND LEN(@Password) < 4
    BEGIN
        RAISERROR (N'Password too short.', 16, 1);
        RETURN;
    END

    -- 9. PATCH update (NULL-safe)
    UPDATE Employees
    SET
        FullName = CASE WHEN @FullName IS NOT NULL THEN @FullName ELSE FullName END,
        Phone    = CASE WHEN @Phone IS NOT NULL THEN @Phone ELSE Phone END,
        Email    = CASE WHEN @Email IS NOT NULL THEN @Email ELSE Email END,
        Address  = CASE WHEN @Address IS NOT NULL THEN @Address ELSE Address END,
        Username = CASE WHEN @Username IS NOT NULL THEN @Username ELSE Username END,
        Password = CASE 
                        WHEN @Password IS NOT NULL 
                        THEN dbo.fn_HashPassword(@Password)
                        ELSE Password
                   END,
        RoleId   = CASE WHEN @NewRoleId IS NOT NULL THEN @NewRoleId ELSE RoleId END,
        Status   = CASE WHEN @Status IS NOT NULL THEN @Status ELSE Status END
    WHERE EmployeeId = @EmployeeId;

    -- 10. Return result
    SELECT * FROM dbo.fn_GetEmployeeById(@EmployeeId);
END
GO

-- Procedure 7: Get Employee Audit History
CREATE OR ALTER PROCEDURE sp_GetEmployeeAuditHistory
    @EmployeeId INT,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate employee exists
    IF NOT EXISTS (
        SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        RAISERROR (N'Employee not found.', 16, 1);
        RETURN;
    END

    -- 2. Return audit history
    SELECT 
        a.AuditId,
        a.EmployeeId,

        e.FullName AS EmployeeName,

        a.FieldName,
        a.OldValue,
        a.NewValue,

        a.ChangedBy,
        cb.FullName AS ChangedByName,

        a.ChangedAt
    FROM EmployeeAuditLogs a
    LEFT JOIN Employees e ON a.EmployeeId = e.EmployeeId
    LEFT JOIN Employees cb ON a.ChangedBy = cb.EmployeeId
    WHERE a.EmployeeId = @EmployeeId
      AND (@FromDate IS NULL OR a.ChangedAt >= @FromDate)
      AND (@ToDate IS NULL OR a.ChangedAt <= @ToDate)
    ORDER BY a.ChangedAt DESC;
END
GO


-- Procedure: Update own profile (full name, username, phone, email, address)
CREATE OR ALTER PROCEDURE sp_UpdateMyProfile
    @EmployeeId INT,

    @FullName NVARCHAR(100) = NULL,
    @Username NVARCHAR(50) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @FullName = NULLIF(LTRIM(RTRIM(@FullName)), '');
    SET @Username = NULLIF(LTRIM(RTRIM(@Username)), '');
    SET @Phone    = NULLIF(LTRIM(RTRIM(@Phone)), '');
    SET @Email    = NULLIF(LTRIM(RTRIM(@Email)), '');
    SET @Address  = NULLIF(LTRIM(RTRIM(@Address)), '');

    -- 1. No-op check
    IF @FullName IS NULL 
       AND @Username IS NULL 
       AND @Phone IS NULL
       AND @Email IS NULL 
       AND @Address IS NULL
    BEGIN
        RAISERROR (N'No fields to update.', 16, 1);
        RETURN;
    END

    -- 2. Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId)
    BEGIN
        RAISERROR (N'Employee not found.', 16, 1);
        RETURN;
    END

    -- 3. Username uniqueness
    IF @Username IS NOT NULL AND EXISTS (
        SELECT 1 FROM Employees 
        WHERE Username = @Username AND EmployeeId <> @EmployeeId
    )
    BEGIN
        RAISERROR (N'Username already exists.', 16, 1);
        RETURN;
    END

    -- 4. Email uniqueness (if your system requires it)
    IF @Email IS NOT NULL AND EXISTS (
        SELECT 1 FROM Employees 
        WHERE Email = @Email AND EmployeeId <> @EmployeeId
    )
    BEGIN
        RAISERROR (N'Email already exists.', 16, 1);
        RETURN;
    END

    -- 5. Phone uniqueness
    IF @Phone IS NOT NULL AND EXISTS (
        SELECT 1 FROM Employees 
        WHERE Phone = @Phone AND EmployeeId <> @EmployeeId
    )
    BEGIN
        RAISERROR (N'Phone already exists.', 16, 1);
        RETURN;
    END

    -- 6. PATCH update
    UPDATE Employees
    SET
        FullName = CASE WHEN @FullName IS NOT NULL THEN @FullName ELSE FullName END,
        Username = CASE WHEN @Username IS NOT NULL THEN @Username ELSE Username END,
        Phone = CASE WHEN @Phone IS NOT NULL THEN @Phone ELSE Phone END,
        Email    = CASE WHEN @Email IS NOT NULL THEN @Email ELSE Email END,
        Address  = CASE WHEN @Address IS NOT NULL THEN @Address ELSE Address END
    WHERE EmployeeId = @EmployeeId;

    -- 7. Return updated data
    SELECT EmployeeId, FullName, Username, Phone, Email, Address
    FROM Employees
    WHERE EmployeeId = @EmployeeId;
END
GO

-- Procedure: Get own profile
CREATE OR ALTER PROCEDURE sp_GetMyProfile
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Optional safety check
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId AND Status = 1)
    BEGIN
        RAISERROR (N'User not found or inactive.', 16, 1);
        RETURN;
    END

    SELECT *
    FROM dbo.fn_GetEmployeeById(@EmployeeId);
END
GO