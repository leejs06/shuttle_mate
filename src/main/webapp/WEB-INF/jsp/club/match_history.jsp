<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 매칭 내역</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
    <%-- 매칭 상세 카드(court-card 등) 스타일을 club_manage.css에서 그대로 재사용 --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/club/club_manage.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/club/match_history.css">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const contextPath = '${pageContext.request.contextPath}';
    </script>
    <script src="${pageContext.request.contextPath}/js/club/match_history.js" defer></script>
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main>
    <div class="container my-5">
        <h2 class="page-title mb-4">
            <i class="fa-solid fa-clock-rotate-left me-2"></i>매칭 내역
        </h2>

        <c:choose>
            <%-- 1) 모임이 없음 --%>
            <c:when test="${empty myClub}">
                <div class="empty-state bg-white rounded-4 shadow-sm border text-center">
                    <i class="fa-solid fa-clock-rotate-left fa-4x text-light mb-3"></i>
                    <p class="fw-bold text-secondary mb-1">아직 모임이 없어요</p>
                    <p class="text-muted small mb-3">모임을 만들고 매칭을 진행하면 여기서 매칭 내역을 확인할 수 있어요.</p>
                    <a href="<c:url value="/club/create"/>" class="btn btn-main rounded-pill px-4">모임 만들러 가기</a>
                </div>
            </c:when>

            <%-- 2) 모임은 있지만 매칭 기록이 없음 --%>
            <c:when test="${empty matchHistory}">
                <div class="empty-state bg-white rounded-4 shadow-sm border text-center">
                    <i class="fa-solid fa-clock-rotate-left fa-4x text-light mb-3"></i>
                    <p class="fw-bold text-secondary mb-1">아직 매칭 내역이 없어요</p>
                    <p class="text-muted small mb-3">"${myClub.clubTitle}"에서 첫 매칭을 진행하면 여기에 표시돼요.</p>
                    <a href="<c:url value="/club/manage?clubId=${myClub.clubId}"/>" class="btn btn-main rounded-pill px-4">매칭 진행하러 가기</a>
                </div>
            </c:when>

            <%-- 3) 매칭 내역 표시 (같은 날짜끼리 하루 단위로 묶어서 표시) --%>
            <c:otherwise>
                <div class="manage-card p-4">
                    <c:forEach items="${matchHistory}" var="dayGroup" varStatus="dayStatus">
                        <div class="match-day-group">
                            <div class="match-day-header" data-bs-toggle="collapse"
                                 data-bs-target="#dayCollapse${dayStatus.index}"
                                 role="button" aria-expanded="false" aria-controls="dayCollapse${dayStatus.index}">
                                <div>
                                    <i class="fa-solid fa-calendar-day me-2 text-success"></i>
                                    <span class="fw-bold">${dayGroup.matchDay}</span>
                                    <span class="text-muted small ms-2">경기 ${dayGroup.matchCount}건</span>
                                </div>
                                <i class="fa-solid fa-chevron-down match-day-caret"></i>
                            </div>
                            <div class="collapse" id="dayCollapse${dayStatus.index}">
                                <div class="table-responsive">
                                    <table class="table member-table align-middle mb-0">
                                        <thead>
                                        <tr>
                                            <th>시간</th>
                                            <th>경기 방식</th>
                                            <th>코트 수</th>
                                            <th>참여 인원</th>
                                            <th>관리</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach items="${dayGroup.matches}" var="h">
                                            <c:set var="typeLabel" value="${h.matchType eq 'SINGLES' ? '단식' : (h.matchType eq 'MIXED' ? '혼합 복식' : '복식')}"/>
                                            <tr>
                                                <td>${h.matchTime}</td>
                                                <td>${typeLabel}</td>
                                                <td>${h.courtCount}개</td>
                                                <td>${h.memberCount}명</td>
                                                <td>
                                                    <button class="btn btn-view-match" onclick="viewMatch('${h.matchId}')">
                                                        상세
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

                    <%-- 페이지네이션 (10일 기준) --%>
                    <c:if test="${totalPages > 1}">
                        <div class="d-flex align-items-center justify-content-between mt-3">
                            <a class="btn btn-sm btn-outline-secondary ${currentPage <= 1 ? 'disabled' : ''}"
                               href="<c:url value='/club/matchHistory'><c:param name='page' value='${currentPage - 1}'/></c:url>">
                                <i class="fa-solid fa-chevron-left me-1"></i>이전
                            </a>
                            <span class="text-muted small">${currentPage} / ${totalPages}페이지</span>
                            <a class="btn btn-sm btn-outline-secondary ${currentPage >= totalPages ? 'disabled' : ''}"
                               href="<c:url value='/club/matchHistory'><c:param name='page' value='${currentPage + 1}'/></c:url>">
                                다음<i class="fa-solid fa-chevron-right ms-1"></i>
                            </a>
                        </div>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

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

</body>
</html>
