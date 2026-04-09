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
                <label>아이디</label>
                <div class="id-check-row"><input type="text" id="userId" name="userId" placeholder="6자 이상 입력">
                    <button type="button" id="btnIdCheck" class="btn-secondary">중복확인</button>
                </div>
                <span id="idCheckMsg"></span>
            </div>
            <div class="input-group">
                <label for="regPw">비밀번호</label>
                <input type="password" id="userPw" name="userPw" placeholder="영문, 숫자, 특수문자 포함 8자 이상" required>
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
                <label for="email">이메일 (인증용)</label>
                <input type="email" id="userEmail" name="userEmail" placeholder="ex): test0001@gmail.com" required>
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
            <button type="button" id="joinBtn" class="btn-primary">가입하기</button>
        </form>
        <div class="auth-footer">
            이미 회원이신가요? <a href="<c:url value="/login"/>">로그인</a>
        </div>
    </div>
</div>

<%-- 푸터 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script type="text/javascript">
    $(function() {
        // 1. 전역 상태 및 DOM 캐싱 (성능 최적화)
        let isIdChecked = false;

        const $userIdField = $("#userId");
        const $idCheckMsg = $("#idCheckMsg");
        const $userPwField = $("#userPw");
        const $userNameField = $("#userName");
        const $userHpField = $("#userHp");
        const $userEmailField = $("#userEmail");
        const $userBirthField = $("#userBirth");
        const $userGenderField = $("#userGender");
        const $addr1LevelField = $("#addr1Level");
        const $addr2LevelField = $("#addr2Level");
        const $addr3LevelField = $("#addr3Level");

        // 2. 아이디 입력 감시 (수정 시 중복체크 무효화)
        $userIdField.on("input", function () {
            isIdChecked = false;
            $idCheckMsg.stop(true, true).fadeOut(200);
            $(this).removeClass("is-valid is-invalid");
        });

        // 3. 아이디 중복 체크 로직
        $("#btnIdCheck").on("click", async function () {
            const userIdVal = $userIdField.val().trim();

            if (userIdVal === "" || userIdVal.length < 6) {
                alert("아이디를 6자 이상 입력해주세요.");
                $userIdField.focus();
                return;
            }

            try {
                const isDuplicate = await $.ajax({
                    url: "join/idCheck",
                    type: "POST",
                    data: { userId: userIdVal },
                    dataType: "json"
                });

                $idCheckMsg.stop(true, true).show();

                if (isDuplicate) {
                    $idCheckMsg.text("이미 사용중인 아이디거나\n형식에 맞지 않는 아이디입니다.").css("color", "#e74c3c");
                    $userIdField.addClass("is-invalid").removeClass("is-valid");
                    isIdChecked = false;
                } else {
                    $idCheckMsg.text("사용 가능한 아이디입니다.").css("color", "#2ecc71");
                    $userIdField.removeClass("is-invalid").addClass("is-valid");
                    isIdChecked = true;
                }

                // 3초 뒤 메시지 자동 사라짐
                setTimeout(() => $idCheckMsg.fadeOut(500), 3000);

            } catch (error) {
                console.error("중복체크 중 에러 발생", error);
                alert("서버 통신 실패");
            }
        });

        // 4. 유효성 검사 함수
        function validateForm() {
            // 정규식 정의
            const USER_ID_REGEX = /^[a-z0-9]{6,20}$/;
            const USER_PW_REGEX = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,20}$/;
            const USER_NAME_REGEX = /^[a-zA-Z가-힣]+$/;
            const USER_HP_REGEX = /^01[0-9]{8,9}$/;
            const USER_EMAIL_REGEX = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

            // 값 가져오기
            const userId = $userIdField.val().trim();
            const userPw = $userPwField.val().trim();
            const userName = $userNameField.val().trim();
            const userHp = $userHpField.val().trim();
            const cleanedPhone = userHp.replace(/[^0-9]/g, "");
            const userEmail = $userEmailField.val().trim();
            const userBirth = $userBirthField.val().trim();
            const userGender = $userGenderField.val();
            const addr1Level = $addr1LevelField.val();
            const addr2Level = $addr2LevelField.val();
            const addr3Level = $addr3LevelField.val();

            // [핵심] 중복체크 여부 검사
            if (!isIdChecked) {
                alert("아이디 중복 확인을 먼저 진행해주세요.");
                $userIdField.focus();
                return null;
            }

            // 아이디 형식 검사
            if (!USER_ID_REGEX.test(userId)) {
                alert("아이디는 6~20자의 영문 소문자와 숫자만 가능합니다.");
                $userIdField.focus();
                return null;
            }

            // 비밀번호 검사
            if (!USER_PW_REGEX.test(userPw)) {
                alert("비밀번호는 8~20자의 영문, 숫자, 특수문자 조합이어야 합니다.");
                $userPwField.focus();
                return null;
            }

            // 이름 검사
            if (!USER_NAME_REGEX.test(userName)) {
                alert("사용자명은 한글과 영어만 입력 가능합니다.");
                $userNameField.focus();
                return null;
            }

            // 휴대폰 번호 검사
            if (!USER_HP_REGEX.test(cleanedPhone)) {
                alert("올바른 휴대폰번호를 입력해주세요.");
                $userHpField.focus();
                return null;
            }

            // 이메일 항목 체크
            if (!userEmail) {
                alert("이메일을 입력해주세요.");
                $userEmailField.focus();
                return null;
            }

            // 이메일 유효성 검사
            if (!USER_EMAIL_REGEX.test(userEmail)) {
                alert("이메일 형식이 올바르지 않습니다.");
                $userEmailField.focus();
                return null;
            }

            // 생년월일 항목 체크
            if (!userBirth) {
                alert("생년월일을 입력해주세요.");
                $userBirthField.focus();
                return null;
            }

            // 성별 및 급수 선택 검사 (배드민턴 매칭 핵심 데이터)
            if (!userGender) { alert("성별을 선택해주세요."); return null; }
            if (!addr1Level) { alert("전국 급수를 선택해주세요."); return null; }
            if (!addr2Level) { alert("시 급수를 선택해주세요."); return null; }
            if (!addr3Level) { alert("구 급수를 선택해주세요."); return null; }

            return {
                userId, userPw, userName, userBirth,
                userHp: cleanedPhone,
                userEmail, userGender, addr1Level, addr2Level, addr3Level
            };
        }

        // 5. 회원가입 API 호출
        async function joinUser(param) {
            try {
                const res = await fetch("join/add", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(param)
                });
                if (!res.ok) throw new Error("API 호출 실패");
                return await res.json();
            } catch (err) {
                console.error(err);
                return { success: false, message: "서버 연결 오류" };
            }
        }

        // 6. 회원가입 버튼 클릭 이벤트
        $("#joinBtn").on("click", async function () {
            const data = validateForm();
            if (!data) return; // 유효성 검사 실패 시 중단

            const result = await joinUser(data);

            if (result && result.success) {
                alert("셔틀메이트 가입을 축하합니다! 로그인 페이지로 이동합니다. 🏸");
                location.href = "/login";
            } else {
                alert("회원가입 실패: " + (result.message || "다시 시도해주세요."));
            }
        });
    });
</script>

<script type="text/javascript">
    $(document).ready(function () {

        $.datepicker.setDefaults({
            dateFormat: 'yy-mm-dd',
            changeYear: true,
            changeMonth: true,
            showMonthAfterYear: true,
            yearSuffix: '년',
            monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
            monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
            dayNames: ['일요일','월요일','화요일','수요일','목요일','금요일','토요일'],
            dayNamesShort: ['일','월','화','수','목','금','토'],
            dayNamesMin: ['일','월','화','수','목','금','토']
        });

        $("#userBirth").datepicker({
            yearRange: "1900:" + new Date().getFullYear(),
            maxDate: 0  // 미래 날짜 선택 방지
        });

    });
</script>

</body>
</html>