package employee.controller;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author PCQN
 */
import employee.dao.UserManagementDao;
import jakarta.servlet.http.HttpSession;
import employee.model.Employee;

public class ManagerEmployeeServlet extends HttpServlet {

    private UserManagementDao  managerEmployeeDao;

    @Override
    public void init() throws ServletException {
        managerEmployeeDao = new  UserManagementDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isStoreManager(request, response)) {
            return;
        }

        int branchID = getLoggedInBranchID(request);

        if (branchID <= 0) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Your account is not assigned to any branch.");
            return;
        }

        String action = getParam(request, "action", "list");

        if ("detail".equals(action)) {
            loadSelectedEmployee(request, branchID);
            request.setAttribute("formMode", "detail");
        } else {
            request.setAttribute("formMode", "list");
        }

        loadPageData(request, branchID);

        request.setAttribute("pageTitle", "Branch Employee List");
        request.setAttribute("pageSubtitle", "Store Manager views employee accounts in the assigned branch");
        request.setAttribute("addButtonText", "");
        request.setAttribute("baseUrl", request.getContextPath() + "/manager/emp");

        request.setAttribute("showBranch", true);
        request.setAttribute("canCreate", false);
        request.setAttribute("canEdit", false);
        request.setAttribute("canLock", false);
        request.setAttribute("canResetPassword", false);

        request.getRequestDispatcher("/view/user/user-list.jsp")
                .forward(request, response);
    }

    private void loadPageData(HttpServletRequest request, int branchID) {
        String keyword = request.getParameter("keyword");
        String roleID = request.getParameter("roleId");
        String status = request.getParameter("status");

        request.setAttribute(
                "users",
                managerEmployeeDao.getEmployeesByBranch(branchID, keyword, roleID, status)
        );

        request.setAttribute("roles", managerEmployeeDao.getEmployeeRoles());

        request.setAttribute("keyword", keyword);
        request.setAttribute("roleFilter", parseInt(roleID, -1));
        request.setAttribute("statusFilter", status);
    }

    private void loadSelectedEmployee(HttpServletRequest request, int branchID) {
        int employeeID = parseInt(request.getParameter("id"), -1);

        if (employeeID > 0) {
            request.setAttribute(
                    "detailUser",
                    managerEmployeeDao.getEmployeeByIdInBranch(employeeID, branchID)
            );
        }
    }

    private boolean isStoreManager(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        String roleName = (String) session.getAttribute("roleName");

        if (!"StoreManager".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. StoreManager only.");
            return false;
        }

        return true;
    }

    private int getLoggedInBranchID(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return -1;
        }

        Object branchObj = session.getAttribute("branchId");

        if (branchObj instanceof Number) {
            return ((Number) branchObj).intValue();
        }

        if (branchObj instanceof String) {
            return parseInt((String) branchObj, -1);
        }

        Object employeeObj = session.getAttribute("employee");

        if (employeeObj instanceof Employee) {
            Employee employee = (Employee) employeeObj;

            if (employee.getBranchID() != null) {
                return employee.getBranchID();
            }
        }

        return -1;
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

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}