/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package employee.controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author PCQN
 */
import employee.dao.UserManagementDao;
import employee.model.Employee;
import employee.service.EmailUtil;
import employee.service.PasswordUtil;

public class OwnerUserServlet extends HttpServlet {

    private UserManagementDao ownerUserDao;

    @Override
    public void init() throws ServletException {
        ownerUserDao = new UserManagementDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isOwner(request, response)) {
            return;
        }

        String action = getParam(request, "action", "list");

        switch (action) {
            case "add":
                request.setAttribute("formMode", "add");
                break;

            case "edit":
                loadSelectedEmployee(request, "editingUser");
                request.setAttribute("selectedRoleIds", getSelectedRoleIds(request));
                request.setAttribute("formMode", "edit");
                break;

            case "detail":
                loadSelectedEmployee(request, "detailUser");
                request.setAttribute("formMode", "detail");
                break;

            case "reset":
                loadSelectedEmployee(request, "resetUser");
                request.setAttribute("formMode", "reset");
                break;

            default:
                request.setAttribute("formMode", "list");
                break;
        }

        loadPageData(request);

        request.setAttribute("pageTitle", "Employee Management");
        request.setAttribute("pageSubtitle", "Owner views and manages all employee accounts across branches");
        request.setAttribute("addButtonText", "Add Employee");
        request.setAttribute("baseUrl", request.getContextPath() + "/owner/emp");

        request.setAttribute("showBranch", true);
        request.setAttribute("canCreate", true);
        request.setAttribute("canEdit", true);
        request.setAttribute("canLock", true);
        request.setAttribute("canResetPassword", true);

        request.getRequestDispatcher("/view/user/user-list.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isOwner(request, response)) {
            return;
        }

        String action = getParam(request, "action", "list");

        switch (action) {
            case "create":
                createEmployee(request);
                break;

            case "update":
                updateEmployee(request);
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

        response.sendRedirect(request.getContextPath() + "/owner/emp");
    }

    private void loadPageData(HttpServletRequest request) {
        String keyword = request.getParameter("keyword");
        String branchId = request.getParameter("branchId");
        String roleId = request.getParameter("roleId");
        String status = request.getParameter("status");

        request.setAttribute("users", ownerUserDao.getEmployees(keyword, branchId, roleId, status));
        request.setAttribute("branches", ownerUserDao.getAllBranches());
        request.setAttribute("roles", ownerUserDao.getEmployeeRoles());

        request.setAttribute("keyword", keyword);
        request.setAttribute("branchFilter", parseInt(branchId, -1));
        request.setAttribute("roleFilter", parseInt(roleId, -1));
        request.setAttribute("statusFilter", status);
    }

    private void loadSelectedEmployee(HttpServletRequest request, String attributeName) {
        int employeeId = parseInt(request.getParameter("id"), -1);

        if (employeeId > 0) {
            request.setAttribute(attributeName, ownerUserDao.getEmployeeById(employeeId));
        }
    }

    private int[] getSelectedRoleIds(HttpServletRequest request) {
        int employeeId = parseInt(request.getParameter("id"), -1);

        if (employeeId <= 0) {
            return new int[0];
        }

        java.util.List<Integer> roleIdList = ownerUserDao.getEmployeeRoleIds(employeeId);
        int[] roleIds = new int[roleIdList.size()];

        for (int i = 0; i < roleIdList.size(); i++) {
            roleIds[i] = roleIdList.get(i);
        }

        return roleIds;
    }

