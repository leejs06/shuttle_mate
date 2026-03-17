<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>shuttle-mate-홈 화면</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main/index.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main/main.css">
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<%--<nav class="navbar navbar-light sticky-top">
    <div class="container-fluid">
        <span class="navbar-brand">셔틀메이트</span>
        <div class="d-flex">
            <i class="fa-regular fa-bell fa-lg mt-2 me-3"></i>
            <i class="fa-regular fa-circle-user fa-lg mt-2"></i>
        </div>
    </div>
</nav>--%>

<div class="container mt-4">
    <div class="d-flex overflow-auto pb-2 mb-3" style="white-space: nowrap;">
        <button class="btn btn-outline-secondary btn-sm me-2 rounded-pill active">전체</button>
        <button class="btn btn-outline-secondary btn-sm me-2 rounded-pill">서울</button>
        <button class="btn btn-outline-secondary btn-sm me-2 rounded-pill">경기</button>
        <button class="btn btn-outline-secondary btn-sm me-2 rounded-pill">인천</button>
    </div>

    <div class="row g-2 mb-4">
        <div class="col-6">
            <div class="p-3 bg-white border rounded-4 text-center" onclick="location.href='/random'">
                <i class="fa-solid fa-bolt text-warning mb-2" style="font-size: 1.5rem;"></i>
                <div class="fw-bold">랜덤 매칭</div>
                <small class="text-muted">로그인 없이 즉시</small>
            </div>
        </div>
        <div class="col-6">
            <div class="p-3 bg-white border rounded-4 text-center" onclick="location.href='/club/create'">
                <i class="fa-solid fa-users text-primary mb-2" style="font-size: 1.5rem;"></i>
                <div class="fw-bold">모임 만들기</div>
                <small class="text-muted">전적 관리/정밀 밸런스</small>
            </div>
        </div>
    </div>

    <h5 class="fw-bold mb-3">내 주변 매칭 공고</h5>

    <div class="card match-card p-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="badge-level">C조 이상</span>
            <span class="text-muted small"><i class="fa-solid fa-location-dot"></i> 강남구 역삼동</span>
        </div>
        <h6 class="fw-bold mb-1">역삼 체육관 남복/혼복 모집합니다!</h6>
        <div class="text-muted small mb-3">오전 10:00 ~ 12:00 | 2/4명 모집</div>
        <div class="d-flex justify-content-between align-items-center">
            <div class="user-avatars">
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
            </div>
            <button class="btn btn-sm btn-main">참여하기</button>
        </div>
    </div>

    <div class="card match-card p-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="badge-level">자강 또는 A조</span>
            <span class="text-muted small"><i class="fa-solid fa-location-dot"></i> 고양시 신평동</span>
        </div>
        <h6 class="fw-bold mb-1">더쎈 체육관 남복/혼복/여복 모집합니다!</h6>
        <div class="text-muted small mb-3">야간 22:00 ~  | 7/24명 모집</div>
        <div class="d-flex justify-content-between align-items-center">
            <div class="user-avatars">
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
            </div>
            <button class="btn btn-sm btn-main">참여하기</button>
        </div>
    </div>

    <div class="card match-card p-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="badge-level">B조 이상</span>
            <span class="text-muted small"><i class="fa-solid fa-location-dot"></i> 인천광역시 연수구</span>
        </div>
        <h6 class="fw-bold mb-1">대학공원 체육관 남복/혼복/여복 모집합니다!</h6>
        <div class="text-muted small mb-3">오후 13:00 ~ 16:00 | 5/20명 모집</div>
        <div class="d-flex justify-content-between align-items-center">
            <div class="user-avatars">
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
            </div>
            <button class="btn btn-sm btn-main">참여하기</button>
        </div>
    </div>

    <div class="card match-card p-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="badge-level">초심 이상</span>
            <span class="text-muted small"><i class="fa-solid fa-location-dot"></i> 인천광역시 선학동</span>
        </div>
        <h6 class="fw-bold mb-1">선학 체육관 남복/여복 모집합니다!</h6>
        <div class="text-muted small mb-3">오전 09:00 ~ 12:00 | 2/10명 모집</div>
        <div class="d-flex justify-content-between align-items-center">
            <div class="user-avatars">
                <i class="fa-solid fa-circle-user text-secondary"></i>
                <i class="fa-solid fa-circle-user text-secondary"></i>
            </div>
            <button class="btn btn-sm btn-main">참여하기</button>
        </div>
    </div>

</div>

<div class="mobile-nav d-md-none">
    <a href="#" class="mobile-nav-item active">
        <i class="fa-solid fa-house"></i>홈
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-magnifying-glass"></i>검색
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-plus-circle" style="font-size: 1.8rem; color: var(--main-green);"></i>생성
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-ranking-star"></i>랭킹
    </a>
    <a href="#" class="mobile-nav-item">
        <i class="fa-solid fa-bars"></i>전체
    </a>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>