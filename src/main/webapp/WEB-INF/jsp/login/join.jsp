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

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">

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
            <div class="input-group">
                <label for="birth">생년월일</label>
                <input type="text" id="userBirth" name="userBirth" placeholder="YYYY-MM-DD" readonly />
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
                    <label for="addr1Level">전국 급수</label>
                    <select id="addr1Level" name="addr1Level">
                        <option value="">:: 선택하세요 ::</option>
                        <c:if test="${not empty addr1Level}">
                            <c:forEach items="${addr1Level}" var="addr1L">
                                <option value="<c:out value="${addr1L.value}"/>"><c:out value="${addr1L.value}"/></option>
                            </c:forEach>
                        </c:if>
                    </select>
                </div>
                <div class="input-group">
                    <label for="addr2Level">시 급수</label>
                    <select id="addr2Level" name="addr2Level">
                        <option value="">:: 선택하세요 ::</option>
                        <c:if test="${not empty addr2Level}">
                            <c:forEach items="${addr2Level}" var="addr2L">
                                <option value="<c:out value="${addr2L.value}"/>"><c:out value="${addr2L.value}"/></option>
                            </c:forEach>
                        </c:if>
                    </select>
                </div>
                <div class="input-group">
                    <label for="addr3Level">구 급수</label>
                    <select id="addr3Level" name="addr3Level">
                        <option value="">:: 선택하세요 ::</option>
                        <c:if test="${not empty addr3Level}">
                            <c:forEach items="${addr3Level}" var="addr3L">
                                <option value="<c:out value="${addr3L.value}"/>"><c:out value="${addr3L.value}"/></option>
                            </c:forEach>
                        </c:if>
                    </select>
                </div>
            </div>
            <button type="button" id="joinBtn" class="btn-primary" onclick="validateForm()">가입하기</button>
        </form>
        <div class="auth-footer">
            이미 회원이신가요? <a href="/login">로그인</a>
        </div>
    </div>
</div>

<%-- 푸터 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script type="text/javascript">


    // 각 항목 유효성 검사 진행
    function validateForm() {

        const USER_ID_REGEX = /^[a-z0-9]{6,20}$/;
        const USER_PW_REGEX = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,20}$/;
        const USER_NAME_REGEX = /^[a-zA-Z가-힣]+$/;

        // 사용자 아이디
        var $UserId = $("#userId").val().trim();

        // 항목의 값이 없을 때
        if (!$UserId) {
            alert("아이디를 입력해주세요.");
            $UserId.focus();
            return;
        }

        // 6~20자 영문 소문자, 숫자 외의 다른 값이 들어왔을 때
        if ($UserId && !USER_ID_REGEX.test($UserId)) {
            alert("아이디는 6~20자의 영문 소문자와 숫자만 가능합니다.");
            $UserId.focus();
            return;
        }

        // 사용자 비밀번호
        var $UserPw = $("#userPw").val().trim();

        // 항목의 값이 없을 때
        if (!$UserPw) {
            alert("비밀번호를 입력해주세요.");
            $UserPw.focus();
            return;
        }

        if ($UserPw && !USER_PW_REGEX.test($UserPw)) {
            alert("비밀번호는 8~20자의 영문, 소문자, 특수문자 보함이여야 됩니다.");
            $UserPw.focus();
            return;
        }

        // 사용자 이름
        var $UserName = $("#userName").val().trim();

        if (!$UserName) {
            alert("사용자명을 입력해주세요.");
            $UserName.focus();
            return;
        }

        if ($UserName && !USER_NAME_REGEX.test($UserName)) {
            alert("사용자명은 한글과 영어만 입력 가능합니다.");
            $UserName.focus();
            return;
        }

        // 사용자 휴대폰번호
        var $UserHp = $("#userHp").val().trim();

        const cleanedPhone = $UserHp.replace(/[^0-9]/g, "");

        const USER_HP_REGEX = /^01[0-9]{8,9}$/;

        if (!$UserHp) {
            alert("사용자 휴대폰번호를 입력해주세요.");
            return;
        }

        if ($UserHp && !USER_HP_REGEX.test(cleanedPhone)) {
            alert("올바른 휴대폰번호를 입력해주세요.");
            return;
        }

        // 사용자 생년월일
        const $UserBirth = $("#userBirth").val().trim();

        if (!$UserBirth) {
            alert("생년월일을 입력해주세요.");
            $UserBirth.focus();
            return;
        }

        // 사용자 성별
        var $UserGender = $("#userGender option:selected").val().trim();

        if (!$UserGender) {
            alert("성별을 선택해주세요.");
            $UserGender.focus();
            return;
        }

        // 사용자 전국 급수
        var $Addr1Level = $("#addr1Level option:selected").val().trim();

        if (!$Addr1Level) {
            alert("전국 급수를 선택해주세요.");
            $Addr1Level.focus();
            return;
        }

        // 사용자 시 급수
        var $Addr2Level = $("#addr2Level option:selected").val().trim();

        if (!$Addr2Level) {
            alert("시 급수를 선택해주세요.");
            $Addr2Level.focus();
            return;
        }

        // 사용자 구 급수
        var $Addr3Level = $("#addr3Level option:selected").val().trim();

        if (!$Addr3Level) {
            alert("구 급수를 선택해주세요.");
            $Addr3Level.focus();
            return;
        }

        return {
            userId: $UserId,
            userPw: $UserPw,
            userName: $UserName,
            userHp: cleanedPhone,
            userBirth: $UserBirth,
            userGender: $UserGender,
            addr1Level: $Addr1Level,
            addr2Level: $Addr2Level,
            addr3Level: $Addr3Level
        }

    }

    // url: "join/add" 에서 회원가입 처리
    async function joinUser(param) {
        try {
            const res = await fetch("join/add", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(param)
            });

            if (!res.ok) throw new Error("API 실패");

            return await res.json();
        } catch (err) {
            console.error(err);
        }
    }

    // 회원가입 처리 > 로그인 페이지 이동
    $("#joinBtn").on("click", async function () {
        const data = validateForm();
        if (!data) return;

        const result = await joinUser(data);
        console.log(result);

        if (result.success) {
            alert("회원가입 완료");
            location.href = "/login";
        }
    })
</script>

<script type="text/javascript">
    $(document).ready(function () {

        $.datepicker.setDefaults({
            dateFormat: 'yy-mm-dd',
            changeYear: true,
            changeMonth: true,
            showMonthAfterYear: true,
            yearSuffix: '년'
        });

        $("#userBirth").datepicker({
            yearRange: "1900:" + new Date().getFullYear(),
            maxDate: 0  // 미래 날짜 선택 방지
        });

    });
</script>

</body>
</html>