<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 연령대 계산용 현재 연도 --%>
<c:set var="currentYear" value="<%= java.time.Year.now().getValue() %>"/>
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
  <%-- 수동 매칭 - 선수 카드 드래그앤드롭용 (PC 마우스 + 모바일 터치 모두 지원) --%>
  <script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/Sortable.min.js"></script>
  <script>
    // JS에서 사용할 contextPath / clubId 전역 변수
    const contextPath = '${pageContext.request.contextPath}';
    const clubId = '${club.clubId}';
  </script>
  <script src="${pageContext.request.contextPath}/js/club/club_manage.js" defer></script>
</head>
<body>

<c:if test="${param.blocked == 'club'}">
<script>
    alert('이미 운영 중인 모임이 있어 추가로 생성할 수 없습니다.\n계정당 모임은 1개만 만들 수 있습니다.');
</script>
</c:if>

<%-- 모바일 메뉴 "검색" 진입점: 회원 관리 탭을 바로 열고 이름 검색창에 포커스 --%>
<c:if test="${param.tab == 'member'}">
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const memberTabBtn = document.getElementById('member-tab');
        if (memberTabBtn && window.bootstrap) {
            new bootstrap.Tab(memberTabBtn).show();
        }
        setTimeout(function () {
            const searchInput = document.getElementById('memberSearch');
            if (searchInput) searchInput.focus();
        }, 150);
    });
</script>
</c:if>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main>
  <div class="container my-5">

    <%-- 페이지 헤더 --%>
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title mb-1">
          <i class="fa-solid fa-people-group me-2"></i><%--${club.clubTitle}--%> 모임 관리
        </h2>
<%--
        <p class="text-muted mb-0">모임의 회원을 관리하고 정보를 수정할 수 있습니다.</p>
