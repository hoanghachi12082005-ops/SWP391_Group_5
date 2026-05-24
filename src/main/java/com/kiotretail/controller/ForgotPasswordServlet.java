package com.kiotretail.controller;

import com.kiotretail.dao.EmployeeDAO;
import com.kiotretail.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;

public class ForgotPasswordServlet extends HttpServlet {

    private EmployeeDAO employeeDAO;

    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("send-otp".equals(action)) {
            String username = request.getParameter("username");
            String email = request.getParameter("email");

            if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin!");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            // Kiểm tra khớp tài khoản và email
            if (!employeeDAO.checkUsernameAndEmailMatch(username.trim(), email.trim())) {
                request.setAttribute("error", "Thông tin tài khoản hoặc email không chính xác!");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            // Tạo OTP ảo / Hoặc chạy OTP thật tùy cấu hình của bạn
            Random random = new Random();
            int otpValue = 100000 + random.nextInt(900000);
            String strOtp = String.valueOf(otpValue);

            session.setAttribute("resetOtp", strOtp);
            session.setAttribute("resetEmail", email.trim());

            System.out.println("[KiotRetail Debug] Mã OTP của bạn là: " + strOtp);
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);

        } else if ("reset-password".equals(action)) {
            String inputOtp = request.getParameter("otp");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            String sessionOtp = (String) session.getAttribute("resetOtp");
            String sessionEmail = (String) session.getAttribute("resetEmail");

            if (sessionOtp == null || sessionEmail == null) {
                request.setAttribute("error", "Phiên làm việc đã hết hạn. Vui lòng thử lại.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            if (!inputOtp.trim().equals(sessionOtp)) {
                request.setAttribute("error", "Mã xác thực OTP không chính xác!");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Xác nhận mật khẩu mới không trùng khớp!");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            // Mã hóa mật khẩu theo SHA-256 đồng bộ với trang Đăng ký
            String encryptedPassword = PasswordUtil.hashPassword(newPassword);
            boolean isUpdated = employeeDAO.updatePasswordByEmail(sessionEmail, encryptedPassword);

            if (isUpdated) {
                session.removeAttribute("resetOtp");
                session.removeAttribute("resetEmail");
                request.setAttribute("successMessage", "Đổi mật khẩu thành công! Vui lòng đăng nhập.");
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Lỗi hệ thống không thể cập nhật cơ sở dữ liệu!");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
            }
        }
    }
}