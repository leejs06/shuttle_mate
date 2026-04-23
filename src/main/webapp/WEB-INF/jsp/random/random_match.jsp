<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ShuttleMate - 랜덤 매칭</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <%--<link rel="stylesheet" href="${pageContext.request.contextPath}/css/main/main.css">--%>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common/common.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/random/random_match.css">
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" defer></script>
  <script src="${pageContext.request.contextPath}/js/random/random_match.js" defer></script>
</head>
<body>

<%-- 헤더 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<div class="match-container">
  <header class="match-header">
    <h1 class="logo">랜덤 매칭<span></span></h1>
    <p class="subtitle">2 VS 2 팀전</p>
  </header>

  <main class="match-main">
    <section class="input-section" id="inputSection">
      <%--<h2>플레이어 정보 입력</h2>--%>
      <div class="input-group">
        <input type="text" id="player1" class="player-input" placeholder="플레이어1 이름 입력" required>
        <input type="text" id="player2" class="player-input" placeholder="플레이어2 이름 입력" required>
        <input type="text" id="player3" class="player-input" placeholder="플레이어3 이름 입력" required>
        <input type="text" id="player4" class="player-input" placeholder="플레이어4 이름 입력" required>
      </div>
      <button type="button" class="btn-primary" id="btnShuffle">매칭 시작</button>
    </section>

    <section class="result-section hidden" id="resultSection">
      <h2 style="text-align: center;">매칭 결과</h2>

      <div class="vs-container">
        <div class="team-box team-a">
          <h3>Team A</h3>
          <ul id="teamAList">
          </ul>
        </div>

        <div class="vs-divider">VS</div>

        <div class="team-box team-b">
          <h3>Team B</h3>
          <ul id="teamBList">
          </ul>
        </div>
      </div>

      <div class="action-group">
        <button type="button" class="btn-secondary" id="btnReset">다시 매칭하기</button>
        <%--<button type="button" class="btn-primary" id="btnStart">매칭 시작</button>--%>
      </div>
    </section>
  </main>
</div>

<%-- 모바일 하단 메뉴 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/mobile/mobile_menu.jsp" />

<%-- 푸터 적용 --%>
<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

</body>
</html>