<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 내 모임 목록</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/myclub/myclub.css">
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main class="container my-5" style="min-height: 70vh;">
    <div class="d-flex justify-content-between align-items-center mb-5" style="margin-top: 100px;">
        <div>
            <h2 class="fw-bold m-0">운영 중인 모임</h2>
            <p class="text-muted m-0 mt-1">방장으로 활동 중인 모임 리스트입니다.</p>
        </div>
        <a href="<c:url value="/club/create"/>" class="btn btn-dark rounded-pill px-4 shadow-sm">
            <i class="fa-solid fa-plus me-1"></i> 새 모임 만들기
        </a>
    </div>

    <div class="row g-4">
        <c:choose>
            <c:when test="${not empty clubList}">
                <c:forEach items="${clubList}" var="club">
                    <div class="col-md-6 col-lg-4">
                        <div class="card club-card shadow-sm h-100">
                            <div class="card-body p-4 d-flex flex-column">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <span class="status-badge">운영중</span>
                                    <small class="text-muted">${club.regDate}</small>
                                </div>
                                <h4 class="fw-bold mb-2 text-dark">${club.clubTitle}</h4>
                                <p class="text-muted mb-4 flex-grow-1">
                                    <i class="fa-solid fa-location-dot me-1 text-danger"></i> ${club.location}
                                </p>
                                <div class="d-grid">
                                    <a href="<c:url value="/club/manage?clubId=${club.clubId}"/>" class="btn manage-btn py-2 shadow-sm">
                                        모임 관리 페이지 이동 <i class="fa-solid fa-chevron-right ms-1"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12">
                    <div class="empty-state bg-white rounded-4 shadow-sm border">
                        <i class="fa-solid fa-users-slash fa-4x text-light mb-3"></i>
                        <h4 class="fw-bold text-secondary">운영 중인 모임이 없습니다.</h4>
                        <p class="text-muted">직접 모임을 만들고 관리자를 시작해보세요!</p>
                        <a href="<c:url value="/club/create"/>" class="btn btn-primary mt-3 px-4 py-2 rounded-pill">모임 생성하기</a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/myclub/myclub.js" defer></script>

</body>
</html>