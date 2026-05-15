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
                    updateSelectedCount();
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

    /* 참여 멤버 선택 카운트 */
    function updateSelectedCount() {
        const count = $('.participant-checkbox:checked').length;
        $('#selectedMemberCount').text(count);
    }
    $(document).on('change', '.participant-checkbox', updateSelectedCount);

    /* 전체 선택 / 해제 */
    $('#btnSelectAll').on('click', function () {
        $('.participant-checkbox').prop('checked', true);
        updateSelectedCount();
    });
    $('#btnDeselectAll').on('click', function () {
        $('.participant-checkbox').prop('checked', false);
        updateSelectedCount();
    });

    /* 매칭 생성 / 다시 매칭 */
    $('#btnGenerateMatch').on('click', generateMatch);
    $('#btnReshuffle').on('click', generateMatch);

    function generateMatch() {
        const participants = [];
        $('.participant-checkbox:checked').each(function () {
            participants.push({
                memberId: $(this).val(),
                name:     $(this).data('name'),
                gender:   $(this).data('gender'),
                level:    $(this).data('level')
            });
        });

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

    /* 초기화 */
    updateSelectedCount();


    /* ═════════════════════════════════════════
       ★ 수동 매칭 ★
       ═════════════════════════════════════════ */

    // 코트 상태 머신: 코트 인덱스 → { state, type, selecting:{a:[id,id],b:[id,id]}, players:[...], winner:'A'|'B'|null }
    let manualCourts = [];

    /* 코트 생성 버튼 */
    $('#btnBuildManualCourts').on('click', function () {
        const type = $('#manualMatchType').val();
        const count = parseInt($('#manualCourtCount').val()) || 1;

        if (count < 1 || count > 20) {
            alert('코트 수는 1~20 사이여야 합니다.');
            return;
        }

        // 기존 진행 중 코트가 있으면 경고
        const inProgress = manualCourts.some(function (c) { return c.state !== 'selecting'; });
        if (inProgress) {
            if (!confirm('진행 중이거나 완료된 코트가 있습니다. 코트를 재생성하면 모두 초기화됩니다. 계속할까요?')) {
                return;
            }
        }

        // 상태 초기화
        const teamSize = (type === 'SINGLES') ? 1 : 2;
        manualCourts = [];
        for (let i = 0; i < count; i++) {
            manualCourts.push({
                courtNo: i + 1,
                state: 'selecting',           // selecting | playing | done
                type: type,
                teamSize: teamSize,
                selecting: { a: new Array(teamSize).fill(null), b: new Array(teamSize).fill(null) },
                players: [],                  // playing 단계에서 사용 (각 player에 team 속성 포함)
                winner: null
            });
        }

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

    /* 경기 진행/완료 단계 본문 */
    function buildPlayingBody(court, idx) {
        const teamA = court.players.filter(function (p) { return p.team === 'A'; });
        const teamB = court.players.filter(function (p) { return p.team === 'B'; });

        let html = '';
        html += '<div class="team-box team-a"><div class="team-label">A팀</div><div>' +
            teamA.map(playingPlayerTag).join('') + '</div></div>';
        html += '<div class="vs-divider">VS</div>';
        html += '<div class="team-box team-b"><div class="team-label">B팀</div><div>' +
            teamB.map(playingPlayerTag).join('') + '</div></div>';

        // 승리팀 선택 버튼 / 되돌리기
        const aSel = court.winner === 'A' ? ' selected' : '';
        const bSel = court.winner === 'B' ? ' selected' : '';
        html += '<div class="manual-court-actions">';
        html += '  <button type="button" class="btn btn-win-a' + aSel + '" data-court-idx="' + idx + '" data-win="A">A팀 승</button>';
        html += '  <button type="button" class="btn btn-win-b' + bSel + '" data-court-idx="' + idx + '" data-win="B">B팀 승</button>';
        html += '  <button type="button" class="btn btn-court-undo" data-court-idx="' + idx + '">' +
            '    <i class="fa-solid fa-rotate-left"></i>' +
            '  </button>';
        html += '</div>';

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

            // 옵션 다시 그리기
            $sel.empty().append('<option value="">:: 멤버 선택 ::</option>');
            (window.clubMembers || []).forEach(function (m) {
                const isUsedElsewhere = usedIds.has(String(m.memberId)) && String(m.memberId) !== currentIdStr;
                const sel = String(m.memberId) === currentIdStr ? ' selected' : '';
                const dis = isUsedElsewhere ? ' disabled' : '';
                $sel.append('<option value="' + m.memberId + '"' + sel + dis + '>' +
                    m.name + ' (' + (m.gender === 'M' ? '남' : '여') + ' / ' + (m.addr3 || '-') + ')' +
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
        const allMembers = window.clubMembers || [];

        // 매칭 중/예정인 멤버 집합
        const usedIds = new Set();
        manualCourts.forEach(function (court) {
            if (court.state === 'selecting') {
                court.selecting.a.forEach(function (id) { if (id) usedIds.add(String(id)); });
                court.selecting.b.forEach(function (id) { if (id) usedIds.add(String(id)); });
            } else {
                court.players.forEach(function (p) { usedIds.add(String(p.memberId)); });
            }
        });

        const waiting = allMembers.filter(function (m) { return !usedIds.has(String(m.memberId)); });

        $('#manualWaitingNum').text(waiting.length);
        $('#manualWaitingCount').text(waiting.length);

        const $list = $('#manualWaitingList').empty();
        if (waiting.length === 0) {
            $list.html('<span class="text-muted small">대기 중인 멤버가 없습니다.</span>');
            return;
        }
        waiting.forEach(function (m) {
            const genderText = m.gender === 'M' ? '남' : '여';
            $list.append('<span class="badge-waiting">' +
                m.name + ' <small class="text-muted">(' + genderText + ')</small>' +
                '</span>');
        });
    }

    /* 초기 대기 멤버 표시 */
    renderManualWaiting();

});
