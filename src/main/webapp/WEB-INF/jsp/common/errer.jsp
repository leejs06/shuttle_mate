<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>ShuttleMate - 알림</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .error-container { min-height: 80vh; display: flex; align-items: center; justify-content: center; }
        .error-card { max-width: 500px; width: 100%; padding: 2rem; border-radius: 15px; border: none; }
        .error-icon { font-size: 4rem; color: #ff6b6b; margin-bottom: 1rem; }
    </style>
</head>
<body class="bg-light">

<div class="error-container">
    <div class="error-card bg-white shadow-sm text-center">
        <i class="fa-solid fa-circle-exclamation error-icon"></i>
        <h3 class="fw-bold mb-3">안내드립니다</h3>
        <p class="text-muted mb-4">${msg != null ? msg : "알 수 없는 오류가 발생했습니다.<br>잠시 후 다시 시도해주세요."}</p>

        <div class="d-grid gap-2">
            <a href="javascript:history.back();" class="btn btn-outline-secondary">이전 페이지로</a>
            <a href="<c:url value="/"/>" class="btn btn-success">메인으로 이동</a>
        </div>
    </div>
</div>

</body>
</html>