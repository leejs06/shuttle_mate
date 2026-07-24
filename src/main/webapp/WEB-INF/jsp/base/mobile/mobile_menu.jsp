<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/base/mobile_menu.css">

    <%--
        로그인이 필요한 진입점(생성/회원 검색/매칭 내역)은 미로그인 시
        "모임 관리" 카드와 동일하게 alert 후 로그인 페이지로 이동.
        홈은 로그인 여부와 무관하게 그냥 이동.
    --%>
    <script>
        (function () {
            var isLoggedIn = <c:choose><c:when test="${not empty sessionScope.loginUser}">true</c:when><c:otherwise>false</c:otherwise></c:choose>;
            var loginUrl = '${pageContext.request.contextPath}/login';

            window.checkLoginAndGo = function (targetUrl) {
                if (!isLoggedIn) {
                    alert('세션이 만료되었거나 로그인이 필요합니다.\n로그인 페이지로 이동합니다.');
                    location.href = loginUrl;
                } else {
                    location.href = targetUrl;
                }
            };
        })();
    </script>

<div class="mobile-nav">
    <a href="<c:url value="/"/>" class="mobile-nav-item">
        <i class="fa-solid fa-house"></i>
        <span>홈</span>
    </a>
    <a href="javascript:void(0);" onclick="checkLoginAndGo('${pageContext.request.contextPath}/club/manage?tab=member')" class="mobile-nav-item">
        <i class="fa-solid fa-magnifying-glass"></i>
        <span>회원 검색</span>
    </a>
    <a href="javascript:void(0);" onclick="checkLoginAndGo('${pageContext.request.contextPath}/club/create')" class="mobile-nav-item nav-center-btn active">
        <i class="fa-solid fa-circle-plus"></i>
        <span>생성</span>
    </a>
    <a href="javascript:void(0);" onclick="checkLoginAndGo('${pageContext.request.contextPath}/club/matchHistory')" class="mobile-nav-item">
        <i class="fa-solid fa-clock-rotate-left"></i>
        <span>매칭 내역</span>
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-bars"></i>
        <span>전체</span>
    </a>
</div>