--%>
      </div>
    </div>

    <%-- 탭 네비게이션 --%>
    <ul class="nav nav-tabs manage-tabs mb-4" id="manageTabs" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="match-tab"
                data-bs-toggle="tab" data-bs-target="#matchPanel"
                type="button" role="tab">
          <i class="fa-solid fa-shuttle-space me-1"></i>경기 매칭
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="member-tab"
                data-bs-toggle="tab" data-bs-target="#memberPanel"
                type="button" role="tab">
          <i class="fa-solid fa-users me-1"></i>회원 관리
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

      <%-- ① 경기 매칭 탭 (첫 화면) --%>
      <div class="tab-pane fade show active" id="matchPanel" role="tabpanel">
        <div class="manage-card p-4">

          <%-- ───────────────────────────────────────────────
               🆕 오늘 참석 회원 선택 (자동/수동 매칭 공통 풀)
               ─────────────────────────────────────────────── --%>
          <div class="attending-box mb-4">
            <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
              <h6 class="fw-bold mb-0">
                <i class="fa-solid fa-clipboard-user me-1 text-success"></i>
                참석 회원 선택
                <span class="text-muted small ms-2">
            (전체 ${memberList.size()}명 중 <strong id="attendingCount">0</strong>명 선택)
          </span>
              </h6>
              <div class="d-flex gap-2">
                <button type="button" class="btn btn-sm btn-select-all" id="btnAttendAll">
                  <i class="fa-solid fa-check-double me-1"></i>전체 선택
                </button>
                <button type="button" class="btn btn-sm btn-deselect-all" id="btnAttendClear">
                  <i class="fa-solid fa-xmark me-1"></i>전체 해제
                </button>
                <button type="button" class="btn btn-sm btn-attend-toggle" id="btnAttendToggle"
                        data-bs-toggle="collapse" data-bs-target="#attendingCollapse"
                        aria-expanded="true" aria-controls="attendingCollapse" title="접기/펼치기">
                  <i class="fa-solid fa-chevron-up"></i>
                </button>
              </div>
            </div>

            <%-- 참석 회원 선택 내용 - 접기/펼치기 대상. 기본은 펼침, 코트 추가 시 자동으로 접힘 --%>
            <div class="collapse show" id="attendingCollapse">

              <%-- 이름 검색 --%>
              <div class="input-group mb-3 attend-search-group">
          <span class="input-group-text bg-white">
            <i class="fa-solid fa-magnifying-glass text-muted"></i>
          </span>
                <input type="text" id="attendSearchInput" class="form-control"
                       placeholder="이름으로 검색">
                <button class="btn btn-outline-secondary" type="button" id="btnAttendSearchClear" title="검색어 지우기">
                  <i class="fa-solid fa-xmark"></i>
                </button>
              </div>

              <%-- 회원 카드 그리드 (참여 회원 카드 스타일 재활용) --%>
              <div class="participant-list">
                <c:choose>
                  <c:when test="${empty memberList}">
                    <div class="text-center text-muted py-4">
                      등록된 회원이 없습니다. <b>회원 관리</b> 탭에서 먼저 회원을 추가해주세요.
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div class="row g-2" id="attendingGrid">
                      <c:forEach items="${memberList}" var="m">
                        <%-- m.age는 ClubMemberDto.getAge()의 (현재년도-출생년도)+1 한국식 나이를 그대로 사용 (다른 계산식과 통일) --%>
                        <c:set var="ageGroupA" value="${m.age - (m.age mod 10)}"/>
                        <div class="col-6 col-sm-4 col-md-3 col-lg-3 attending-col"
                             data-name="${m.userName}">
                          <label class="participant-card" for="attend-${m.memberSeq}">
                            <input class="participant-checkbox attend-checkbox"
                                   type="checkbox"
                                   id="attend-${m.memberSeq}"
                                   value="${m.memberSeq}"
                                   data-name="${m.userName}"
                                   data-gender="${m.gender}"
                                   data-addr1="${m.addr1Level}"
                                   data-addr2="${m.addr2Level}"
                                   data-addr3="${m.addr3Level}">
                            <div class="participant-info">
                              <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="participant-name">
                                    ${m.userName}
                                    <c:if test="${m.userRole == 'GUEST'}">
                                        <span class="badge-guest-tag">게스트</span>
                                    </c:if>
                                </span>
                                <span class="badge-gender ${m.gender eq 'M' ? 'male' : 'female'}">
                                    ${m.gender eq 'M' ? '남' : '여'}
                                </span>
                              </div>
                              <div class="participant-meta mb-1">
                                <span class="badge-age">${ageGroupA}대</span>
                              </div>
                              <div class="participant-levels">
                                <span class="badge-level ${empty m.addr1Level ? 'lv-none' : 'lv-'.concat(fn:toLowerCase(m.addr1Level))}">${empty m.addr1Level ? '-' : m.addr1Level}</span>
                                <span class="badge-level ${empty m.addr2Level ? 'lv-none' : 'lv-'.concat(fn:toLowerCase(m.addr2Level))}">${empty m.addr2Level ? '-' : m.addr2Level}</span>
                                <span class="badge-level ${empty m.addr3Level ? 'lv-none' : 'lv-'.concat(fn:toLowerCase(m.addr3Level))}">${empty m.addr3Level ? '-' : m.addr3Level}</span>
                              </div>
                            </div>
                          </label>
                        </div>
                      </c:forEach>
                    </div>
                    <%-- 검색 결과 없을 때 표시 --%>
                    <div id="attendingEmpty" class="text-center text-muted py-3" style="display:none;">
                      검색 결과가 없습니다.
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <hr class="my-4">

          <%-- 자동/수동 서브탭 --%>
          <ul class="nav match-subtabs mb-4" id="matchSubTabs" role="tablist">
            <li class="nav-item" role="presentation" style="display: none;">
              <button class="nav-link" id="auto-match-tab"
                      data-bs-toggle="tab" data-bs-target="#autoMatchSub"
                      type="button" role="tab">
                <i class="fa-solid fa-wand-magic-sparkles me-1"></i>자동 매칭
              </button>
            </li>
            <li class="nav-item" role="presentation">
              <button class="nav-link active" id="manual-match-tab"
                      data-bs-toggle="tab" data-bs-target="#manualMatchSub"
                      type="button" role="tab">
                <i class="fa-solid fa-hand-pointer me-1"></i>수동 매칭
              </button>
            </li>
          </ul>

          <div class="tab-content">

            <%-- ───────── 자동 매칭 ───────── --%>
            <div class="tab-pane fade" id="autoMatchSub" role="tabpanel">

              <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
                <h6 class="fw-bold mb-0">
                  <i class="fa-solid fa-shuttle-space me-1 text-success"></i>자동 매칭
                </h6>
                <span class="text-muted small">
            참석 회원 기준 매칭됩니다.
          </span>
              </div>

              <%-- 매칭 옵션 박스 --%>
              <div class="match-option-box p-3 mb-4">
                <div class="row g-3 align-items-end">
                  <div class="col-12 col-md-3">
                    <label class="form-label">경기 방식</label>
                    <select id="matchType" class="form-select">
                      <option value="DOUBLES" selected>복식 (4인)</option>
                      <option value="SINGLES">단식 (2인)</option>
                      <option value="MIXED">혼합 복식</option>
                    </select>
                  </div>
                  <div class="col-12 col-md-3">
                    <label class="form-label">매칭 기준</label>
                    <select id="matchCriteria" class="form-select">
                      <option value="LEVEL" selected>급수 균형</option>
                      <option value="RANDOM">랜덤</option>
                      <option value="GENDER">성별 균형</option>
                    </select>
                  </div>
                  <div class="col-6 col-md-2">
                    <label class="form-label">코트 수</label>
                    <input type="number" id="courtCount" class="form-control"
                           value="2" min="1" max="20">
                  </div>
                  <div class="col-6 col-md-4">
                    <button type="button" class="btn btn-generate w-100" id="btnGenerateMatch">
                      <i class="fa-solid fa-wand-magic-sparkles me-1"></i>매칭 생성하기
                    </button>
                  </div>
                </div>
              </div>

              <%-- 매칭 결과 영역 --%>
              <div id="matchResultArea" style="display: none;">
                <hr class="my-4">
                <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
                  <h6 class="fw-bold mb-0">
                    <i class="fa-solid fa-trophy me-1 text-warning"></i>매칭 결과
                  </h6>
                  <div class="d-flex gap-2">
                    <button type="button" class="btn btn-sm btn-reshuffle" id="btnReshuffle">
                      <i class="fa-solid fa-shuffle me-1"></i>다시 매칭
                    </button>
                    <button type="button" class="btn btn-sm btn-save-match" id="btnSaveMatch">
                      <i class="fa-solid fa-floppy-disk me-1"></i>매칭 저장
                    </button>
                  </div>
                </div>

                <div id="matchResultList" class="row g-3"></div>

                <%-- 대기자 영역 --%>
                <div id="waitingArea" class="waiting-area mt-3" style="display: none;">
                  <h6 class="fw-bold mb-2">
                    <i class="fa-solid fa-hourglass-half me-1"></i>대기자
                  </h6>
                  <div id="waitingList" class="d-flex flex-wrap gap-2"></div>
                </div>
              </div>

            </div><%-- /#autoMatchSub --%>

            <%-- ───────── 수동 매칭 ───────── --%>
            <div class="tab-pane fade show active" id="manualMatchSub" role="tabpanel">

              <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
                <h6 class="fw-bold mb-0">
                  <i class="fa-solid fa-hand-pointer me-1 text-success"></i>수동 매칭
                </h6>
                <span class="text-muted small">
            대기 회원: <strong id="manualWaitingCount">0</strong>명
          </span>
              </div>

              <%-- 수동 매칭 옵션 박스 --%>
              <div class="match-option-box p-3 mb-4">
                <div class="row g-3 align-items-end">
                  <div class="col-12 col-md-5">
                    <label class="form-label">경기 방식 (코트 추가 시 적용)</label>
                    <select id="manualMatchType" class="form-select">
                      <option value="DOUBLES" selected>복식 (4인)</option>
                      <option value="SINGLES">단식 (2인)</option>
                    </select>
                  </div>
                  <div class="col-12 col-md-7">
                    <button type="button" class="btn btn-generate w-100" id="btnBuildManualCourts">
                      <i class="fa-solid fa-plus me-1"></i>코트 추가
                    </button>
                  </div>
                </div>
              </div>

              <%-- 수동 코트 카드 영역 --%>
              <div id="manualCourtArea" class="row g-3">
                <div class="col-12 text-center text-muted py-4">
                  참석 회원을 선택한 뒤 [코트 추가] 버튼을 눌러주세요.
                </div>
              </div>

              <%-- 대기 회원 영역 --%>
              <div class="waiting-area mt-4" id="manualWaitingArea">

                <%-- 대기 매칭: 다음에 비는 코트에 넣을 회원들을 4명 단위로 미리 선택해두는 곳 (여러 세트 동시 보관 가능) --%>
                <div class="pending-match-box mb-3" id="pendingMatchBox">
                  <div class="d-flex align-items-center justify-content-between mb-2">
                    <h6 class="fw-bold mb-0">
                      <i class="fa-solid fa-layer-group me-1 text-primary"></i>대기 매칭
                      <span class="text-muted small ms-1">(<span id="pendingMatchCount">0</span>명)</span>
                    </h6>
                    <button type="button" class="btn btn-sm btn-outline-secondary" id="btnClearPendingMatch" title="비우기">
                      <i class="fa-solid fa-rotate-left me-1"></i>비우기
                    </button>
                  </div>
                  <div id="pendingMatchDrop" class="pending-match-drop">
                    <span class="pending-match-placeholder">대기 회원을 여기로 드래그하세요 (4명씩 자동으로 한 매칭으로 묶여요)</span>
                  </div>
                  <p class="pending-match-hint mb-0" id="pendingMatchReadyHint" style="display:none;">
                    <i class="fa-solid fa-circle-check text-success me-1"></i>준비된 매칭이 있어요! 빈 코트로 드래그하면 한 번에 배정돼요.
                  </p>
                </div>

                <h6 class="fw-bold mb-2">
                  <i class="fa-solid fa-hourglass-half me-1"></i>대기 회원
                  (<span id="manualWaitingNum">0</span>명)
                </h6>
                <div id="manualWaitingList" class="d-flex flex-wrap gap-2">
                  <span class="text-muted small">참석 회원을 먼저 선택하세요.</span>
                </div>
              </div>

            </div><%-- /#manualMatchSub --%>

          </div><%-- /서브탭 .tab-content --%>

        </div>
      </div>

      <%-- ② 회원 관리 탭 --%>
      <div class="tab-pane fade" id="memberPanel" role="tabpanel">
        <div class="manage-card p-4">
          <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
            <h6 class="fw-bold mb-0">
              회원 목록 (<span id="memberCount">${regularMemberList.size()}</span>명)
            </h6>

            <!-- 회원명 검색으로 회원 찾기 -->
            <div class="input-group member-search-group member-search-group-narrow">
              <span class="input-group-text bg-white">
                <i class="fa-solid fa-magnifying-glass text-muted"></i>
              </span>
              <input type="text" id="memberSearch" class="form-control"
                     placeholder="이름으로 검색">
              <button class="btn btn-outline-secondary" type="button"
                      id="btnMemberSearchClear" title="검색어 지우기">
                <i class="fa-solid fa-xmark"></i>
              </button>
            </div>

            <div class="d-flex gap-2">
              <button type="button" class="btn btn-add-guest" onclick="openGuestAddModal()">
                <i class="fa-solid fa-user-plus me-1"></i>게스트 추가
              </button>
              <button class="btn btn-add-member" data-bs-toggle="modal" data-bs-target="#addMemberModal">
                <i class="fa-solid fa-plus me-1"></i>회원 등록
              </button>
            </div>
          </div>

          <%-- 오늘의 게스트 (정회원과 별도 - 그날 하루만 함께 운동하는 지인) --%>
          <c:if test="${not empty guestList}">
            <div class="guest-list-box mb-3">
              <div class="guest-list-title"><i class="fa-solid fa-user-group me-1"></i>오늘의 게스트</div>
              <div class="d-flex flex-wrap gap-2">
                <c:forEach items="${guestList}" var="g">
                  <span class="badge-guest">
                    ${g.userName}
                    <button type="button" class="btn-guest-remove"
                            onclick="kickMember(${g.memberSeq}, '${g.userName}')" title="게스트 제외">
                      <i class="fa-solid fa-xmark"></i>
                    </button>
                  </span>
                </c:forEach>
              </div>
            </div>
          </c:if>

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
                <c:when test="${empty regularMemberList}">
                  <tr>
                    <td colspan="5" class="text-center text-muted py-4">
                      등록된 회원이 없습니다.
                    </td>
                  </tr>
                </c:when>
                <c:otherwise>
                  <c:forEach items="${regularMemberList}" var="m">
                    <tr data-name="${m.userName}">
                      <td class="fw-semibold">${m.userName}</td>
                      <td>
                        <span class="badge-gender ${m.gender eq 'M' ? 'male' : 'female'}">
                            ${m.gender eq 'M' ? '남성' : '여성'}
                        </span>
                      </td>
                      <td>${m.birthYear}년</td>
                      <td>
                        <span class="badge-level ${empty m.addr1Level ? 'lv-none' : 'lv-'.concat(fn:toLowerCase(m.addr1Level))}">
                            ${empty m.addr1Level ? '-' : m.addr1Level}
                        </span>
                        <span class="badge-level ${empty m.addr2Level ? 'lv-none' : 'lv-'.concat(fn:toLowerCase(m.addr2Level))}">
                            ${empty m.addr2Level ? '-' : m.addr2Level}
                        </span>
                        <span class="badge-level ${empty m.addr3Level ? 'lv-none' : 'lv-'.concat(fn:toLowerCase(m.addr3Level))}">
                            ${empty m.addr3Level ? '-' : m.addr3Level}
                        </span>
                      </td>
                      <td>
                        <div class="d-flex gap-1 justify-content-start flex-wrap">
                          <button class="btn btn-edit-member"
                                  data-member-seq="${m.memberSeq}"
                                  data-user-name="${m.userName}"
                                  data-gender="${m.gender}"
                                  data-birth-year="${m.birthYear}"
                                  data-addr1="${m.addr1Level}"
                                  data-addr2="${m.addr2Level}"
                                  data-addr3="${m.addr3Level}"
                                  onclick="openEditMemberModal(this)">
                            수정
                          </button>
                          <button class="btn btn-kick"
                                  onclick="kickMember('${m.memberSeq}', '${m.userName}')">
                            삭제
                          </button>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
              </tbody>
            </table>
          </div>

          <%-- 회원 목록 페이지네이션 (검색 결과 기준, 클라이언트 사이드) --%>
          <div class="d-flex align-items-center justify-content-between mt-3" id="memberPaginationBar" style="display:none;">
            <button type="button" class="btn btn-sm btn-outline-secondary" id="btnMemberPrevPage">
              <i class="fa-solid fa-chevron-left me-1"></i>이전
            </button>
            <span class="text-muted small" id="memberPageIndicator">1 / 1페이지</span>
            <button type="button" class="btn btn-sm btn-outline-secondary" id="btnMemberNextPage">
              다음<i class="fa-solid fa-chevron-right ms-1"></i>
            </button>
          </div>
        </div>
      </div>

      <%-- ③ 모임 정보 수정 탭 --%>
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

          <hr class="my-4">

          <%-- 모임 삭제 (위험 구역) --%>
          <div class="d-grid">
            <button type="button" class="btn btn-danger py-3 fw-bold" id="btnDeleteClub">
              <i class="fa-solid fa-trash-can me-2"></i>모임 삭제
            </button>
          </div>
          <p class="text-muted small mt-2 mb-0">모임을 삭제하면 회원 정보와 매칭 기록이 모두 함께 삭제되며 복구할 수 없습니다.</p>
        </div>
      </div>

    </div><%-- /tab-content --%>
  </div>
