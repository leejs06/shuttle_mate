<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<%
    Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
    if (statusCode == null) statusCode = 404;

    String errorClass = "status-500";
    String emoji = "⚠️";
    String title = "문제가 발생했습니다";
    String message = "요청을 처리하는 중 오류가 발생했습니다.";

    if (statusCode == 404) {
        errorClass = "status-404";
        emoji = "🏸";
        title = "페이지를 찾을 수 없습니다";
        message = "요청하신 페이지가 존재하지 않거나<br>이동되었습니다. 홈으로 돌아가 주세요.";
    } else if (statusCode == 400) {
        errorClass = "status-500";
        emoji = "🚫";
        title = "잘못된 요청입니다";
        message = "입력하신 값이 올바르지 않습니다.<br>다시 확인해 주세요.";
    } else if (statusCode >= 500) {
        errorClass = "status-500";
        emoji = "🛠️";
        title = "서버 오류가 발생했습니다";
        message = "서버 내부 문제로 이용이 원활하지 않습니다.<br>잠시 후 다시 시도해 주세요.";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - <%=statusCode%></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/error/error.css">
</head>
<body class="<%=errorClass%>">

<header>
    <a href="${pageContext.request.contextPath}/" class="logo">
        SHUTTLE<span>MATE</span>
    </a>
    <nav>
        <a href="#">매칭</a>
        <a href="#">마이페이지</a>
        <a href="#">로그인</a>
    </nav>
</header>

<div class="error-container">
    <div class="icon-circle"><%=emoji%></div>
    <h1><%=statusCode%></h1>
    <h2><%=title%></h2>
    <p><%=message%></p>

    <div class="btn-group">
        <a href="javascript:history.back();" class="btn btn-prev">이전 페이지</a>
        <a href="${pageContext.request.contextPath}/" class="btn btn-home">홈으로 이동</a>
    </div>
</div>

<footer>
    <a href="#">이용약관</a>
    <a href="#">개인정보처리방침</a>
    <a href="#">고객센터</a>
</footer>

</body>
</html>