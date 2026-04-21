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
