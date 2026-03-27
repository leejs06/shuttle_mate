<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 회원가입</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth/auth.css">
    <script src="${pageContext.request.contextPath}/js/auth/auth.js" defer></script>
</head>
<body>

<%-- 헤더 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<div class="auth-container">
    <div class="auth-box">
        <h2 class="title">회원가입</h2>
        <form id="signupForm" action="<c:url value="/join/add"/>" method="POST">
            <div class="input-group">
                <label for="regId">아이디</label>
                <input type="text" id="userId" name="userId" placeholder="6자 이상 입력" required>
            </div>
            <div class="input-group">
                <label for="regPw">비밀번호</label>
                <input type="password" id="userPw" name="userPw" placeholder="영문, 숫자 포함 8자 이상" required>
            </div>
            <div class="input-group">
                <label for="userName">이름</label>
                <input type="text" id="userName" name="userName" placeholder="이름을 입력하세요" required>
            </div>
            <div class="input-group">
                <label for="hp">휴대폰번호</label>
                <input type="text" id="userHp" name="userHp" placeholder="010-0000-0000" required>
            </div>
            <div class="input-row">
                <div class="input-group">
                    <label for="userGender">성별</label>
                    <select id="userGender" name="userGender">
                        <option value="">:: 선택하세요 ::</option>
                        <option value="M">남성</option>
                        <option value="F">여성</option>
                    </select>
                </div>
                <div class="input-group">
                    <label for="userAgeGroup">연령대</label>
                    <select id="userAgeGroup" name="userAgeGroup">
                        <option value="">:: 선택하세요 ::</option>
                        <c:if test="${not empty userAgeGroup}">
                            <c:forEach items="${userAgeGroup}" var="userAge">
                                <option value="<c:out value="${userAge.code}"/>"><c:out value="${userAge.value}"/></option>
                            </c:forEach>
                        </c:if>
                    </select>
                </div>
                <div class="input-group">
                    <label for="user1Level">전국 급수</label>
                    <select id="user1Level" name="user1Level">
                        <option value="">:: 선택하세요 ::</option>
                        <c:if test="${not empty addr1Level}">
                            <c:forEach items="${addr1Level}" var="addr1L">
                                <option value="<c:out value="${addr1L.code}"/>"><c:out value="${addr1L.value}"/></option>
                            </c:forEach>
                        </c:if>
                    </select>
                </div>
                <div class="input-group">
                    <label for="user2Level">시 급수</label>
                    <select id="user2Level" name="user2Level">
                        <option value="">:: 선택하세요 ::</option>
                        <c:if test="${not empty addr2Level}">
                            <c:forEach items="${addr2Level}" var="addr2L">
                                <option value="<c:out value="${addr2L.code}"/>"><c:out value="${addr2L.value}"/></option>
                            </c:forEach>
                        </c:if>
                    </select>
                </div>
                <div class="input-group">
                    <label for="user3Level">구 급수</label>
                    <select id="user3Level" name="user3Level">
                        <option value="">:: 선택하세요 ::</option>
                        <c:if test="${not empty addr3Level}">
                            <c:forEach items="${addr3Level}" var="addr3L">
                                <option value="<c:out value="${addr3L.code}"/>"><c:out value="${addr3L.value}"/></option>
                            </c:forEach>
                        </c:if>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn-primary">가입하기</button>
        </form>
        <div class="auth-footer">
            이미 회원이신가요? <a href="/login">로그인</a>
        </div>
    </div>
</div>

<%-- 푸터 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

</body>
</html>