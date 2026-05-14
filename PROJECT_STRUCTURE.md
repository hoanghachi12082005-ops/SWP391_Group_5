# KiotRetail - Project Structure Summary

## 📁 Complete File Structure

```
D:\code\kiotretail\
│
├── 📄 pom.xml                                    # Maven configuration
├── 📄 README.md                                  # Full documentation
├── 📄 QUICKSTART.md                              # Quick start guide
│
├── 📁 sql\
│   └── 📄 schema.sql                             # Database schema + sample data
│
└── 📁 src\main\
    │
    ├── 📁 java\com\kiotretail\
    │   │
    │   ├── 📁 controller\                        # Servlet Controllers
    │   │   ├── 📄 LoginServlet.java              # Login handler
    │   │   ├── 📄 LogoutServlet.java             # Logout handler
    │   │   ├── 📄 RoleSelectionServlet.java      # Role selection
    │   │   ├── 📄 DashboardServlet.java          # Dashboard
    │   │   └── 📄 ProductServlet.java            # Product management
    │   │
    │   ├── 📁 dao\                               # Data Access Objects
    │   │   ├── 📄 EmployeeDAO.java               # Employee database operations
    │   │   └── 📄 ProductDAO.java                # Product database operations
    │   │
    │   ├── 📁 model\                             # Entity Models
    │   │   ├── 📄 Employee.java                  # Employee entity
    │   │   └── 📄 Product.java                   # Product entity
    │   │
    │   ├── 📁 filter\                            # Servlet Filters
    │   │   ├── 📄 EncodingFilter.java            # UTF-8 encoding
    │   │   └── 📄 AuthFilter.java                # Authentication
    │   │
    │   └── 📁 util\                              # Utilities
    │       └── 📄 DatabaseUtil.java              # Database connection
    │
    └── 📁 webapp\
        │
        ├── 📄 index.jsp                          # Landing page
        │
        ├── 📁 WEB-INF\
        │   │
        │   ├── 📄 web.xml                        # Web application config
        │   │
        │   └── 📁 views\                         # JSP Views
        │       │
        │       ├── 📁 common\                    # Reusable components
        │       │   ├── 📄 header.jsp             # Header component
        │       │   ├── 📄 footer.jsp             # Footer component
        │       │   └── 📄 sidebar.jsp            # Sidebar navigation
        │       │
        │       ├── 📁 auth\                      # Authentication pages
        │       │   ├── 📄 login.jsp              # Login page
        │       │   └── 📄 role-selection.jsp     # Role selection page
        │       │
        │       └── 📁 admin\                     # Admin pages
        │           ├── 📄 dashboard.jsp          # Dashboard
        │           └── 📄 products.jsp           # Product management
        │
        └── 📁 assets\                            # Static resources
            │
            ├── 📁 css\
            │   └── 📄 style.css                  # Custom styles
            │
            ├── 📁 js\
            │   └── 📄 main.js                    # JavaScript utilities
            │
            └── 📁 images\                        # Images folder (empty)
```

## 🗄️ Database Tables

```
kiotretail (Database)
├── roles                    # Vai trò
├── permissions              # Quyền hạn
├── branches                 # Chi nhánh
├── employees                # Nhân viên
├── categories               # Nhóm hàng
├── products                 # Hàng hóa
├── customers                # Khách hàng
├── suppliers                # Nhà cung cấp
├── invoices                 # Hóa đơn bán
├── invoice_details          # Chi tiết hóa đơn
├── purchase_orders          # Phiếu nhập hàng
├── purchase_order_details   # Chi tiết phiếu nhập
├── cash_transactions        # Sổ quỹ
└── price_lists              # Bảng giá
```

## 🎯 Features Implemented

### ✅ Core Features
- **Authentication System**
  - Login with username/password
  - Session management
  - Remember me functionality
  - Logout

- **Role-Based Access**
  - Role selection after login
  - Admin dashboard
  - POS interface (placeholder)

- **Product Management**
  - List all products
  - Add new product
  - Update product
  - Delete product (soft delete)
  - Search products
  - Filter by category
  - Stock level indicators

