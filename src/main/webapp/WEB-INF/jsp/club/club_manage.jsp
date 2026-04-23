<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ShuttleMate - 모임 관리</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/club/club_create.css">
  <style>
    .nav-tabs .nav-link { color: #495057; font-weight: 600; border: none; padding: 1rem 1.5rem; }
    .nav-tabs .nav-link.active { color: #2ECC71; border-bottom: 3px solid #2ECC71; background: none; }
    .member-card { border-left: 5px solid #2ECC71; transition: transform 0.2s; }
    .member-card:hover { transform: translateX(5px); }
  </style>
</head>
<body class="bg-light">

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main class="container my-5">
  <div class="mx-auto" style="max-width: 900px; margin-top: 80px;">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h3 class="fw-bold m-0"><i class="fa-solid fa-gear me-2"></i>모임 관리 센터</h3>
      <span class="badge bg-success p-2">운영 중</span>
    </div>

    <ul class="nav nav-tabs mb-4 bg-white shadow-sm rounded-top" id="manageTab" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="info-tab" data-bs-toggle="tab" data-bs-target="#info-content" type="button">정보 수정</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="member-tab" data-bs-toggle="tab" data-bs-target="#member-content" type="button">멤버 승인/관리</button>
      </li>
    </ul>

    <div class="tab-content border-0">
      <div class="tab-pane fade show active" id="info-content" role="tabpanel">
        <div class="bg-white p-4 shadow-sm rounded-bottom">
          <form action="/club/updatePro" method="post">
            <input type="hidden" name="clubId" value="${club.clubId}">
            <div class="row g-3">
              <div class="col-12">
                <label class="form-label fw-bold">모임명</label>
                <input type="text" name="clubTitle" class="form-control" value="${club.clubTitle}">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">활동 장소</label>
                <input type="text" name="location" class="form-control" value="${club.location}">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">최대 인원</label>
                <input type="number" name="maxMembers" class="form-control" value="${club.maxMembers}">
              </div>
              <div class="col-12">
                <label class="form-label">모임 소개</label>
                <textarea name="description" class="form-control" rows="3" placeholder="모임 규칙 및 소개를 입력하세요."></textarea>
              </div>
              <div class="col-12 text-end mt-4">
                <button type="submit" class="btn btn-success px-5 py-2 fw-bold">설정 저장하기</button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <div class="tab-pane fade" id="member-content" role="tabpanel">
        <div class="bg-white p-4 shadow-sm rounded-bottom">
          <h6 class="fw-bold mb-3">가입 신청 대기 (${pendingList.size()}명)</h6>
          <c:forEach items="${pendingList}" var="member">
            <div class="member-card bg-light p-3 mb-3 rounded d-flex justify-content-between align-items-center shadow-sm">
              <div>
                <span class="fw-bold">${member.userId}</span>
                <small class="text-muted ms-2">${member.gender} / ${member.birthYear}년생</small>
                <div class="mt-1"><span class="badge bg-outline-success border border-success text-success">${member.addr1Level}</span></div>
              </div>
              <div class="btn-group">
                <button class="btn btn-sm btn-primary px-3">승인</button>
                <button class="btn btn-sm btn-outline-danger px-3">거절</button>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>