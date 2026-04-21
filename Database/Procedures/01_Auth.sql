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
