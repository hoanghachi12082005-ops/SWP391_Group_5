<%-- 
    Document   : profile
    Created on : 27 May 2026, 21:18:57
    Author     : PCQN
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Profile - FinoraRetail</title>

    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/assets/css/base.css?v=20260528"/>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/assets/css/layout.css?v=20260528"/>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/assets/css/form-modal.css?v=20260528"/>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/assets/css/user-management.css?v=20260528"/>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
</head>

<body>  
<div class="app-layout">
    <jsp:include page="/view/common/sidebar.jsp"/>

    <div class="main-wrapper">

        <main class="page-content">
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success">
                    ${sessionScope.successMessage}
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-error">
                    ${sessionScope.errorMessage}
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <section class="page-header">
                <div>
                    <h2>My Profile</h2>
                    <p>View your account information and change password</p>
                </div>
            </section>

            <section class="table-card" style="padding: 24px; margin-bottom: 24px;">
                <h3 style="margin-top: 0;">Account Information</h3>

                <div class="detail-list">
                    <p><strong>Full Name:</strong> ${profile.fullName}</p>
                    <p><strong>Email:</strong> ${profile.email}</p>
                    <p><strong>Phone:</strong> ${profile.phone}</p>
                    <p><strong>Role:</strong> ${profile.roleNames}</p>
                    <p>
                        <strong>Branch:</strong>
                        <c:choose>
                            <c:when test="${not empty profile.branchName}">
                                ${profile.branchName}
                            </c:when>
                            <c:otherwise>
                                System-wide
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <p><strong>Status:</strong> ${profile.status}</p>
                    <p>
                        <strong>Created At:</strong>
                        <fmt:formatDate value="${profile.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </p>
                </div>
            </section>

            <section class="table-card" style="padding: 24px; margin-bottom: 24px;">
                <h3 style="margin-top: 0;">Update Profile</h3>

                <form method="post" action="${pageContext.request.contextPath}/profile">
                    <input type="hidden" name="action" value="updateProfile"/>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Full Name <span>*</span></label>
                            <input name="fullName" required type="text" value="${profile.fullName}"/>
                        </div>

                        <div class="form-group">
                            <label>Email <span>*</span></label>
                            <input name="email" required type="email" value="${profile.email}"/>
                        </div>
                    </div>

                    <div class="form-group" style="margin-top: 16px;">
                        <label>Phone</label>
                        <input name="phone" type="text" value="${profile.phone}"/>
                    </div>

                    <div style="margin-top: 18px;">
                        <button class="btn-primary" type="submit">Save Profile</button>
                    </div>
                </form>
            </section>

            <section class="table-card" style="padding: 24px;">
                <h3 style="margin-top: 0;">Change Password</h3>

                <form method="post" action="${pageContext.request.contextPath}/profile">
                    <input type="hidden" name="action" value="changePassword"/>

                    <div class="form-group">
                        <label>Old Password <span>*</span></label>
                        <input name="oldPassword" required type="password"/>
                    </div>

                    <div class="form-row" style="margin-top: 16px;">
                        <div class="form-group">
                            <label>New Password <span>*</span></label>
                            <input name="newPassword" required type="password"/>
                        </div>

                        <div class="form-group">
                            <label>Confirm Password <span>*</span></label>
                            <input name="confirmPassword" required type="password"/>
                        </div>
                    </div>

                    <div style="margin-top: 18px;">
                        <button class="btn-primary" type="submit">Change Password</button>
                    </div>
                </form>
            </section>
        </main>
    </div>
</div>
</body>
</html>