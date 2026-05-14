# KiotRetail - Quick Start Guide

## Bắt đầu nhanh trong 5 phút

### Bước 1: Cài đặt Database (2 phút)

```bash
# Mở MySQL Command Line hoặc MySQL Workbench
mysql -u root -p

# Import database
source D:/code/kiotretail/sql/schema.sql

# Hoặc copy-paste nội dung file schema.sql vào MySQL Workbench và Execute
```

### Bước 2: Cấu hình kết nối Database (1 phút)

Mở file: `src/main/java/com/kiotretail/util/DatabaseUtil.java`

Sửa thông tin kết nối:
```java
private static final String USERNAME = "root";
private static final String PASSWORD = "your_mysql_password";
```

### Bước 3: Build và Deploy (2 phút)

#### Sử dụng Maven:
```bash
cd D:\code\kiotretail
mvn clean package
# File WAR sẽ được tạo trong target/kiotretail.war
# Copy vào tomcat/webapps/
```

#### Hoặc sử dụng IDE:
1. Import project vào Eclipse/IntelliJ
2. Add Tomcat Server
3. Deploy project
4. Start server

### Bước 4: Truy cập ứng dụng

```
http://localhost:8080/kiotretail/
```

**Đăng nhập:**
- Username: `admin`
- Password: `123456`

## Cấu trúc Project đã tạo

```
kiotretail/
├── sql/
│   └── schema.sql                          ✅ Database schema với dữ liệu mẫu
│
├── src/main/
│   ├── java/com/kiotretail/
│   │   ├── controller/
│   │   │   ├── LoginServlet.java           ✅ Xử lý đăng nhập
│   │   │   ├── LogoutServlet.java          ✅ Xử lý đăng xuất
│   │   │   ├── RoleSelectionServlet.java   ✅ Chọn vai trò
│   │   │   ├── DashboardServlet.java       ✅ Trang tổng quan
│   │   │   └── ProductServlet.java         ✅ Quản lý sản phẩm
│   │   │
│   │   ├── dao/
│   │   │   ├── EmployeeDAO.java            ✅ DAO cho nhân viên
│   │   │   └── ProductDAO.java             ✅ DAO cho sản phẩm
│   │   │
│   │   ├── model/
│   │   │   ├── Employee.java               ✅ Model nhân viên
│   │   │   └── Product.java                ✅ Model sản phẩm
│   │   │
│   │   ├── filter/
│   │   │   ├── EncodingFilter.java         ✅ UTF-8 encoding
│   │   │   └── AuthFilter.java             ✅ Kiểm tra đăng nhập
│   │   │
│   │   └── util/
│   │       └── DatabaseUtil.java           ✅ Kết nối database
│   │
│   └── webapp/
│       ├── WEB-INF/
│       │   ├── web.xml                     ✅ Cấu hình web
│       │   └── views/
│       │       ├── common/
│       │       │   ├── header.jsp          ✅ Header component
│       │       │   ├── footer.jsp          ✅ Footer component
│       │       │   └── sidebar.jsp         ✅ Sidebar navigation
│       │       ├── auth/
│       │       │   ├── login.jsp           ✅ Trang đăng nhập
│       │       │   └── role-selection.jsp  ✅ Chọn vai trò
│       │       └── admin/
│       │           ├── dashboard.jsp       ✅ Trang tổng quan
│       │           └── products.jsp        ✅ Quản lý sản phẩm
│       │
│       ├── assets/
│       │   ├── css/
│       │   │   └── style.css               ✅ Custom CSS
│       │   └── js/
│       │       └── main.js                 ✅ JavaScript utilities
│       │
│       └── index.jsp                       ✅ Landing page
│
├── pom.xml                                 ✅ Maven configuration
└── README.md                               ✅ Hướng dẫn chi tiết
```

## Tính năng đã triển khai

### ✅ Hoàn thành
- [x] Database schema với dữ liệu mẫu
- [x] Đăng nhập/Đăng xuất
- [x] Chọn vai trò (POS/Admin)
- [x] Dashboard với thống kê
- [x] Quản lý sản phẩm (CRUD)
- [x] Tìm kiếm sản phẩm
- [x] Responsive design
- [x] UTF-8 encoding
- [x] Authentication filter
- [x] MVC architecture
- [x] DAO pattern
- [x] Reusable JSP components

### 🚧 Cần mở rộng
- [ ] Giao diện POS (Point of Sale)
- [ ] Quản lý hóa đơn
- [ ] Quản lý khách hàng
- [ ] Quản lý nhân viên
- [ ] Báo cáo chi tiết
- [ ] Sổ quỹ
- [ ] Quản lý phân quyền
- [ ] In hóa đơn
- [ ] Export Excel/PDF

## Các trang đã tạo

1. **Landing Page** (`/`)
   - Giới thiệu hệ thống
   - Tính năng nổi bật
   - Link đăng nhập

2. **Login** (`/login`)
   - Form đăng nhập
   - Ghi nhớ đăng nhập
   - Validation

3. **Role Selection** (`/role-selection`)
   - Chọn vai trò POS hoặc Admin
   - UI card đẹp mắt

4. **Dashboard** (`/admin/dashboard`)
   - Thống kê tổng quan
   - Biểu đồ doanh thu
   - Sản phẩm bán chạy
   - Giao dịch gần đây
   - Cảnh báo tồn kho

5. **Products Management** (`/admin/products`)
   - Danh sách sản phẩm
   - Thêm/Sửa/Xóa
   - Tìm kiếm
   - Lọc theo danh mục
   - Hiển thị tồn kho

## Mở rộng thêm tính năng

### Thêm module mới (Ví dụ: Customers)

1. **Tạo Model**: `src/main/java/com/kiotretail/model/Customer.java`
2. **Tạo DAO**: `src/main/java/com/kiotretail/dao/CustomerDAO.java`
3. **Tạo Servlet**: `src/main/java/com/kiotretail/controller/CustomerServlet.java`
4. **Tạo JSP**: `src/main/webapp/WEB-INF/views/admin/customers.jsp`
5. **Cập nhật web.xml**: Thêm servlet mapping
6. **Cập nhật sidebar**: Thêm menu item

### Thêm API endpoint

```java
@WebServlet("/api/products")
public class ProductAPIServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("application/json");
        // Return JSON
    }
}
```

## Troubleshooting nhanh

### Lỗi kết nối database
```bash
# Kiểm tra MySQL đang chạy
mysql -u root -p

# Test connection
SELECT 1;
```

### Lỗi 404
- Kiểm tra context path: `/kiotretail/`
- Kiểm tra servlet mapping trong web.xml

### Lỗi tiếng Việt
- Đảm bảo database charset: `utf8mb4`
- Kiểm tra EncodingFilter trong web.xml

### Lỗi JSTL
```bash
# Thêm vào WEB-INF/lib/
jstl-1.2.jar
```

## Dependencies cần thiết

### Thư viện JAR (nếu không dùng Maven)
1. `mysql-connector-java-8.0.33.jar`
2. `jstl-1.2.jar`
3. `servlet-api-4.0.jar` (provided by Tomcat)

### Download links
- MySQL Connector: https://dev.mysql.com/downloads/connector/j/
- JSTL: https://repo1.maven.org/maven2/javax/servlet/jstl/1.2/

## Liên hệ & Hỗ trợ

- GitHub Issues: [Report bugs]
- Email: support@kiotretail.vn
- Documentation: README.md

---

**Chúc bạn triển khai thành công! 🚀**
