<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShuttleMate - 모임 만들기</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/club/club_create.css">
    <script src="${pageContext.request.contextPath}/js/club/club_create.js" defer></script>
</head>
<body>
<%-- 헤더 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/header.jsp" />




<%-- 모바일 메뉴 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

<%-- 푸터 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

</body>
</html>
