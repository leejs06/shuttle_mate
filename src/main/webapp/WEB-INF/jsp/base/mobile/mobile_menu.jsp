<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<style>
    /* 모바일 하단 바 메뉴 스타일 */
    .mobile-nav {
        position: fixed !important;
        bottom: 0 !important;
        left: 0;
        width: 100%;
        height: 70px;
        background-color: #ffffff !important; /* 배경색 흰색 고정 */
        display: flex !important;
        justify-content: space-around;
        align-items: center;
        border-top: 1px solid #e9ecef;
        z-index: 10000; /* 어떤 요소보다 위에 표시 */
        box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05); /* 상단에 은은한 그림자 */
    }

    .mobile-nav-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-decoration: none !important;
        color: #495057; /* 기본 아이콘/글자 색상 */
        font-size: 0.75rem;
        flex: 1;
        transition: color 0.2s ease;
    }

    .mobile-nav-item i {
        font-size: 1.4rem;
        margin-bottom: 4px;
    }

    /* 활성화된 상태 (현재 페이지) */
    .mobile-nav-item.active {
        color: #2ECC71 !important; /* 셔틀메이트 메인 그린 색상 */
    }

    /* 이미지처럼 '생성' 버튼 강조 스타일 */
    .nav-center-btn i {
        font-size: 1.8rem !important;
        color: #2ECC71;
    }

    /*
       PC에서는 하단 바 숨김.
       기준을 1025px로 잡은 이유: 가장 큰 아이패드(12.9인치 iPad Pro)의 세로 모드
       논리 해상도가 1024px이라, 그 아이패드까지는 모바일 메뉴가 계속 보이게 하기 위함.
       (해당 기준은 club_create.css / club_manage.css / random_match.css 에도 동일하게 맞춰둠)
    */
    @media (min-width: 1025px) {
        .mobile-nav {
            display: none !important;
        }
    }
</style>

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