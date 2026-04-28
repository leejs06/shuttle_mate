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
    /* 탭 스타일 유지 */
    .nav-tabs .nav-link { color: #495057; font-weight: 600; border: none; padding: 1rem 1.5rem; }
    .nav-tabs .nav-link.active { color: #2ECC71; border-bottom: 3px solid #2ECC71; background: none; }
    .member-card { border-left: 5px solid #2ECC71; transition: transform 0.2s; }
    .member-card:hover { transform: translateX(5px); }
    main { min-height: 80vh; padding-bottom: 50px; }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main class="container my-5">
  <div class="mb-4" style="margin-top: 40px;">
    <h2 class="fw-bold"><i class="fa-solid fa-users-gear me-2"></i>${club.clubTitle} 관리</h2>
    <p class="text-muted">모임의 멤버를 관리하고 정보를 수정할 수 있습니다.</p>
  </div>

  <div class="tab-pane fade show active" id="member-content" role="tabpanel">
    <div class="bg-white p-4 shadow-sm rounded-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h6 class="fw-bold m-0">등록된 멤버 목록 (${memberList.size()}명)</h6>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addMemberModal">
          <i class="fa-solid fa-plus me-1"></i> 멤버 직접 추가
        </button>
      </div>

      <div class="table-responsive">
        <table class="table table-hover align-middle" style="font-size: 0.95rem;">
          <thead class="table-light">
          <tr>
            <th>이름</th>
            <th>성별</th>
            <th>생년</th>
            <th>급수 (전국/시/구)</th>
            <th class="text-center">관리</th>
          </tr>
          </thead>
          <tbody>
          <c:choose>
            <c:when test="${not empty memberList}">
              <c:forEach items="${memberList}" var="m">
                <tr>
                  <td><span class="fw-bold text-dark">${m.userName}</span></td>
                  <td>
                    <c:choose>
                      <c:when test="${m.gender == 'M'}"><span class="text-primary">남성</span></c:when>
                      <c:when test="${m.gender == 'F'}"><span class="text-danger">여성</span></c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </td>
                  <td>${m.birthYear}년</td>
                  <td>
                    <span class="badge bg-success">${m.addr1Level}</span>
                    <span class="badge bg-secondary">${m.addr2Level}</span>
                    <span class="badge bg-info text-dark">${m.addr3Level}</span>
                  </td>
                  <td class="text-center">
                    <button class="btn btn-sm btn-outline-danger">제외</button>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="5" class="text-center py-5 text-muted">등록된 멤버가 없습니다.</td>
              </tr>
            </c:otherwise>
          </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</main>

<div class="modal fade" id="addMemberModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <form action="<c:url value='/club/addMemberPro'/>" method="post">
        <input type="hidden" name="clubId" value="${club.clubId}">
        <div class="modal-header bg-primary text-white">
          <h5 class="modal-title fw-bold">새 멤버 정보 입력</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body p-4">
          <div class="mb-3">
            <label class="form-label fw-semibold">이름</label>
            <input type="text" name="userName" class="form-control" placeholder="성함을 입력하세요" required>
          </div>
          <div class="row mb-3">
            <div class="col-6">
              <label class="form-label fw-semibold">성별</label>
              <select name="gender" class="form-select">
                <option value="M">남성</option>
                <option value="F">여성</option>
              </select>
            </div>
            <div class="col-6">
              <label class="form-label fw-semibold">출생 연도</label>
              <input type="number" name="birthYear" class="form-control" placeholder="예: 1995" min="1950" max="2026">
            </div>
          </div>
          <div class="mb-2">
            <label class="form-label text-success fw-bold">전국/시/구 급수</label>
            <div class="d-flex gap-2">
              <select name="addr1Level" class="form-select">
                <option value="">전국</option>
                <c:forEach items="${addr1Level}" var="l"><option value="${l.addr1Level}">${l.addr1Level}</option></c:forEach>
              </select>
              <select name="addr2Level" class="form-select">
                <option value="">시</option>
                <c:forEach items="${addr2Level}" var="l"><option value="${l.addr2Level}">${l.addr2Level}</option></c:forEach>
              </select>
              <select name="addr3Level" class="form-select">
                <option value="">구</option>
                <c:forEach items="${addr3Level}" var="l"><option value="${l.addr3Level}">${l.addr3Level}</option></c:forEach>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer border-0">
          <button type="button" class="btn btn-light" data-bs-dismiss="modal">취소</button>
          <button type="submit" class="btn btn-primary px-4">멤버 등록 완료</button>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>