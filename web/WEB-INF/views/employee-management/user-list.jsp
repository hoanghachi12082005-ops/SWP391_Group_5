<%-- 
    Document   : user-list
    Created on : 27 May 2026, 21:16:05
    Author     : PCQN
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>${pageTitle} - FinoraRetail</title>

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
                <div class="alert alert-success">${sessionScope.successMessage}</div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-error">${sessionScope.errorMessage}</div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <section class="page-header">
                <div>
                    <h2>${pageTitle}</h2>
                    <p>${pageSubtitle}</p>
                </div>

                <c:if test="${canCreate}">
                    <a class="btn-primary" href="${baseUrl}?action=add">
                        <span class="material-symbols-outlined">add</span>
                        ${addButtonText}
                    </a>
                </c:if>
            </section>

            <form class="filter-card" method="get" action="${baseUrl}">
                <div class="filter-grid">
                    <div class="form-group filter-search">
                        <label>Search</label>
                        <input name="keyword" value="${keyword}" type="text" placeholder="Name, email or phone..."/>
                    </div>

                    <c:if test="${showBranch && not empty branches}">
                        <div class="form-group">
                            <label>Branch</label>
                            <select name="branchId">
                                <option value="">All Branches</option>
                                <c:forEach var="branch" items="${branches}">
                                    <option value="${branch.branchID}" ${branchFilter == branch.branchID ? 'selected' : ''}>
                                        ${branch.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>

                    <c:if test="${not empty roles}">
                        <div class="form-group">
                            <label>Role</label>
                            <select name="roleId">
                                <option value="">All Roles</option>
                                <c:forEach var="role" items="${roles}">
                                    <option value="${role.roleID}" ${roleFilter == role.roleID ? 'selected' : ''}>
                                        ${role.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>

                    <div class="form-group">
                        <label>Status</label>
                        <select name="status">
                            <option value="">All Status</option>
                            <option value="active" ${statusFilter == 'active' ? 'selected' : ''}>Active</option>
                            <option value="locked" ${statusFilter == 'locked' ? 'selected' : ''}>Locked</option>
                        </select>
                    </div>

                    <div class="filter-actions">
                        <button class="btn-primary" type="submit">Apply</button>
                        <a class="btn-secondary" href="${baseUrl}">Reset</a>
                    </div>
                </div>
            </form>

            <section class="table-card">
                <div class="table-scroll">
                    <table class="data-table">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Phone</th>
                            <th>Role</th>

                            <c:if test="${showBranch}">
                                <th>Branch</th>
                            </c:if>

                            <th>Status</th>
                            <th class="text-right">Actions</th>
                        </tr>
                        </thead>

                        <tbody>
                        <c:choose>
                            <c:when test="${empty users}">
                                <tr>
                                    <td colspan="${showBranch ? 6 : 5}" class="empty-row">
                                        No user accounts found.
                                    </td>
                                </tr>
                            </c:when>

                            <c:otherwise>
                                <c:forEach var="user" items="${users}">
                                    <tr>
                                        <td>
                                            <div class="user-cell"> 
                                                <div class="avatar-text">
                                                    <c:choose>
                                                        <c:when test="${not empty user.fullName}">
                                                            ${fn:substring(user.fullName, 0, 1)}
                                                        </c:when>
                                                        <c:otherwise>U</c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <div>
                                                    <strong>${user.fullName}</strong>
                                                    <span>${user.email}</span>
                                                </div>
                                            </div>
                                        </td>

                                        <td>${empty user.phone ? '—' : user.phone}</td>

                                        <td>
                                            <span class="role-badge">
                                                ${empty user.roleNames ? user.roleName : user.roleNames}
                                            </span>
                                        </td>

                                        <c:if test="${showBranch}">
                                            <td>${empty user.branchName ? '—' : user.branchName}</td>
                                        </c:if>

                                        <td>
                                            <c:choose>
                                                <c:when test="${user.status == 'active'}">
                                                    <span class="status-badge active">Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge locked">Locked</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <div class="table-actions">
                                                <a href="${baseUrl}?action=detail&id=${user.employeeId}" title="View Detail">
                                                    <span class="material-symbols-outlined">visibility</span>
                                                </a>

                                                <c:if test="${canEdit}">
                                                    <a href="${baseUrl}?action=edit&id=${user.employeeId}" title="Edit">
                                                        <span class="material-symbols-outlined">edit</span>
                                                    </a>
                                                </c:if>

                                                <c:if test="${canResetPassword}">
                                                    <a href="${baseUrl}?action=reset&id=${user.employeeId}" title="Reset Password">
                                                        <span class="material-symbols-outlined">key</span>
                                                    </a>
                                                </c:if>

                                                <c:if test="${canLock}">
                                                    <form method="post" action="${baseUrl}">
                                                        <input type="hidden" name="employeeId" value="${user.employeeId}"/>

                                                        <c:choose>
                                                            <c:when test="${user.status == 'active'}">
                                                                <input type="hidden" name="action" value="lock"/>
                                                                <button type="submit" title="Lock" onclick="return confirm('Lock this account?')">
                                                                    <span class="material-symbols-outlined">lock</span>
                                                                </button>
                                                            </c:when>

                                                            <c:otherwise>
                                                                <input type="hidden" name="action" value="unlock"/>
                                                                <button type="submit" title="Unlock" onclick="return confirm('Unlock this account?')">
                                                                    <span class="material-symbols-outlined">lock_open</span>
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="table-footer">
                    Showing ${empty users ? 0 : users.size()} entries
                </div>
            </section>
        </main>
    </div>
</div>

<c:if test="${formMode == 'add'}">
    <div class="modal-overlay">
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-error">${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        <form class="modal-box" method="post" action="${baseUrl}">
            <input type="hidden" name="action" value="create"/>

            <div class="modal-header">
                <h3>${addButtonText}</h3>
                <a href="${baseUrl}" class="modal-close">
                    <span class="material-symbols-outlined">close</span>
                </a>
            </div>

            <div class="modal-body">
                <div class="form-group">
                    <label>Full Name *</label>
                    <input name="fullName" required type="text"/>
                </div>

                <div class="form-group">
                    <label>Email *</label>
                    <input name="email" required type="email"/>
                </div>

                <div class="form-group">
                    <label>Phone</label>
                    <input name="phone" type="tel"/>
                </div>


                <c:if test="${showBranch && not empty branches}">
                    <div class="form-group">
                        <label>Branch *</label>
                        <select name="branchId" required>
                            <option value="">Select Branch</option>
                            <c:forEach var="branch" items="${branches}">
                                <option value="${branch.branchID}">
                                    ${branch.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </c:if>

                <c:if test="${not empty roles}">
                    <div class="form-group">
                        <label>Role *</label>

                        <div class="checkbox-grid">
                            <c:forEach var="role" items="${roles}">
                                <label class="checkbox-card">
                                    <input type="checkbox" name="roleIds" value="${role.roleID}"/>
                                    <span>${role.name}</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <div class="form-group">
                    <label>Status</label>
                    <select name="status">
                        <option value="active">Active</option>
                        <option value="locked">Locked</option>
                    </select>
                </div>
            </div>

            <div class="modal-footer">
                <a class="btn-secondary" href="${baseUrl}">Cancel</a>
                <button class="btn-primary" type="submit">Create</button>
            </div>
        </form>
    </div>
</c:if>

<c:if test="${formMode == 'edit' && not empty editingUser}">
    <div class="modal-overlay">
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-error">${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        <form class="modal-box" method="post" action="${baseUrl}">
            <input type="hidden" name="action" value="update"/>
            <input type="hidden" name="employeeId" value="${editingUser.employeeId}"/>

            <div class="modal-header">
                <h3>Edit Account</h3>
                <a href="${baseUrl}" class="modal-close">
                    <span class="material-symbols-outlined">close</span>
                </a>
            </div>

            <div class="modal-body">
                <div class="form-group">
                    <label>Full Name *</label>
                    <input name="fullName" value="${editingUser.fullName}" required type="text"/>
                </div>

                <div class="form-group">
                    <label>Email *</label>
                    <input name="email" value="${editingUser.email}" required type="email"/>
                </div>

                <div class="form-group">
                    <label>Phone</label>
                    <input name="phone" value="${editingUser.phone}" type="tel"/>
                </div>

                <c:if test="${showBranch && not empty branches}">
                    <div class="form-group">
                        <label>Branch *</label>
                        <select name="branchId" required>
                            <option value="">Select Branch</option>
                            <c:forEach var="branch" items="${branches}">
                                <option value="${branch.branchID}" ${editingUser.branchId == branch.branchID ? 'selected' : ''}>
                                    ${branch.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </c:if>

                <c:if test="${not empty roles}">
                    <div class="form-group">
                        <label>Role *</label>

                        <div class="checkbox-grid">
                            <c:forEach var="role" items="${roles}">
                                <label class="checkbox-card">
                                    <input type="checkbox"
                                           name="roleIds"
                                           value="${role.roleID}"
                                           ${fn:contains(editingUser.roleNames, role.name) ? 'checked' : ''}/>
                                    <span>${role.name}</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <div class="form-group">
                    <label>Status</label>
                    <select name="status">
                        <option value="active" ${editingUser.status == 'active' ? 'selected' : ''}>Active</option>
                        <option value="locked" ${editingUser.status == 'locked' ? 'selected' : ''}>Locked</option>
                    </select>
                </div>
            </div>

            <div class="modal-footer">
                <a class="btn-secondary" href="${baseUrl}">Cancel</a>
                <button class="btn-primary" type="submit">Save Changes</button>
            </div>
        </form>
    </div>
</c:if>

<c:if test="${formMode == 'reset' && not empty resetUser}">
    <div class="modal-overlay">
        <form class="modal-box small-modal" method="post" action="${baseUrl}">
            <input type="hidden" name="action" value="resetPassword"/>
            <input type="hidden" name="employeeId" value="${resetUser.employeeId}"/>

<!--            <div class="modal-header">
                <h3>Reset Password</h3>
                <a href="${baseUrl}" class="modal-close">
                    <span class="material-symbols-outlined">close</span>
                </a>
            </div>

            <div class="modal-body">
                <p>Reset password for <strong>${resetUser.fullName}</strong>.</p>

                <div class="form-group">
                    <label>New Password</label>
                    <input name="newPassword" required type="password"/>
                </div>

                <div class="form-group">
                    <label>Confirm Password</label>
                    <input name="confirmPassword" required type="password"/>
                </div>
            </div>-->

<!--            <div class="modal-footer">
                <a class="btn-secondary" href="${baseUrl}">Cancel</a>
                <button class="btn-primary" type="submit">Reset</button>
            </div>-->
        </form>
    </div>
</c:if>

<c:if test="${formMode == 'detail' && not empty detailUser}">
    <div class="modal-overlay">
        <div class="modal-box small-modal">
            <div class="modal-header">
                <h3>Account Detail</h3>
                <a href="${baseUrl}" class="modal-close">
                    <span class="material-symbols-outlined">close</span>
                </a>
            </div>

            <div class="modal-body detail-list">
                <p><strong>Name:</strong> ${detailUser.fullName}</p>
                <p><strong>Email:</strong> ${detailUser.email}</p>
                <p><strong>Phone:</strong> ${detailUser.phone}</p>
                <p><strong>Role:</strong> ${empty detailUser.roleNames ? detailUser.roleName : detailUser.roleNames}</p>

                <c:if test="${showBranch}">
                    <p><strong>Branch:</strong> ${empty detailUser.branchName ? '—' : detailUser.branchName}</p>
                </c:if>

                <p><strong>Status:</strong> ${detailUser.status}</p>
                <p>
                    <strong>Created At:</strong>
                    <fmt:formatDate value="${detailUser.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                </p>
            </div>

            <div class="modal-footer">
                <a class="btn-primary" href="${baseUrl}">Close</a>
            </div>
        </div>
    </div>
</c:if>

</body>
</html>