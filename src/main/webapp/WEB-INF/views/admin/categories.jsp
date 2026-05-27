<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Quản lý nhóm hàng"/>
</jsp:include>

<div class="d-flex">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="categories"/>
    </jsp:include>

    <div class="main-content flex-grow-1">
        <!-- Top Bar -->
        <div class="top-bar">
            <div>
                <h4 class="mb-1 fw-bold">Nhóm hàng</h4>
                <p class="text-muted mb-0">Quản lý danh mục và phân loại sản phẩm</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-outline-secondary" onclick="window.print()">
                    <span class="material-icons">print</span>
                    In danh sách
                </button>
                <c:if test="${sessionScope.canManageCategory}">
                    <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                        <span class="material-icons">add</span>
                        Thêm nhóm hàng
                    </button>
                </c:if>
            </div>
        </div>

        <!-- Alert Messages -->
        <c:if test="${not empty sessionScope.message}">
            <div class="alert alert-${sessionScope.messageType} alert-dismissible fade show category-alert" role="alert">
                <span class="material-icons">${sessionScope.messageType == 'success' ? 'check_circle' : sessionScope.messageType == 'warning' ? 'warning' : 'error'}</span>
                <span>${sessionScope.message}</span>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="message" scope="session"/>
            <c:remove var="messageType" scope="session"/>
        </c:if>

        <!-- Stats Summary Cards -->
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="category-stat-card">
                    <div class="category-stat-icon" style="background: rgba(46, 125, 50, 0.1);">
                        <span class="material-icons" style="color: #2e7d32;">folder</span>
                    </div>
                    <div>
                        <div class="category-stat-value">${totalItems}</div>
                        <div class="category-stat-label">Tổng nhóm hàng</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="category-stat-card">
                    <div class="category-stat-icon" style="background: rgba(2, 136, 209, 0.1);">
                        <span class="material-icons" style="color: #0288d1;">account_tree</span>
                    </div>
                    <div>
                        <div class="category-stat-value">
                            <c:set var="parentCount" value="0"/>
                            <c:forEach var="cat" items="${categories}">
                                <c:if test="${empty cat.parentName}">
                                    <c:set var="parentCount" value="${parentCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${parentCount}
                        </div>
                        <div class="category-stat-label">Nhóm gốc (trang này)</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="category-stat-card">
                    <div class="category-stat-icon" style="background: rgba(245, 124, 0, 0.1);">
                        <span class="material-icons" style="color: #f57c00;">inventory_2</span>
                    </div>
                    <div>
                        <div class="category-stat-value">
                            <c:set var="totalProducts" value="0"/>
                            <c:forEach var="cat" items="${categories}">
                                <c:set var="totalProducts" value="${totalProducts + cat.productCount}"/>
                            </c:forEach>
                            ${totalProducts}
                        </div>
                        <div class="category-stat-label">Sản phẩm (trang này)</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters & Search -->
        <div class="card category-filter-card">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/categories" class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label">
                            <span class="material-icons" style="font-size: 16px; vertical-align: text-bottom;">search</span>
                            Tìm kiếm
                        </label>
                        <div class="search-box">
                            <span class="material-icons">search</span>
                            <input type="text" class="form-control" name="keyword" placeholder="Tên nhóm hoặc mô tả..." value="${keyword}">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">
                            <span class="material-icons" style="font-size: 16px; vertical-align: text-bottom;">tune</span>
                            Trạng thái
                        </label>
                        <select class="form-select" name="status">
                            <option value="" ${empty selectedStatus ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="active" ${selectedStatus == 'active' ? 'selected' : ''}>Đang sử dụng</option>
                            <option value="inactive" ${selectedStatus == 'inactive' ? 'selected' : ''}>Ngừng sử dụng</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">
                            <span class="material-icons" style="font-size: 16px; vertical-align: text-bottom;">account_tree</span>
                            Nhóm cha
                        </label>
                        <input type="text" class="form-control" name="parentName" value="${parentNameFilter}" placeholder="Nhập tên nhóm cha">
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button type="submit" class="btn btn-danger flex-fill">
                            <span class="material-icons">filter_alt</span>
                            Lọc
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-outline-secondary btn-icon" title="Làm mới">
                            <span class="material-icons">refresh</span>
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Categories Table -->
        <div class="card category-table-card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="categoriesTable">
                        <thead>
                            <tr>
                                <th style="width: 80px;">Mã</th>
                                <th>Tên nhóm hàng</th>
                                <th>Nhóm cha</th>
                                <th>Mô tả</th>
                                <th style="width: 110px; text-align: center;">Sản phẩm</th>
                                <th style="width: 150px;">Trạng thái</th>
                                <c:if test="${sessionScope.canManageCategory}">
                                    <th style="width: 100px; text-align: center;">Thao tác</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty categories}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <span class="material-icons">category</span>
                                                <h5>Không tìm thấy nhóm hàng</h5>
                                                <p>Thử thay đổi bộ lọc hoặc thêm nhóm hàng mới.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="category" items="${categories}" varStatus="loop">
                                        <tr class="category-row" style="animation-delay: ${loop.index * 0.03}s;">
                                            <td>
                                                <span class="category-id-badge">#${category.categoryId}</span>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="category-icon-wrapper">
                                                        <span class="material-icons">
                                                            ${empty category.parentName ? 'folder' : 'subdirectory_arrow_right'}
                                                        </span>
                                                    </div>
                                                    <div class="fw-semibold"><c:out value="${category.name}"/></div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${empty category.parentName}">
                                                        <span class="category-parent-badge root">
                                                            <span class="material-icons" style="font-size: 14px;">hub</span>
                                                            Nhóm gốc
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="category-parent-badge child">
                                                            <span class="material-icons" style="font-size: 14px;">subdirectory_arrow_right</span>
                                                            <c:out value="${category.parentName}"/>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${empty category.description}">
                                                        <span class="text-muted fst-italic" style="font-size: 13px;">Chưa có mô tả</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="category-description"><c:out value="${category.description}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">
                                                <span class="category-product-count ${category.productCount > 0 ? 'has-products' : ''}">
                                                    <span class="material-icons" style="font-size: 14px;">inventory_2</span>
                                                    ${category.productCount}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${category.status == 'active'}">
                                                        <span class="category-status-badge active">
                                                            <span class="status-dot"></span>
                                                            Đang sử dụng
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="category-status-badge inactive">
                                                            <span class="status-dot"></span>
                                                            Ngừng sử dụng
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <c:if test="${sessionScope.canManageCategory}">
                                                <td style="text-align: center;">
                                                    <button type="button"
                                                            class="btn btn-sm btn-outline-primary btn-icon category-edit-btn"
                                                            title="Chỉnh sửa nhóm hàng"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#editCategoryModal"
                                                            data-category-id="${category.categoryId}"
                                                            data-category-name="${fn:escapeXml(category.name)}"
                                                            data-category-description="${fn:escapeXml(category.description)}"
                                                            data-category-parent-name="${fn:escapeXml(category.parentName)}"
                                                            data-category-status="${category.status}"
                                                            onclick="prepareEditCategory(this)">
                                                        <span class="material-icons" style="font-size: 18px;">edit</span>
                                                    </button>
                                                </td>
                                            </c:if>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="category-pagination-bar">
                <div class="text-muted d-flex align-items-center gap-2">
                    <span class="material-icons" style="font-size: 18px;">view_list</span>
                    <span>Hiển thị <strong>${fn:length(categories)}</strong> / <strong>${totalItems}</strong> nhóm hàng</span>
                </div>
                <nav>
                    <ul class="pagination mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/categories?page=${currentPage - 1}&keyword=${keyword}&status=${selectedStatus}&parentName=${parentNameFilter}">
                                <span class="material-icons" style="font-size: 18px;">chevron_left</span>
                                Trước
                            </a>
                        </li>
                        <c:forEach var="pageIndex" begin="1" end="${totalPages}">
                            <li class="page-item ${currentPage == pageIndex ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/categories?page=${pageIndex}&keyword=${keyword}&status=${selectedStatus}&parentName=${parentNameFilter}">
                                    ${pageIndex}
                                </a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/categories?page=${currentPage + 1}&keyword=${keyword}&status=${selectedStatus}&parentName=${parentNameFilter}">
                                Sau
                                <span class="material-icons" style="font-size: 18px;">chevron_right</span>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
