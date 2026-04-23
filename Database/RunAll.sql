-- IMPORTANT:
-- 1. Open SSMS
-- 2. File → Open → File → select this file from its folder
-- 3. Enable SQLCMD Mode
-- 4. Run

:setvar __REQUIRE_SQLCMD "TRUE"
GO

PRINT 'STARTING DATABASE SETUP: QLSieuThiDB';


:r ".\00_Database.sql"
:r ".\01_Tables_and_Indexes.sql"
:r ".\02_Functions.sql"
:r ".\03_Triggers.sql"

:r ".\Procedures\01_Auth.sql"
:r ".\Procedures\02_Employees.sql"
:r ".\Procedures\03_Customers.sql"
:r ".\Procedures\04_Products.sql"
:r ".\Procedures\05_Sales.sql"
:r ".\Procedures\06_SupplierOrders.sql"
:r ".\Procedures\07_Reports.sql"

:r ".\99_Inserts.sql"

PRINT 'DONE';