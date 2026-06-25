/**
 * club_manage.js
 * 모임 관리 페이지 (경기 매칭 + 멤버 관리 + 모임 정보 수정 탭)
 */

$(function () {

    /* ─────────────────────────────────────────
       1. 출생 연도 셀렉트 초기화 (모임 정보 수정 탭)
          #editBirthYear[data-selected] 값을 selected 처리
       ───────────────────────────────────────── */
    const $birthYear = $('#editBirthYear');
    const selectedYear = parseInt($birthYear.data('selected')) || new Date().getFullYear() - 30;
    const currentYear = new Date().getFullYear();

    for (let y = currentYear - 10; y >= 1940; y--) {
        const option = $('<option>', {
            value: y,
            text: y + '년',
            selected: y === selectedYear
        });
        $birthYear.append(option);
    }

    /* ─────────────────────────────────────────
       1-2. 멤버 추가/수정 모달의 생년 셀렉트 초기화
       ───────────────────────────────────────── */
    const $newBirthYear = $('#newBirthYear');
    $newBirthYear.append('<option value="">:: 선택 ::</option>');
    for (let y = currentYear - 10; y >= 1940; y--) {
        $newBirthYear.append($('<option>', { value: y, text: y + '년' }));
    }

    /* ─────────────────────────────────────────
       2. 수정 폼 초기화 버튼 (모임 정보 수정 탭)
       ───────────────────────────────────────── */
    $('#btnResetForm').on('click', function () {
        if (confirm('변경 내용을 모두 초기화하시겠습니까?')) {
            document.getElementById('clubEditForm').reset();
            $birthYear.val(selectedYear);
        }
    });

    /* ─────────────────────────────────────────
       3. 수정 폼 제출 확인 (모임 정보 수정 탭)
       ───────────────────────────────────────── */
    $('#clubEditForm').on('submit', function (e) {
        const title = $('input[name="clubTitle"]').val().trim();
        const location = $('input[name="location"]').val().trim();

        if (!title || !location) {
            e.preventDefault();
            alert('모임명과 활동 장소는 필수 입력 항목입니다.');
            return;
        }
        if (!confirm('수정 내용을 저장하시겠습니까?')) {
            e.preventDefault();
        }
    });

    /* ─────────────────────────────────────────
       4. 멤버 제외 (kick)
       ───────────────────────────────────────── */
    window.kickMember = function (memberSeq, userName) {
        if (!confirm('"' + userName + '" 님을 모임에서 제외하시겠습니까?')) return;

        $.ajax({
            url: contextPath + '/club/kickMember',
            type: 'POST',
            data: { memberId: memberSeq, clubId: clubId },
            success: function (res) {
                if (res.result === 'success') {
                    $('button[onclick*="' + memberSeq + '"]').closest('tr').fadeOut(300, function () {
                        $(this).remove();
                        const count = $('#memberTableBody tr').length;
                        $('#memberCount').text(count);
                        $('#availableMemberCount').text(count);
                        if (count === 0) {
                            $('#memberTableBody').html(
                                '<tr><td colspan="5" class="text-center text-muted py-4">등록된 멤버가 없습니다.</td></tr>'
                            );
                        }
                    });
                    $('#participant-' + memberSeq).closest('.col-6, .col-md-4, .col-lg-3').remove();
                } else {
                    alert('제외 처리 중 오류가 발생했습니다.');
                }
            },
            error: function () {
                alert('서버 통신 오류가 발생했습니다.');
            }
        });
    };

    /* ═════════════════════════════════════════
       5. 멤버 직접 추가 / 수정 (공용 모달)
       ─────────────────────────────────────────
       - "멤버 직접 추가" 버튼 → mode = 'add'
       - 멤버 행의 "수정" 버튼   → mode = 'edit'
       ═════════════════════════════════════════ */
    const $addForm = $('#addMemberForm');

    // 모달 열릴 때 폼 초기화 + 모드별 헤더/버튼 텍스트 설정
    $('#addMemberModal').on('show.bs.modal', function () {
        $addForm[0].reset();
        $('#editMemberSeq').val('');
        $addForm.find('.is-invalid').removeClass('is-invalid');
        $addForm.find('.form-error-msg').removeClass('show').remove();

        // openEditMemberModal에서 mode를 미리 'edit'로 세팅했다면 그대로 유지,
        // 아니면 기본값 'add'로 초기화
        if ($addForm.data('mode') !== 'edit') {
            $addForm.data('mode', 'add');
            $('#memberModalTitleText').text('멤버 직접 추가');
            $('#memberModalSubmitText').text('멤버 추가');
            $('#memberModalSubmitIcon').removeClass().addClass('fa-solid fa-plus me-1');
            $('#memberModalDescription').html(
                '<i class="fa-solid fa-circle-info me-1"></i>' +
                '모임 내에서만 사용되는 멤버 정보를 직접 입력합니다.'
            );
        }
    });

    // 모달이 완전히 닫힌 후 모드 리셋 (다음번 열기를 위해)
    $('#addMemberModal').on('hidden.bs.modal', function () {
        $addForm.data('mode', 'add');
    });

    // 입력 시 실시간 에러 표시 해제
    $addForm.on('input change', '.form-control, .form-select, .btn-check', function () {
        $(this).removeClass('is-invalid');
        $(this).closest('.mb-3, .col-6, .col-12').find('.form-error-msg').removeClass('show').remove();
    });

    /**
     * "수정" 버튼 클릭 → 모달을 수정 모드로 열기
     * 행의 data-* 속성을 받아 폼에 채워 넣음
     */
    window.openEditMemberModal = function (btn) {
        const $btn = $(btn);

        // 1) 모드를 미리 edit로 세팅 (show.bs.modal 핸들러가 이를 보고 헤더 갱신을 스킵)
        $addForm.data('mode', 'edit');

        // 2) 모달 제목/버튼/설명 텍스트 변경
        $('#memberModalTitleText').text('멤버 정보 수정');
        $('#memberModalSubmitText').text('수정 저장');
        $('#memberModalSubmitIcon').removeClass().addClass('fa-solid fa-floppy-disk me-1');
        $('#memberModalDescription').html(
            '<i class="fa-solid fa-pen-to-square me-1"></i>' +
            '<strong>' + $btn.data('user-name') + '</strong> 님의 정보를 수정합니다.'
        );

        // 3) 모달이 완전히 표시된 후에 폼 채우기 (reset 후 채워야 하므로 shown 이벤트 사용)
        const modalEl = document.getElementById('addMemberModal');
        $(modalEl).one('shown.bs.modal', function () {
            $('#editMemberSeq').val($btn.data('member-seq'));
            $addForm.find('input[name="userName"]').val($btn.data('user-name'));
            $addForm.find('select[name="birthYear"]').val(String($btn.data('birth-year')));
            $addForm.find('select[name="addr1Level"]').val($btn.data('addr1') || '');
            $addForm.find('select[name="addr2Level"]').val($btn.data('addr2') || '');
            $addForm.find('select[name="addr3Level"]').val($btn.data('addr3') || '');

            // 성별 라디오
            const gender = $btn.data('gender');
            if (gender === 'M') $('#newGenderM').prop('checked', true);
            else if (gender === 'F') $('#newGenderF').prop('checked', true);
        });

        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    };

    // 폼 제출 (추가/수정 공용)
    $addForm.on('submit', function (e) {
        e.preventDefault();

        const mode = $addForm.data('mode') === 'edit' ? 'edit' : 'add';

        // 입력값 수집
        const userName  = $.trim($addForm.find('input[name="userName"]').val());
        const gender    = $addForm.find('input[name="gender"]:checked').val();
        const birthYear = $addForm.find('select[name="birthYear"]').val();
        const addr1     = $addForm.find('select[name="addr1Level"]').val();
        const addr2     = $addForm.find('select[name="addr2Level"]').val();
        const addr3     = $addForm.find('select[name="addr3Level"]').val();

        // 유효성 검사
        let isValid = true;

        if (!userName) {
            markError($addForm.find('input[name="userName"]'), '이름을 입력하세요.');
            isValid = false;
        } else if (userName.length < 2) {
            markError($addForm.find('input[name="userName"]'), '이름은 2자 이상이어야 합니다.');
            isValid = false;
        }
        if (!gender) {
            markError($addForm.find('#newGenderM').closest('.btn-group'), '성별을 선택하세요.');
            isValid = false;
        }
        if (!birthYear) {
            markError($addForm.find('select[name="birthYear"]'), '생년을 선택하세요.');
            isValid = false;
        }
        if (!addr1 && !addr2 && !addr3) {
            markError($addForm.find('select[name="addr3Level"]'), '급수를 1개 이상 선택하세요.');
            isValid = false;
        }

        if (!isValid) return;

        // AJAX URL / 페이로드 모드별 분기
        const url = (mode === 'edit')
            ? contextPath + '/club/updateMember'
            : contextPath + '/club/addMember';

        const data = {
            clubId:     clubId,
            userName:   userName,
            gender:     gender,
            birthYear:  birthYear,
            addr1Level: addr1 || '',
            addr2Level: addr2 || '',
            addr3Level: addr3 || ''
        };
        if (mode === 'edit') {
            data.memberSeq = $('#editMemberSeq').val();
        }

        const $submitBtn = $addForm.find('button[type="submit"]');
        const originalBtnHtml = mode === 'edit'
            ? '<i class="fa-solid fa-floppy-disk me-1"></i><span id="memberModalSubmitText">수정 저장</span>'
            : '<i class="fa-solid fa-plus me-1"></i><span id="memberModalSubmitText">멤버 추가</span>';

        $submitBtn.prop('disabled', true).html(
            '<i class="fa-solid fa-spinner fa-spin me-1"></i>' + (mode === 'edit' ? '저장 중...' : '등록 중...')
        );

        $.ajax({
            url: url,
            type: 'POST',
            data: data,
            success: function (res) {
                if (res.result === 'success') {
                    alert(mode === 'edit'
                        ? '"' + userName + '" 님의 정보가 수정되었습니다.'
                        : '"' + userName + '" 님이 멤버로 추가되었습니다.');
                    const modalEl = document.getElementById('addMemberModal');
                    bootstrap.Modal.getInstance(modalEl).hide();
                    location.reload();
                } else if (res.result === 'duplicate') {
                    alert('이미 같은 이름의 멤버가 등록되어 있습니다.');
                    $submitBtn.prop('disabled', false).html(originalBtnHtml);
                } else if (res.result === 'maxExceeded') {
                    alert('최대 관리 인원을 초과했습니다. 모임 정보 수정 탭에서 최대 인원을 늘려주세요.');
                    $submitBtn.prop('disabled', false).html(originalBtnHtml);
                } else {
                    alert('처리 중 오류가 발생했습니다.');
                    $submitBtn.prop('disabled', false).html(originalBtnHtml);
                }
            },
            error: function () {
                alert('서버 통신 오류가 발생했습니다.');
                $submitBtn.prop('disabled', false).html(originalBtnHtml);
            }
        });
    });

    // 에러 표시 유틸
    function markError($target, message) {
        $target.addClass('is-invalid');
        const $group = $target.closest('.mb-3, .col-6, .col-12');
        if ($group.find('.form-error-msg').length === 0) {
            $group.append('<div class="form-error-msg show">' + message + '</div>');
        }
    }

    /* ═════════════════════════════════════════
       ★ 경기 매칭 탭 ★
       ═════════════════════════════════════════ */

    let lastMatchResult = null;


    /* 매칭 생성 / 다시 매칭 */
    $('#btnGenerateMatch').on('click', generateMatch);
    $('#btnReshuffle').on('click', generateMatch);

    function generateMatch() {
        // 참석 풀에서 가져오기 (자동 매칭은 참석 멤버 전체를 풀로 사용)
        const participants = getAttendingMembers();

        const matchType = $('#matchType').val();
        const criteria = $('#matchCriteria').val();
        const courtCount = parseInt($('#courtCount').val()) || 1;

        const playersPerCourt = (matchType === 'SINGLES') ? 2 : 4;
        const requiredMin = playersPerCourt;

        if (participants.length < requiredMin) {
            alert('선택된 멤버가 ' + requiredMin + '명 이상 필요합니다. (현재 ' + participants.length + '명)');
            return;
        }

        const result = buildMatches(participants, matchType, criteria, courtCount);
        lastMatchResult = result;

        renderMatchResult(result, matchType);

        $('html, body').animate({
            scrollTop: $('#matchResultArea').offset().top - 80
        }, 400);
    }

    function buildMatches(players, matchType, criteria, courtCount) {
        const playersPerCourt = (matchType === 'SINGLES') ? 2 : 4;

        let arranged = [];
        if (matchType === 'MIXED') {
            arranged = arrangeMixed(players, courtCount);
        } else if (criteria === 'LEVEL') {
            arranged = arrangeByLevel(players);
        } else if (criteria === 'GENDER') {
            arranged = arrangeByGender(players);
        } else {
            arranged = shuffle(players.slice());
        }

        const totalNeeded = courtCount * playersPerCourt;
        const playing = arranged.slice(0, totalNeeded);
        const waiting = arranged.slice(totalNeeded);

        const courts = [];
        for (let i = 0; i < courtCount; i++) {
            const slice = playing.slice(i * playersPerCourt, (i + 1) * playersPerCourt);
            if (slice.length < playersPerCourt) break;
            if (matchType === 'SINGLES') {
                courts.push({ courtNo: i + 1, teamA: [slice[0]], teamB: [slice[1]] });
            } else {
                courts.push({
                    courtNo: i + 1,
                    teamA: [slice[0], slice[3]],
                    teamB: [slice[1], slice[2]]
                });
            }
        }

        return {
            matchType: matchType,
            criteria: criteria,
            courtCount: courts.length,
            courts: courts,
            waiting: waiting
        };
    }

    function arrangeByLevel(players) {
        const sorted = players.slice().sort(function (a, b) {
            return levelScore(a.level) - levelScore(b.level);
        });
        return shuffleWithinLevel(sorted);
    }
    function levelScore(lv) {
        if (!lv) return 99;
        const map = { 'S': 0, 'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5 };
        const key = String(lv).trim().charAt(0).toUpperCase();
        return map[key] !== undefined ? map[key] : 99;
    }
    function shuffleWithinLevel(sorted) {
        const groups = {};
        sorted.forEach(function (p) {
            const s = levelScore(p.level);
            if (!groups[s]) groups[s] = [];
            groups[s].push(p);
        });
        const keys = Object.keys(groups).sort(function (a, b) { return a - b; });
        let out = [];
        keys.forEach(function (k) { out = out.concat(shuffle(groups[k])); });
        return out;
    }
    function arrangeByGender(players) {
        const males   = shuffle(players.filter(function (p) { return p.gender === 'M'; }));
        const females = shuffle(players.filter(function (p) { return p.gender === 'F'; }));
        const out = [];
        const max = Math.max(males.length, females.length);
        for (let i = 0; i < max; i++) {
            if (i < males.length)   out.push(males[i]);
            if (i < females.length) out.push(females[i]);
        }
        return out;
    }
    function arrangeMixed(players, courtCount) {
        const males   = shuffle(players.filter(function (p) { return p.gender === 'M'; }));
        const females = shuffle(players.filter(function (p) { return p.gender === 'F'; }));
        const out = [];
        const courts = Math.min(courtCount, Math.floor(males.length / 2), Math.floor(females.length / 2));
        for (let i = 0; i < courts; i++) {
            out.push(males[i * 2]);
            out.push(females[i * 2]);
            out.push(males[i * 2 + 1]);
            out.push(females[i * 2 + 1]);
        }
        const used = new Set(out.map(function (p) { return p.memberId; }));
        players.forEach(function (p) { if (!used.has(p.memberId)) out.push(p); });
        return out;
    }
    function shuffle(arr) {
        const a = arr.slice();
        for (let i = a.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [a[i], a[j]] = [a[j], a[i]];
        }
        return a;
    }

    function renderMatchResult(result, matchType) {
        const $list = $('#matchResultList').empty();

        const typeLabel = {
            'SINGLES': '단식',
            'DOUBLES': '복식',
            'MIXED':   '혼합 복식'
        }[matchType] || '복식';

        result.courts.forEach(function (court) {
            const card = $(
                '<div class="col-12 col-md-6">' +
                '  <div class="court-card">' +
                '    <div class="court-header">' +
                '      <span class="court-title"><i class="fa-solid fa-feather me-2"></i>코트 ' + court.courtNo + '</span>' +
                '      <span class="court-type">' + typeLabel + '</span>' +
                '    </div>' +
                '    <div class="team-box team-a">' +
                '      <div class="team-label">A팀</div>' +
                '      <div>' + court.teamA.map(playerTag).join('') + '</div>' +
                '    </div>' +
                '    <div class="vs-divider">VS</div>' +
                '    <div class="team-box team-b">' +
                '      <div class="team-label">B팀</div>' +
                '      <div>' + court.teamB.map(playerTag).join('') + '</div>' +
                '    </div>' +
                '  </div>' +
                '</div>'
            );
            $list.append(card);
        });

        const $waitArea = $('#waitingArea');
        const $waitList = $('#waitingList').empty();
        if (result.waiting && result.waiting.length > 0) {
            result.waiting.forEach(function (p) {
                $waitList.append('<span class="badge-waiting">' + escapeHtml(p.name) + '</span>');
            });
            $waitArea.show();
        } else {
            $waitArea.hide();
        }

        $('#matchResultArea').show();
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

    /* 매칭 저장 */
    $('#btnSaveMatch').on('click', function () {
        if (!lastMatchResult) {
            alert('저장할 매칭 결과가 없습니다.');
            return;
        }
        if (!confirm('현재 매칭 결과를 저장하시겠습니까?')) return;

        const payload = {
            clubId: clubId,
            matchType: lastMatchResult.matchType,
            criteria: lastMatchResult.criteria,
            courtCount: lastMatchResult.courtCount,
            courts: lastMatchResult.courts.map(function (c) {
                return {
                    courtNo: c.courtNo,
                    teamAIds: c.teamA.map(function (p) { return p.memberId; }),
                    teamBIds: c.teamB.map(function (p) { return p.memberId; })
                };
            }),
            waitingIds: (lastMatchResult.waiting || []).map(function (p) { return p.memberId; })
        };

        $.ajax({
            url: contextPath + '/club/saveMatch',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(payload),
            success: function (res) {
                if (res.result === 'success') {
                    alert('매칭 결과가 저장되었습니다.');
                    location.reload();
                } else {
                    alert('저장 중 오류가 발생했습니다.');
                }
            },
            error: function () {
                alert('서버 통신 오류가 발생했습니다.');
            }
        });
    });

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

        const $row = $('<div class="row g-3"></div>');
        data.courts.forEach(function (court) {
            $row.append(
                '<div class="col-12 col-md-6">' +
                '  <div class="court-card">' +
                '    <div class="court-header">' +
                '      <span class="court-title"><i class="fa-solid fa-feather me-2"></i>코트 ' + court.courtNo + '</span>' +
                '      <span class="court-type">' + typeLabel + '</span>' +
                '    </div>' +
                '    <div class="team-box team-a">' +
                '      <div class="team-label">A팀</div>' +
                '      <div>' + (court.teamA || []).map(playerTag).join('') + '</div>' +
                '    </div>' +
                '    <div class="vs-divider">VS</div>' +
                '    <div class="team-box team-b">' +
                '      <div class="team-label">B팀</div>' +
                '      <div>' + (court.teamB || []).map(playerTag).join('') + '</div>' +
                '    </div>' +
                '  </div>' +
                '</div>'
            );
        });
        $body.append($row);
    }

    /* ═════════════════════════════════════════
       ★ getAttendingMembers 함수 (먼저 정의) ★
       수동 매칭 / 자동 매칭에서 사용하므로 미리 정의
       ═════════════════════════════════════════ */
    window.getAttendingMembers = function () {
        const result = [];
        $('.attend-checkbox:checked').each(function () {
            const $cb = $(this);
            result.push({
                memberId: $cb.val(),
                name:     $cb.data('name'),
                gender:   $cb.data('gender'),
                addr1:    $cb.data('addr1'),
                addr2:    $cb.data('addr2'),
                addr3:    $cb.data('addr3'),
                level:    $cb.data('addr3')
            });
        });
        return result;
    };

    /* ═════════════════════════════════════════
       ★ 수동 매칭 ★
       ═════════════════════════════════════════ */

// 코트 상태 머신
    let manualCourts = [];

// 멤버별 오늘 경기 통계: memberId → { count: 경기수, lastPlayedAt: timestamp }
// 페이지 새로고침하면 리셋 (B단계에서 DB 연동 예정)
    let memberStats = {};

// 새 경기 종료 시 통계 갱신
    function recordGameForMembers(memberIds) {
        const now = Date.now();
        memberIds.forEach(function (id) {
            const key = String(id);
            if (!memberStats[key]) {
                memberStats[key] = { count: 0, lastPlayedAt: 0 };
            }
            memberStats[key].count += 1;
            memberStats[key].lastPlayedAt = now;
        });
    }

// 멤버의 오늘 경기 수
    function getGameCount(memberId) {
        const s = memberStats[String(memberId)];
        return s ? s.count : 0;
    }

// 멤버의 마지막 경기 시각 (없으면 0 = 가장 오래 쉰 것으로 간주)
    function getLastPlayedAt(memberId) {
        const s = memberStats[String(memberId)];
        return s ? s.lastPlayedAt : 0;
    }
    /* 코트 추가 버튼 (기존 코트 유지, 새 코트 1개만 뒤에 추가) */
    $('#btnBuildManualCourts').on('click', function () {
        const type = $('#manualMatchType').val();
        const teamSize = (type === 'SINGLES') ? 1 : 2;

        // 최대 코트 수 제한
        if (manualCourts.length >= 20) {
            alert('코트는 최대 20개까지 추가할 수 있습니다.');
            return;
        }

        // 참석 멤버 풀 검증: 최소 필요 인원
        const attending = getAttendingMembers();
        const need = teamSize * 2;
        if (attending.length < need) {
            alert(type === 'SINGLES'
                ? '단식은 최소 2명의 참석 멤버가 필요합니다. (현재 ' + attending.length + '명)'
                : '복식은 최소 4명의 참석 멤버가 필요합니다. (현재 ' + attending.length + '명)');
            return;
        }

        // 기존 배열에 새 코트 1개만 push (코트 번호는 기존 +1)
        manualCourts.push({
            courtNo: manualCourts.length + 1,
            state: 'selecting',
            type: type,
            teamSize: teamSize,
            selecting: { a: new Array(teamSize).fill(null), b: new Array(teamSize).fill(null) },
            players: [],
            winner: null
        });

        renderManualCourts();
        renderManualWaiting();
    });

    /* 코트 카드 렌더링 (전체) */
    function renderManualCourts() {
        const $area = $('#manualCourtArea').empty();
        if (manualCourts.length === 0) {
            $area.html('<div class="col-12 text-center text-muted py-4">코트를 먼저 생성하세요.</div>');
            return;
        }

        manualCourts.forEach(function (court, idx) {
            const $col = $('<div class="col-12 col-md-6"></div>');
            $col.append(buildCourtCardHtml(court, idx));
            $area.append($col);
        });

        // 모든 드롭다운 옵션 동기화
        refreshAllManualDropdowns();
    }

    function buildCourtCardHtml(court, idx) {
        const stateLabel = {
            'selecting': '선수 선택',
            'playing':   '진행 중',
            'done':      '결과 입력 완료'
        }[court.state];
        const stateCls = { 'selecting': 's-selecting', 'playing': 's-playing', 'done': 's-done' }[court.state];
        const cardCls = court.state === 'playing' ? 'state-playing' : (court.state === 'done' ? 'state-done' : '');

        let body = '';
        if (court.state === 'selecting') {
            body = buildSelectingBody(court, idx);
        } else {
            body = buildPlayingBody(court, idx);
        }

        return $(
            '<div class="manual-court-card ' + cardCls + '" data-court-idx="' + idx + '">' +
            '  <div class="court-header">' +
            '    <span class="court-title"><i class="fa-solid fa-feather me-2"></i>코트 ' + court.courtNo + '</span>' +
            '    <span class="manual-court-state ' + stateCls + '">' + stateLabel + '</span>' +
            '  </div>' +
            '  <div class="court-body">' + body + '</div>' +
            '</div>'
        );
    }

    /* 선수 선택 단계 본문 */
    function buildSelectingBody(court, idx) {
        let html = '';

        // A팀 슬롯
        html += '<div class="team-box team-a"><div class="team-label">A팀</div><div class="manual-slot-row">';
        for (let i = 0; i < court.teamSize; i++) {
            html += slotHtml(idx, 'A', i, court.selecting.a[i]);
        }
        html += '</div></div>';

        html += '<div class="vs-divider">VS</div>';

        // B팀 슬롯
        html += '<div class="team-box team-b"><div class="team-label">B팀</div><div class="manual-slot-row">';
        for (let i = 0; i < court.teamSize; i++) {
            html += slotHtml(idx, 'B', i, court.selecting.b[i]);
        }
        html += '</div></div>';

        // 액션 버튼
        const allFilled = court.selecting.a.concat(court.selecting.b).every(function (v) { return !!v; });
        html += '<div class="manual-court-actions">';
        html += '  <button type="button" class="btn btn-start-court" ' +
            '          data-court-idx="' + idx + '" ' + (allFilled ? '' : 'disabled') + '>' +
            '    <i class="fa-solid fa-play me-1"></i>경기 시작' +
            '  </button>';
        html += '</div>';

        return html;
    }

    function slotHtml(idx, team, slotIdx, selectedId) {
        const badgeCls = team === 'A' ? 'team-a' : 'team-b';
        return '<div class="manual-slot">' +
            '<span class="manual-slot-badge ' + badgeCls + '">' + (slotIdx + 1) + '</span>' +
            '<select class="form-select manual-slot-select" ' +
            '        data-court-idx="' + idx + '" data-team="' + team + '" data-slot-idx="' + slotIdx + '">' +
            '  <option value="">:: 멤버 선택 ::</option>' +
            '</select>' +
            '</div>';
    }

    function buildPlayingBody(court, idx) {
        const teamA = court.players.filter(function (p) { return p.team === 'A'; });
        const teamB = court.players.filter(function (p) { return p.team === 'B'; });

        let html = '';
        html += '<div class="team-box team-a"><div class="team-label">A팀</div><div>' +
            teamA.map(playingPlayerTag).join('') + '</div></div>';
        html += '<div class="vs-divider">VS</div>';
        html += '<div class="team-box team-b"><div class="team-label">B팀</div><div>' +
            teamB.map(playingPlayerTag).join('') + '</div></div>';

        const aSel = court.winner === 'A' ? ' selected' : '';
        const bSel = court.winner === 'B' ? ' selected' : '';

        html += '<div class="manual-court-actions">';
        html += '  <button type="button" class="btn btn-win-a' + aSel + '" data-court-idx="' + idx + '" data-win="A">A팀 승</button>';
        html += '  <button type="button" class="btn btn-win-b' + bSel + '" data-court-idx="' + idx + '" data-win="B">B팀 승</button>';
        html += '  <button type="button" class="btn btn-court-undo" data-court-idx="' + idx + '" title="선수 선택으로 되돌리기">' +
            '    <i class="fa-solid fa-rotate-left"></i>' +
            '  </button>';
        html += '</div>';

        // 결과 입력 완료 상태에서만 [경기 종료] 버튼 표시
        if (court.state === 'done') {
            html += '<div class="manual-court-actions mt-2">';
            html += '  <button type="button" class="btn btn-end-game" data-court-idx="' + idx + '">' +
                '    <i class="fa-solid fa-flag-checkered me-1"></i>경기 종료' +
                '  </button>';
            html += '</div>';
        }

        return html;
    }

    function playingPlayerTag(p) {
        const genderCls  = p.gender === 'M' ? 'male' : 'female';
        const genderText = p.gender === 'M' ? '남' : '여';
        return '<span class="manual-playing-player">' +
            p.name +
            ' <span class="badge-gender ' + genderCls + '" style="font-size:0.7rem;padding:1px 7px;">' + genderText + '</span>' +
            '</span>';
    }

    /* 드롭다운 옵션 갱신 (사용 중인 멤버는 disabled) */
    function refreshAllManualDropdowns() {
        // 현재 사용 중인 memberId 집합 (selecting 슬롯 + playing 단계의 선수들 전부)
        const usedIds = new Set();
        manualCourts.forEach(function (court) {
            if (court.state === 'selecting') {
                court.selecting.a.forEach(function (id) { if (id) usedIds.add(String(id)); });
                court.selecting.b.forEach(function (id) { if (id) usedIds.add(String(id)); });
            } else {
                court.players.forEach(function (p) { usedIds.add(String(p.memberId)); });
            }
        });

        $('.manual-slot-select').each(function () {
            const $sel = $(this);
            const idx     = parseInt($sel.data('court-idx'));
            const team    = $sel.data('team');
            const slotIdx = parseInt($sel.data('slot-idx'));
            const court = manualCourts[idx];
            if (!court) return;

            const currentId = (team === 'A' ? court.selecting.a[slotIdx] : court.selecting.b[slotIdx]);
            const currentIdStr = currentId ? String(currentId) : '';

            // 옵션 다시 그리기 (참석 멤버만 옵션으로 노출)
            $sel.empty().append('<option value="">:: 멤버 선택 ::</option>');
            getAttendingMembers().forEach(function (m) {
                const isUsedElsewhere = usedIds.has(String(m.memberId)) && String(m.memberId) !== currentIdStr;
                const sel = String(m.memberId) === currentIdStr ? ' selected' : '';
                const dis = isUsedElsewhere ? ' disabled' : '';
                const cnt = getGameCount(m.memberId);
                const cntLabel = cnt > 0 ? ' · ' + cnt + '경기' : '';
                $sel.append('<option value="' + m.memberId + '"' + sel + dis + '>' +
                    m.name + ' (' + (m.gender === 'M' ? '남' : '여') + ' / ' + (m.addr3 || '-') + cntLabel + ')' +
                    '</option>');
            });
        });

        // 시작 버튼 활성/비활성 상태 갱신
        manualCourts.forEach(function (court, idx) {
            if (court.state !== 'selecting') return;
            const allFilled = court.selecting.a.concat(court.selecting.b).every(function (v) { return !!v; });
            $('.manual-court-card[data-court-idx="' + idx + '"] .btn-start-court').prop('disabled', !allFilled);
        });
    }

    /* 경기 시작 버튼 */
    $(document).on('click', '.btn-start-court', function () {
        const idx = parseInt($(this).data('court-idx'));
        const court = manualCourts[idx];
        if (!court) return;

        // selecting 정보를 players 배열로 변환
        const players = [];
        const memMap = {};
        (window.clubMembers || []).forEach(function (m) { memMap[String(m.memberId)] = m; });

        court.selecting.a.forEach(function (id) {
            const m = memMap[String(id)];
            if (m) players.push(Object.assign({}, m, { team: 'A' }));
        });
        court.selecting.b.forEach(function (id) {
            const m = memMap[String(id)];
            if (m) players.push(Object.assign({}, m, { team: 'B' }));
        });

        court.players = players;
        court.state = 'playing';
        court.winner = null;

        renderManualCourts();
        renderManualWaiting();
    });

    /* 드롭다운 변경 → 상태 반영 */
    $(document).on('change', '.manual-slot-select', function () {
        const $sel = $(this);
        const idx     = parseInt($sel.data('court-idx'));
        const team    = $sel.data('team');
        const slotIdx = parseInt($sel.data('slot-idx'));
        const newId   = $sel.val() || null;

        const court = manualCourts[idx];
        if (!court) return;
        if (team === 'A') court.selecting.a[slotIdx] = newId;
        else              court.selecting.b[slotIdx] = newId;

        refreshAllManualDropdowns();
        renderManualWaiting();
    });

    /* 경기 종료 (결과 입력 완료 → 코트 카드 제거 + 멤버 통계 갱신 + 대기열 복귀) */
    $(document).on('click', '.btn-end-game', function () {
        const idx = parseInt($(this).data('court-idx'));
        const court = manualCourts[idx];
        if (!court) return;
        if (court.state !== 'done') {
            alert('승리팀을 먼저 선택해주세요.');
            return;
        }

        // 1) 통계 갱신 — 이 경기에 참여한 모든 멤버
        const memberIds = court.players.map(function (p) { return p.memberId; });
        recordGameForMembers(memberIds);

        // 2) 코트 제거
        manualCourts.splice(idx, 1);

        // 3) 남은 코트들의 courtNo 재정렬
        manualCourts.forEach(function (c, i) { c.courtNo = i + 1; });

        // 4) 화면 갱신
        renderManualCourts();
        renderManualWaiting();
    });

    /* 승리팀 선택 */
    $(document).on('click', '.btn-win-a, .btn-win-b', function () {
        const idx = parseInt($(this).data('court-idx'));
        const win = $(this).data('win');
        const court = manualCourts[idx];
        if (!court) return;

        // 토글: 같은 버튼 또 누르면 해제
        court.winner = (court.winner === win) ? null : win;
        court.state = court.winner ? 'done' : 'playing';

        renderManualCourts();
    });

    /* 되돌리기 (진행 중/완료 → 선수 선택으로 복귀) */
    $(document).on('click', '.btn-court-undo', function () {
        const idx = parseInt($(this).data('court-idx'));
        const court = manualCourts[idx];
        if (!court) return;
        if (!confirm('이 코트를 선수 선택 단계로 되돌리시겠습니까?')) return;

        court.state = 'selecting';
        court.winner = null;
        // selecting 슬롯은 그대로 두어 다시 시작하면 같은 멤버 유지 가능
        court.players = [];

        renderManualCourts();
        renderManualWaiting();
    });

    /* 대기 멤버 영역 갱신 */
    function renderManualWaiting() {
        const allMembers = getAttendingMembers();

        const usedIds = new Set();
        manualCourts.forEach(function (court) {
            if (court.state === 'selecting') {
                court.selecting.a.forEach(function (id) { if (id) usedIds.add(String(id)); });
                court.selecting.b.forEach(function (id) { if (id) usedIds.add(String(id)); });
            } else {
                court.players.forEach(function (p) { usedIds.add(String(p.memberId)); });
            }
        });

        let waiting = allMembers.filter(function (m) { return !usedIds.has(String(m.memberId)); });

        // 정렬: 경기 수 적은 사람 우선 → 동률이면 마지막 경기 시각 빠른 사람 우선
        waiting.sort(function (a, b) {
            const cntA = getGameCount(a.memberId);
            const cntB = getGameCount(b.memberId);
            if (cntA !== cntB) return cntA - cntB;
            return getLastPlayedAt(a.memberId) - getLastPlayedAt(b.memberId);
        });

        $('#manualWaitingNum').text(waiting.length);
        $('#manualWaitingCount').text(waiting.length);

        const $list = $('#manualWaitingList').empty();
        if (waiting.length === 0) {
            $list.html('<span class="text-muted small">대기 중인 멤버가 없습니다.</span>');
            return;
        }
        waiting.forEach(function (m) {
            const genderText = m.gender === 'M' ? '남' : '여';
            const cnt = getGameCount(m.memberId);
            const cntBadge = cnt > 0
                ? ' <span class="badge-game-count">오늘 ' + cnt + '경기</span>'
                : ' <span class="badge-game-count zero">오늘 0</span>';

            $list.append('<span class="badge-waiting">' +
                m.name + ' <small class="text-muted">(' + genderText + ')</small>' +
                cntBadge +
                '</span>');
        });
    }

    /* 초기 대기 멤버 표시 */
    renderManualWaiting();

    // sessionStorage 키 (모임별로 분리)
    const ATTEND_KEY = 'shuttlemate.attending.' + clubId;

    /* 참석 카운트 갱신 + 매칭 화면 동기화 + sessionStorage 저장 */
    function refreshAttendingState() {
        const ids = [];
        $('.attend-checkbox:checked').each(function () { ids.push($(this).val()); });

        $('#attendingCount').text(ids.length);

        // 수동 매칭 대기자/카운트 동기화
        if (typeof renderManualWaiting === 'function') {
            renderManualWaiting();
        }

        // sessionStorage 저장
        try {
            sessionStorage.setItem(ATTEND_KEY, JSON.stringify(ids));
        } catch (e) { /* 무시 */ }
    }

    /* 체크박스 변경 시 */
    $(document).on('change', '.attend-checkbox', function () {
        // 수동 매칭에서 이미 코트에 배정된 멤버를 해제하려는 경우 차단
        if (!$(this).prop('checked') && typeof manualCourts !== 'undefined') {
            const memberId = String($(this).val());
            const isInCourt = manualCourts.some(function (court) {
                if (court.state === 'selecting') {
                    return court.selecting.a.concat(court.selecting.b)
                        .some(function (id) { return String(id) === memberId; });
                } else {
                    return court.players.some(function (p) { return String(p.memberId) === memberId; });
                }
            });
            if (isInCourt) {
                alert('이 멤버는 현재 수동 매칭 코트에 배정되어 있습니다.\n먼저 코트에서 제외해주세요.');
                $(this).prop('checked', true);   // 해제 되돌리기
                return;
            }
        }
        refreshAttendingState();
    });

    /* 전체 선택 */
    $('#btnAttendAll').on('click', function () {
        // 검색 중이면 보이는 것만 선택
        $('.attending-col:visible .attend-checkbox').prop('checked', true);
        refreshAttendingState();
    });

    /* 전체 해제 — 수동 매칭 코트에 배정된 멤버는 유지 */
    $('#btnAttendClear').on('click', function () {
        let blocked = 0;
        $('.attend-checkbox').each(function () {
            const memberId = String($(this).val());
            let isInCourt = false;
            if (typeof manualCourts !== 'undefined') {
                isInCourt = manualCourts.some(function (court) {
                    if (court.state === 'selecting') {
                        return court.selecting.a.concat(court.selecting.b)
                            .some(function (id) { return String(id) === memberId; });
                    } else {
                        return court.players.some(function (p) { return String(p.memberId) === memberId; });
                    }
                });
            }
            if (isInCourt) { blocked++; return; }
            $(this).prop('checked', false);
        });
        if (blocked > 0) {
            alert('수동 매칭 코트에 배정된 ' + blocked + '명은 해제되지 않았습니다.');
        }
        refreshAttendingState();
    });

    /* 이름 검색 (실시간 필터) */
    $('#attendSearchInput').on('input', function () {
        const keyword = String($(this).val()).trim().toLowerCase();
        let visible = 0;
        $('.attending-col').each(function () {
            const name = String($(this).data('name') || '').toLowerCase();
            const match = !keyword || name.indexOf(keyword) !== -1;
            $(this).toggle(match);
            if (match) visible++;
        });
        $('#attendingEmpty').toggle(visible === 0);
    });

    /* 검색어 지우기 버튼 */
    $('#btnAttendSearchClear').on('click', function () {
        $('#attendSearchInput').val('').trigger('input');
    });

    /* 페이지 진입 시 sessionStorage에서 복원 */
    (function restoreAttending() {
        try {
            const raw = sessionStorage.getItem(ATTEND_KEY);
            if (!raw) return;
            const ids = JSON.parse(raw);
            if (!Array.isArray(ids)) return;
            ids.forEach(function (id) {
                $('#attend-' + id).prop('checked', true);
            });
        } catch (e) { /* 무시 */ }
        refreshAttendingState();
    })();

    /* ─────────────────────────────────────────
   멤버 관리 탭 - 이름 검색 기능
   ───────────────────────────────────────── */
    $(function () {
        const $searchInput = $('#memberSearch');
        const $clearBtn    = $('#btnMemberSearchClear');
        const $memberRows  = $('#memberTableBody tr[data-name]');
        const $countSpan   = $('#memberCount');
        const $tbody       = $('#memberTableBody');
        const totalCount   = $memberRows.length;

        // 검색 결과 없을 때 표시할 행 (한 번만 만들어서 재사용)
        const $noResultRow = $(
            '<tr class="member-no-result" style="display:none;">' +
            '<td colspan="5">' +
            '<i class="fa-solid fa-magnifying-glass me-1"></i>' +
            '검색 결과가 없습니다.' +
            '</td>' +
            '</tr>'
        );
        $tbody.append($noResultRow);

        function filterMembers() {
            const keyword = $searchInput.val().trim().toLowerCase();

            // 검색어 없으면 전체 표시
            if (!keyword) {
                $memberRows.show();
                $noResultRow.hide();
                $countSpan.text(totalCount);
                return;
            }

            let visibleCount = 0;
            $memberRows.each(function () {
                const name = String($(this).data('name') || '').toLowerCase();
                const match = name.includes(keyword);
                $(this).toggle(match);
                if (match) visibleCount++;
            });

            $countSpan.text(visibleCount);
            $noResultRow.toggle(visibleCount === 0);
        }

        // 실시간 필터링
        $searchInput.on('input', filterMembers);

        // X 버튼 → 검색어 지우기 + 포커스 유지
        $clearBtn.on('click', function () {
            $searchInput.val('').trigger('input').focus();
        });

        // ESC 키로도 지우기 (선택 사항이지만 UX 좋음)
        $searchInput.on('keydown', function (e) {
            if (e.key === 'Escape') {
                $(this).val('').trigger('input');
            }
        });
    });

});