    private void createEmployee(HttpServletRequest request) {
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String autoGeneratedPassword = EmailUtil.generateRandomPassword();
        String status = trim(request.getParameter("status"));

        int branchId = parseInt(request.getParameter("branchId"), -1);
        int[] roleIds = parseRoleIds(request.getParameterValues("roleIds"));

        if (isBlank(fullName) || isBlank(email) || branchId <= 0 || roleIds.length == 0) {
            setFlash(request, "errorMessage", "Please enter full name, email, password, branch and at least one role.");
            return;
        }
        
        if (ownerUserDao.isEmailExists(email,phone, null)) {
            setFlash(request, "errorMessage", "Email/Phone already exists.");
            return;
        }
        boolean isMailSent = EmailUtil.sendPasswordEmail(email.trim(), fullName.trim(), autoGeneratedPassword);

        if (!isMailSent) {
            setFlash(request, "errorMessage", "Cannot send password email. Please check email configuration.");
            return;
        }

        Employee employee = new Employee();
        employee.setFullName(fullName);
        employee.setEmail(email);
        employee.setPhone(phone);
        employee.setBranchId(branchId);
        employee.setStatus(isBlank(status) ? "active" : status);

        String hashedPassword = PasswordUtil.hashPassword(autoGeneratedPassword);
                                                    
        boolean success = ownerUserDao.addEmployee(employee, hashedPassword, roleIds);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Employee account created successfully." : "Cannot create employee account."
        );
        
    }

    private void updateEmployee(HttpServletRequest request) {
        int employeeId = parseInt(request.getParameter("employeeId"), -1);
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String status = trim(request.getParameter("status"));

        int branchId = parseInt(request.getParameter("branchId"), -1);
        int[] roleIds = parseRoleIds(request.getParameterValues("roleIds"));

        if (employeeId <= 0 || isBlank(fullName) || isBlank(email) || branchId <= 0 || roleIds.length == 0) {
            setFlash(request, "errorMessage", "Invalid employee update data.");
            return;
        }

        if (ownerUserDao.isEmailExists(email,phone, employeeId)) {
            setFlash(request, "errorMessage", "Email/Phone already exists.");
            return;
        }

        Employee employee = new Employee();
        employee.setEmployeeId(employeeId);
        employee.setFullName(fullName);
        employee.setEmail(email);
        employee.setPhone(phone);
        employee.setBranchId(branchId);
        employee.setStatus(isBlank(status) ? "active" : status);

        boolean success = ownerUserDao.updateEmployee(employee, roleIds);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Employee account updated successfully." : "Cannot update employee account."
        );
    }

    private void updateStatus(HttpServletRequest request, String status) {
        int employeeId = parseInt(request.getParameter("employeeId"), -1);

        if (employeeId <= 0) {
            setFlash(request, "errorMessage", "Invalid employee ID.");
            return;
        }

        boolean success = ownerUserDao.updateEmployeeStatus(employeeId, status);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Employee status updated successfully." : "Cannot update employee status."
        );
    }

    private void resetPassword(HttpServletRequest request) {
        int employeeId = parseInt(request.getParameter("employeeId"), -1);
        String autoGeneratedPassword = EmailUtil.generateRandomPassword();

        if (employeeId <= 0 ) {
            setFlash(request, "errorMessage", "Invalid reset password data.");
            return;
        }
        Employee employee = ownerUserDao.getEmployeeInfoById(employeeId);
        
        boolean isMailSent = EmailUtil.sendPasswordEmail(employee.getEmail(), employee.getFullName(), autoGeneratedPassword);

        if (!isMailSent) {
            setFlash(request, "errorMessage", "Cannot send password email. Please check email configuration.");
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(autoGeneratedPassword);

        boolean success = ownerUserDao.resetEmployeePassword(employeeId, hashedPassword);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Employee password reset successfully." : "Cannot reset employee password."
        );
    }

    private boolean isOwner(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        String roleName = (String) session.getAttribute("roleName");

        if (!"Owner".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Owner only.");
            return false;
        }

        return true;
    }

    private int[] parseRoleIds(String[] values) {
        if (values == null || values.length == 0) {
            return new int[0];
        }

        java.util.List<Integer> list = new java.util.ArrayList<Integer>();

        for (String value : values) {
            int id = parseInt(value, -1);

            if (id > 0 && !list.contains(id)) {
                list.add(id);
            }
        }

        int[] roleIds = new int[list.size()];

        for (int i = 0; i < list.size(); i++) {
            roleIds[i] = list.get(i);
        }

        return roleIds;
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