/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package employee.controller;

/**
 *
 * @author PCQN
 */
import employee.dao.ProfileDao;
import employee.model.Employee;
import employee.service.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class ProfileServlet extends HttpServlet {

    private ProfileDao profileDao;

    @Override
    public void init() throws ServletException {
        profileDao = new ProfileDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request, response)) {
            return;
        }

        loadProfile(request);

        request.getRequestDispatcher("/view/profile/profile.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request, response)) {
            return;
        }

        String action = request.getParameter("action");

        if ("updateProfile".equals(action)) {
            updateProfile(request);
        } else if ("changePassword".equals(action)) {
            changePassword(request);
        } else {
            setFlash(request, "errorMessage", "Invalid action.");
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private void loadProfile(HttpServletRequest request) {
        int employeeID = getLoggedInEmployeeID(request);

        Employee profile = profileDao.getProfileById(employeeID);

        request.setAttribute("profile", profile);
    }

    private void updateProfile(HttpServletRequest request) {
        int employeeID = getLoggedInEmployeeID(request);

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));

        if (isBlank(fullName) || isBlank(email)) {
            setFlash(request, "errorMessage", "Full name and email are required.");
            return;
        }

        if (profileDao.isEmailExists(email, employeeID)) {
            setFlash(request, "errorMessage", "Email already exists.");
            return;
        }

        boolean success = profileDao.updateProfile(employeeID, fullName, email, phone);

        if (success) {
            HttpSession session = request.getSession(false);

            if (session != null) {
                session.setAttribute("employeeName", fullName);

                Object employeeObj = session.getAttribute("employee");

                if (employeeObj instanceof Employee) {
                    Employee employee = (Employee) employeeObj;

                    employee.setFullName(fullName);
                    employee.setEmail(email);
                    employee.setPhone(phone);

                    session.setAttribute("employee", employee);
                }
            }
        }

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Profile updated successfully." : "Cannot update profile."
        );
    }

    private void changePassword(HttpServletRequest request) {
        int employeeID = getLoggedInEmployeeID(request);

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (isBlank(oldPassword) || isBlank(newPassword) || isBlank(confirmPassword)) {
            setFlash(request, "errorMessage", "Please fill all password fields.");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            setFlash(request, "errorMessage", "Confirm password does not match.");
            return;
        }

        String currentHash = profileDao.getPasswordHash(employeeID);
        String oldPasswordHash = PasswordUtil.hashPassword(oldPassword);

        if (currentHash == null || !currentHash.equals(oldPasswordHash)) {
            setFlash(request, "errorMessage", "Old password is incorrect.");
            return;
        }

        String newPasswordHash = PasswordUtil.hashPassword(newPassword);

        boolean success = profileDao.updatePasswordHash(employeeID, newPasswordHash);

        setFlash(
                request,
                success ? "successMessage" : "errorMessage",
                success ? "Password changed successfully." : "Cannot change password."
        );
    }

    private boolean isLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        return true;
    }

    private int getLoggedInEmployeeID(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return -1;
        }

        Object employeeIdObj = session.getAttribute("employeeId");

        if (employeeIdObj instanceof Number) {
            return ((Number) employeeIdObj).intValue();
        }

        if (employeeIdObj instanceof String) {
            return parseInt((String) employeeIdObj, -1);
        }

        Object employeeObj = session.getAttribute("employee");

        if (employeeObj instanceof Employee) {
            return ((Employee) employeeObj).getEmployeeID();
        }

        return -1;
    }

    private void setFlash(HttpServletRequest request, String key, String message) {
        request.getSession().setAttribute(key, message);
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
