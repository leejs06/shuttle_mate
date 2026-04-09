<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 비밀번호 찾기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/find/find-account.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp"/>

<div class="container find-container">
    <div class="card find-card">
        <h4 class="find-title">비밀번호 찾기</h4>
        <p class="find-desc">본인 인증 후 비밀번호를<br> 재설정하실 수 있습니다.</p>

        <form action="<c:url value='/find/pw'/>" method="post" class="find-form">
            <div class="mb-3">
                <label class="form-label">아이디</label>
                <input type="text" id="userId" name="userId" class="form-control find-input" placeholder="아이디를 입력하세요">
            </div>

            <div class="mb-3">
                <label class="form-label">이름</label>
                <input type="text" id="userName" name="userName" class="form-control find-input" placeholder="이름을 입력하세요">
            </div>

            <div class="mb-4">
                <label class="form-label">이메일</label>
                <input type="email" id="userEmail" name="userEmail" class="form-control find-input"
                       placeholder="이메일을 입력하세요"/>
            </div>

            <div id="authSection" style="display: none; margin-top: 1.5rem;">
                <div class="mb-3">
                    <label class="form-label">인증번호</label>
                    <input type="text" id="authCode" class="form-control find-input"
                           placeholder="메일로 발송된 6자리 입력" maxlength="6">
                </div>
                <button type="button" id="btnCheckAuth" class="btn w-100 find-btn"
                        style="background-color: #00d1b2 !important;">인증 완료</button>
            </div>

            <button type="button" id="findPw" class="btn w-100 find-btn">비밀번호 확인</button>
        </form>

        <div class="find-footer">
            <a href="<c:url value='/login'/>" class="find-link">로그인으로 돌아가기</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp"/>

<script type="text/javascript">
    $(function() {
        const $UserId = $("#userId");
        const $UserName = $("#userName");
        const $UserEmail = $("#userEmail");
        const $AuthSection = $("#authSection"); // 인증 세션 추가
        const $AuthCode = $("#authCode");       // 인증번호 입력창 추가
        const $FindPwBtn = $("#findPw");        // 메인 버튼

        // 비밀번호 찾기 (인증번호 발송 단계)
        $FindPwBtn.on("click", async function() {
            const idVal = $UserId.val().trim();
            const nameVal = $UserName.val().trim();
            const emailVal = $UserEmail.val().trim();

            // 아이디 항목 체크
            if (!idVal) {
                alert("아이디를 입력해주세요.");
                $UserId.focus();
                return;
            }
            if (idVal.length < 6 || idVal.length > 20) {
                alert("아이디는 6~20자 입니다.");
                $UserId.focus();
                return;
            }

            // 이름 항목 체크
            if (!nameVal) {
                alert("이름을 입력해주세요.");
                $UserName.focus();
                return;
            }
            if (nameVal.length < 2 || nameVal.length > 20) {
                alert("이름은 2~20자 입니다.");
                $UserName.focus();
                return;
            }

            // 이메일 항목 체크
            if (!emailVal) {
                alert("이메일을 입력해주세요.");
                $UserEmail.focus();
                return;
            }
            const USER_EMAIL_REGEX = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
            if (!USER_EMAIL_REGEX.test(emailVal)) {
                alert("이메일 형식이 올바르지 않습니다.");
                $UserEmail.focus();
                return;
            }

            try {
                // 기존 /find/pw/result 대신 실제 메일 발송 엔드포인트(/find/pw/sendEmail) 사용 권장
                // 여기서는 요청하신 대로 구조를 유지하며 result 처리를 진행합니다.
                const response = await fetch("<c:url value='/find/pw/sendEmail'/>", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        userId: idVal,
                        userName: nameVal,
                        userEmail: emailVal
                    })
                });

                const result = await response.json();

                // 서버 응답 처리 추가
                if (result.success) {
                    alert("인증번호가 메일로 발송되었습니다.");

                    // 정보 수정 방지
                    $UserId.attr("readonly", true);
                    $UserName.attr("readonly", true);
                    $UserEmail.attr("readonly", true);

                    // UI 전환
                    $AuthSection.fadeIn(); // 인증번호 입력창 노출
                    $FindPwBtn.hide();     // 기존 버튼 숨김
                    $AuthCode.focus();
                } else {
                    alert(result.message || "정보가 일치하지 않습니다.");
                }

            } catch (err) {
                console.error(err);
                alert("서버 통신 중 오류가 발생했습니다.");
            }
        });

        // 인증번호 검증 버튼 클릭 이벤트 (새로 추가됨)
        $("#btnCheckAuth").on("click", async function() {
            const authCodeVal = $AuthCode.val().trim();

            if (!authCodeVal || authCodeVal.length !== 6) {
                alert("인증번호 6자리를 정확히 입력해주세요.");
                $AuthCode.focus();
                return;
            }

            try {
                const response = await fetch("<c:url value='/find/pw/verify'/>", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        userId: $UserId.val().trim(),
                        authCode: authCodeVal
                    })
                });

                const result = await response.json();

                if (result.success) {
                    alert("인증에 성공했습니다. 비밀번호 재설정 페이지로 이동합니다.");
                    // 비밀번호 재설정 페이지로 이동 (userId 파라미터 포함)
                    location.href = "<c:url value='/find/pw/reset'/>?userId=" + encodeURIComponent($UserId.val().trim());
                } else {
                    alert(result.message || "인증번호가 틀렸거나 만료되었습니다.");
                }
            } catch (err) {
                console.error(err);
                alert("인증 확인 중 오류가 발생했습니다.");
            }
        });
    });
</script>

</body>
</html>