<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<link rel="stylesheet" href="<c:url value='/css/common/common.css'/>">
<link rel="stylesheet" href="<c:url value='/css/base/header.css'/>">

<header class="main-header">
    <div class="header-inner">
        <a href="<c:url value='/'/>" class="logo">
            SHUTTLE<span>MATE</span>
        </a>

        <nav>
            <ul class="nav-list">
                <li><a href="<c:url value='/'/>">매칭</a></li>
                <li><a href="<c:url value='/mypage/main'/>">마이페이지</a></li>

                <c:choose>
                    <c:when test="${not empty sessionScope.loginUser}">
                        <li><a href="javascript:void(0);" onclick="handleLogout();">로그아웃</a></li>
                    </c:when>
                    <c:otherwise>
                        <li><a href="<c:url value='/login'/>">로그인</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </nav>
    </div>
</header>

<script>
    // 로그아웃 하기 전 재확인
    function handleLogout() {
        if (confirm("로그아웃 하시겠습니까?")) {
            location.href = "<c:url value='/logout'/>";
        }
    }
</script>