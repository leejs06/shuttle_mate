/**
 * match_history.js
 * 매칭 내역 페이지 - 매칭 상세 보기 모달
 * (club_manage.js의 매칭 상세 보기 로직과 동일, 이 페이지 전용으로 최소 구성)
 */

/* 매칭 상세 보기 */
window.viewMatch = function (matchId) {
    $.ajax({
        url: contextPath + '/club/matchDetail',
        type: 'GET',
        data: { matchId: matchId },
        success: function (res) {
            renderMatchDetail(res);
            const modal = new bootstrap.Modal(document.getElementById('matchDetailModal'));
            modal.show();
        },
        error: function () {
            alert('상세 내역 조회 중 오류가 발생했습니다.');
        }
    });
};

function renderMatchDetail(data) {
    const $body = $('#matchDetailBody').empty();
    if (!data || !data.courts || data.courts.length === 0) {
        $body.html('<p class="text-muted text-center py-3">조회된 정보가 없습니다.</p>');
        return;
    }

    const typeLabel = {
        'SINGLES': '단식',
        'DOUBLES': '복식',
        'MIXED':   '혼합 복식'
    }[data.matchType] || '복식';

    const $info = $(
        '<div class="mb-3 small text-muted">' +
        '<i class="fa-regular fa-calendar me-1"></i>' + escapeHtml(data.matchDate || '') +
        ' &nbsp;|&nbsp; <i class="fa-solid fa-tag me-1"></i>' + typeLabel +
        '</div>'
    );
    $body.append($info);

    // 코트가 1개뿐이면(수동 매칭은 코트 1개씩 저장됨) 굳이 절반 폭으로 좁히지 않고 꽉 채워서 보여줌
    const courtColClass = data.courts.length <= 1 ? 'col-12' : 'col-12 col-md-6';

    const $row = $('<div class="row g-3"></div>');
    data.courts.forEach(function (court) {
        const aWin = court.winnerSide === 'A';
        const bWin = court.winnerSide === 'B';
        $row.append(
            '<div class="' + courtColClass + '">' +
            '  <div class="court-card">' +
            '    <div class="court-header">' +
            '      <span class="court-title"><i class="fa-solid fa-feather me-2"></i>코트 ' + court.courtNo + '</span>' +
            '      <span class="court-type">' + typeLabel + '</span>' +
            '    </div>' +
            '    <div class="team-box team-a' + (aWin ? ' team-winner' : '') + '">' +
            '      <div class="team-label">A팀' + (aWin ? ' <span class="team-win-badge">승</span>' : '') + '</div>' +
            '      <div>' + (court.teamA || []).map(playerTag).join('') + '</div>' +
            '    </div>' +
            '    <div class="vs-divider">VS</div>' +
            '    <div class="team-box team-b' + (bWin ? ' team-winner' : '') + '">' +
            '      <div class="team-label">B팀' + (bWin ? ' <span class="team-win-badge">승</span>' : '') + '</div>' +
            '      <div>' + (court.teamB || []).map(playerTag).join('') + '</div>' +
            '    </div>' +
            '  </div>' +
            '</div>'
        );
    });
    $body.append($row);
}

function playerTag(p) {
    const genderCls  = p.gender === 'M' ? 'male' : 'female';
    const genderText = p.gender === 'M' ? '남' : '여';
    return '<span class="team-player">' +
        escapeHtml(p.name) +
        ' <span class="badge-gender ' + genderCls + '" style="font-size:0.7rem;padding:1px 7px;">' + genderText + '</span>' +
        '</span>';
}

function escapeHtml(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}
