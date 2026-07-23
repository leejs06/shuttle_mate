<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> <%-- JSTL 추가 --%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>shuttleMate - 메인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main/main.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" defer></script>

    <style>
        /* 블러 처리를 위한 추가 CSS */
        .matching-container { position: relative; }

        .not-logged-in .match-list-blur {
            filter: blur(8px);
            pointer-events: none;
            user-select: none;
        }

        .login-overlay {
            position: absolute;
            top: 55%; left: 50%;
            transform: translate(-50%, -50%);
            z-index: 10;
            text-align: center;
            width: 100%;
        }

        .btn-main { background-color: #0391ff; color: white; border: none; }
        .btn-main:hover { background-color: #0752be; color: white; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main>
<div class="container mt-4">
    <div class="row g-2 mb-4">
        <div class="col-6">
            <a href="javascript:void(0);" onclick="checkLoginAndGo('${pageContext.request.contextPath}/club/create')" class="p-3 bg-white border rounded-4 text-center d-block text-decoration-none" style="cursor:pointer;">
                <i class="fa-solid fa-circle-plus text-warning mb-2" style="font-size: 1.5rem;"></i>
                <div class="fw-bold text-dark">모임 생성</div>
                <small class="text-muted">새로운 모임 만들기</small>
            </a>
        </div>
        <div class="col-6">
            <%-- 로그인 체크 함수 연결 --%>
            <div class="p-3 bg-white border rounded-4 text-center" onclick="checkLoginForClub()" style="cursor:pointer;">
                <i class="fa-solid fa-users text-primary mb-2" style="font-size: 1.5rem;"></i>
                <div class="fw-bold">모임 관리</div>
                <small class="text-muted">자동 매칭/수동 매칭</small>
            </div>
        </div>
    </div>

    <%-- 모임 현황 통계 섹션: 로그인/모임보유/매칭기록 여부에 따라 단계별로 다르게 노출 --%>
    <div class="stats-section mb-4">
        <h5 class="fw-bold mb-3">모임 현황</h5>

        <c:choose>
            <%-- 1) 로그인 + 모임 보유: 신규 회원 / 최근 경기 내역 / 이번 달 순위표 --%>
            <c:when test="${not empty myClub}">
                <div class="row g-3 stats-grid">
                    <%-- 최근 가입 회원 --%>
                    <div class="col-12 col-md-4">
                        <div class="stat-panel bg-white border rounded-4 p-3 h-100">
                            <div class="stat-panel-title"><i class="fa-solid fa-user-plus me-1"></i>최근 가입 회원</div>
                            <c:choose>
                                <c:when test="${not empty recentMembers}">
                                    <ul class="stat-list">
                                        <c:forEach items="${recentMembers}" var="mem">
                                            <li>
                                                <a href="javascript:void(0);" class="stat-list-name stat-list-name-link"
                                                   onclick="viewMemberDetail(${mem.memberSeq})">${mem.userName}</a>
                                                <span class="stat-list-sub">
                                                    <c:choose>
                                                        <c:when test="${mem.daysSinceJoin == 0}">오늘 가입</c:when>
                                                        <c:otherwise>${mem.daysSinceJoin}일 전 가입</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <p class="stat-empty-text">아직 회원이 없어요.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- 최근 경기 내역 (수동 매칭 결과만) --%>
                    <div class="col-12 col-md-4">
                        <div class="stat-panel bg-white border rounded-4 p-3 h-100">
                            <div class="stat-panel-title"><i class="fa-solid fa-list-check me-1"></i>최근 경기 내역</div>
                            <c:choose>
                                <c:when test="${not empty recentMatches}">
                                    <ul class="stat-list">
                                        <c:forEach items="${recentMatches}" var="mr">
                                            <li>
                                                <span class="stat-list-name">
                                                    <c:if test="${mr.winnerSide == 'A'}">${mr.teamAName} 승</c:if>
                                                    <c:if test="${mr.winnerSide == 'B'}">${mr.teamBName} 승</c:if>
                                                </span>
                                                <span class="stat-list-sub">${mr.matchDate}</span>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <p class="stat-empty-text">아직 기록된 경기가 없어요.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- 이번 달 순위표 --%>
                    <div class="col-12 col-md-4">
                        <div class="stat-panel bg-white border rounded-4 p-3 h-100">
                            <div class="stat-panel-title"><i class="fa-solid fa-trophy me-1"></i>이번 달 순위표</div>
                            <c:choose>
                                <c:when test="${not empty monthlyRanking}">
                                    <div class="table-responsive">
                                        <table class="table stat-rank-table mb-0">
                                            <thead>
                                            <tr>
                                                <th>순위</th>
                                                <th>이름</th>
                                                <th>출석</th>
                                                <th>경기</th>
                                                <th>승</th>
                                                <th>점수</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach items="${monthlyRanking}" var="rk" varStatus="loop">
                                                <tr class="${loop.index == 0 ? 'rank-first' : ''}">
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${loop.index == 0}"><i class="fa-solid fa-trophy text-warning"></i></c:when>
                                                            <c:otherwise>${loop.index + 1}</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>${rk.userName}</td>
                                                    <td>${rk.attendDays}일</td>
                                                    <td>${rk.gameCount}</td>
                                                    <td>${rk.winCount}</td>
                                                    <td class="fw-bold">${rk.totalScore}</td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="stat-empty-text">이번 달 기록이 없어요.<br>수동 매칭으로 경기를 진행해보세요.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <c:if test="${empty monthlyRanking}">
                    <div class="text-center mt-3">
                        <a href="<c:url value="/club/manage?clubId=${myClub.clubId}"/>" class="btn btn-main rounded-pill px-4">수동 매칭 진행하러 가기</a>
                    </div>
                </c:if>
            </c:when>

            <%-- 2) 로그인 O + 모임 없음 --%>
            <c:when test="${not empty sessionScope.loginUser}">
                <div class="empty-state bg-white rounded-4 shadow-sm border text-center">
                    <i class="fa-solid fa-chart-simple fa-4x text-light mb-3"></i>
                    <p class="fw-bold text-secondary mb-1">아직 모임이 없어요</p>
                    <p class="text-muted small mb-3">모임을 만들고 매칭을 진행하면 여기에 통계가 표시돼요.</p>
                    <a href="<c:url value="/club/create"/>" class="btn btn-main rounded-pill px-4">모임 만들러 가기</a>
                </div>
            </c:when>

            <%-- 3) 비로그인 --%>
            <c:otherwise>
                <div class="empty-state bg-white rounded-4 shadow-sm border text-center">
                    <i class="fa-solid fa-chart-simple fa-4x text-light mb-3"></i>
                    <p class="fw-bold text-secondary mb-1">로그인하고 내 모임 통계를 확인해보세요</p>
                    <p class="text-muted small mb-3">모임 생성, 매칭 참여 기록을 한눈에 볼 수 있어요.</p>
                    <a href="<c:url value="/login"/>" class="btn btn-main rounded-pill px-4">로그인 하러가기</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <h5 class="fw-bold mb-3" style="display: none">내 주변 매칭 공고</h5>

    <%-- 매칭 공고 컨테이너 시작 --%>
    <div class="matching-container ${empty sessionScope.loginUser ? 'not-logged-in' : ''}" style="display: none">

        <c:if test="${empty sessionScope.loginUser}">
            <div class="login-overlay">
                <p class="fw-bold shadow-sm p-2 bg-white d-inline-block rounded">매칭 공고 기능은 로그인 후 이용 가능합니다.</p><br>
                <a href="<c:url value="/login"/>" class="btn btn-main mt-2">로그인 하러가기</a>
            </div>
        </c:if>

        <div class="match-list-blur">
            <%-- 기존 카드 리스트들 --%>
            <div class="card match-card p-3 mb-2">
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

            <div class="card match-card p-3 mb-2">
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

            <div class="card match-card p-3 mb-2">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="badge-level">전국 A조 이상</span>
                    <span class="text-muted small"><i class="fa-solid fa-location-dot"></i> 인천광역시 연수구</span>
                </div>
                <h6 class="fw-bold mb-1">대학공원 배드민턴장 남복/혼복/여복 모집합니다!</h6>
                <div class="text-muted small mb-3">오후 22:00 ~ 01:00 | 7/30명 모집</div>
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
        </div>
    </div>
