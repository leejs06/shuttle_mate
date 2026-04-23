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

    /* PC에서는 하단 바 숨김 (Bootstrap d-md-none과 동일 역할) */
    @media (min-width: 768px) {
        .mobile-nav {
            display: none !important;
        }
    }
</style>

<div class="mobile-nav">
    <a href="<c:url value="/"/>" class="mobile-nav-item">
        <i class="fa-solid fa-house"></i>
        <span>홈</span>
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-magnifying-glass"></i>
        <span>검색</span>
    </a>
    <a href="<c:url value="/club/create"/>" class="mobile-nav-item nav-center-btn active">
        <i class="fa-solid fa-circle-plus"></i>
        <span>생성</span>
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-clock-rotate-left"></i>
        <span>히스토리</span>
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-bars"></i>
        <span>전체</span>
    </a>
</div>