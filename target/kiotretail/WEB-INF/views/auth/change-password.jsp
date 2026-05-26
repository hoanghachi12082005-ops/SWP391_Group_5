<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Thay đổi mật khẩu hệ thống</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow-sm border-0 rounded-3">
                <div class="card-body p-4">
                    <h4 class="text-center mb-3" style="color: #93000b;">Đổi mật khẩu bảo mật</h4>
                    <p class="text-muted text-center small">Mật khẩu mới yêu cầu từ 6 ký tự trở lên, bao gồm chữ cái, chữ số và ít nhất 1 ký tự đặc biệt (!@#$...).</p>
                    
                    <form action="${pageContext.request.contextPath}/change-password" method="POST" id="changePassForm">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Mật khẩu tạm thời hiện tại</label>
                            <input type="password" name="currentPassword" class="form-control shadow-none" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Mật khẩu mới</label>
                            <input type="password" id="newPassword" name="newPassword" class="form-control shadow-none" required>
                        </div>
                        <div class="mb-4">
                            <label class="form-label small fw-bold">Nhập lại mật khẩu mới</label>
                            <input type="password" id="confirmPassword" class="form-control shadow-none" required>
                            <div class="invalid-feedback" id="errorText">Mật khẩu không khớp hoặc không đủ điều kiện bảo mật.</div>
                        </div>
                        <button type="submit" class="btn w-100 text-white" style="background-color: #93000b;">Xác nhận đổi mật khẩu</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.getElementById('changePassForm').addEventListener('submit', function(e) {
    const newPass = document.getElementById('newPassword').value;
    const confirmPass = document.getElementById('confirmPassword').value;
    const errorText = document.getElementById('errorText');
    const confirmInput = document.getElementById('confirmPassword');

    // Biểu thức Regex kiểm tra: tối thiểu 6 ký tự, có ít nhất 1 chữ cái, 1 chữ số, 1 ký tự đặc biệt
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$/;

    if (!passwordRegex.test(newPass)) {
        e.preventDefault();
        confirmInput.classList.add('is-invalid');
        errorText.innerText = "Mật khẩu mới phải từ 6 ký tự trở lên, gồm đầy đủ chữ cái, chữ số và ít nhất 1 ký tự đặc biệt (!@#$...).";
        return false;
    }

    if (newPass !== confirmPass) {
        e.preventDefault();
        confirmInput.classList.add('is-invalid');
        errorText.innerText = "Xác nhận mật khẩu mới không trùng khớp nhau!";
        return false;
    }

    confirmInput.classList.remove('is-invalid');
});
</script>
</body>
</html>