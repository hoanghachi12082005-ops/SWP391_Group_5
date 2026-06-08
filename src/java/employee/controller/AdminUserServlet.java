/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package employee.controller;

import employee.dao.UserManagementDao;
import employee.model.Employee;
import employee.service.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import employee.service.EmailUtil;

public class AdminUserServlet extends HttpServlet {

    private UserManagementDao adminUserDao;

    @Override
    public void init() throws ServletException {
        adminUserDao = new UserManagementDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }

        String action = getParam(request, "action", "list");

        switch (action) {
            case "add":
                request.setAttribute("formMode", "add");
                break;
            case "edit":
                loadSelectedOwner(request, "editingUser");
                request.setAttribute("formMode", "edit");
                break;
            case "detail":
                loadSelectedOwner(request, "detailUser");
                request.setAttribute("formMode", "detail");
                break;
            case "reset":
                loadSelectedOwner(request, "resetUser");
                request.setAttribute("formMode", "reset");
                break;
            default:
                request.setAttribute("formMode", "list");
                break;
        }

        loadOwnerList(request);

        request.setAttribute("pageTitle", "Owner Account Management");
        request.setAttribute("pageSubtitle", "Admin views and manages all owner accounts in the system");
        request.setAttribute("addButtonText", "Add Owner");
        request.setAttribute("baseUrl", request.getContextPath() + "/admin/users");

        request.setAttribute("showBranch", false);
        request.setAttribute("canCreate", true);
        request.setAttribute("canEdit", true);
        request.setAttribute("canLock", true);
        request.setAttribute("canResetPassword", true);

        request.getRequestDispatcher("/view/user/user-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }

        String action = getParam(request, "action", "list");

        switch (action) {
            case "create":
                createOwner(request);
                break;
            case "update":
                updateOwner(request);
                break;
            case "lock":
                updateStatus(request, "locked");
                break;
            case "unlock":
                updateStatus(request, "active");
                break;
            case "resetPassword":
                resetPassword(request);
                break;
            default:
                setFlash(request, "errorMessage", "Invalid action.");
                break;
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void loadOwnerList(HttpServletRequest request) {
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        request.setAttribute("users", adminUserDao.getOwners(keyword, status));
        request.setAttribute("keyword", keyword);
        request.setAttribute("statusFilter", status);
    }

    private void loadSelectedOwner(HttpServletRequest request, String attributeName) {
        int employeeId = parseInt(request.getParameter("id"), -1);
        if (employeeId > 0) {
            request.setAttribute(attributeName, adminUserDao.getOwnerById(employeeId));
        }
    }

    private void createOwner(HttpServletRequest request) {
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String password = request.getParameter("password");
        String status = trim(request.getParameter("status"));

        if (isBlank(fullName) || isBlank(email) || isBlank(password)) {
            setFlash(request, "errorMessage", "Full name, email and password are required.");
            return;
        }

        if (adminUserDao.isEmailExists(email,phone, null)) {
            setFlash(request, "errorMessage", "Email already exists.");
            return;
        }

        Employee owner = new Employee();
        owner.setFullName(fullName);
        owner.setEmail(email);
        owner.setPhone(phone);
        owner.setStatus(isBlank(status) ? "active" : status);

        boolean success = adminUserDao.createOwner(owner, PasswordUtil.hashPassword(password));

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Owner account created successfully." : "Cannot create owner account."
        );
    }

    private void updateOwner(HttpServletRequest request) {
        int employeeId = parseInt(request.getParameter("employeeId"), -1);
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String status = trim(request.getParameter("status"));

        if (employeeId <= 0 || isBlank(fullName) || isBlank(email)) {
            setFlash(request, "errorMessage", "Invalid owner update data.");
            return;
        }

        if (adminUserDao.isEmailExists(email,phone,employeeId)) {
            setFlash(request, "errorMessage", "Email already exists.");
            return;
        }

        Employee owner = new Employee();
        owner.setEmployeeId(employeeId);
        owner.setFullName(fullName);
        owner.setEmail(email);
        owner.setPhone(phone);
        owner.setStatus(isBlank(status) ? "active" : status);

        boolean success = adminUserDao.updateOwner(owner);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Owner account updated successfully." : "Cannot update owner account."
        );
    }

    private void updateStatus(HttpServletRequest request, String status) {
        int employeeId = parseInt(request.getParameter("employeeId"), -1);

        if (employeeId <= 0) {
            setFlash(request, "errorMessage", "Invalid owner ID.");
            return;
        }

        boolean success = adminUserDao.updateOwnerStatus(employeeId, status);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Owner status updated successfully." : "Cannot update owner status."
        );
    }

    private void resetPassword(HttpServletRequest request) {
        int employeeId = parseInt(request.getParameter("employeeId"), -1);
        String autoGeneratedPassword = EmailUtil.generateRandomPassword();

        if (employeeId <= 0 ) {
            setFlash(request, "errorMessage", "Invalid reset password data.");
            return;
        }
        Employee employee = adminUserDao.getEmployeeInfoById(employeeId);
        
        boolean isMailSent = EmailUtil.sendPasswordEmail(employee.getEmail(), employee.getFullName(), autoGeneratedPassword);

        if (!isMailSent) {
            setFlash(request, "errorMessage", "Cannot send password email. Please check email configuration.");
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(autoGeneratedPassword);

        boolean success = adminUserDao.resetEmployeePassword(employeeId, hashedPassword);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Employee password reset successfully." : "Cannot reset employee password."
        );
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        String roleName = (String) session.getAttribute("roleName");

        if (!"Admin".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin only.");
            return false;
        }

        return true;
    }

    private void setFlash(HttpServletRequest request, String key, String message) {
        request.getSession().setAttribute(key, message);
    }

    private String getParam(HttpServletRequest request, String name, String defaultValue) {
        String value = request.getParameter(name);
        return isBlank(value) ? defaultValue : value.trim();
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
