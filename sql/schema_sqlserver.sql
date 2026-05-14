-- KiotRetail Database Schema for SQL Server
-- Encoding: UTF-8

-- Tạo database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SamplePE')
BEGIN
    CREATE DATABASE SamplePE;
END
GO

USE SamplePE;
GO

-- Bảng vai trò (Roles)
IF OBJECT_ID('roles', 'U') IS NOT NULL DROP TABLE roles;
CREATE TABLE roles (
    role_id INT PRIMARY KEY IDENTITY(1,1),
    role_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE()
);
GO

-- Bảng quyền (Permissions)
IF OBJECT_ID('permissions', 'U') IS NOT NULL DROP TABLE permissions;
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY IDENTITY(1,1),
    module_name NVARCHAR(100) NOT NULL,
    can_view BIT DEFAULT 0,
    can_create BIT DEFAULT 0,
    can_update BIT DEFAULT 0,
    can_delete BIT DEFAULT 0,
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);
GO

-- Bảng chi nhánh (Branches)
IF OBJECT_ID('branches', 'U') IS NOT NULL DROP TABLE branches;
CREATE TABLE branches (
    branch_id INT PRIMARY KEY IDENTITY(1,1),
    branch_name NVARCHAR(200) NOT NULL,
    address NVARCHAR(MAX),
    phone NVARCHAR(20),
    status NVARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at DATETIME2 DEFAULT GETDATE()
);
GO

-- Bảng nhân viên (Employees)
IF OBJECT_ID('employees', 'U') IS NOT NULL DROP TABLE employees;
CREATE TABLE employees (
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    employee_code NVARCHAR(50) UNIQUE NOT NULL,
    full_name NVARCHAR(200) NOT NULL,
    email NVARCHAR(100),
    phone NVARCHAR(20),
    username NVARCHAR(50) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    role_id INT,
    branch_id INT,
    department NVARCHAR(100),
    position NVARCHAR(100),
    status NVARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);
GO

-- Bảng nhóm hàng (Product Categories)
IF OBJECT_ID('categories', 'U') IS NOT NULL DROP TABLE categories;
CREATE TABLE categories (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    category_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    parent_id INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);
GO

-- Bảng hàng hóa (Products)
IF OBJECT_ID('products', 'U') IS NOT NULL DROP TABLE products;
CREATE TABLE products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    product_code NVARCHAR(50) UNIQUE NOT NULL,
    product_name NVARCHAR(300) NOT NULL,
    category_id INT,
    unit NVARCHAR(50),
    cost_price DECIMAL(15,2) DEFAULT 0,
    selling_price DECIMAL(15,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    min_stock INT DEFAULT 0,
    max_stock INT DEFAULT 0,
    image_url NVARCHAR(500),
    status NVARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
GO

-- Bảng khách hàng (Customers)
IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    customer_code NVARCHAR(50) UNIQUE NOT NULL,
    full_name NVARCHAR(200) NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(100),
    address NVARCHAR(MAX),
    customer_group NVARCHAR(100),
    total_purchases DECIMAL(15,2) DEFAULT 0,
    current_debt DECIMAL(15,2) DEFAULT 0,
    created_at DATETIME2 DEFAULT GETDATE()
);
GO

-- Bảng nhà cung cấp (Suppliers)
IF OBJECT_ID('suppliers', 'U') IS NOT NULL DROP TABLE suppliers;
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY IDENTITY(1,1),
    supplier_code NVARCHAR(50) UNIQUE NOT NULL,
    supplier_name NVARCHAR(200) NOT NULL,
    contact_person NVARCHAR(200),
    phone NVARCHAR(20),
    email NVARCHAR(100),
    address NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE()
);
GO

-- Bảng hóa đơn bán hàng (Sales Invoices)
IF OBJECT_ID('invoices', 'U') IS NOT NULL DROP TABLE invoices;
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY IDENTITY(1,1),
    invoice_code NVARCHAR(50) UNIQUE NOT NULL,
    customer_id INT,
    employee_id INT,
    branch_id INT,
    invoice_date DATETIME2 DEFAULT GETDATE(),
    total_amount DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    final_amount DECIMAL(15,2) NOT NULL,
    payment_method NVARCHAR(50),
    payment_status NVARCHAR(20) DEFAULT 'paid' CHECK (payment_status IN ('paid', 'unpaid', 'partial')),
    status NVARCHAR(20) DEFAULT 'completed' CHECK (status IN ('completed', 'cancelled', 'returned')),
    notes NVARCHAR(MAX),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);
