<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 로그인 페이지</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth/auth.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/auth/auth.js"></script>
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<div class="auth-container">
    <div class="auth-box">
        <h1 class="logo">셔틀<span>메이트</span></h1>
        <p class="subtitle">오늘의 콕, 함께 경기할 메이트를 찾아보세요!</p>

        <form id="loginForm" action="<c:url value="/login/success"/>" method="POST">
            <div class="input-group">
                <input type="text" id="userId" name="userId" placeholder="아이디" required>
            </div>
            <div class="input-group">
                <input type="password" id="userPw" name="userPw" placeholder="비밀번호" required>
            </div>
            <button type="button" id="loginBtn" class="btn-primary">로그인</button>
        </form>

        <div class="auth-footer">
            <a href="<c:url value="/find/id"/>">아이디 찾기</a>
            <span class="divider">|</span>
            <a href="<c:url value="/find/pw"/>">비밀번호 찾기</a>
            <span class="divider">|</span>
            <a href="<c:url value="/join"/>">회원가입</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script type="text/javascript">
    $(function() {
        const $userIdField = $('#userId');
        const $userPwField = $('#userPw');

        // 입력 유효성 검사
        function categoryCheck() {
            const userId = $userIdField.val().trim();
            const userPw = $userPwField.val().trim();

            if (!userId) {
                alert("아이디를 입력하세요.");
                $userIdField.focus();
                return null;
            }

            if (!userPw) {
                alert("비밀번호를 입력하세요.");
                $userPwField.focus();
                return null;
            }

            return {
                userId: userId,
                userPw: userPw
            };
        }

        // 로그인 API 호출
        async function loginUser(param) {
            try {
                const res = await fetch("/login/success", { // URL을 좀 더 직관적으로 변경
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(param)
                });

                if (!res.ok) throw new Error("네트워크 응답 오류");
                return await res.json();
            } catch (err) {
                console.error("로그인 에러:", err);
                return { success: false, message: "서버 통신에 실패했습니다." };
            }
        }

        // 로그인 버튼 클릭
        $("#loginBtn").on("click", async function() {
            const data = categoryCheck();
            if (!data) return;

            const result = await loginUser(data);

            if (result.success) {
                alert("로그인 성공\n셔틀메이트에 오신 것을 환영합니다! 🏸");
                location.href = "/index"; // 메인 페이지 이동
            } else {
                alert(result.message || "아이디 또는 비밀번호가 일치하지 않습니다.");
            }
        });
    });
</script>

</body>
</html>
