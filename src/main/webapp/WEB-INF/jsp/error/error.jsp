<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<%
    Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
    if (statusCode == null) statusCode = 404;

    String errorClass = (statusCode == 500) ? "status-500" : "status-404";
    String emoji = (statusCode == 500) ? "🛠️" : "🏸";
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
    <h2><%= (statusCode == 500) ? "서버 오류가 발생했습니다" : "페이지를 찾을 수 없습니다" %></h2>
    <p>서비스 이용에 불편을 드려 죄송합니다.<br>잠시 후 다시 시도하거나 홈으로 이동해 주세요.</p>

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