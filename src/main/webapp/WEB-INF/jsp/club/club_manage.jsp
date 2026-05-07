<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ShuttleMate - ${club.clubTitle} 관리</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/club/club_manage.css">

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/js/club/club_manage.js" defer></script>
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main>
  <div class="container my-5">

    <%-- 페이지 헤더 --%>
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title mb-1">
          <i class="fa-solid fa-people-group me-2"></i>${club.clubTitle} 관리
        </h2>
        <p class="text-muted mb-0">모임의 멤버를 관리하고 정보를 수정할 수 있습니다.</p>
      </div>
    </div>

    <%-- 탭 네비게이션 --%>
    <ul class="nav nav-tabs manage-tabs mb-4" id="manageTabs" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="member-tab"
                data-bs-toggle="tab" data-bs-target="#memberPanel"
                type="button" role="tab">
          <i class="fa-solid fa-users me-1"></i>멤버 관리
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="edit-tab"
                data-bs-toggle="tab" data-bs-target="#editPanel"
                type="button" role="tab">
          <i class="fa-solid fa-pen-to-square me-1"></i>모임 정보 수정
        </button>
      </li>
    </ul>

    <%-- 탭 콘텐츠 --%>
    <div class="tab-content" id="manageTabContent">

      <%-- ① 멤버 관리 탭 (기존 기능) --%>
      <div class="tab-pane fade show active" id="memberPanel" role="tabpanel">
        <div class="manage-card p-4">
          <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
            <h6 class="fw-bold mb-0">
              등록된 멤버 목록 (<span id="memberCount">${memberList.size()}</span>명)
            </h6>
            <button class="btn btn-add-member" data-bs-toggle="modal" data-bs-target="#addMemberModal">
              <i class="fa-solid fa-plus me-1"></i>멤버 직접 추가
            </button>
          </div>

          <div class="table-responsive">
            <table class="table member-table align-middle mb-0">
              <thead>
              <tr>
                <th>이름</th>
                <th>성별</th>
                <th>생년</th>
                <th>급수 (전국/시/구)</th>
                <th>관리</th>
              </tr>
              </thead>
              <tbody id="memberTableBody">
              <c:choose>
                <c:when test="${empty memberList}">
                  <tr>
                    <td colspan="5" class="text-center text-muted py-4">
                      등록된 멤버가 없습니다.
                    </td>
                  </tr>
                </c:when>
                <c:otherwise>
                  <c:forEach items="${memberList}" var="m">
                    <tr>
                      <td class="fw-semibold">${m.userName}</td>
                      <td>
                        <span class="badge-gender ${m.gender eq 'M' ? 'male' : 'female'}">
                            ${m.gender eq 'M' ? '남성' : '여성'}
                        </span>
                      </td>
                      <td>${m.birthYear}년</td>
                      <td>
                        <span class="badge-level">${m.addr1Level}</span>
                        <span class="badge-level">${m.addr2Level}</span>
                        <span class="badge-level city">${m.addr3Level}</span>
                      </td>
                      <td>
                        <button class="btn btn-kick"
                                onclick="kickMember('${m.memberId}', '${m.userName}')">
                          제외
                        </button>
                      </td>
                    </tr>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <%-- ② 모임 정보 수정 탭 (신규) --%>
      <div class="tab-pane fade" id="editPanel" role="tabpanel">
        <div class="manage-card p-4">
          <form action="<c:url value="/club/update"/>" method="post" id="clubEditForm">
            <%-- clubId는 hidden으로 전달 --%>
            <input type="hidden" name="clubId" value="${club.clubId}">

            <%-- 모임 기본 정보 --%>
            <div class="form-section mb-5">
              <h5 class="section-title">
                <i class="fa-solid fa-circle-info me-2"></i>모임 기본 정보
              </h5>
              <div class="row g-3">
                <div class="col-12">
                  <label class="form-label">모임명</label>
                  <input type="text" name="clubTitle" class="form-control"
                         value="${club.clubTitle}" required>
                </div>
                <div class="col-md-6">
                  <label class="form-label">활동 장소</label>
                  <input type="text" name="location" class="form-control"
                         value="${club.location}" required>
                </div>
                <div class="col-md-6">
                  <label class="form-label">최대 관리 인원(명)</label>
                  <input type="number" name="maxMembers" class="form-control"
                         value="${club.maxMembers}" min="4" max="500">
                </div>
                <div class="col-12">
                  <label class="form-label">모임 소개</label>
                  <textarea name="description" class="form-control" rows="4">${club.description}</textarea>
                </div>
              </div>
            </div>

            <%-- 관리자(본인) 프로필 수정 --%>
            <div class="form-section mb-4">
              <h5 class="section-title">
                <i class="fa-solid fa-id-card me-2"></i>모임 관리자(본인) 상세 프로필
              </h5>

              <%-- Row 1: 계정 정보 (읽기 전용) + 출생 연도 --%>
              <div class="row g-3 mb-3">
                <div class="col-12 col-md-4">
                  <label class="form-label">사용자 ID</label>
                  <input type="text" class="form-control bg-light"
                         value="${sessionScope.loginUser.userId}" readonly>
                </div>
                <div class="col-12 col-md-4">
                  <label class="form-label">사용자명</label>
                  <input type="text" class="form-control bg-light"
                         value="${sessionScope.loginUser.userName}" readonly>
                </div>
                <div class="col-12 col-md-4">
                  <label class="form-label">출생 연도</label>
                  <select name="birthYear" id="editBirthYear" class="form-select"
                          data-selected="${adminMember.birthYear}">
                  </select>
                </div>
              </div>

              <%-- Row 2: 성별 + 급수 3종 (모바일 2열 / PC 4열) --%>
              <div class="row g-3">
                <div class="col-6 col-md-3">
                  <label class="form-label">성별</label>
                  <div class="btn-group w-100" role="group" aria-label="성별 선택">
                    <input type="radio" class="btn-check" name="gender" id="editGenderM" value="M"
                    ${adminMember.gender eq 'M' ? 'checked' : ''}>
                    <label class="btn btn-outline-primary" for="editGenderM">남성</label>
                    <input type="radio" class="btn-check" name="gender" id="editGenderF" value="F"
                    ${adminMember.gender eq 'F' ? 'checked' : ''}>
                    <label class="btn btn-outline-danger" for="editGenderF">여성</label>
                  </div>
                </div>
                <div class="col-6 col-md-3">
                  <label class="form-label text-success fw-bold">전국 급수</label>
                  <select name="addr1Level" class="form-select border-success">
                    <option value="">:: 선택 ::</option>
                    <c:forEach items="${addr1Level}" var="addr1L">
                      <option value="${addr1L.addr1Level}"
                        ${adminMember.addr1Level eq addr1L.addr1Level ? 'selected' : ''}>
                          ${addr1L.addr1Level}
                      </option>
                    </c:forEach>
                  </select>
                </div>
                <div class="col-6 col-md-3">
                  <label class="form-label">시 급수</label>
                  <select name="addr2Level" class="form-select border-success">
                    <option value="">:: 선택 ::</option>
                    <c:forEach items="${addr2Level}" var="addr2L">
                      <option value="${addr2L.addr2Level}"
                        ${adminMember.addr2Level eq addr2L.addr2Level ? 'selected' : ''}>
                          ${addr2L.addr2Level}
                      </option>
                    </c:forEach>
                  </select>
                </div>
                <div class="col-6 col-md-3">
                  <label class="form-label">구 급수</label>
                  <select name="addr3Level" class="form-select border-success">
                    <option value="">:: 선택 ::</option>
                    <c:forEach items="${addr3Level}" var="addr3L">
                      <option value="${addr3L.addr3Level}"
                        ${adminMember.addr3Level eq addr3L.addr3Level ? 'selected' : ''}>
                          ${addr3L.addr3Level}
                      </option>
                    </c:forEach>
                  </select>
                </div>
              </div>
            </div>

            <div class="d-flex gap-2 mt-4">
              <button type="submit" class="btn btn-save flex-grow-1 py-3 fw-bold shadow-sm">
                <i class="fa-solid fa-floppy-disk me-2"></i>수정 내용 저장
              </button>
              <button type="button" class="btn btn-outline-secondary py-3 px-4 fw-bold"
                      id="btnResetForm">
                <i class="fa-solid fa-rotate-left me-1"></i>초기화
              </button>
            </div>
          </form>
        </div>
      </div>

    </div><%-- /tab-content --%>
  </div>
</main>

<%-- 멤버 직접 추가 모달 --%>
<div class="modal fade" id="addMemberModal" tabindex="-1" aria-labelledby="addMemberModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title fw-bold" id="addMemberModalLabel">
          <i class="fa-solid fa-user-plus me-2 text-success"></i>멤버 직접 추가
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label class="form-label">사용자 ID 또는 이름 검색</label>
          <div class="input-group">
            <input type="text" id="searchMemberInput" class="form-control"
                   placeholder="검색어를 입력하세요">
            <button class="btn btn-outline-success" type="button" id="btnSearchMember">
              <i class="fa-solid fa-magnifying-glass"></i>
            </button>
          </div>
        </div>
        <div id="searchResult"></div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

</body>
</html>