- **Dashboard**
  - Revenue statistics
  - Order count
  - Product count
  - Customer count
  - Recent transactions
  - Stock alerts
  - Best selling products

### 🎨 UI/UX Features
- Responsive design (Bootstrap 5)
- Material Icons
- Clean admin interface
- Professional color scheme (Red #93000b)
- Vietnamese language support
- Toast notifications
- Modal dialogs
- Loading spinners

### 🏗️ Architecture
- **MVC Pattern**
  - Model: Entity classes
  - View: JSP pages
  - Controller: Servlets

- **DAO Pattern**
  - Separation of data access logic
  - Reusable database operations

- **Filters**
  - UTF-8 encoding filter
  - Authentication filter

- **Reusable Components**
  - Header JSP
  - Footer JSP
  - Sidebar JSP

## 🔧 Technologies Used

| Technology | Version | Purpose |
|------------|---------|---------|
| Java | 8+ | Backend language |
| JSP | 2.3 | View layer |
| Servlet | 4.0 | Controller layer |
| JDBC | - | Database connectivity |
| MySQL | 8.0+ | Database |
| Bootstrap | 5.3.0 | CSS framework |
| Material Icons | - | Icon library |
| jQuery | 3.7.0 | JavaScript library |
| Apache Tomcat | 9.0+ | Application server |
| Maven | 3.6+ | Build tool |

## 📋 URL Mappings

| URL | Servlet | Description |
|-----|---------|-------------|
| `/` | - | Landing page |
| `/login` | LoginServlet | Login page |
| `/logout` | LogoutServlet | Logout |
| `/role-selection` | RoleSelectionServlet | Choose role |
| `/admin/dashboard` | DashboardServlet | Admin dashboard |
| `/admin/products` | ProductServlet | Product management |
| `/admin/invoices` | InvoiceServlet | Invoice management (TODO) |
| `/admin/customers` | CustomerServlet | Customer management (TODO) |
| `/admin/employees` | EmployeeServlet | Employee management (TODO) |
| `/pos/sale` | POSServlet | POS interface (TODO) |

## 🔐 Default Accounts

### Admin Account
```
Username: admin
Password: 123456
Role: Quản trị hệ thống
Employee Code: NV00124
Name: Nguyễn Văn Hải
```

### Staff Account
```
Username: thungan01
Password: 123456
Role: Nhân viên bán hàng
Employee Code: NV00125
Name: Trần Thị Mai
```

## 📦 Maven Dependencies

```xml
- javax.servlet-api (4.0.1)
- javax.servlet.jsp-api (2.3.3)
- jstl (1.2)
- mysql-connector-java (8.0.33)
- jbcrypt (0.4) - optional
- commons-lang3 (3.12.0) - optional
- gson (2.10.1) - optional
```

## 🚀 Deployment Steps

1. **Setup Database**
   ```bash
   mysql -u root -p < sql/schema.sql
   ```

2. **Configure Database Connection**
   - Edit `DatabaseUtil.java`
   - Update username/password

3. **Build Project**
   ```bash
   mvn clean package
   ```

4. **Deploy to Tomcat**
   - Copy `target/kiotretail.war` to `tomcat/webapps/`
   - Start Tomcat

5. **Access Application**
   ```
   http://localhost:8080/kiotretail/
   ```

## 📝 Next Steps for Development

### High Priority
1. Implement POS interface
2. Complete invoice management
3. Add customer management
4. Implement employee management
5. Create detailed reports

### Medium Priority
6. Add role permission management
7. Implement cash book
8. Add purchase order management
9. Create end-of-day report
10. Add print functionality

### Low Priority
11. Export to Excel/PDF
12. Email notifications
13. SMS integration
14. Multi-language support
15. Mobile app

## 📞 Support

For questions or issues:
- Check README.md for detailed documentation
- Check QUICKSTART.md for quick setup
- Review code comments for implementation details

---

**Project Status**: ✅ Core structure complete, ready for extension

**Last Updated**: 2024
**Version**: 1.0.0
