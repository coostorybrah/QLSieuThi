# HỆ THỐNG QUẢN LÝ SIÊU THỊ
## 1. SETUP
### 1.1. Database
- Mở folder Database, sau đó mở file RunAll.sql bằng MSSQL;
- Bật SQLCMD Mode (Query -> SQLCMD Mode, xem ảnh SETUP.PNG).
- Chọn toàn bộ dòng lệnh trong file và chạy (không cần chạy từng dòng).
### 1.2. App
- Vào folder App, sau đó mở file QLSieuThi (.csproject hoặc .sln) bằng Visual Studio, build và chạy.
## 2. GIẢI THÍCH
### 2.1. Tổng quan hệ thống
- Hệ thống quản lý siêu thị được xây dựng nhằm hỗ trợ các hoạt động chính bao gồm:
  - Quản lý nhân viên
  - Quản lý sản phẩm và danh mục
  - Quản lý bán hàng
  - Quản lý nhập hàng từ nhà cung cấp
  - Quản lý tồn kho
  - Ghi nhận lịch sử thay đổi dữ liệu (audit)

- Hệ thống được chia thành 2 nhóm đối tượng chính:

  - Đối tượng sử dụng (Actors):
    - Employees: Là người trực tiếp sử dụng hệ thống (admin, manager, cashier)
  - Đối tượng dữ liệu (Entities), bao gồm các bảng phục vụ lưu trữ và xử lý nghiệp vụ:
    - EmployeesAuditLogs, Roles
    - Sales, SaleDetails
    - Suppliers, SupplierOrders, SupplierOrderDetails
    - Products, Categories, ProductCategories
    - InventoryTransactions
    - Customers
### 2.2. Quản lý nhân viên và phân quyền

- Các bảng liên quan:
  - Employees
  - Roles
  - EmployeesAuditLogs

- Mô tả:
  - Bảng Employees lưu trữ thông tin nhân viên như họ tên, số điện thoại, email, tài khoản đăng nhập và trạng thái hoạt động.
  - Bảng Roles định nghĩa các vai trò trong hệ thống như quản trị viên, quản lý và thu ngân.
  - Mỗi nhân viên được gán một RoleId để xác định quyền hạn tương ứng.
  - Bảng EmployeesAuditLogs ghi nhận lịch sử thay đổi dữ liệu nhân viên, bao gồm người thay đổi, trường dữ liệu bị thay đổi, giá trị cũ và giá trị mới.

- Mục đích:
  - Kiểm soát quyền truy cập
  - Đảm bảo khả năng truy vết và kiểm tra dữ liệu

### 2.3. Quản lý sản phẩm và danh mục

- Các bảng liên quan:
  - Products
  - Categories
  - ProductCategories

- Mô tả:
  - Bảng Products lưu thông tin chi tiết của sản phẩm như tên, mã vạch, giá nhập, giá bán, số lượng tồn kho và đơn vị tính.
  - Bảng Categories dùng để phân loại sản phẩm theo từng nhóm.
  - Bảng ProductCategories thể hiện mối quan hệ nhiều-nhiều giữa Products và Categories.

- Mục đích:
  - Tổ chức và phân loại sản phẩm một cách linh hoạt
  - Hỗ trợ tìm kiếm và quản lý sản phẩm hiệu quả

### 2.4. Quản lý bán hàng

- Các bảng liên quan:
  - Sales
  - SaleDetails

- Mô tả:
  - Bảng Sales lưu thông tin chung của hóa đơn bán hàng, bao gồm nhân viên thực hiện, khách hàng, tổng tiền, giảm giá, số tiền thanh toán cuối cùng và phương thức thanh toán.
  - Bảng SaleDetails lưu thông tin chi tiết từng sản phẩm trong hóa đơn, bao gồm số lượng và đơn giá.

- Quy trình:
  1. Nhân viên tạo hóa đơn bán hàng
  2. Thêm sản phẩm vào hóa đơn
  3. Tính toán tổng tiền và áp dụng giảm giá (nếu có)
  4. Lưu thông tin giao dịch

- Mục đích:
  - Quản lý giao dịch bán hàng
  - Theo dõi doanh thu

### 2.5. Quản lý khách hàng

- Bảng liên quan:
  - Customers

- Mô tả:
  - Lưu thông tin khách hàng như họ tên, số điện thoại, email, địa chỉ và điểm tích lũy.
  - Trường CustomerId trong bảng Sales có thể để trống, cho phép bán hàng không cần thông tin khách hàng.

- Mục đích:
  - Hỗ trợ quản lý khách hàng thân thiết
  - Áp dụng các chương trình tích điểm và ưu đãi

### 2.6. Quản lý nhà cung cấp và nhập hàng

- Các bảng liên quan:
  - Suppliers
  - SupplierOrders
  - SupplierOrderDetails

- Mô tả:
  - Bảng Suppliers lưu thông tin nhà cung cấp.
  - Bảng SupplierOrders lưu thông tin đơn nhập hàng, bao gồm nhân viên thực hiện, nhà cung cấp, tổng tiền và trạng thái đơn hàng.
  - Bảng SupplierOrderDetails lưu chi tiết các sản phẩm trong từng đơn nhập.

