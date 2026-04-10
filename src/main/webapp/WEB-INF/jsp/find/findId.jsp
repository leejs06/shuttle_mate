<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial=scale=1.0">
    <title>ShuttleMate - 아이디 찾기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/find/find-account.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<div class="container find-container">
    <div class="card find-card">
        <h4 class="find-title">아이디 찾기</h4>
        <p class="find-desc">이름과 휴대폰 번호를 입력해주세요.</p>

        <form  method="post" class="find-form">
            <div class="mb-3">
                <label class="form-label">이름</label>
                <input type="text" id="userName" name="userName" class="find-input" placeholder="이름을 입력하세요" maxlength="20">
            </div>

            <div class="mb-3">
                <label class="form-label">휴대폰 번호</label>
                <input type="tel" id="userHp" name="userPhone" class="find-input" placeholder="'-' 없이 숫자만 입력" maxlength="11">
            </div>

            <div class="mb-3">
                <label class="form-label">이메일</label>
                <input type="email" id="userEmail" name="userEmail" class="find-input" placeholder="이메일을 입력하세요">
            </div>

            <button type="button" id="findId" class="find-btn">아이디 찾기</button>
        </form>

        <div class="find-footer">
            <a href="<c:url value='/login'/>" class="find-link">로그인으로 돌아가기</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script type="text/javascript">
    $(function() {
        const $UserName = $("#userName");
        const $UserHp = $("#userHp");
        const $UserEmail = $("#userEmail");

        // 아이디 찾기
        $("#findId").on("click", async function() {
            const USER_EMAIL_REGEX = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

            const nameVal = $UserName.val().trim();
            const hpVal = $UserHp.val().trim();
            const emailVal = $UserEmail.val().trim();

            // 이름 항목 체크
            if (!nameVal) {
                alert("이름을 입력해주세요.");
                $UserName.focus();
                return;
            }

            // 휴대폰 번호 항목 체크
            if (!hpVal) {
                alert("휴대폰 번호를 입력해주세요.");
                $UserHp.focus();
                return;
            }

            if (!emailVal) {
                alert("이메일을 입력하세요.");
                $UserEmail.focus();
                return;
            }

            if (nameVal.length < 2 || nameVal.length > 20) {
                alert("이름은 2~20자 입니다.");
                $UserName.focus();
                return;
            }

            if (hpVal.length !== 11) {
                alert("휴대폰 번호 형식이 올바르지 않습니다.");
                $UserHp.focus();
                return;
            }

            // 이메일 유효성 검사
            if (!USER_EMAIL_REGEX.test(emailVal)) {
                alert("이메일 형식이 올바르지 않습니다.");
                $UserEmail.focus();
                return null;
            }

            try {
                const response = await fetch("<c:url value='/find/id/result'/>", {
                    method: "POST",
                    headers: {"Content-Type": "application/json"},
                    body: JSON.stringify({
                        userName: nameVal,
                        userHp: hpVal,
                        userEmail: emailVal
                    })
                });

                // json으로
                const result = await response.json();

                if (result && result.success) {
                    alert("회원님의 아이디는 [ " + result.userId + " ] 입니다.");
                } else {
                    alert(result.message || "일치하는 회원 정보가 없습니다.");
                }

            } catch (err) {
                console.error("에러 밟생", err);
                alert("서버 통신 중 오류가 발생했습니다.");
            }
        });

    });
</script>

</body>
</html>