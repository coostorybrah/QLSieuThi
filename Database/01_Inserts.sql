USE QLSieuThiDB
GO

-- Roles
INSERT INTO Roles (RoleName) VALUES
(N'Admin'),
(N'Manager'),
(N'Cashier');

-- Employees
INSERT INTO Employees (FullName, Phone, Email, Address, RoleId, Username, Password)
VALUES
(N'Nguyen Van A', '0901234567', 'nva@gmail.com', N'Ha Noi', 1, 'admin', dbo.fn_HashPassword('admin123')),
(N'Tran Thi B', '0902345678', 'ttb@gmail.com', N'Ha Noi', 2, 'manager1', dbo.fn_HashPassword('manager123')),
(N'Le Van C', '0903456789', 'lvc@gmail.com', N'Ha Noi', 3, 'cashier1', dbo.fn_HashPassword('cashier123'));

-- Customers
INSERT INTO Customers (Phone, FullName, Email, Address, LoyaltyPoints)
VALUES
('0911111111', N'Pham Minh', 'minh@gmail.com', N'Ha Noi', 100),
('0922222222', N'Hoang Lan', 'lan@gmail.com', N'Ha Noi', 50),
('0933333333', N'Doan Nam', 'nam@gmail.com', N'Ha Noi', 20);

-- Suppliers
INSERT INTO Suppliers (SupplierName, Phone, Email, Address)
VALUES
(N'Vinamilk Supplier', '0988888888', 'vinamilk@gmail.com', N'Ho Chi Minh'),
(N'Coca Supplier', '0977777777', 'coca@gmail.com', N'Ha Noi');

-- Categories
INSERT INTO Categories (CategoryName, Description)
VALUES
(N'Dairy', N'Milk and dairy products'),
(N'Beverages', N'Drinks and soft drinks'),
(N'Snacks', N'Fast food and snacks');

-- Products
INSERT INTO Products (ProductName, Barcode, SupplierId, CostPrice, SellingPrice, StockQuantity, Unit)
VALUES
(N'Vinamilk Milk 1L', '111111', 1, 20000, 25000, 100, N'Bottle'),
(N'Coca Cola Can', '222222', 2, 8000, 12000, 200, N'Can'),
(N'Oreo Cookies', '333333', 2, 10000, 15000, 150, N'Pack');

-- Products-Categories
INSERT INTO ProductCategories (ProductId, CategoryId)
VALUES
(1, 1), -- Milk -> Dairy
(2, 2), -- Coca -> Beverages
(3, 3); -- Oreo -> Snacks

-- Sales
INSERT INTO Sales (EmployeeId, CustomerId, CustomerName, CustomerPhone, TotalAmount, Discount, FinalAmount, PaymentMethod)
VALUES
(3, 1, N'Pham Minh', '0911111111', 50000, 5000, 45000, N'Cash'),
(3, 2, N'Hoang Lan', '0922222222', 36000, 0, 36000, N'Card');

-- Sale Details
INSERT INTO SaleDetails (SaleId, ProductId, Quantity, UnitPrice, TotalPrice)
VALUES
(1, 1, 2, 25000, 50000),
(2, 2, 3, 12000, 36000);

-- Supplier Orders
INSERT INTO SupplierOrders (SupplierId, EmployeeId, TotalAmount, Status)
VALUES
(1, 2, 2000000, 'Completed'),
(2, 2, 1500000, 'Pending');

-- Supplier Order Details
INSERT INTO SupplierOrderDetails (SupplierOrderId, ProductId, Quantity, CostPrice, TotalPrice)
VALUES
(1, 1, 100, 20000, 2000000),
(2, 2, 200, 8000, 1600000);