</div>
</main>

<%-- 회원 상세 정보 팝업 (읽기 전용 - 수정 불가) --%>
<div class="modal fade" id="memberDetailModal" tabindex="-1" aria-labelledby="memberDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="memberDetailModalLabel">
                    <i class="fa-solid fa-id-card me-2"></i>회원 정보
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="memberDetailBody">
                <%-- JS에서 동적 렌더링 --%>
            </div>
        </div>
    </div>
</div>

<script>
    function checkLoginForClub() {
        // JSP 세션 체크
        const isLoggedIn = ${not empty sessionScope.loginUser ? 'true' : 'false'};
        if (!isLoggedIn) {
            alert("세션이 만료되었거나 로그인이 필요합니다.\n로그인 페이지로 이동합니다.");
            location.href = "${pageContext.request.contextPath}/login";
        } else {
            <c:choose>
                <c:when test="${not empty myClub}">
            location.href = "${pageContext.request.contextPath}/club/manage?clubId=${myClub.clubId}";
                </c:when>
                <c:otherwise>
            location.href = "${pageContext.request.contextPath}/club/create";
                </c:otherwise>
            </c:choose>
        }
    }

    /* 최근 가입 회원 이름 클릭 → 읽기 전용 상세 정보 팝업 (수정 기능 없음) */
    function viewMemberDetail(memberSeq) {
        fetch("${pageContext.request.contextPath}/club/memberDetail?memberSeq=" + memberSeq)
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (data.result !== "success") {
                    alert(data.message || "회원 정보를 불러오지 못했습니다.");
                    return;
                }
                renderMemberDetail(data.member);
                new bootstrap.Modal(document.getElementById("memberDetailModal")).show();
            })
            .catch(function () {
                alert("서버 통신 중 오류가 발생했습니다.");
            });
    }

    function renderMemberDetail(m) {
        const genderText = m.gender === "M" ? "남성" : "여성";
        const rows = [
            ["이름", escapeHtml(m.userName)],
            ["성별", genderText],
            ["출생연도", (m.birthYear ? m.birthYear + "년" : "-")],
            ["전국 급수", m.addr1Level || "-"],
            ["시 급수", m.addr2Level || "-"],
            ["구 급수", m.addr3Level || "-"],
            ["가입일", m.createDate || "-"]
        ];

        let html = "";
        rows.forEach(function (row) {
            html += '<div class="member-detail-row">' +
                '<span class="member-detail-label">' + row[0] + '</span>' +
                '<span class="member-detail-value">' + row[1] + '</span>' +
                '</div>';
        });
        document.getElementById("memberDetailBody").innerHTML = html;
    }

    function escapeHtml(str) {
        if (str === null || str === undefined) return "";
        return String(str)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
</script>

<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />
<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

</body>
</html>