/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package employee.dao;

/**
 *
 * @author PCQN
 */
import employee.model.Employee;
import employee.service.DBContext;

import java.sql.*;

public class ProfileDao extends DBContext {

    public Employee getProfileById(int employeeID) {
        String sql =
                "SELECT DISTINCT " +
                "    e.EmployeeID, " +
                "    e.RoleID, " +
                "    e.BranchID, " +
                "    e.FullName, " +
                "    e.Email, " +
                "    e.Phone, " +
                "    e.Status, " +
                "    e.CreatedAt, " +
                "    b.Name AS BranchName, " +
                "    STUFF(( " +
                "        SELECT ', ' + r2.Name " +
                "        FROM EmployeeRole er2 " +
                "        JOIN Role r2 ON er2.RoleID = r2.RoleID " +
                "        WHERE er2.EmployeeID = e.EmployeeID " +
                "        FOR XML PATH(''), TYPE " +
                "    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS RoleNames " +
                "FROM Employee e " +
                "LEFT JOIN Branch b ON e.BranchID = b.BranchID " +
                "WHERE e.EmployeeID = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, employeeID);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Employee employee = mapEmployee(rs);

                rs.close();
                ps.close();

                return employee;
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateProfile(int employeeID, String fullName, String email, String phone) {
        String sql =
                "UPDATE Employee " +
                "SET FullName = ?, Email = ?, Phone = ? " +
                "WHERE EmployeeID = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setInt(4, employeeID);

            boolean success = ps.executeUpdate() > 0;

            ps.close();

            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean isEmailExists(String email, int excludeEmployeeID) {
        String sql =
                "SELECT COUNT(*) AS Total " +
                "FROM Employee " +
                "WHERE Email = ? " +
                "AND EmployeeID <> ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, email);
            ps.setInt(2, excludeEmployeeID);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                boolean exists = rs.getInt("Total") > 0;

                rs.close();
                ps.close();

                return exists;
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return true;
    }

    public String getPasswordHash(int employeeID) {
        String sql =
                "SELECT PasswordHash " +
                "FROM Employee " +
                "WHERE EmployeeID = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, employeeID);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String passwordHash = rs.getString("PasswordHash");

                rs.close();
                ps.close();

                return passwordHash;
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updatePasswordHash(int employeeID, String newPasswordHash) {
        String sql =
                "UPDATE Employee " +
                "SET PasswordHash = ? " +
                "WHERE EmployeeID = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, newPasswordHash);   
            ps.setInt(2, employeeID);

            boolean success = ps.executeUpdate() > 0;

            ps.close();

            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private Employee mapEmployee(ResultSet rs) throws SQLException {
        Employee employee = new Employee();

        employee.setEmployeeID(rs.getInt("EmployeeID"));
        employee.setRoleID(rs.getInt("RoleID"));

        int branchID = rs.getInt("BranchID");

        if (!rs.wasNull()) {
            employee.setBranchID(branchID);
        }

        employee.setFullName(rs.getString("FullName"));
        employee.setEmail(rs.getString("Email"));
        employee.setPhone(rs.getString("Phone"));
        employee.setStatus(rs.getString("Status"));
        employee.setCreatedAt(rs.getTimestamp("CreatedAt"));
        employee.setBranchName(rs.getString("BranchName"));
        employee.setRoleNames(rs.getString("RoleNames"));

        return employee;
    }
}