</div>

<!-- Add Category Modal -->
<div class="modal fade" id="addCategoryModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content category-modal">
            <form method="post" action="${pageContext.request.contextPath}/admin/categories">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <div class="d-flex align-items-center gap-3">
                        <div class="modal-icon-wrapper">
                            <span class="material-icons">create_new_folder</span>
                        </div>
                        <div>
                            <h5 class="modal-title fw-bold mb-0">Thêm nhóm hàng mới</h5>
                            <small class="text-muted">Tạo danh mục phân loại sản phẩm</small>
                        </div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên nhóm hàng <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="name" maxlength="255" required placeholder="Nhập tên nhóm hàng">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Nhóm cha</label>
                            <input type="text" class="form-control" name="parentName" placeholder="Để trống = nhóm gốc">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="active" selected>Đang sử dụng</option>
                                <option value="inactive">Ngừng sử dụng</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea class="form-control" name="description" rows="3" maxlength="1000" placeholder="Mô tả ngắn về nhóm hàng..."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <span class="material-icons">close</span>
                        Hủy
                    </button>
                    <button type="submit" class="btn btn-danger">
                        <span class="material-icons">save</span>
                        Lưu nhóm hàng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Category Modal -->
<div class="modal fade" id="editCategoryModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content category-modal">
            <form method="post" action="${pageContext.request.contextPath}/admin/categories">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="categoryId" id="editCategoryId">
                <div class="modal-header">
                    <div class="d-flex align-items-center gap-3">
                        <div class="modal-icon-wrapper edit">
                            <span class="material-icons">edit_note</span>
                        </div>
                        <div>
                            <h5 class="modal-title fw-bold mb-0">Cập nhật nhóm hàng</h5>
                            <small class="text-muted">Chỉnh sửa thông tin danh mục</small>
                        </div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên nhóm hàng <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="name" id="editCategoryName" maxlength="255" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Nhóm cha</label>
                            <input type="text" class="form-control" name="parentName" id="editCategoryParentName" placeholder="Để trống = nhóm gốc">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Trạng thái</label>
                            <select class="form-select" name="status" id="editCategoryStatus">
                                <option value="active">Đang sử dụng</option>
                                <option value="inactive">Ngừng sử dụng</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea class="form-control" name="description" id="editCategoryDescription" rows="3" maxlength="1000"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <span class="material-icons">close</span>
                        Hủy
                    </button>
                    <button type="submit" class="btn btn-danger">
                        <span class="material-icons">save</span>
                        Cập nhật nhóm hàng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function prepareEditCategory(button) {
    const categoryId = button.dataset.categoryId || '';
    document.getElementById('editCategoryId').value = categoryId;
    document.getElementById('editCategoryName').value = button.dataset.categoryName || '';
    document.getElementById('editCategoryDescription').value = button.dataset.categoryDescription || '';
    document.getElementById('editCategoryStatus').value = button.dataset.categoryStatus || 'active';
    document.getElementById('editCategoryParentName').value = button.dataset.categoryParentName || '';
}
</script>

