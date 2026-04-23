<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 마이페이지</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<div class="auth-container"> <div class="mypage-box">
    <h2 class="mypage-title">마이페이지</h2>

    <section class="my-clubs">
        <div class="section-header">
            <h3>🏸 내가 만든 모임 관리</h3>
            <button class="btn-create" onclick="location.href='/club/create'">+ 새 모임 만들기</button>
        </div>

        <div class="club-grid">
            <c:forEach items="${myClubs}" var="club">
                <div class="club-card">
                    <div class="status-badge ${club.status}">${club.status == 'OPEN' ? '모집중' : '마감'}</div>
                    <h4>${club.clubName}</h4>
                    <div class="club-info">
                        <p><span>📍</span> ${club.location}</p>
                        <p><span>⏰</span> ${club.meetingTime}</p>
                    </div>
                    <div class="card-footer">
                        <button class="btn-secondary btn-small" onclick="location.href='/club/edit?id=${club.clubId}'">수정</button>
                        <button class="btn-primary btn-small" onclick="location.href='/club/manage?id=${club.clubId}'">매칭 관리</button>
                    </div>
                </div>
            </c:forEach>

            <c:if test="${empty myClubs}">
                <div class="empty-state">
                    <p>아직 생성한 모임이 없습니다.</p>
                    <p>첫 모임을 만들어 메이트를 찾아보세요! 셔틀콕!</p>
                </div>
            </c:if>
        </div>
    </section>
</div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script>
    $(function() {
        // 카드 호버 시 간단한 효과나 로그 출력 등 확장 가능
        $('.club-card').on('mouseenter', function() {
            // 추가적인 인터랙션이 필요할 경우 여기에 작성
        });
    });
</script>
</body>
</html>