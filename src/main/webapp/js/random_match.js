document.addEventListener('DOMContentLoaded', () => {
    const btnShuffle = document.getElementById('btnShuffle');
    const btnReset = document.getElementById('btnReset');
    const inputSection = document.getElementById('inputSection');
    const resultSection = document.getElementById('resultSection');
    const playerInputs = document.querySelectorAll('.player-input');

    // 1. 팀 섞기 버튼 클릭 이벤트
    btnShuffle.addEventListener('click', () => {
        const players = [];
        let allFilled = true;

        // 이름 입력 확인 및 배열 생성
        playerInputs.forEach(input => {
            if (input.value.trim() === '') {
                allFilled = false;
                input.style.borderColor = 'red'; // 빈칸은 빨간색 표시
            } else {
                input.style.borderColor = '#ddd';
                players.push(input.value.trim());
            }
        });

        if (!allFilled) {
            alert('Please enter all 4 player names.');
            return;
        }

        // 피셔-예이츠 셔플 알고리즘 (진짜 랜덤)
        for (let i = players.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [players[i], players[j]] = [players[j], players[i]];
        }

        // 팀 배정 (앞의 2명 Team A, 뒤의 2명 Team B)
        const teamA = players.slice(0, 2);
        const teamB = players.slice(2, 4);

        // UI에 결과 반영
        displayResults(teamA, teamB);
    });

    // 2. 다시 섞기 버튼 클릭 이벤트
    btnReset.addEventListener('click', () => {
        resultSection.classList.add('hidden');
        inputSection.classList.remove('hidden');
    });

    // 결과 표시 함수
    function displayResults(teamA, teamB) {
        const teamAList = document.getElementById('teamAList');
        const teamBList = document.getElementById('teamBList');

        // 기존 목록 초기화
        teamAList.innerHTML = '';
        teamBList.innerHTML = '';

        // 이름 삽입
        teamA.forEach(name => {
            const li = document.createElement('li');
            li.textContent = name;
            teamAList.appendChild(li);
        });

        teamB.forEach(name => {
            const li = document.createElement('li');
            li.textContent = name;
            teamBList.appendChild(li);
        });

        // 화면 전환
        inputSection.classList.add('hidden');
        resultSection.classList.remove('hidden');
    }
});