<style>
/* ===== Category Stats Cards ===== */
.category-stat-card {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 20px 24px;
    background: var(--bg-primary);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.category-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.category-stat-icon {
    width: 48px;
    height: 48px;
    border-radius: var(--radius-lg);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.category-stat-icon .material-icons {
    font-size: 24px;
}

.category-stat-value {
    font-size: 24px;
    font-weight: 700;
    font-family: var(--font-heading);
    color: var(--text-primary);
    line-height: 1.2;
}

.category-stat-label {
    font-size: 13px;
    color: var(--text-muted);
    margin-top: 2px;
}

/* ===== Filter Card ===== */
.category-filter-card {
    border: 1px solid var(--border-light);
}

.category-filter-card .form-label {
    font-size: 13px;
    color: var(--text-secondary);
    display: flex;
    align-items: center;
    gap: 4px;
}

/* ===== Table Card ===== */
.category-table-card .table thead th {
    background: linear-gradient(180deg, #f8f9fb 0%, #f1f3f5 100%);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--text-secondary);
    border-bottom: 2px solid var(--border-color);
}

/* Row enter animation */
@keyframes fadeSlideIn {
    from {
        opacity: 0;
        transform: translateY(8px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.category-row {
    animation: fadeSlideIn 0.3s ease forwards;
}

.category-row:hover {
    background-color: rgba(147, 0, 11, 0.03) !important;
}

/* Category ID Badge */
.category-id-badge {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    background: #f0f1f3;
    color: var(--text-secondary);
    font-family: 'Manrope', monospace;
}

/* Category Icon Wrapper */
.category-icon-wrapper {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(147, 0, 11, 0.08);
    flex-shrink: 0;
}

.category-icon-wrapper .material-icons {
    font-size: 18px;
    color: var(--primary-color);
}

/* Parent Badge */
.category-parent-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 500;
}

.category-parent-badge.root {
    background: #e8f5e9;
    color: #2e7d32;
}

.category-parent-badge.child {
    background: #e3f2fd;
    color: #1565c0;
}

/* Description */
.category-description {
    font-size: 13px;
    color: var(--text-secondary);
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    max-width: 250px;
}

/* Product Count */
.category-product-count {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 600;
    background: #f5f5f5;
    color: var(--text-muted);
    transition: all 0.2s ease;
}

.category-product-count.has-products {
    background: #fff3e0;
    color: #e65100;
}

.category-product-count .material-icons {
    opacity: 0.7;
}

/* Status Badge */
.category-status-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.2px;
}

.category-status-badge.active {
    background: #e8f5e9;
    color: #2e7d32;
}

.category-status-badge.inactive {
    background: #f5f5f5;
    color: #9e9e9e;
}

.status-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    flex-shrink: 0;
}

.category-status-badge.active .status-dot {
    background: #2e7d32;
    box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.2);
    animation: pulse-green 2s infinite;
}

.category-status-badge.inactive .status-dot {
    background: #bdbdbd;
}

@keyframes pulse-green {
    0%, 100% { box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.2); }
    50% { box-shadow: 0 0 0 6px rgba(46, 125, 50, 0.1); }
}

/* Edit Button */
.category-edit-btn {
    border-radius: 10px !important;
    transition: all 0.2s ease !important;
}

.category-edit-btn:hover {
    transform: scale(1.1);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
}

/* ===== Pagination Bar ===== */
.category-pagination-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    background: var(--bg-primary);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    margin-bottom: 24px;
}

