<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 비밀번호 변경</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/find/find-account.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp"/>

<div class="container find-container">
    <div class="card find-card">
        <h4 class="find-title">비밀번호 재설정</h4>
        <p class="find-desc">새로운 비밀번호를 입력해주세요.</p>

        <form class="find-form">
            <input type="hidden" id="resetUserId" value="${userId}">

            <div class="mb-3">
                <label class="form-label">새 비밀번호</label>
                <input type="password" id="newPw" class="find-input" placeholder="새 비밀번호 입력">
            </div>

            <div class="mb-4">
                <label class="form-label">비밀번호 확인</label>
                <input type="password" id="newPwConfirm" class="find-input" placeholder="비밀번호 재입력">
            </div>

            <button type="button" id="btnReset" class="find-btn">비밀번호 변경하기</button>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script>
    // 비밀번호 변경
    $("#btnReset").on("click", async function() {
        const $newPw = $("#newPw");
        const $newPwConfirm = $("#newPwConfirm");
        const pw = $newPw.val().trim();
        const pwConfirm = $newPwConfirm.val().trim();
        const userId = $("#resetUserId").val();

        // 빈 값 체크
        if (!pw) {
            alert("새 비밀번호를 입력해주세요.");
            $newPw.focus();
            return;
        }

        if (!pwConfirm) {
            alert("비밀번호 확인란을 입력해주세요.");
            $newPwConfirm.focus();
            return;
        }

        // 정규식 유효성 검사 (영문, 숫자, 특수문자 조합 8~20자)
        const USER_PW_REGEX = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,20}$/;

        if (!USER_PW_REGEX.test(pw)) {
            alert("비밀번호는 영문, 숫자, 특수문자를 포함하여 8~20자로 설정해주세요.");
            $newPw.focus();
            return;
        }

        // 비밀번호 일치 여부 체크
        if (pw !== pwConfirm) {
            alert("비밀번호가 서로 일치하지 않습니다.");
            $newPwConfirm.focus();
            return;
        }

        // 서버 전송
        try {
            const response = await fetch("<c:url value='/change/pw/resetUpdate'/>", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    userId: userId,
                    userPw: pw
                })
            });

            const result = await response.json();

            if (result.success) {
                alert("비밀번호가 성공적으로 변경되었습니다. 다시 로그인해주세요.");
                location.href = "<c:url value='/login'/>";
            } else {
                alert(result.message || "비밀번호 변경에 실패했습니다.");
            }
        } catch (err) {
            console.error(err);
            alert("서버 통신 중 오류가 발생했습니다.");
        }
    });
</script>

</body>
</html>
