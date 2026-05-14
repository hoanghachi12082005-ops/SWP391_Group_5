-- KiotRetail Database Schema
-- Encoding: UTF-8

CREATE DATABASE IF NOT EXISTS kiotretail
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE kiotretail;

-- Bảng vai trò (Roles)
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng quyền (Permissions)
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    module_name VARCHAR(100) NOT NULL,
    can_view BOOLEAN DEFAULT FALSE,
    can_create BOOLEAN DEFAULT FALSE,
    can_update BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE,
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng chi nhánh (Branches)
CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(200) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng nhân viên (Employees)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id INT,
    branch_id INT,
    department VARCHAR(100),
    position VARCHAR(100),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng nhóm hàng (Product Categories)
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(200) NOT NULL,
    description TEXT,
    parent_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng hàng hóa (Products)
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(300) NOT NULL,
    category_id INT,
    unit VARCHAR(50),
    cost_price DECIMAL(15,2) DEFAULT 0,
    selling_price DECIMAL(15,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    min_stock INT DEFAULT 0,
    max_stock INT DEFAULT 0,
    image_url VARCHAR(500),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng khách hàng (Customers)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    customer_group VARCHAR(100),
    total_purchases DECIMAL(15,2) DEFAULT 0,
    current_debt DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng nhà cung cấp (Suppliers)
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_code VARCHAR(50) UNIQUE NOT NULL,
    supplier_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng hóa đơn bán hàng (Sales Invoices)
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_code VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT,
    employee_id INT,
    branch_id INT,
    invoice_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    final_amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status ENUM('paid', 'unpaid', 'partial') DEFAULT 'paid',
    status ENUM('completed', 'cancelled', 'returned') DEFAULT 'completed',
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng chi tiết hóa đơn (Invoice Details)
CREATE TABLE invoice_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng phiếu nhập hàng (Purchase Orders)
CREATE TABLE purchase_orders (
    po_id INT PRIMARY KEY AUTO_INCREMENT,
    po_code VARCHAR(50) UNIQUE NOT NULL,
    supplier_id INT,
    employee_id INT,
    branch_id INT,
    po_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    status ENUM('completed', 'pending', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng chi tiết phiếu nhập (Purchase Order Details)
CREATE TABLE purchase_order_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng sổ quỹ (Cash Book)
CREATE TABLE cash_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_code VARCHAR(50) UNIQUE NOT NULL,
    transaction_type ENUM('income', 'expense') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50),
    person_name VARCHAR(200),
    description TEXT,
    employee_id INT,
    branch_id INT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('completed', 'cancelled') DEFAULT 'completed',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng bảng giá (Price Lists)
CREATE TABLE price_lists (
    price_list_id INT PRIMARY KEY AUTO_INCREMENT,
    list_name VARCHAR(200) NOT NULL,
    description TEXT,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dữ liệu mẫu (Sample Data)

-- Vai trò
INSERT INTO roles (role_name, description) VALUES
('Quản trị hệ thống', 'Toàn quyền quản lý hệ thống'),
('Quản lý cửa hàng', 'Quản lý hoạt động cửa hàng'),
('Nhân viên bán hàng', 'Bán hàng và chăm sóc khách hàng'),
('Thủ kho', 'Quản lý kho hàng'),
('Kế toán', 'Quản lý tài chính');

-- Quyền cho vai trò Nhân viên bán hàng
INSERT INTO permissions (module_name, can_view, can_create, can_update, can_delete, role_id) VALUES
('Bán hàng (POS)', TRUE, TRUE, TRUE, FALSE, 3),
('Quản lý hóa đơn', TRUE, FALSE, FALSE, FALSE, 3),
('Khách hàng', TRUE, TRUE, TRUE, FALSE, 3),
('Danh mục hàng hóa', TRUE, FALSE, FALSE, FALSE, 3),
('Báo cáo doanh thu', FALSE, FALSE, FALSE, FALSE, 3);

-- Chi nhánh
INSERT INTO branches (branch_name, address, phone) VALUES
('Chi nhánh Trung tâm', '123 Nguyễn Huệ, Quận 1, TP.HCM', '0281234567'),
('Chi nhánh Quận 1', '456 Lê Lợi, Quận 1, TP.HCM', '0281234568'),
('Chi nhánh Gò Vấp', '789 Quang Trung, Gò Vấp, TP.HCM', '0281234569');

-- Nhân viên (password: 123456 - đã hash bằng BCrypt)
INSERT INTO employees (employee_code, full_name, email, phone, username, password, role_id, branch_id, department, position) VALUES
('NV00124', 'Nguyễn Văn Hải', 'hai.nguyen@kiotretail.vn', '0901234567', 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 1, 1, 'Quản lý', 'Cửa hàng trưởng'),
('NV00125', 'Trần Thị Mai', 'mai.tran@kiotretail.vn', '0987654321', 'thungan01', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 3, 1, 'Bán hàng', 'Thu ngân');

-- Nhóm hàng
INSERT INTO categories (category_name, description) VALUES
('Điện thoại & Máy tính bảng', 'Các thiết bị di động thông minh'),
('Phụ kiện công nghệ', 'Phụ kiện cho thiết bị điện tử'),
('Thiết bị âm thanh', 'Tai nghe, loa, âm thanh'),
('Gia dụng thông minh', 'Thiết bị gia dụng công nghệ cao');

-- Hàng hóa
INSERT INTO products (product_code, product_name, category_id, unit, cost_price, selling_price, stock_quantity, min_stock, image_url) VALUES
('SP00102', 'iPhone 15 Pro Max 256GB', 1, 'Chiếc', 28000000, 32990000, 45, 10, '/assets/images/products/iphone15.jpg'),
('PK0491', 'Cáp sạc nhanh 20W Type-C', 2, 'Cái', 150000, 250000, 3, 20, NULL),
('AT8820', 'Tai nghe Bluetooth Sony WH-1000XM5', 3, 'Chiếc', 6500000, 8490000, 0, 5, '/assets/images/products/sony-headphone.jpg');

-- Khách hàng
INSERT INTO customers (customer_code, full_name, phone, email, customer_group, total_purchases) VALUES
('KH00124', 'Nguyễn Văn An', '0901234567', 'an.nguyen@email.com', 'VIP', 12500000),
('KH00125', 'Trần Thị Bích', '0988765432', 'bich.tran@email.com', 'Lẻ', 3200000);

-- Nhà cung cấp
INSERT INTO suppliers (supplier_code, supplier_name, contact_person, phone, email) VALUES
('NCC001', 'Công ty CP Thực phẩm CJ', 'Nguyễn Văn A', '0281111111', 'contact@cj.vn'),
('NCC042', 'Nhà phân phối Thái Hưng', 'Trần Văn B', '0282222222', 'info@thaihu ng.vn');

-- Bảng giá
INSERT INTO price_lists (list_name, description, discount_percent) VALUES
('Bảng giá Chung', 'Áp dụng cho toàn bộ khách hàng lẻ', 0),
('Đại lý Cấp 1', 'Chính sách chiết khấu dành riêng cho đối tác phân phối', 15),
('Khách VIP', 'Ưu đãi đặc biệt cho thành viên đạt hạng Kim cương', 10);
