CREATE DATABASE IF NOT EXISTS DBFinora;
USE DBFinora;
GO

-- =====================================================
-- 1. ROLES
-- =====================================================
CREATE TABLE Roles (
    RoleID      BIGINT PRIMARY KEY IDENTITY(1,1),
    RoleName    VARCHAR(50)    NOT NULL UNIQUE,
    Description NVARCHAR(MAX),
    CreatedAt   DATETIME       DEFAULT GETDATE()
);
GO

-- =====================================================
-- 2. STORE OWNERS
-- =====================================================
CREATE TABLE StoreOwners (
    OwnerID      BIGINT PRIMARY KEY IDENTITY(1,1),
    FullName     NVARCHAR(100)  NOT NULL,
    Email        VARCHAR(100)   NOT NULL UNIQUE,
    Phone        VARCHAR(20)    UNIQUE,
    PasswordHash NVARCHAR(255)  NOT NULL,
    AvatarURL    NVARCHAR(255),
    Status       VARCHAR(20)    NOT NULL
                 CHECK (Status IN ('ACTIVE', 'INACTIVE', 'LOCKED'))
                 DEFAULT 'ACTIVE',
    LastLogin    DATETIME       NULL,
    CreatedAt    DATETIME       DEFAULT GETDATE(),
    UpdatedAt    DATETIME       DEFAULT GETDATE()
);
GO

-- =====================================================
-- 3. BRANCHES
-- =====================================================
CREATE TABLE Branches (
    BranchID   BIGINT PRIMARY KEY IDENTITY(1,1),
    OwnerID    BIGINT         NOT NULL,
    BranchName NVARCHAR(100)  NOT NULL,
    Phone      VARCHAR(20),
    Address    NVARCHAR(MAX),
    Status     VARCHAR(20)    NOT NULL
               CHECK (Status IN ('ACTIVE', 'INACTIVE'))
               DEFAULT 'ACTIVE',
    CreatedAt  DATETIME       DEFAULT GETDATE(),
    UpdatedAt  DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_Branches_StoreOwners
        FOREIGN KEY (OwnerID) REFERENCES StoreOwners(OwnerID)
        ON DELETE CASCADE
);
GO