</main>

<%-- ─────────────────────────────────────────
     회원 직접 추가 / 수정 공용 모달
     ───────────────────────────────────────── --%>
<div class="modal fade" id="addMemberModal" tabindex="-1" aria-labelledby="addMemberModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title fw-bold" id="addMemberModalLabel">
          <i class="fa-solid fa-user-plus me-2 text-success"></i>
          <span id="memberModalTitleText">회원 등록</span>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <form id="addMemberForm" novalidate>
        <input type="hidden" name="clubId" value="${club.clubId}">
        <%-- 수정 모드일 때 회원 식별용 hidden --%>
        <input type="hidden" name="memberSeq" id="editMemberSeq" value="">

        <div class="modal-body">
          <p class="text-muted small mb-3" id="memberModalDescription">
            <i class="fa-solid fa-circle-info me-1"></i>
            모임 내에서만 사용되는 회원 정보를 직접 입력합니다.
          </p>

          <%-- 이름 --%>
          <div class="mb-3">
            <label class="form-label">
              이름 <span class="text-danger">*</span>
            </label>
            <input type="text" name="userName" id="newMemberName"
                   class="form-control" placeholder="회원 이름을 입력하세요"
                   maxlength="20" required>
          </div>

          <%-- 성별 + 생년 --%>
          <div class="row g-3 mb-3">
            <div class="col-6">
              <label class="form-label">
                성별 <span class="text-danger">*</span>
              </label>
              <div class="btn-group w-100" role="group" aria-label="성별 선택">
                <input type="radio" class="btn-check" name="gender" id="newGenderM" value="M" required>
                <label class="btn btn-outline-primary" for="newGenderM">남성</label>
                <input type="radio" class="btn-check" name="gender" id="newGenderF" value="F">
                <label class="btn btn-outline-danger" for="newGenderF">여성</label>
              </div>
            </div>
            <div class="col-6">
              <label class="form-label">
                생년 <span class="text-danger">*</span>
              </label>
              <select name="birthYear" id="newBirthYear" class="form-select" required>
                <%-- JS에서 옵션 동적 생성 --%>
              </select>
            </div>
          </div>

          <%-- 급수 3종 --%>
          <div class="row g-3 mb-2">
            <div class="col-12">
              <label class="form-label fw-bold text-success">
                <i class="fa-solid fa-medal me-1"></i>급수 정보
              </label>
            </div>
            <div class="col-12 col-sm-4">
              <label class="form-label small text-muted">전국 급수</label>
              <select name="addr1Level" class="form-select border-success">
                <option value="">:: 선택 ::</option>
                <c:forEach items="${addr1Level}" var="addr1L">
                  <option value="${addr1L.addr1Level}">${addr1L.addr1Level}</option>
                </c:forEach>
              </select>
            </div>
            <div class="col-12 col-sm-4">
              <label class="form-label small text-muted">시 급수</label>
              <select name="addr2Level" class="form-select border-success">
                <option value="">:: 선택 ::</option>
                <c:forEach items="${addr2Level}" var="addr2L">
                  <option value="${addr2L.addr2Level}">${addr2L.addr2Level}</option>
                </c:forEach>
              </select>
            </div>
            <div class="col-12 col-sm-4">
              <label class="form-label small text-muted">구 급수</label>
              <select name="addr3Level" class="form-select border-success">
                <option value="">:: 선택 ::</option>
                <c:forEach items="${addr3Level}" var="addr3L">
                  <option value="${addr3L.addr3Level}">${addr3L.addr3Level}</option>
                </c:forEach>
              </select>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
            취소
          </button>
          <button type="submit" class="btn btn-add-confirm-main" id="memberModalSubmitBtn">
            <i class="fa-solid fa-plus me-1" id="memberModalSubmitIcon"></i>
            <span id="memberModalSubmitText">회원 추가</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<%-- 매칭 상세 보기 모달 --%>
<div class="modal fade" id="matchDetailModal" tabindex="-1" aria-labelledby="matchDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title fw-bold" id="matchDetailModalLabel">
          <i class="fa-solid fa-trophy me-2 text-warning"></i>매칭 상세 내역
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" id="matchDetailBody">
        <%-- JS에서 동적 렌더링 --%>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

<%-- 수동 매칭 JS가 사용할 회원 데이터 전역 변수 --%>
<script>
  window.clubMembers = [
    <c:forEach items="${memberList}" var="m" varStatus="st">
    {
      memberId: '${m.memberSeq}',
      name:     '${m.userName}',
      gender:   '${m.gender}',
      addr1:    '${m.addr1Level}',
      addr2:    '${m.addr2Level}',
      addr3:    '${m.addr3Level}'
    }<c:if test="${!st.last}">,</c:if>
    </c:forEach>
  ];
</script>

</body>
</html>
