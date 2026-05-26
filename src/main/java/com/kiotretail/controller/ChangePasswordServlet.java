package com.kiotretail.controller;

import com.kiotretail.dao.EmployeeDAO;
import com.kiotretail.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;


public class ChangePasswordServlet extends HttpServlet {
    private EmployeeDAO employeeDAO = new EmployeeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        
        HttpSession session = request.getSession(false);
        Employee emp = (session != null) ? (Employee) session.getAttribute("employee") : null;
        
        if (emp == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Kiểm tra độ phức tạp của mật khẩu bằng Regex phía Server
        String regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{6,}$";
        if (newPassword == null || !newPassword.matches(regex)) {
            request.setAttribute("error", "Mật khẩu không đạt chuẩn yêu cầu hệ thống.");
            request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
            return;
        }

        // Gọi hàm kiểm tra pass cũ và cập nhật mật khẩu mới của EmployeeDAO
        boolean isUpdated = employeeDAO.updatePassword(emp.getEmployeeId(), currentPassword, newPassword);
        
        if (isUpdated) {
            session.invalidate(); // Đăng xuất bắt buộc đăng nhập lại bằng mật khẩu mới
            response.sendRedirect(request.getContextPath() + "/login?message=changed_success");
        } else {
            request.setAttribute("error", "Mật khẩu tạm thời hiện tại nhập vào không chính xác.");
            request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
        }
    }
}