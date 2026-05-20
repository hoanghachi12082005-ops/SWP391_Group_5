CREATE DATABASE IF NOT EXISTS DBFinora;
USE DBFinora;
GO

-- =====================================================
-- 1. ROLES TABLE
-- =====================================================

CREATE TABLE Roles (
    RoleID BIGINT PRIMARY KEY IDENTITY(1,1),

    RoleName VARCHAR(50) NOT NULL UNIQUE,

    Description NVARCHAR(MAX),

    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- =====================================================
-- 2. STORE OWNERS TABLE
-- =====================================================

CREATE TABLE StoreOwners (
    OwnerID BIGINT PRIMARY KEY IDENTITY(1,1),

    FullName NVARCHAR(100) NOT NULL,

    Email VARCHAR(100) NOT NULL UNIQUE,

    Phone VARCHAR(20) UNIQUE,

    PasswordHash NVARCHAR(255) NOT NULL,

    AvatarURL NVARCHAR(255),

    Status VARCHAR(20)
    CHECK (Status IN ('ACTIVE', 'INACTIVE', 'LOCKED'))
    DEFAULT 'ACTIVE',

    LastLogin DATETIME NULL,

    CreatedAt DATETIME DEFAULT GETDATE(),

    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

-- =====================================================
-- 3. BRANCHES TABLE
-- =====================================================

CREATE TABLE Branches (
    BranchID BIGINT PRIMARY KEY IDENTITY(1,1),

    OwnerID BIGINT NOT NULL,

    BranchName NVARCHAR(100) NOT NULL,

    Phone VARCHAR(20),

    Address NVARCHAR(MAX),

    Status VARCHAR(20)
    CHECK (Status IN ('ACTIVE', 'INACTIVE'))
    DEFAULT 'ACTIVE',

    CreatedAt DATETIME DEFAULT GETDATE(),

    UpdatedAt DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Branches_StoreOwners
    FOREIGN KEY (OwnerID)
    REFERENCES StoreOwners(OwnerID)
    ON DELETE CASCADE
);
GO

-- =====================================================
-- 4. EMPLOYEES TABLE
-- =====================================================

CREATE TABLE Employees (
    EmployeeID BIGINT PRIMARY KEY IDENTITY(1,1),

    BranchID BIGINT NOT NULL,

    RoleID BIGINT NOT NULL,

    FullName NVARCHAR(100) NOT NULL,

    Email VARCHAR(100) NOT NULL UNIQUE,

    Phone VARCHAR(20) UNIQUE,

    PasswordHash NVARCHAR(255) NOT NULL,

    AvatarURL NVARCHAR(255),

    HireDate DATE,

    Salary DECIMAL(18,2),

    Status VARCHAR(20)
    CHECK (Status IN ('ACTIVE', 'INACTIVE', 'LOCKED'))
    DEFAULT 'ACTIVE',

    LastLogin DATETIME NULL,

    CreatedAt DATETIME DEFAULT GETDATE(),

    UpdatedAt DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Employees_Branches
    FOREIGN KEY (BranchID)
    REFERENCES Branches(BranchID)
    ON DELETE CASCADE,

    CONSTRAINT FK_Employees_Roles
    FOREIGN KEY (RoleID)
    REFERENCES Roles(RoleID)
);
GO

-- =====================================================
-- 5. REFRESH TOKENS TABLE
-- =====================================================

CREATE TABLE RefreshTokens (
    RefreshTokenID BIGINT PRIMARY KEY IDENTITY(1,1),

    EmployeeID BIGINT NULL,

    OwnerID BIGINT NULL,

    Token NVARCHAR(MAX) NOT NULL,

    ExpiredAt DATETIME NOT NULL,

    Revoked BIT DEFAULT 0,

    CreatedAt DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_RefreshTokens_Employees
    FOREIGN KEY (EmployeeID)
    REFERENCES Employees(EmployeeID),

    CONSTRAINT FK_RefreshTokens_StoreOwners
    FOREIGN KEY (OwnerID)
    REFERENCES StoreOwners(OwnerID)
);
GO

-- =====================================================
-- 6. PASSWORD RESET TOKENS TABLE
-- =====================================================

CREATE TABLE PasswordResetTokens (
    ResetID BIGINT PRIMARY KEY IDENTITY(1,1),

    Email VARCHAR(100) NOT NULL,

    Token NVARCHAR(255) NOT NULL UNIQUE,

    ExpiredAt DATETIME NOT NULL,

    Used BIT DEFAULT 0,

    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- =====================================================
-- 7. AUDIT LOGS TABLE
-- =====================================================

CREATE TABLE AuditLogs (
    LogID BIGINT PRIMARY KEY IDENTITY(1,1),

    ActorType VARCHAR(20)
    CHECK (ActorType IN ('OWNER', 'EMPLOYEE')),

    ActorID BIGINT NOT NULL,

    ActionName VARCHAR(100) NOT NULL,

    EntityType VARCHAR(100),

    EntityID BIGINT,

    Description NVARCHAR(MAX),

    IPAddress VARCHAR(45),

    UserAgent NVARCHAR(MAX),

    CreatedAt DATETIME DEFAULT GETDATE()
);
GO