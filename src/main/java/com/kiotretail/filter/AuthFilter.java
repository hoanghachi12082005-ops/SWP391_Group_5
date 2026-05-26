package com.kiotretail.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Authentication Filter
 * Kiểm tra đăng nhập cho các trang yêu cầu xác thực và cấu hình ngăn bộ nhớ đệm (Cache)
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        // Kiểm tra trạng thái đăng nhập
        boolean isLoggedIn = (session != null && session.getAttribute("employee") != null);
        String loginURI = httpRequest.getContextPath() + "/login";

        boolean isLoginRequest = httpRequest.getRequestURI().equals(loginURI);
        boolean isLoginPage = httpRequest.getRequestURI().endsWith("login.jsp");

        // Thêm kiểm tra loại bỏ các tài nguyên tĩnh như CSS, JS, hình ảnh nếu cần thiết
        boolean isResourceRequest = httpRequest.getRequestURI().contains("/assets/") 
                || httpRequest.getRequestURI().endsWith(".css") 
                || httpRequest.getRequestURI().endsWith(".js");

        if (isLoggedIn || isLoginRequest || isLoginPage || isResourceRequest) {
            
            // NẾU NGƯỜI DÙNG ĐÃ ĐĂNG NHẬP VÀ ĐANG VÀO TRANG QUẢN TRỊ NỘI BỘ
            if (isLoggedIn && !isLoginRequest && !isLoginPage && !isResourceRequest) {
                // Ép trình duyệt KHÔNG ĐƯỢC LƯU CACHE các dữ liệu giao diện của trang quản trị này
                httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
                httpResponse.setHeader("Pragma", "no-cache"); // HTTP 1.0
                httpResponse.setDateHeader("Expires", 0); // Định thời gian hết hạn cache ngay lập tức
            }
            
            chain.doFilter(request, response);
        } else {
            // Chưa đăng nhập hoặc session đã bị hủy sau khi nhấn đăng xuất
            httpResponse.sendRedirect(loginURI);
        }
    }

    @Override
    public void destroy() {
    }
}