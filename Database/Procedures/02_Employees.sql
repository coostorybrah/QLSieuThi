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