GO

-- Bảng chi tiết hóa đơn (Invoice Details)
IF OBJECT_ID('invoice_details', 'U') IS NOT NULL DROP TABLE invoice_details;
CREATE TABLE invoice_details (
    detail_id INT PRIMARY KEY IDENTITY(1,1),
    invoice_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- Bảng phiếu nhập hàng (Purchase Orders)
IF OBJECT_ID('purchase_orders', 'U') IS NOT NULL DROP TABLE purchase_orders;
CREATE TABLE purchase_orders (
    po_id INT PRIMARY KEY IDENTITY(1,1),
    po_code NVARCHAR(50) UNIQUE NOT NULL,
    supplier_id INT,
    employee_id INT,
    branch_id INT,
    po_date DATETIME2 DEFAULT GETDATE(),
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN ('completed', 'pending', 'cancelled')),
    notes NVARCHAR(MAX),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);
GO

-- Bảng chi tiết phiếu nhập (Purchase Order Details)
IF OBJECT_ID('purchase_order_details', 'U') IS NOT NULL DROP TABLE purchase_order_details;
CREATE TABLE purchase_order_details (
    detail_id INT PRIMARY KEY IDENTITY(1,1),
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- Bảng sổ quỹ (Cash Book)
IF OBJECT_ID('cash_transactions', 'U') IS NOT NULL DROP TABLE cash_transactions;
CREATE TABLE cash_transactions (
    transaction_id INT PRIMARY KEY IDENTITY(1,1),
    transaction_code NVARCHAR(50) UNIQUE NOT NULL,
    transaction_type NVARCHAR(20) NOT NULL CHECK (transaction_type IN ('income', 'expense')),
    amount DECIMAL(15,2) NOT NULL,
    payment_method NVARCHAR(50),
    person_name NVARCHAR(200),
    description NVARCHAR(MAX),
    employee_id INT,
    branch_id INT,
    transaction_date DATETIME2 DEFAULT GETDATE(),
    status NVARCHAR(20) DEFAULT 'completed' CHECK (status IN ('completed', 'cancelled')),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);
GO

-- Bảng bảng giá (Price Lists)
IF OBJECT_ID('price_lists', 'U') IS NOT NULL DROP TABLE price_lists;
CREATE TABLE price_lists (
    price_list_id INT PRIMARY KEY IDENTITY(1,1),
    list_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    discount_percent DECIMAL(5,2) DEFAULT 0,
    status NVARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at DATETIME2 DEFAULT GETDATE()
);
GO

-- Dữ liệu mẫu (Sample Data)

-- Vai trò
SET IDENTITY_INSERT roles ON;
INSERT INTO roles (role_id, role_name, description) VALUES
(1, N'Quản trị hệ thống', N'Toàn quyền quản lý hệ thống'),
(2, N'Quản lý cửa hàng', N'Quản lý hoạt động cửa hàng'),
(3, N'Nhân viên bán hàng', N'Bán hàng và chăm sóc khách hàng'),
(4, N'Thủ kho', N'Quản lý kho hàng'),
(5, N'Kế toán', N'Quản lý tài chính');
SET IDENTITY_INSERT roles OFF;
GO

-- Quyền cho vai trò Nhân viên bán hàng
INSERT INTO permissions (module_name, can_view, can_create, can_update, can_delete, role_id) VALUES
(N'Bán hàng (POS)', 1, 1, 1, 0, 3),
(N'Quản lý hóa đơn', 1, 0, 0, 0, 3),
(N'Khách hàng', 1, 1, 1, 0, 3),
(N'Danh mục hàng hóa', 1, 0, 0, 0, 3),
(N'Báo cáo doanh thu', 0, 0, 0, 0, 3);
GO

-- Chi nhánh
SET IDENTITY_INSERT branches ON;
INSERT INTO branches (branch_id, branch_name, address, phone) VALUES
(1, N'Chi nhánh Trung tâm', N'123 Nguyễn Huệ, Quận 1, TP.HCM', '0281234567'),
(2, N'Chi nhánh Quận 1', N'456 Lê Lợi, Quận 1, TP.HCM', '0281234568'),
(3, N'Chi nhánh Gò Vấp', N'789 Quang Trung, Gò Vấp, TP.HCM', '0281234569');
SET IDENTITY_INSERT branches OFF;
GO

-- Nhân viên (password: 123456 - plain text for demo)
SET IDENTITY_INSERT employees ON;
INSERT INTO employees (employee_id, employee_code, full_name, email, phone, username, password, role_id, branch_id, department, position) VALUES
(1, 'NV00124', N'Nguyễn Văn Hải', 'hai.nguyen@kiotretail.vn', '0901234567', 'admin', '123456', 1, 1, N'Quản lý', N'Cửa hàng trưởng'),
(2, 'NV00125', N'Trần Thị Mai', 'mai.tran@kiotretail.vn', '0987654321', 'thungan01', '123456', 3, 1, N'Bán hàng', N'Thu ngân');
SET IDENTITY_INSERT employees OFF;
GO

-- Nhóm hàng
SET IDENTITY_INSERT categories ON;
INSERT INTO categories (category_id, category_name, description) VALUES
(1, N'Điện thoại & Máy tính bảng', N'Các thiết bị di động thông minh'),
(2, N'Phụ kiện công nghệ', N'Phụ kiện cho thiết bị điện tử'),
(3, N'Thiết bị âm thanh', N'Tai nghe, loa, âm thanh'),
(4, N'Gia dụng thông minh', N'Thiết bị gia dụng công nghệ cao');
SET IDENTITY_INSERT categories OFF;
GO

-- Hàng hóa
SET IDENTITY_INSERT products ON;
INSERT INTO products (product_id, product_code, product_name, category_id, unit, cost_price, selling_price, stock_quantity, min_stock, image_url) VALUES
(1, 'SP00102', N'iPhone 15 Pro Max 256GB', 1, N'Chiếc', 28000000, 32990000, 45, 10, '/assets/images/products/iphone15.jpg'),
(2, 'PK0491', N'Cáp sạc nhanh 20W Type-C', 2, N'Cái', 150000, 250000, 3, 20, NULL),
(3, 'AT8820', N'Tai nghe Bluetooth Sony WH-1000XM5', 3, N'Chiếc', 6500000, 8490000, 0, 5, '/assets/images/products/sony-headphone.jpg');
SET IDENTITY_INSERT products OFF;
GO

-- Khách hàng
SET IDENTITY_INSERT customers ON;
INSERT INTO customers (customer_id, customer_code, full_name, phone, email, customer_group, total_purchases) VALUES
(1, 'KH00124', N'Nguyễn Văn An', '0901234567', 'an.nguyen@email.com', 'VIP', 12500000),
(2, 'KH00125', N'Trần Thị Bích', '0988765432', 'bich.tran@email.com', N'Lẻ', 3200000);
SET IDENTITY_INSERT customers OFF;
GO

-- Nhà cung cấp
SET IDENTITY_INSERT suppliers ON;
INSERT INTO suppliers (supplier_id, supplier_code, supplier_name, contact_person, phone, email) VALUES
(1, 'NCC001', N'Công ty CP Thực phẩm CJ', N'Nguyễn Văn A', '0281111111', 'contact@cj.vn'),
(2, 'NCC042', N'Nhà phân phối Thái Hưng', N'Trần Văn B', '0282222222', 'info@thaihung.vn');
SET IDENTITY_INSERT suppliers OFF;
GO

-- Bảng giá
SET IDENTITY_INSERT price_lists ON;
INSERT INTO price_lists (price_list_id, list_name, description, discount_percent) VALUES
(1, N'Bảng giá Chung', N'Áp dụng cho toàn bộ khách hàng lẻ', 0),
(2, N'Đại lý Cấp 1', N'Chính sách chiết khấu dành riêng cho đối tác phân phối', 15),
(3, N'Khách VIP', N'Ưu đãi đặc biệt cho thành viên đạt hạng Kim cương', 10);
SET IDENTITY_INSERT price_lists OFF;
GO

PRINT 'Database schema created successfully!';
GO