.category-pagination-bar .text-muted {
    font-size: 14px;
}

/* ===== Modal Enhancements ===== */
.category-modal .modal-header {
    background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%);
    padding: 24px 28px;
}

.modal-icon-wrapper {
    width: 48px;
    height: 48px;
    border-radius: var(--radius-lg);
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(147, 0, 11, 0.1);
    flex-shrink: 0;
}

.modal-icon-wrapper .material-icons {
    font-size: 24px;
    color: var(--primary-color);
}

.modal-icon-wrapper.edit {
    background: rgba(2, 136, 209, 0.1);
}

.modal-icon-wrapper.edit .material-icons {
    color: #0288d1;
}

.category-modal .modal-body {
    padding: 28px;
}

.category-modal .modal-footer {
    padding: 16px 28px;
    background: #fafafa;
}

/* ===== Alert Enhancement ===== */
.category-alert {
    border-radius: var(--radius-lg);
    animation: fadeSlideIn 0.4s ease;
}

/* ===== Responsive ===== */
@media (max-width: 768px) {
    .category-stat-card {
        padding: 16px;
    }

    .category-stat-value {
        font-size: 20px;
    }

    .category-pagination-bar {
        flex-direction: column;
        gap: 12px;
    }

    .category-description {
        max-width: 150px;
    }
}
</style>

<jsp:include page="../common/footer.jsp"/>