-- =====================================================
-- 4. EMPLOYEES
-- =====================================================
CREATE TABLE Employees (
    EmployeeID   BIGINT PRIMARY KEY IDENTITY(1,1),
    BranchID     BIGINT         NOT NULL,
    RoleID       BIGINT         NOT NULL,
    FullName     NVARCHAR(100)  NOT NULL,
    Email        VARCHAR(100)   NOT NULL UNIQUE,
    Phone        VARCHAR(20)    UNIQUE,
    PasswordHash NVARCHAR(255)  NOT NULL,
    AvatarURL    NVARCHAR(255),
    HireDate     DATE,
    Salary       DECIMAL(18,2),
    Status       VARCHAR(20)    NOT NULL
                 CHECK (Status IN ('ACTIVE', 'INACTIVE', 'LOCKED'))
                 DEFAULT 'ACTIVE',
    LastLogin    DATETIME       NULL,
    CreatedAt    DATETIME       DEFAULT GETDATE(),
    UpdatedAt    DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_Employees_Branches
        FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
        ON DELETE CASCADE,

    CONSTRAINT FK_Employees_Roles
        FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

-- =====================================================
-- 5. REFRESH TOKENS
-- =====================================================
CREATE TABLE RefreshTokens (
    RefreshTokenID BIGINT PRIMARY KEY IDENTITY(1,1),
    EmployeeID     BIGINT         NULL,
    OwnerID        BIGINT         NULL,
    Token          NVARCHAR(MAX)  NOT NULL,
    ExpiredAt      DATETIME       NOT NULL,
    Revoked        BIT            DEFAULT 0,
    CreatedAt      DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_RefreshTokens_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
        ON DELETE SET NULL,

    CONSTRAINT FK_RefreshTokens_StoreOwners
        FOREIGN KEY (OwnerID) REFERENCES StoreOwners(OwnerID)
        ON DELETE SET NULL
);
GO

-- =====================================================
-- 6. PASSWORD RESET TOKENS
-- =====================================================
CREATE TABLE PasswordResetTokens (
    ResetID   BIGINT PRIMARY KEY IDENTITY(1,1),
    Email     VARCHAR(100)   NOT NULL,
    Token     NVARCHAR(255)  NOT NULL UNIQUE,
    ExpiredAt DATETIME       NOT NULL,
    Used      BIT            DEFAULT 0,
    CreatedAt DATETIME       DEFAULT GETDATE()
);
GO

-- =====================================================
-- 7. AUDIT LOGS
-- Ghi nhận mọi hành động của Owner & Employee
-- Thêm old_data / new_data so với script gốc (theo ERD)
-- =====================================================
CREATE TABLE AuditLogs (
    LogID       BIGINT PRIMARY KEY IDENTITY(1,1),
    ActorType   VARCHAR(20)    NOT NULL
                CHECK (ActorType IN ('OWNER', 'EMPLOYEE')),
    ActorID     BIGINT         NOT NULL,
    ActionName  VARCHAR(100)   NOT NULL,   -- e.g. CREATE_ORDER, UPDATE_PRODUCT
    EntityType  VARCHAR(100),              -- e.g. 'Order', 'Product'
    EntityID    BIGINT,
    OldData     NVARCHAR(MAX),             -- JSON snapshot trước khi thay đổi
    NewData     NVARCHAR(MAX),             -- JSON snapshot sau khi thay đổi
    Description NVARCHAR(MAX),
    IPAddress   VARCHAR(45),
    UserAgent   NVARCHAR(MAX),
    CreatedAt   DATETIME       DEFAULT GETDATE()
);
GO

-- =====================================================
-- 8. CATEGORIES
-- Hỗ trợ danh mục cha-con (parent_id tự tham chiếu)
-- =====================================================
CREATE TABLE Categories (
    CategoryID  BIGINT PRIMARY KEY IDENTITY(1,1),
    Name        NVARCHAR(100)  NOT NULL,
    Description NVARCHAR(MAX),
    ParentID    BIGINT         NULL,       -- NULL = danh mục gốc
    Status      VARCHAR(20)    NOT NULL
                CHECK (Status IN ('ACTIVE', 'INACTIVE'))
                DEFAULT 'ACTIVE',

    CONSTRAINT FK_Categories_Parent
        FOREIGN KEY (ParentID) REFERENCES Categories(CategoryID)
);
GO

-- =====================================================
-- 9. SUPPLIERS
-- =====================================================
CREATE TABLE Suppliers (
    SupplierID BIGINT PRIMARY KEY IDENTITY(1,1),
    Name       NVARCHAR(100)  NOT NULL,
    Phone      VARCHAR(20),
    Email      VARCHAR(100),
    Address    NVARCHAR(MAX),
    Status     VARCHAR(20)    NOT NULL
               CHECK (Status IN ('ACTIVE', 'INACTIVE'))
               DEFAULT 'ACTIVE',
    CreatedAt  DATETIME       DEFAULT GETDATE()
);
GO

-- =====================================================
-- 10. PRODUCTS
-- =====================================================
CREATE TABLE Products (
    ProductID      BIGINT PRIMARY KEY IDENTITY(1,1),
    CategoryID     BIGINT         NOT NULL,
    Name           NVARCHAR(200)  NOT NULL,
    SKU            VARCHAR(100)   NOT NULL UNIQUE,
    Price          DECIMAL(18,2)  NOT NULL DEFAULT 0,   -- giá bán
    CostPrice      DECIMAL(18,2)  NOT NULL DEFAULT 0,   -- giá vốn
    StockAlertQty  INT            DEFAULT 0,            -- ngưỡng cảnh báo tồn kho
    Status         VARCHAR(20)    NOT NULL
                   CHECK (Status IN ('ACTIVE', 'INACTIVE'))
                   DEFAULT 'ACTIVE',
    CreatedAt      DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- =====================================================
-- 11. WAREHOUSES
-- Mỗi kho thuộc một chi nhánh
-- =====================================================
CREATE TABLE Warehouses (
    WarehouseID BIGINT PRIMARY KEY IDENTITY(1,1),
    BranchID    BIGINT         NOT NULL,
    Name        NVARCHAR(100)  NOT NULL,
    Address     NVARCHAR(MAX),
    Status      VARCHAR(20)    NOT NULL
                CHECK (Status IN ('ACTIVE', 'INACTIVE'))
                DEFAULT 'ACTIVE',
    CreatedAt   DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_Warehouses_Branches
        FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
        ON DELETE CASCADE
);
GO

-- =====================================================
-- 12. INVENTORIES
-- Tồn kho của từng sản phẩm trong từng kho
-- =====================================================
CREATE TABLE Inventories (
    InventoryID       BIGINT PRIMARY KEY IDENTITY(1,1),
    WarehouseID       BIGINT  NOT NULL,
    ProductID         BIGINT  NOT NULL,
    Quantity          INT     NOT NULL DEFAULT 0,
    ReservedQuantity  INT     NOT NULL DEFAULT 0,   -- đã đặt chưa xuất
    AvailableQuantity AS (Quantity - ReservedQuantity) PERSISTED,  -- tính toán
    MinQuantity       INT     DEFAULT 0,
    MaxQuantity       INT     DEFAULT 0,
    UpdatedAt         DATETIME DEFAULT GETDATE(),
    CreatedAt         DATETIME DEFAULT GETDATE(),

    CONSTRAINT UQ_Inventories_Warehouse_Product
        UNIQUE (WarehouseID, ProductID),

    CONSTRAINT FK_Inventories_Warehouses
        FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
        ON DELETE CASCADE,

    CONSTRAINT FK_Inventories_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =====================================================
-- 13. INVENTORY TRANSACTIONS
-- Lịch sử mọi biến động kho (nhập, xuất, điều chỉnh…)
-- =====================================================
CREATE TABLE InventoryTransactions (
    InventoryTransactionID BIGINT PRIMARY KEY IDENTITY(1,1),
    WarehouseID            BIGINT        NOT NULL,
    ProductID              BIGINT        NOT NULL,
    TransactionType        VARCHAR(50)   NOT NULL
                           CHECK (TransactionType IN (
                               'IMPORT',       -- nhập hàng
                               'EXPORT',       -- xuất hàng (bán)
                               'TRANSFER_IN',  -- nhận điều chuyển
                               'TRANSFER_OUT', -- xuất điều chuyển
                               'ADJUSTMENT'    -- điều chỉnh thủ công
                           )),
    Quantity               INT           NOT NULL,
    ReferenceType          VARCHAR(50),  -- 'PurchaseOrder' | 'Order' | 'StockTransfer'
    ReferenceID            BIGINT,       -- ID tương ứng
    CreatedBy              BIGINT,       -- EmployeeID thực hiện
    CreatedAt              DATETIME      DEFAULT GETDATE(),

    CONSTRAINT FK_InvTxn_Warehouses
        FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID),

    CONSTRAINT FK_InvTxn_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID),

    CONSTRAINT FK_InvTxn_Employees
        FOREIGN KEY (CreatedBy) REFERENCES Employees(EmployeeID)
);
GO

-- =====================================================
-- 14. PURCHASE ORDERS (Đơn đặt hàng nhà cung cấp)
-- =====================================================
CREATE TABLE PurchaseOrders (
    PurchaseOrderID BIGINT PRIMARY KEY IDENTITY(1,1),
    POCode          VARCHAR(50)    NOT NULL UNIQUE,
    SupplierID      BIGINT         NOT NULL,
    EmployeeID      BIGINT         NOT NULL,   -- nhân viên tạo đơn
    WarehouseID     BIGINT         NOT NULL,   -- nhập về kho nào
    Subtotal        DECIMAL(18,2)  NOT NULL DEFAULT 0,
    TotalAmount     DECIMAL(18,2)  NOT NULL DEFAULT 0,
    Status          VARCHAR(30)    NOT NULL
                    CHECK (Status IN ('PENDING', 'APPROVED', 'RECEIVED', 'CANCELLED'))
                    DEFAULT 'PENDING',
    CreatedAt       DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_PO_Suppliers
        FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),

    CONSTRAINT FK_PO_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),

    CONSTRAINT FK_PO_Warehouses
        FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);
