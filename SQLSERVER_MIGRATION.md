# SQL Server Migration Guide

## ✅ Đã chuyển đổi sang SQL Server

### Thay đổi đã thực hiện:

1. **Database Schema** (`sql/schema_sqlserver.sql`)
   - Chuyển từ MySQL sang SQL Server syntax
   - Sử dụng `NVARCHAR` thay vì `VARCHAR` cho Unicode
   - Sử dụng `DATETIME2` thay vì `TIMESTAMP`
   - Sử dụng `IDENTITY(1,1)` thay vì `AUTO_INCREMENT`
   - Sử dụng `BIT` thay vì `BOOLEAN`
   - Sử dụng `GETDATE()` thay vì `CURRENT_TIMESTAMP`
   - Thêm `SET IDENTITY_INSERT` cho sample data

2. **DatabaseUtil.java**
   - URL: `jdbc:sqlserver://localhost:1433;databaseName=SamplePE;trustServerCertificate=true`
   - Driver: `com.microsoft.sqlserver.jdbc.SQLServerDriver`
   - Username: `sa`
   - Password: `123456`

3. **pom.xml**
   - Thay MySQL Connector bằng SQL Server JDBC Driver
   - Dependency: `mssql-jdbc` version 12.4.2.jre8

4. **web.xml**
   - Cập nhật database configuration parameters

## 🚀 Hướng dẫn cài đặt

### Bước 1: Cài đặt SQL Server

Đảm bảo SQL Server đã được cài đặt và đang chạy trên port 1433.

### Bước 2: Tạo Database

**Cách 1: Sử dụng SQL Server Management Studio (SSMS)**
1. Mở SSMS
2. Connect với: `localhost` / `sa` / `123456`
3. Mở file `sql/schema_sqlserver.sql`
4. Execute (F5)

**Cách 2: Sử dụng sqlcmd**
```bash
sqlcmd -S localhost -U sa -P 123456 -i "D:\code\kiotretail\sql\schema_sqlserver.sql"
```

### Bước 3: Kiểm tra Database

```sql
USE SamplePE;
GO

-- Kiểm tra tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- Kiểm tra dữ liệu mẫu
SELECT * FROM employees;
SELECT * FROM products;
```

### Bước 4: Thêm SQL Server JDBC Driver

**Cách 1: Sử dụng Maven**
```bash
mvn clean install
```

**Cách 2: Thêm JAR thủ công**
1. Download SQL Server JDBC Driver từ:
   https://learn.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server
2. Copy file `mssql-jdbc-12.4.2.jre8.jar` vào `WEB-INF/lib/`

### Bước 5: Build và Deploy

```bash
# Build project
mvn clean package

# Deploy to Tomcat
# Copy target/kiotretail.war to tomcat/webapps/

# Start Tomcat
cd C:\apache-tomcat-9.0.xx\bin
startup.bat
```

### Bước 6: Truy cập ứng dụng

```
http://localhost:8080/kiotretail/
```

**Login:**
- Username: `admin`
- Password: `123456`

## 📝 Sự khác biệt giữa MySQL và SQL Server

| Feature | MySQL | SQL Server |
|---------|-------|------------|
| String (Unicode) | VARCHAR | NVARCHAR |
| Auto Increment | AUTO_INCREMENT | IDENTITY(1,1) |
| Boolean | BOOLEAN | BIT |
| Timestamp | TIMESTAMP | DATETIME2 |
| Current Time | CURRENT_TIMESTAMP | GETDATE() |
| String Concat | CONCAT() | + operator |
| Limit | LIMIT n | TOP n |
| Engine | ENGINE=InnoDB | N/A |
| Charset | CHARACTER SET utf8mb4 | N/A (Unicode by default) |

## 🔧 Cấu hình Connection String

```
jdbc:sqlserver://localhost:1433;databaseName=SamplePE;trustServerCertificate=true
```

**Các tham số:**
- `localhost:1433` - Server và port
- `databaseName=SamplePE` - Tên database
- `trustServerCertificate=true` - Bỏ qua SSL certificate validation (cho development)

**Tham số bổ sung (optional):**
```
jdbc:sqlserver://localhost:1433;databaseName=SamplePE;trustServerCertificate=true;encrypt=false;integratedSecurity=false
```

## 🐛 Troubleshooting

### Lỗi: "Login failed for user 'sa'"
```sql
-- Enable SQL Server Authentication
-- Trong SSMS: Server Properties > Security > SQL Server and Windows Authentication mode
-- Restart SQL Server service
```

### Lỗi: "TCP/IP connection failed"
```
1. Mở SQL Server Configuration Manager
2. SQL Server Network Configuration > Protocols for MSSQLSERVER
3. Enable TCP/IP
4. Restart SQL Server service
```

### Lỗi: "The driver could not establish a secure connection"
```
Thêm trustServerCertificate=true vào connection string
```

### Lỗi: "Cannot insert explicit value for identity column"
```sql
-- Sử dụng SET IDENTITY_INSERT khi insert với ID cụ thể
SET IDENTITY_INSERT table_name ON;
INSERT INTO table_name (id, ...) VALUES (1, ...);
SET IDENTITY_INSERT table_name OFF;
```

## 📦 Dependencies

**Maven (pom.xml):**
```xml
<dependency>
    <groupId>com.microsoft.sqlserver</groupId>
    <artifactId>mssql-jdbc</artifactId>
    <version>12.4.2.jre8</version>
</dependency>
```

**Manual JAR:**
- Download: https://learn.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server
- File: `mssql-jdbc-12.4.2.jre8.jar`
- Location: `WEB-INF/lib/`

## ✅ Checklist

- [x] Tạo file schema SQL Server (`schema_sqlserver.sql`)
- [x] Cập nhật DatabaseUtil.java
- [x] Cập nhật pom.xml (SQL Server JDBC Driver)
- [x] Cập nhật web.xml (connection parameters)
- [x] Tạo migration guide

## 🎯 Các file đã thay đổi

1. `sql/schema_sqlserver.sql` - ✅ NEW (SQL Server schema)
2. `src/main/java/com/kiotretail/util/DatabaseUtil.java` - ✅ UPDATED
3. `pom.xml` - ✅ UPDATED
4. `src/main/webapp/WEB-INF/web.xml` - ✅ UPDATED
5. `SQLSERVER_MIGRATION.md` - ✅ NEW (this file)

## 📚 Tài liệu tham khảo

- SQL Server JDBC Driver: https://learn.microsoft.com/en-us/sql/connect/jdbc/
- SQL Server Data Types: https://learn.microsoft.com/en-us/sql/t-sql/data-types/
- Connection String: https://www.connectionstrings.com/sql-server/

---

**Lưu ý:** Tất cả các file Java DAO không cần thay đổi vì sử dụng JDBC standard API. Chỉ cần thay đổi connection string và driver class.
