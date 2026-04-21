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

