<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>ShuttleMate - Random Match</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main/index.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/random/random_match.css">
</head>
<body>

<jsp:include page="/WEB-INF/jsp/base/header.jsp" />

<div class="match-container">
  <header class="match-header">
    <h1 class="logo">셔틀<span>메이트</span></h1>
    <p class="subtitle">2 VS 2 팀전</p>
  </header>

  <main class="match-main">
    <section class="input-section" id="inputSection">
      <h2>플레이어 정보 입력</h2>
      <div class="input-group">
        <input type="text" id="player1" class="player-input" placeholder="Player 1 Name" required>
        <input type="text" id="player2" class="player-input" placeholder="Player 2 Name" required>
        <input type="text" id="player3" class="player-input" placeholder="Player 3 Name" required>
        <input type="text" id="player4" class="player-input" placeholder="Player 4 Name" required>
      </div>
      <button type="button" class="btn-primary" id="btnShuffle">매칭 시작</button>
    </section>

    <section class="result-section hidden" id="resultSection">
      <h2>매칭 결과</h2>

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
        <button type="button" class="btn-secondary" id="btnReset">Re-Shuffle</button>
        <button type="button" class="btn-primary" id="btnStart">Start Match!</button>
      </div>
    </section>
  </main>
</div>

<jsp:include page="/WEB-INF/jsp/base/footer.jsp" />

<script src="${pageContext.request.contextPath}/js/random_match.js"></script>
</body>
</html>