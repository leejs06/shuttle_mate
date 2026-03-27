<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 로그인 페이지</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth/auth.css">
    <script src="${pageContext.request.contextPath}/js/auth/auth.js" defer></script>
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<div class="auth-container">
    <div class="auth-box">
        <h1 class="logo">셔틀<span>메이트</span></h1>
        <p class="subtitle">오늘의 콕, 함께 경기할 메이트를 찾아보세요!</p>

        <form id="loginForm" action="<c:url value="/login/success"/>" method="POST">
            <div class="input-group">
                <input type="text" id="userId" name="userId" placeholder="아이디" required>
            </div>
            <div class="input-group">
                <input type="password" id="userPw" name="userPw" placeholder="비밀번호" required>
            </div>
            <button type="submit" class="btn-primary">로그인</button>
        </form>

        <div class="auth-footer">
            <a href="#">아이디/비밀번호 찾기</a>
            <span class="divider">|</span>
            <a href="/join">회원가입</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

</body>
</html>
