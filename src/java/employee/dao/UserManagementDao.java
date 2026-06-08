/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package employee.dao;

/**
 *
 * @author Dzung
 */
import employee.model.Branch;
import employee.model.Employee;
import employee.model.Role;
import employee.service.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserManagementDao extends DBContext {

    // =====================================================
    // COMMON SELECT PART
    // =====================================================

    private static final String USER_SELECT =
            "SELECT DISTINCT " +
            "    e.EmployeeID, " +
            "    e.RoleID, " +
            "    e.BranchID, " +
            "    e.FullName, " +
            "    e.Email, " +
            "    e.Phone, " +
            "    e.Status, " +
            "    e.CreatedAt, " +
            "    r.Name AS RoleName, " +
            "    b.Name AS BranchName, " +
            "    COALESCE( " +
            "        STUFF(( " +
            "            SELECT ', ' + r2.Name " +
            "            FROM EmployeeRole er2 " +
            "            JOIN Role r2 ON er2.RoleID = r2.RoleID " +
            "            WHERE er2.EmployeeID = e.EmployeeID " +
            "            FOR XML PATH(''), TYPE " +
            "        ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''), " +
            "        r.Name " +
            "    ) AS RoleNames " +
            "FROM Employee e " +
            "LEFT JOIN Role r ON e.RoleID = r.RoleID " +
            "LEFT JOIN Branch b ON e.BranchID = b.BranchID ";

    // =====================================================
    // ADMIN SIDE
    // Admin view/add/edit/lock/unlock/reset Owner
    // =====================================================

    public List<Employee> getOwners(String keyword, String statusFilter) {
        List<Employee> list = new ArrayList<Employee>();

        String sql =
                USER_SELECT +
                "WHERE EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = e.EmployeeID " +
                "      AND rr.Name = 'Owner' " +
                ") " +
                "AND ( " +
                "    ? IS NULL " +
                "    OR e.FullName LIKE ? " +
                "    OR e.Email LIKE ? " +
                "    OR e.Phone LIKE ? " +
                ") " +
                "AND (? IS NULL OR e.Status = ?) " +
                "ORDER BY e.EmployeeID DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchValue = normalizeLike(keyword);
            String statusValue = normalize(statusFilter);

            ps.setString(1, searchValue);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);
            ps.setString(4, searchValue);
            ps.setString(5, statusValue);
            ps.setString(6, statusValue);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEmployee(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Employee getOwnerById(int employeeId) {
        String sql =
                USER_SELECT +
                "WHERE e.EmployeeID = ? " +
                "AND EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = e.EmployeeID " +
                "      AND rr.Name = 'Owner' " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, employeeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEmployee(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean createOwner(Employee owner, String hashedPassword) {
        int ownerRoleId = getRoleIdByName("Owner");

        if (ownerRoleId <= 0) {
            throw new IllegalStateException("Role Owner does not exist in database.");
        }

        String insertEmployeeSql =
                "INSERT INTO Employee " +
                "(RoleID, BranchID, FullName, Email, Phone, PasswordHash, Status) " +
                "VALUES (?, NULL, ?, ?, ?, ?, ?)";

        String insertEmployeeRoleSql =
                "INSERT INTO EmployeeRole (EmployeeID, RoleID) " +
                "VALUES (?, ?)";

        try {
            connection.setAutoCommit(false);

            int newEmployeeId;

            try (PreparedStatement ps = connection.prepareStatement(
                    insertEmployeeSql,
                    Statement.RETURN_GENERATED_KEYS
            )) {
                ps.setInt(1, ownerRoleId);
                ps.setString(2, owner.getFullName());
                ps.setString(3, owner.getEmail());
                ps.setString(4, owner.getPhone());
                ps.setString(5, hashedPassword);
                ps.setString(6, normalize(owner.getStatus()) == null ? "active" : owner.getStatus());

                int affectedRows = ps.executeUpdate();

                if (affectedRows == 0) {
                    connection.rollback();
                    return false;
                }

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        connection.rollback();
                        return false;
                    }

                    newEmployeeId = keys.getInt(1);
                }
            }

            try (PreparedStatement psRole = connection.prepareStatement(insertEmployeeRoleSql)) {
                psRole.setInt(1, newEmployeeId);
                psRole.setInt(2, ownerRoleId);
                psRole.executeUpdate();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return false;
        } finally {
            setAutoCommitTrueQuietly();
        }
    }

    public boolean updateOwner(Employee owner) {
        String sql =
                "UPDATE Employee " +
                "SET FullName = ?, Email = ?, Phone = ?, Status = ? " +
                "WHERE EmployeeID = ? " +
                "AND EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = Employee.EmployeeID " +
                "      AND rr.Name = 'Owner' " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, owner.getFullName());
            ps.setString(2, owner.getEmail());
            ps.setString(3, owner.getPhone());
            ps.setString(4, owner.getStatus());
            ps.setInt(5, owner.getEmployeeId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateOwnerStatus(int employeeId, String status) {
        String sql =
                "UPDATE Employee " +
                "SET Status = ? " +
                "WHERE EmployeeID = ? " +
                "AND EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = Employee.EmployeeID " +
                "      AND rr.Name = 'Owner' " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, employeeId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean resetOwnerPassword(int employeeId, String hashedPassword) {
        String sql =
                "UPDATE Employee " +
                "SET PasswordHash = ? " +
                "WHERE EmployeeID = ? " +
                "AND EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = Employee.EmployeeID " +
                "      AND rr.Name = 'Owner' " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, employeeId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =====================================================
    // OWNER SIDE
    // Owner view/add/edit/lock/unlock/reset Employee
    // =====================================================

    public List<Employee> getEmployees(String keyword,
                                       String branchFilter,
                                       String roleFilter,
                                       String statusFilter) {
        List<Employee> list = new ArrayList<Employee>();

        String sql =
                USER_SELECT +
                "WHERE NOT EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = e.EmployeeID " +
                "      AND rr.Name IN ('Admin', 'Owner') " +
                ") " +
                "AND ( " +
                "    ? IS NULL " +
                "    OR e.FullName LIKE ? " +
                "    OR e.Email LIKE ? " +
                "    OR e.Phone LIKE ? " +
                ") " +
                "AND (? IS NULL OR e.BranchID = ?) " +
                "AND (? IS NULL OR EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er3 " +
                "    WHERE er3.EmployeeID = e.EmployeeID " +
                "      AND er3.RoleID = ? " +
                ")) " +
                "AND (? IS NULL OR e.Status = ?) " +
                "ORDER BY e.EmployeeID DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchValue = normalizeLike(keyword);
            Integer branchId = parseInteger(branchFilter);
            Integer roleId = parseInteger(roleFilter);
            String statusValue = normalize(statusFilter);

            ps.setString(1, searchValue);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);
            ps.setString(4, searchValue);

            setNullableInt(ps, 5, branchId);
            setNullableInt(ps, 6, branchId);

            setNullableInt(ps, 7, roleId);
            setNullableInt(ps, 8, roleId);

            ps.setString(9, statusValue);
            ps.setString(10, statusValue);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEmployee(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Employee getEmployeeById(int employeeId) {
        String sql =
                USER_SELECT +
                "WHERE e.EmployeeID = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = e.EmployeeID " +
                "      AND rr.Name IN ('Admin', 'Owner') " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, employeeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEmployee(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Integer> getEmployeeRoleIds(int employeeId) {
        List<Integer> roleIds = new ArrayList<Integer>();

        String sql =
                "SELECT RoleID " +
                "FROM EmployeeRole " +
                "WHERE EmployeeID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, employeeId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roleIds.add(rs.getInt("RoleID"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return roleIds;
    }

    public boolean addEmployee(Employee employee, String hashedPassword, int[] roleIds) {
        if (roleIds == null || roleIds.length == 0) {
            return false;
        }

        int primaryRoleId = roleIds[0];

        String insertEmployeeSql =
                "INSERT INTO Employee " +
                "(RoleID, BranchID, FullName, Email, Phone, PasswordHash, Status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String insertRoleSql =
                "INSERT INTO EmployeeRole (EmployeeID, RoleID) " +
                "VALUES (?, ?)";

        try {
            connection.setAutoCommit(false);

            int newEmployeeId;

            try (PreparedStatement ps = connection.prepareStatement(
                    insertEmployeeSql,
                    Statement.RETURN_GENERATED_KEYS
            )) {
                ps.setInt(1, primaryRoleId);
                setNullableInt(ps, 2, employee.getBranchId());
                ps.setString(3, employee.getFullName());
                ps.setString(4, employee.getEmail());
                ps.setString(5, employee.getPhone());
                ps.setString(6, hashedPassword);
                ps.setString(7, normalize(employee.getStatus()) == null ? "active" : employee.getStatus());

                int affectedRows = ps.executeUpdate();

                if (affectedRows == 0) {
                    connection.rollback();
                    return false;
                }

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        connection.rollback();
                        return false;
                    }

                    newEmployeeId = keys.getInt(1);
                }
            }

            try (PreparedStatement rolePs = connection.prepareStatement(insertRoleSql)) {
                for (int roleId : roleIds) {
                    rolePs.setInt(1, newEmployeeId);
                    rolePs.setInt(2, roleId);
                    rolePs.addBatch();
                }

                rolePs.executeBatch();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return false;
        } finally {
            setAutoCommitTrueQuietly();
        }
    }

    public boolean updateEmployee(Employee employee, int[] roleIds) {
        if (roleIds == null || roleIds.length == 0) {
            return false;
        }

        int primaryRoleId = roleIds[0];

        String updateEmployeeSql =
                "UPDATE Employee " +
                "SET RoleID = ?, " +
                "    BranchID = ?, " +
                "    FullName = ?, " +
                "    Email = ?, " +
                "    Phone = ?, " +
                "    Status = ? " +
                "WHERE EmployeeID = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = Employee.EmployeeID " +
                "      AND rr.Name IN ('Admin', 'Owner') " +
                ")";

        String deleteRoleSql =
                "DELETE FROM EmployeeRole " +
                "WHERE EmployeeID = ?";

        String insertRoleSql =
                "INSERT INTO EmployeeRole (EmployeeID, RoleID) " +
                "VALUES (?, ?)";

        try {
            connection.setAutoCommit(false);

            try (PreparedStatement ps = connection.prepareStatement(updateEmployeeSql)) {
                ps.setInt(1, primaryRoleId);
                setNullableInt(ps, 2, employee.getBranchId());
                ps.setString(3, employee.getFullName());
                ps.setString(4, employee.getEmail());
                ps.setString(5, employee.getPhone());
                ps.setString(6, employee.getStatus());
                ps.setInt(7, employee.getEmployeeId());

                int updated = ps.executeUpdate();

                if (updated == 0) {
                    connection.rollback();
                    return false;
                }
            }

            try (PreparedStatement deletePs = connection.prepareStatement(deleteRoleSql)) {
                deletePs.setInt(1, employee.getEmployeeId());
                deletePs.executeUpdate();
            }

            try (PreparedStatement rolePs = connection.prepareStatement(insertRoleSql)) {
                for (int roleId : roleIds) {
                    rolePs.setInt(1, employee.getEmployeeId());
                    rolePs.setInt(2, roleId);
                    rolePs.addBatch();
                }

                rolePs.executeBatch();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return false;
        } finally {
            setAutoCommitTrueQuietly();
        }
    }

    public boolean updateEmployeeStatus(int employeeId, String status) {
        String sql =
                "UPDATE Employee " +
                "SET Status = ? " +
                "WHERE EmployeeID = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = Employee.EmployeeID " +
                "      AND rr.Name IN ('Admin', 'Owner') " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, employeeId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean resetEmployeePassword(int employeeId, String hashedPassword) {
        String sql =
                "UPDATE Employee " +
                "SET PasswordHash = ? " +
                "WHERE EmployeeID = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = Employee.EmployeeID " +
                "      AND rr.Name IN ('Admin', 'Owner') " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, employeeId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =====================================================
    // MANAGER SIDE
    // StoreManager view employees in assigned branch
    // =====================================================

    public List<Employee> getEmployeesByBranch(int managerBranchId,
                                               String keyword,
                                               String roleFilter,
                                               String statusFilter) {
        List<Employee> list = new ArrayList<Employee>();

        String sql =
                USER_SELECT +
                "WHERE e.BranchID = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = e.EmployeeID " +
                "      AND rr.Name IN ('Admin', 'Owner') " +
                ") " +
                "AND ( " +
                "    ? IS NULL " +
                "    OR e.FullName LIKE ? " +
                "    OR e.Email LIKE ? " +
                "    OR e.Phone LIKE ? " +
                ") " +
                "AND (? IS NULL OR EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er3 " +
                "    WHERE er3.EmployeeID = e.EmployeeID " +
                "      AND er3.RoleID = ? " +
                ")) " +
                "AND (? IS NULL OR e.Status = ?) " +
                "ORDER BY e.EmployeeID DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchValue = normalizeLike(keyword);
            Integer roleId = parseInteger(roleFilter);
            String statusValue = normalize(statusFilter);

            ps.setInt(1, managerBranchId);

            ps.setString(2, searchValue);
            ps.setString(3, searchValue);
            ps.setString(4, searchValue);
            ps.setString(5, searchValue);

            setNullableInt(ps, 6, roleId);
            setNullableInt(ps, 7, roleId);

            ps.setString(8, statusValue);
            ps.setString(9, statusValue);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEmployee(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Employee getEmployeeByIdInBranch(int employeeId, int managerBranchId) {
        String sql =
                USER_SELECT +
                "WHERE e.EmployeeID = ? " +
                "AND e.BranchID = ? " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 " +
                "    FROM EmployeeRole er " +
                "    JOIN Role rr ON er.RoleID = rr.RoleID " +
                "    WHERE er.EmployeeID = e.EmployeeID " +
                "      AND rr.Name IN ('Admin', 'Owner') " +
                ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, managerBranchId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEmployee(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // =====================================================
    // COMMON DATA FOR USER MANAGEMENT PAGE
    // =====================================================

    public List<Role> getEmployeeRoles() {
        List<Role> list = new ArrayList<Role>();

        String sql =
                "SELECT RoleID, Name, Description " +
                "FROM Role " +
                "WHERE Name IN ('StoreManager', 'SalesStaff', 'WarehouseStaff') " +
                "ORDER BY RoleID";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Role role = new Role();

                role.setRoleID(rs.getInt("RoleID"));
                role.setName(rs.getString("Name"));
                role.setDescription(rs.getString("Description"));

                list.add(role);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Branch> getAllBranches() {
        List<Branch> list = new ArrayList<Branch>();

        String sql =
                "SELECT BranchID, Name, Address, Phone, Status " +
                "FROM Branch " +
                "ORDER BY BranchID";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Branch branch = new Branch();

                branch.setBranchID(rs.getInt("BranchID"));
                branch.setName(rs.getString("Name"));
                branch.setAddress(rs.getString("Address"));
                branch.setPhone(rs.getString("Phone"));
                branch.setStatus(rs.getString("Status"));

                list.add(branch);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // =====================================================
    // DUPLICATE CHECK
    // =====================================================

    public boolean isEmailExists(String email, Integer excludeEmployeeId) {
        return isEmailExists(email, null, excludeEmployeeId);
    }

    public boolean isEmailExists(String email, String phone, Integer excludeEmployeeId) {
        String normalizedEmail = normalize(email);
        String normalizedPhone = normalize(phone);

        if (normalizedEmail == null && normalizedPhone == null) {
            return false;
        }

        String sql =
                "SELECT COUNT(*) AS Total " +
                "FROM Employee " +
                "WHERE ( " +
                "    (? IS NOT NULL AND Email = ?) " +
                "    OR (? IS NOT NULL AND Phone = ?) " +
                ") " +
                "AND (? IS NULL OR EmployeeID <> ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, normalizedEmail);
            ps.setString(2, normalizedEmail);
            ps.setString(3, normalizedPhone);
            ps.setString(4, normalizedPhone);

            if (excludeEmployeeId == null) {
                ps.setNull(5, Types.INTEGER);
                ps.setNull(6, Types.INTEGER);
            } else {
                ps.setInt(5, excludeEmployeeId);
                ps.setInt(6, excludeEmployeeId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Total") > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return true;
    }

    // =====================================================
    // PRIVATE HELPER METHODS
    // =====================================================
    
    public Employee getEmployeeInfoById(int id) {
        String sql = "SELECT EmployeeID, Email, FullName " +
                     "FROM Employee " +
                     "WHERE EmployeeID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Employee employee = new Employee();

                    employee.setEmployeeID(rs.getInt("EmployeeID"));
                    employee.setEmail(rs.getString("Email"));
                    employee.setFullName(rs.getString("FullName"));

                    return employee;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
    private int getRoleIdByName(String roleName) {
        String sql =
                "SELECT RoleID " +
                "FROM Role " +
                "WHERE Name = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, roleName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("RoleID");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }

    private Employee mapEmployee(ResultSet rs) throws SQLException {
        Employee employee = new Employee();

        employee.setEmployeeID(rs.getInt("EmployeeID"));
        employee.setRoleID(rs.getInt("RoleID"));

        int branchId = rs.getInt("BranchID");
        if (rs.wasNull()) {
            employee.setBranchID((Integer) null);
        } else {
            employee.setBranchID(branchId);
        }

        employee.setFullName(rs.getString("FullName"));
        employee.setEmail(rs.getString("Email"));
        employee.setPhone(rs.getString("Phone"));
        employee.setStatus(rs.getString("Status"));
        employee.setCreatedAt(rs.getTimestamp("CreatedAt"));

        employee.setRoleName(rs.getString("RoleName"));
        employee.setRoleNames(rs.getString("RoleNames"));
        employee.setBranchName(rs.getString("BranchName"));

        return employee;
    }

    private String normalize(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private String normalizeLike(String value) {
        String normalized = normalize(value);

        if (normalized == null) {
            return null;
        }

        normalized = normalized.replaceAll("\\s+", " ");

        return "%" + normalized + "%";
    }

    private Integer parseInteger(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }

            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value)
            throws SQLException {
        if (value == null || value <= 0) {
            ps.setNull(index, Types.INTEGER);
        } else {
            ps.setInt(index, value);
        }
    }

    private void rollbackQuietly() {
        try {
            connection.rollback();
        } catch (SQLException ignored) {
        }
    }

    private void setAutoCommitTrueQuietly() {
        try {
            connection.setAutoCommit(true);
        } catch (SQLException ignored) {
        }
    }
}
