<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 모임 만들기</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/club/club_create.css">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/club/club_create.js" defer></script>
</head>
<body>

<%-- 공통 헤더 --%>
<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<main>
    <div class="container my-5">
        <div class="create-form-wrapper mx-auto shadow rounded-4 overflow-hidden bg-white">
            <div class="form-header p-4 text-center text-white">
                <h2 class="fw-bold m-0">🏸 모임 생성 🏸</h2>
                <p class="m-0 mt-1 opacity-75">모임을 생성하고 관리자 정보를 등록합니다.</p>
            </div>

            <form action="<c:url value="/club/insertPro"/>" method="post" id="clubCreateForm" class="p-4">

                <%-- ① 모임 기본 정보 섹션 --%>
                <div class="form-section mb-5">
                    <h5 class="section-title"><i class="fa-solid fa-circle-info me-2"></i>모임 기본 정보</h5>
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">모임명</label>
                            <input type="text" name="clubTitle" class="form-control" placeholder="ex) 배치꼬" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">활동 장소</label>
                            <input type="text" name="location" class="form-control" placeholder="ex) 대학공원 배드민턴장" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">최대 관리 인원(명)</label>
                            <input type="number" name="maxMembers" class="form-control" placeholder="ex) 50명" min="4" max="500">
                        </div>
                        <div class="col-12">
                            <label class="form-label">모임 소개</label>
                            <textarea name="description" class="form-control" rows="3" placeholder="모임 규칙 및 소개를 입력하세요."></textarea>
                        </div>
                    </div>
                </div>

                <%-- ② 모임 관리자(본인) 상세 프로필 섹션 --%>
                <%--
                    7개 필드 구성:
                    Row 1: 사용자 ID (readonly) | 사용자명 (readonly) | 출생 연도
                    Row 2: 성별 (radio)         | 전국 급수            | 시 급수    | 구 급수
                    → Row 2는 col-6 col-md-3 으로 모바일 2열, PC 4열 대응
                --%>
                <div class="form-section mb-4">
                    <h5 class="section-title"><i class="fa-solid fa-id-card me-2"></i>모임 관리자(본인) 상세 프로필</h5>

                    <%-- Row 1: 기본 계정 정보 (3열 균등) --%>
                    <div class="row g-3 mb-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label">사용자 ID</label>
                            <input type="text"
                                   name="userId"
                                   class="form-control bg-light"
                                   value="${sessionScope.loginUser.userId}"
                                   readonly>
                        </div>
                        <div class="col-12 col-md-4">
                            <label class="form-label">사용자명</label>
                            <%-- 수정: form-conrol → form-control (오타 수정) --%>
                            <input type="text"
                                   name="userName"
                                   class="form-control bg-light"
                                   value="${sessionScope.loginUser.userName}"
                                   readonly>
                        </div>
                        <div class="col-12 col-md-4">
                            <label class="form-label">출생 연도</label>
                            <select name="birthYear" id="birthYear" class="form-select"></select>
                        </div>
                    </div>

                    <%-- Row 2: 성별 + 급수 3종 (모바일 2열, PC 4열) --%>
                    <div class="row g-3">
                        <%-- 성별 --%>
                        <div class="col-6 col-md-3">
                            <label class="form-label">성별</label>
                            <div class="btn-group w-100" role="group" aria-label="성별 선택">
                                <input type="radio" class="btn-check" name="gender" id="genderM" value="M">
                                <label class="btn btn-outline-primary" for="genderM">남성</label>
                                <input type="radio" class="btn-check" name="gender" id="genderF" value="F">
                                <label class="btn btn-outline-danger" for="genderF">여성</label>
                            </div>
                        </div>

                        <%-- 전국 급수 --%>
                        <div class="col-6 col-md-3">
                            <label class="form-label text-success fw-bold">전국 급수</label>
                            <select name="addr1Level" class="form-select border-success">
                                <option value="">:: 선택 ::</option>
                                <c:forEach items="${addr1Level}" var="addr1L">
                                    <option value="${addr1L.value}">${addr1L.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <%-- 시 급수 --%>
                        <div class="col-6 col-md-3">
                            <label class="form-label">시 급수</label>
                            <select name="addr2Level" class="form-select border-success">
                                <option value="">:: 선택 ::</option>
                                <c:forEach items="${addr2Level}" var="addr2L">
                                    <option value="${addr2L.value}">${addr2L.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <%-- 구 급수 --%>
                        <div class="col-6 col-md-3">
                            <label class="form-label">구 급수</label>
                            <select name="addr3Level" class="form-select border-success">
                                <option value="">:: 선택 ::</option>
                                <c:forEach items="${addr3Level}" var="addr3L">
                                    <option value="${addr3L.value}">${addr3L.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <button type="submit" class="btn btn-submit w-100 py-3 fw-bold mt-4 shadow-sm">모임 생성하기</button>
            </form>
        </div>
    </div>
</main>

<%-- 푸터와 모바일 메뉴 인클루드 --%>
<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

</body>
</html>
