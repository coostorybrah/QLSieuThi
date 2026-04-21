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