- Quy trình:
  1. Nhân viên tạo đơn nhập hàng
  2. Chọn nhà cung cấp
  3. Thêm sản phẩm và số lượng
  4. Xác nhận đơn và cập nhật tồn kho

- Mục đích:
  - Quản lý nguồn cung sản phẩm
  - Theo dõi hoạt động nhập hàng

### 2.7. Quản lý tồn kho

- Bảng liên quan:
  - InventoryTransactions

- Mô tả:
  - Bảng InventoryTransactions ghi nhận tất cả các biến động liên quan đến số lượng sản phẩm trong kho.
  - Các loại giao dịch bao gồm:
    - Nhập kho (từ đơn nhập hàng)
    - Xuất kho (từ bán hàng)
    - Điều chỉnh tồn kho

- Các trường quan trọng:
  - TransactionType: Xác định loại giao dịch (nhập hoặc xuất)
  - ReferenceType: Xác định nguồn phát sinh giao dịch (Sales hoặc SupplierOrders)
  - ReferenceId: Liên kết đến bản ghi cụ thể

- Mục đích:
  - Đảm bảo tính chính xác của tồn kho
  - Hỗ trợ kiểm tra và truy vết dữ liệu

### 2.8. Mối quan hệ giữa các thành phần

- Employees:
  - Thực hiện tạo Sales
  - Thực hiện tạo SupplierOrders

- Sales:
  - Có nhiều SaleDetails

- SupplierOrders:
  - Có nhiều SupplierOrderDetails

- Products:
  - Liên kết với Categories thông qua ProductCategories
  - Được sử dụng trong cả bán hàng và nhập hàng

- InventoryTransactions:
  - Ghi nhận tất cả các thay đổi liên quan đến sản phẩm

## 3. HƯỚNG DẪN SỬ DỤNG
### 3.1. Tổng quan giao diện

- Ứng dụng được thiết kế dạng menu chính (MenuStrip), bao gồm các mục:
  - System
  - Management
  - Sales
  - Inventory
  - Reports

- Mỗi menu tương ứng với một nhóm chức năng và một nhóm Stored Procedure trong database.

- Nguyên tắc:
  - Mỗi form chỉ gọi Stored Procedure
  - Không xử lý logic nghiệp vụ ở phía WinForms
  - Trigger trong database tự động xử lý tồn kho và ghi log


### 3.2. System

- Bao gồm:
  - Logout
  - Exit

- Chức năng:
  - Logout: đăng xuất và quay lại màn hình đăng nhập
  - Exit: thoát ứng dụng

- Liên quan:
  - Procedure đăng nhập trong `01_Auth.sql`


### 3.3. Management

- Bao gồm:
  - Employees
  - Products
  - Customers
  - Suppliers

- Chức năng:
  - Thêm, sửa, cập nhật trạng thái dữ liệu

- Mapping:
  - Employees → `02_Employees.sql`
  - Customers → `03_Customers.sql`
  - Products → `04_Products.sql`
  - Suppliers → `06_SupplierOrders.sql` (phần supplier)

- Lưu ý:
  - Khi cập nhật Employees, trigger sẽ tự động ghi log vào `EmployeesAuditLogs`


### 3.4. Sales

- Bao gồm:
  - New Sale

- Chức năng:
  - Tạo hóa đơn bán hàng
  - Thêm sản phẩm vào hóa đơn
  - Tính tổng tiền và thanh toán

- Mapping:
  - Procedure: `05_Sales.sql`

- Tự động (Trigger):
  - Trừ số lượng tồn kho trong Products
  - Ghi giao dịch vào `InventoryTransactions`

### 3.5. Inventory

- Bao gồm:
  - Import Goods

- Chức năng:
  - Tạo đơn nhập hàng
  - Thêm sản phẩm vào kho

- Mapping:
  - Procedure: `06_SupplierOrders.sql`

- Tự động (Trigger):
  - Cộng số lượng tồn kho
  - Ghi giao dịch vào `InventoryTransactions`

### 3.6. Reports

- Bao gồm:
  - Sales Report
  - Inventory Report
  - Top Products

- Chức năng:
  - Thống kê doanh thu
  - Kiểm tra tồn kho
  - Xem sản phẩm bán chạy

- Mapping:
  - Procedure: `07_Reports.sql`

### 3.7. Luồng sử dụng chính

#### Bán hàng

1. Vào menu Sales → New Sale
2. Tạo hóa đơn
3. Thêm sản phẩm và số lượng
4. Xác nhận thanh toán

- Hệ thống tự động:
  - Trừ tồn kho
  - Ghi log giao dịch

#### Nhập hàng

1. Vào menu Inventory → Import Goods
2. Tạo đơn nhập
3. Chọn nhà cung cấp
4. Thêm sản phẩm

- Hệ thống tự động:
  - Cộng tồn kho
  - Ghi log giao dịch