GO

-- =====================================================
-- 15. PURCHASE ORDER ITEMS
-- =====================================================
CREATE TABLE PurchaseOrderItems (
    PurchaseOrderItemID BIGINT PRIMARY KEY IDENTITY(1,1),
    PurchaseOrderID     BIGINT         NOT NULL,
    ProductID           BIGINT         NOT NULL,
    Quantity            INT            NOT NULL,
    CostPrice           DECIMAL(18,2)  NOT NULL,
    Subtotal            AS (Quantity * CostPrice) PERSISTED,

    CONSTRAINT FK_POItems_PurchaseOrders
        FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrders(PurchaseOrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_POItems_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =====================================================
-- 16. STOCK TRANSFERS (Điều chuyển kho)
-- =====================================================
CREATE TABLE StockTransfers (
    StockTransferID  BIGINT PRIMARY KEY IDENTITY(1,1),
    BranchID         BIGINT        NOT NULL,
    FromWarehouseID  BIGINT        NOT NULL,
    ToWarehouseID    BIGINT        NOT NULL,
    EmployeeID       BIGINT        NOT NULL,
    TransferCode     VARCHAR(50)   NOT NULL UNIQUE,
    TransferDate     DATETIME      NOT NULL DEFAULT GETDATE(),
    Status           VARCHAR(30)   NOT NULL
                     CHECK (Status IN ('PENDING', 'IN_TRANSIT', 'COMPLETED', 'CANCELLED'))
                     DEFAULT 'PENDING',
    Note             NVARCHAR(MAX),
    CreatedAt        DATETIME      DEFAULT GETDATE(),

    CONSTRAINT FK_StockTransfers_Branches
        FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),

    CONSTRAINT FK_StockTransfers_FromWarehouse
        FOREIGN KEY (FromWarehouseID) REFERENCES Warehouses(WarehouseID),

    CONSTRAINT FK_StockTransfers_ToWarehouse
        FOREIGN KEY (ToWarehouseID) REFERENCES Warehouses(WarehouseID),

    CONSTRAINT FK_StockTransfers_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- =====================================================
-- 17. STOCK TRANSFER ITEMS
-- =====================================================
CREATE TABLE StockTransferItems (
    StockTransferItemID BIGINT PRIMARY KEY IDENTITY(1,1),
    StockTransferID     BIGINT  NOT NULL,
    ProductID           BIGINT  NOT NULL,
    Quantity            INT     NOT NULL,
    Note                NVARCHAR(MAX),

    CONSTRAINT FK_STItems_StockTransfers
        FOREIGN KEY (StockTransferID) REFERENCES StockTransfers(StockTransferID)
        ON DELETE CASCADE,

    CONSTRAINT FK_STItems_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =====================================================
-- 18. CUSTOMERS
-- =====================================================
CREATE TABLE Customers (
    CustomerID     BIGINT PRIMARY KEY IDENTITY(1,1),
    FullName       NVARCHAR(100)  NOT NULL,
    Phone          VARCHAR(20)    UNIQUE,
    Email          VARCHAR(100),
    Address        NVARCHAR(MAX),
    DoB            DATE,
    Gender         VARCHAR(10)
                   CHECK (Gender IN ('MALE', 'FEMALE', 'OTHER')),
    MembershipTier VARCHAR(20)
                   CHECK (MembershipTier IN ('STANDARD', 'SILVER', 'GOLD', 'PLATINUM'))
                   DEFAULT 'STANDARD',
    Points         INT            DEFAULT 0,
    CreatedAt      DATETIME       DEFAULT GETDATE()
);
GO

-- =====================================================
-- 19. ORDERS
-- =====================================================
CREATE TABLE Orders (
    OrderID        BIGINT PRIMARY KEY IDENTITY(1,1),
    OrderCode      VARCHAR(50)    NOT NULL UNIQUE,
    CustomerID     BIGINT         NULL,   -- NULL = khách vãng lai
    EmployeeID     BIGINT         NOT NULL,
    BranchID       BIGINT         NOT NULL,
    Subtotal       DECIMAL(18,2)  NOT NULL DEFAULT 0,
    DiscountAmount DECIMAL(18,2)  NOT NULL DEFAULT 0,
    TotalAmount    DECIMAL(18,2)  NOT NULL DEFAULT 0,
    Status         VARCHAR(30)    NOT NULL
                   CHECK (Status IN ('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'REFUNDED'))
                   DEFAULT 'PENDING',
    CreatedAt      DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE SET NULL,

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),

    CONSTRAINT FK_Orders_Branches
        FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
GO

-- =====================================================
-- 20. ORDER ITEMS
-- =====================================================
CREATE TABLE OrderItems (
    OrderItemID    BIGINT PRIMARY KEY IDENTITY(1,1),
    OrderID        BIGINT         NOT NULL,
    ProductID      BIGINT         NOT NULL,
    Quantity       INT            NOT NULL,
    UnitPrice      DECIMAL(18,2)  NOT NULL,
    DiscountAmount DECIMAL(18,2)  NOT NULL DEFAULT 0,
    Subtotal       AS ((UnitPrice - DiscountAmount) * Quantity) PERSISTED,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =====================================================
-- 21. PAYMENTS
-- =====================================================
CREATE TABLE Payments (
    PaymentID     BIGINT PRIMARY KEY IDENTITY(1,1),
    OrderID       BIGINT         NOT NULL,
    PaymentMethod VARCHAR(30)    NOT NULL
                  CHECK (PaymentMethod IN ('CASH', 'BANK_TRANSFER', 'CARD', 'E_WALLET', 'MIXED')),
    Amount        DECIMAL(18,2)  NOT NULL,
    PaidAt        DATETIME       DEFAULT GETDATE(),
    Reference     NVARCHAR(255),  -- mã tham chiếu chuyển khoản / QR
    Status        VARCHAR(20)    NOT NULL
                  CHECK (Status IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED'))
                  DEFAULT 'COMPLETED',
    CreatedAt     DATETIME       DEFAULT GETDATE(),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);
GO

-- =====================================================
-- 22. FINANCIAL TRANSACTIONS
-- Ghi nhận dòng tiền tổng hợp (thu/chi)
-- =====================================================
CREATE TABLE FinancialTransactions (
    FinancialTransactionID BIGINT PRIMARY KEY IDENTITY(1,1),
    BranchID               BIGINT        NOT NULL,
    EmployeeID             BIGINT        NOT NULL,
    PurchaseOrderID        BIGINT        NULL,
    TransactionCode        VARCHAR(50)   NOT NULL UNIQUE,
    TransactionDate        DATETIME      NOT NULL DEFAULT GETDATE(),
    TransactionType        VARCHAR(30)   NOT NULL
                           CHECK (TransactionType IN (
                               'REVENUE',     -- doanh thu bán hàng
                               'EXPENSE',     -- chi phí
                               'REFUND',      -- hoàn tiền
                               'PURCHASE'     -- thanh toán nhà cung cấp
                           )),
    Amount                 DECIMAL(18,2) NOT NULL,
    ReferenceID            BIGINT,       -- PaymentID hoặc PurchaseOrderID
    ReferenceType          VARCHAR(50),  -- 'Payment' | 'PurchaseOrder'
    Note                   NVARCHAR(MAX),
    CreatedAt              DATETIME      DEFAULT GETDATE(),

    CONSTRAINT FK_FinTxn_Branches
        FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),

    CONSTRAINT FK_FinTxn_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),

    CONSTRAINT FK_FinTxn_PurchaseOrders
        FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrders(PurchaseOrderID)
        ON DELETE SET NULL
);
GO

-- =====================================================
-- END OF SCRIPT
-- =====================================================