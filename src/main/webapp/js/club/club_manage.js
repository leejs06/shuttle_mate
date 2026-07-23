/**
 * club_manage.js
 * 모임 관리 페이지 (경기 매칭 + 회원 관리 + 모임 정보 수정 탭)
 */

$(function () {

    /* ─────────────────────────────────────────
       0. 참석 회원 선택 박스 접기/펼치기 아이콘 토글
          (기본은 펼침, 코트 추가 시 자동으로 접힘 - 아래 코트 추가 핸들러 참고)
       ───────────────────────────────────────── */
    const $attendToggleIcon = $('#btnAttendToggle').find('i');
    $('#attendingCollapse').on('show.bs.collapse', function () {
        $attendToggleIcon.removeClass('fa-chevron-down').addClass('fa-chevron-up');
    }).on('hide.bs.collapse', function () {
        $attendToggleIcon.removeClass('fa-chevron-up').addClass('fa-chevron-down');
    });

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
       1-2. 회원 추가/수정 모달의 생년 셀렉트 초기화
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
       3-2. 모임 삭제 (모임 정보 수정 탭, 위험 구역)
       ───────────────────────────────────────── */
    $('#btnDeleteClub').on('click', function () {
        if (!confirm('정말로 이 모임을 삭제하시겠습니까?\n회원 정보와 매칭 기록이 모두 함께 삭제되며 복구할 수 없습니다.')) return;

        const $btn = $(this);
        $btn.prop('disabled', true);

        $.ajax({
            url: contextPath + '/club/delete',
            type: 'POST',
            data: { clubId: clubId },
            success: function (res) {
                alert(res.message);
                if (res.result === 'success') {
                    location.href = contextPath + '/club/myClubs';
                } else {
                    $btn.prop('disabled', false);
                }
            },
            error: function () {
                alert('서버 통신 오류가 발생했습니다.');
                $btn.prop('disabled', false);
            }
        });
    });

    /* ─────────────────────────────────────────
       4. 회원 제외 (kick)
       ───────────────────────────────────────── */
    window.kickMember = function (memberSeq, userName) {
        if (!confirm('"' + userName + '" 님을 모임에서 제외하시겠습니까?')) return;

        $.ajax({
            url: contextPath + '/club/kickMember',
            type: 'POST',
            data: { memberId: memberSeq, clubId: clubId },
            success: function (res) {
                if (res.result === 'success') {
                    const $btn = $('button[onclick*="' + memberSeq + '"]');

                    // 정회원 테이블 행 제거 (회원 관리 탭) - 제거 후 검색/페이지네이션 다시 계산
                    const $row = $btn.closest('tr');
                    if ($row.length) {
                        $row.fadeOut(300, function () {
                            $(this).remove();
                            if (typeof window.refreshMemberList === 'function') {
                                window.refreshMemberList();
                            }
                        });
                    }

                    // 오늘의 게스트 배지 제거 (회원 관리 탭)
                    const $guestBadge = $btn.closest('.badge-guest');
                    if ($guestBadge.length) {
                        $guestBadge.fadeOut(200, function () { $(this).remove(); });
                    }

                    // 참석 회원 선택 카드 제거 (경기 매칭 탭, id 접두사는 attend- 입니다)
                    $('#attend-' + memberSeq).closest('.col-6, .col-md-4, .col-lg-3').remove();
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
       5. 회원 직접 추가 / 수정 (공용 모달)
       ─────────────────────────────────────────
       - "회원 직접 추가" 버튼 → mode = 'add'
       - 회원 행의 "수정" 버튼   → mode = 'edit'
       ═════════════════════════════════════════ */
    const $addForm = $('#addMemberForm');

    // 모달 열릴 때 폼 초기화 + 모드별 헤더/버튼 텍스트 설정
    $('#addMemberModal').on('show.bs.modal', function () {
        $addForm[0].reset();
        $('#editMemberSeq').val('');
        $addForm.find('.is-invalid').removeClass('is-invalid');
        $addForm.find('.form-error-msg').removeClass('show').remove();

        // openEditMemberModal / openGuestAddModal 에서 mode를 미리 'edit'/'guest'로 세팅했다면 그대로 유지,
        // 아니면 기본값 'add'로 초기화
        if ($addForm.data('mode') !== 'edit' && $addForm.data('mode') !== 'guest') {
            $addForm.data('mode', 'add');
            $('#memberModalTitleText').text('회원 직접 추가');
            $('#memberModalSubmitText').text('회원 추가');
            $('#memberModalSubmitIcon').removeClass().addClass('fa-solid fa-plus me-1');
            $('#memberModalDescription').html(
                '<i class="fa-solid fa-circle-info me-1"></i>' +
                '모임 내에서만 사용되는 회원 정보를 직접 입력합니다.'
            );
            $('#newMemberName').attr('placeholder', '회원 이름을 입력하세요');
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
        $('#memberModalTitleText').text('회원 정보 수정');
        $('#memberModalSubmitText').text('수정 저장');
        $('#memberModalSubmitIcon').removeClass().addClass('fa-solid fa-floppy-disk me-1');
        $('#memberModalDescription').html(
            '<i class="fa-solid fa-pen-to-square me-1"></i>' +
            '<strong>' + $btn.data('user-name') + '</strong> 님의 정보를 수정합니다.'
        );
        $('#newMemberName').attr('placeholder', '회원 이름을 입력하세요');

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

    /**
     * "게스트 추가" 버튼 클릭 → 모달을 게스트 모드로 열기
     * 입력 항목은 회원 직접 추가와 동일, 저장 대상 API/문구만 다름
     */
    window.openGuestAddModal = function () {
        $addForm.data('mode', 'guest');

        $('#memberModalTitleText').text('게스트 추가');
        $('#memberModalSubmitText').text('게스트 추가');
        $('#memberModalSubmitIcon').removeClass().addClass('fa-solid fa-user-plus me-1');
        $('#memberModalDescription').html(
            '<i class="fa-solid fa-circle-info me-1"></i>' +
            '오늘 하루만 함께 운동하는 지인의 정보를 입력합니다. (모임 정회원으로는 등록되지 않습니다)'
        );
        $('#newMemberName').attr('placeholder', '게스트 이름을 입력하세요');

        const modalEl = document.getElementById('addMemberModal');
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    };

    // 폼 제출 (추가/수정/게스트 공용)
    $addForm.on('submit', function (e) {
        e.preventDefault();

        const modeRaw = $addForm.data('mode');
        const mode = (modeRaw === 'edit' || modeRaw === 'guest') ? modeRaw : 'add';

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
            : (mode === 'guest')
                ? contextPath + '/club/addGuest'
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
            : mode === 'guest'
                ? '<i class="fa-solid fa-user-plus me-1"></i><span id="memberModalSubmitText">게스트 추가</span>'
                : '<i class="fa-solid fa-plus me-1"></i><span id="memberModalSubmitText">회원 추가</span>';

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
                        : mode === 'guest'
                            ? '"' + userName + '" 님이 게스트로 추가되었습니다.'
                            : '"' + userName + '" 님이 회원으로 추가되었습니다.');
                    const modalEl = document.getElementById('addMemberModal');
                    bootstrap.Modal.getInstance(modalEl).hide();
                    location.reload();
                } else if (res.result === 'duplicate') {
                    alert('이미 같은 이름의 회원이 등록되어 있습니다.');
                    $submitBtn.prop('disabled', false).html(originalBtnHtml);
                } else if (res.result === 'maxExceeded') {
                    alert('최대 관리 인원을 초과했습니다. 모임 정보 수정 탭에서 최대 인원을 늘려주세요.');
                    $submitBtn.prop('disabled', false).html(originalBtnHtml);
                } else {
                    alert(res.message || '처리 중 오류가 발생했습니다.');
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
        // 참석 풀에서 가져오기 (자동 매칭은 참석 회원 전체를 풀로 사용)
        const participants = getAttendingMembers();

        const matchType = $('#matchType').val();
        const criteria = $('#matchCriteria').val();
        const courtCount = parseInt($('#courtCount').val()) || 1;

        const playersPerCourt = (matchType === 'SINGLES') ? 2 : 4;
        const requiredMin = playersPerCourt;

        if (participants.length < requiredMin) {
            alert('선택된 회원이 ' + requiredMin + '명 이상 필요합니다. (현재 ' + participants.length + '명)');
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

// 회원별 오늘 경기 통계: memberId → { count: 경기수, lastPlayedAt: timestamp }
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

// 회원의 오늘 경기 수
    function getGameCount(memberId) {
        const s = memberStats[String(memberId)];
        return s ? s.count : 0;
    }

// 회원의 마지막 경기 시각 (없으면 0 = 가장 오래 쉰 것으로 간주)
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

        // 참석 회원 풀 검증: 최소 필요 인원
        const attending = getAttendingMembers();
        const need = teamSize * 2;
        if (attending.length < need) {
            alert(type === 'SINGLES'
                ? '단식은 최소 2명의 참석 회원이 필요합니다. (현재 ' + attending.length + '명)'
                : '복식은 최소 4명의 참석 회원이 필요합니다. (현재 ' + attending.length + '명)');
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

        // 코트가 생기면 참석 회원 선택은 다 끝난 셈이므로, 화면 공간 확보를 위해 자동으로 접음
        const attendingCollapseEl = document.getElementById('attendingCollapse');
        if (attendingCollapseEl && window.bootstrap) {
            bootstrap.Collapse.getOrCreateInstance(attendingCollapseEl).hide();
        }
    });

    /* 코트 카드 렌더링 (전체) */
    function renderManualCourts() {
        const $area = $('#manualCourtArea').empty();
        if (manualCourts.length === 0) {
            $area.html('<div class="col-12 text-center text-muted py-4">코트를 먼저 생성하세요.</div>');
            initManualDragDrop();
            return;
        }

        manualCourts.forEach(function (court, idx) {
            // 드래그앤드롭이 추가되면서 대기열/다른 코트를 같이 보면서 옮겨야 편하므로
            // 모바일 2개 / 태블릿 이상 3개씩 한 줄에 보이도록 폭을 좁힘
            const $col = $('<div class="col-6 col-sm-4 col-md-4"></div>');
            $col.append(buildCourtCardHtml(court, idx));
            $area.append($col);
        });

        // 렌더링으로 DOM이 새로 생성됐으므로 드래그앤드롭 재초기화
        initManualDragDrop();
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
            '    <div class="court-header-actions">' +
            '      <span class="manual-court-state ' + stateCls + '">' + stateLabel + '</span>' +
            '      <button type="button" class="btn-court-delete" data-court-idx="' + idx + '" title="코트 삭제">' +
            '        <i class="fa-solid fa-trash-can"></i>' +
            '      </button>' +
            '    </div>' +
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

    /* 슬롯 1개 렌더링 - 비어있으면 드롭 안내 문구, 채워져 있으면 드래그 가능한 선수 카드 */
    function slotHtml(idx, team, slotIdx, selectedId) {
        const badgeCls = team === 'A' ? 'team-a' : 'team-b';
        const member = selectedId ? findAttendingMemberById(selectedId) : null;

        // 코트 카드가 한 줄에 2~3개씩 들어가서 슬롯 폭이 좁으므로,
        // 성별은 글자 배지 대신 작은 점(색상)으로만 표시해 이름 공간을 최대한 확보
        const inner = member
            ? '<div class="manual-drag-card" data-member-id="' + member.memberId + '" title="' + escapeHtml(member.name) + ' (' + (member.gender === 'M' ? '남성' : '여성') + ')">' +
              '  <span class="manual-drag-gender-dot ' + (member.gender === 'M' ? 'male' : 'female') + '"></span>' +
              '  <span class="manual-drag-name">' + escapeHtml(member.name) + '</span>' +
              '  <button type="button" class="manual-slot-clear" title="빼기">' +
              '    <i class="fa-solid fa-xmark"></i>' +
              '  </button>' +
              '</div>'
            : '<span class="manual-slot-placeholder">여기로 드래그</span>';

        return '<div class="manual-slot">' +
            '<span class="manual-slot-badge ' + badgeCls + '">' + (slotIdx + 1) + '</span>' +
            '<div class="manual-slot-drop" data-court-idx="' + idx + '" data-team="' + team + '" data-slot-idx="' + slotIdx + '">' +
            inner +
            '</div>' +
            '</div>';
    }

    /* 참석 회원 풀에서 memberId로 조회 */
    function findAttendingMemberById(memberId) {
        const list = getAttendingMembers();
        for (let i = 0; i < list.length; i++) {
            if (String(list[i].memberId) === String(memberId)) return list[i];
        }
        return null;
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

    /* ═════════════════════════════════════════
       ★ 수동 매칭 - 드래그앤드롭 (대기열 ↔ 대기 매칭 ↔ 코트 슬롯) ★
       - SortableJS 사용 (PC 마우스 + 모바일 터치 모두 지원)
       - 렌더링(innerHTML 재생성) 때마다 DOM이 통째로 바뀌므로
         매 렌더링 후 반드시 재초기화 필요
       ═════════════════════════════════════════ */
    let manualSortableInstances = [];

    /*
       대기 매칭(다음에 비는 코트에 한 번에 투입할 미리 선택 그룹)
       - 그룹마다 코트처럼 자리 4개(0~3)를 가짐 → 자리 하나하나가 독립된 드롭 대상이라
         대기 매칭 안에서든, 대기열이든, 코트 슬롯이든 회원을 자유롭게 개별 교체 가능
       - 자리 4개가 다 차면 그 그룹은 "완료" 상태가 되어 별도의 "세트 핸들" 칩이 생기고,
         그 칩을 통째로 빈 코트에 드래그하면 코트 A팀/B팀이 한 번에 채워짐
       - 마지막 그룹은 항상 비어있는 채로 유지돼서 새 회원을 계속 이어서 담을 수 있음
    */
    let pendingMatchGroups = [];
    const PENDING_GROUP_SIZE = 4;

    /* 완전히 빈 그룹은 정리하고, 마지막에는 항상 빈 그룹 1개가 있도록 보정 */
    function normalizePendingGroups() {
        // 완전히 빈 그룹은 정리 (마지막 빈 그룹은 아래에서 필요할 때만 다시 보장)
        pendingMatchGroups = pendingMatchGroups.filter(function (g) {
            return g.seats.some(function (s) { return s !== null; });
        });
        // 마지막 그룹이 없거나 "이미 4명이 꽉 찼을 때"만 다음 줄(새 빈 그룹)을 추가
        const last = pendingMatchGroups[pendingMatchGroups.length - 1];
        const lastIsFull = !!last && last.seats.every(function (s) { return s !== null; });
        if (!last || lastIsFull) {
            pendingMatchGroups.push({ seats: new Array(PENDING_GROUP_SIZE).fill(null) });
        }
    }

    function initManualDragDrop() {
        manualSortableInstances.forEach(function (s) { s.destroy(); });
        manualSortableInstances = [];

        if (typeof Sortable === 'undefined') return;

        const dragOptions = {
            group: 'manualMatchPlayers',
            animation: 150,
            ghostClass: 'manual-drag-ghost',
            // 슬롯 안의 "빼기" 버튼은 드래그 시작 대상에서 제외하고 클릭이 정상 동작하도록 함
            filter: '.manual-slot-clear',
            preventOnFilter: false,
            // 이미 다른 회원이 있는 자리 위로 드래그 중이면(=놓으면 서로 자리를 맞바꾸는 스왑) 파란색으로 강조 표시
            onMove: function (evt) {
                document.querySelectorAll('.manual-slot-drop-swap-target').forEach(function (el) {
                    el.classList.remove('manual-slot-drop-swap-target');
                });

                const $to = $(evt.to);
                if ($to.hasClass('manual-slot-drop')) {
                    const hasOtherOccupant = $to.find('.manual-drag-card').not(evt.dragged).length > 0;
                    if (hasOtherOccupant) {
                        $to.addClass('manual-slot-drop-swap-target');
                    }
                }
                return true;
            },
            onEnd: handleManualDragEnd
        };

        const waitingEl = document.getElementById('manualWaitingList');
        if (waitingEl) {
            manualSortableInstances.push(Sortable.create(waitingEl, dragOptions));
        }

        // 코트 슬롯 + 대기 매칭 자리(둘 다 .manual-slot-drop 클래스 공유)
        document.querySelectorAll('.manual-slot-drop').forEach(function (el) {
            manualSortableInstances.push(Sortable.create(el, dragOptions));
        });

        // 완성된 대기 매칭 세트의 "핸들" 칩 (통째로 코트에 드래그하는 용도)
        document.querySelectorAll('.pending-set-handle-drop').forEach(function (el) {
            manualSortableInstances.push(Sortable.create(el, dragOptions));
        });
    }

    /* 드롭된 컨테이너 종류 분류: 코트 슬롯 / 대기 매칭 자리 / 세트 핸들 / 대기열 */
    function classifyDropContainer($container) {
        if ($container.hasClass('pending-seat-drop')) {
            return {
                type: 'pendingSeat',
                groupIdx: parseInt($container.data('group-idx')),
                seatIdx: parseInt($container.data('seat-idx'))
            };
        }
        if ($container.hasClass('manual-slot-drop')) {
            return {
                type: 'slot',
                courtIdx: parseInt($container.data('court-idx')),
                team: $container.data('team'),
                slotIdx: parseInt($container.data('slot-idx'))
            };
        }
        if ($container.hasClass('pending-set-handle-drop')) {
            return { type: 'pendingHandle', groupIdx: parseInt($container.data('group-idx')) };
        }
        return { type: 'waiting' };
    }

    /* 코트 슬롯 / 대기 매칭 자리 처럼 "값을 하나 담는 자리" 인지 여부 */
    function isPositional(pos) {
        return pos.type === 'slot' || pos.type === 'pendingSeat';
    }

    function getPositionValue(pos) {
        if (pos.type === 'slot') {
            const court = manualCourts[pos.courtIdx];
            if (!court) return null;
            const arr = pos.team === 'A' ? court.selecting.a : court.selecting.b;
            return arr[pos.slotIdx];
        }
        if (pos.type === 'pendingSeat') {
            const group = pendingMatchGroups[pos.groupIdx];
            return group ? group.seats[pos.seatIdx] : null;
        }
        return null;
    }

    function setPositionValue(pos, value) {
        if (pos.type === 'slot') {
            const court = manualCourts[pos.courtIdx];
            if (!court) return;
            const arr = pos.team === 'A' ? court.selecting.a : court.selecting.b;
            arr[pos.slotIdx] = value;
        } else if (pos.type === 'pendingSeat') {
            const group = pendingMatchGroups[pos.groupIdx];
            if (group) group.seats[pos.seatIdx] = value;
        }
    }

    function samePosition(a, b) {
        if (!isPositional(a) || !isPositional(b) || a.type !== b.type) return false;
        if (a.type === 'slot') return a.courtIdx === b.courtIdx && a.team === b.team && a.slotIdx === b.slotIdx;
        return a.groupIdx === b.groupIdx && a.seatIdx === b.seatIdx;
    }

    /*
       드래그 종료 처리 - 대기열 / 대기 매칭 자리 / 코트 슬롯 사이의 이동을 전부 처리
       - 자리(슬롯/대기 매칭 자리) ↔ 자리: 이동, 이미 사람이 있으면 서로 자리를 맞바꿈(스왑) - 종류 안 가리고 자유롭게 교체
       - 자리 ↔ 대기열: 배정/해제
       - 완성된 세트의 "핸들" 칩을 드래그한 경우 → handlePendingSetDrop()에서 코트 전체를 한 번에 채움
    */
    function handleManualDragEnd(evt) {
        const $item = $(evt.item);

        if ($item.attr('data-pending-set') === 'true') {
            const groupIdx = parseInt($item.attr('data-group-idx'));
            handlePendingSetDrop(classifyDropContainer($(evt.to)), groupIdx);
            return;
        }

        const memberId = String($item.data('member-id') || '');
        if (!memberId) return;

        const from = classifyDropContainer($(evt.from));
        const to = classifyDropContainer($(evt.to));

        // 같은 자리에 다시 놓은 경우: 변화 없음
        if (samePosition(from, to)) {
            renderManualCourts();
            renderManualWaiting();
            return;
        }

        // 자리가 아닌 곳끼리(대기열 안에서의 재정렬 등): 상태 변화 없음
        if (!isPositional(from) && !isPositional(to)) {
            renderManualWaiting();
            return;
        }

        // 도착지 반영
        let displacedId = null;
        if (isPositional(to)) {
            displacedId = getPositionValue(to);
            setPositionValue(to, memberId);
        }

        // 출발지 정리
        if (isPositional(from)) {
            if (displacedId && String(displacedId) !== memberId) {
                setPositionValue(from, displacedId); // 자리↔자리 스왑 (슬롯/대기 매칭 종류 안 가림)
            } else {
                setPositionValue(from, null);
            }
        }

        renderManualCourts();
        renderManualWaiting();
    }

    /* 대기 매칭의 완성된 "세트 핸들" 칩을 코트 슬롯 위로 드래그했을 때 - 그 코트 전체(A팀/B팀)를 한 번에 배정 */
    function handlePendingSetDrop(to, groupIdx) {
        const group = pendingMatchGroups[groupIdx];
        if (!group) {
            renderManualWaiting();
            return;
        }

        if (to.type === 'slot') {
            const court = manualCourts[to.courtIdx];
            if (!court) {
                renderManualWaiting();
                return;
            }

            const groupIds = group.seats.filter(function (s) { return s !== null; });
            const needed = court.teamSize * 2;
            if (needed !== groupIds.length) {
                alert('이 코트는 ' + needed + '명이 필요한데, 선택한 매칭 세트는 ' + groupIds.length + '명이에요.');
                renderManualCourts();
                renderManualWaiting();
                return;
            }

            const half = groupIds.length / 2;
            court.selecting.a = groupIds.slice(0, half);
            court.selecting.b = groupIds.slice(half);
            group.seats = new Array(PENDING_GROUP_SIZE).fill(null);
        } else if (to.type === 'waiting') {
            // 세트를 통째로 대기열로 되돌림 - 그룹 비우기 (자연히 일반 대기열에 다시 나타남)
            group.seats = new Array(PENDING_GROUP_SIZE).fill(null);
        }
        // to.type이 pendingHandle 등이면 상태 변화 없이 재렌더링만

        renderManualCourts();
        renderManualWaiting();
    }

    /*
       대기 매칭 영역 렌더링
       - 그룹마다 자리 4개를 코트 슬롯과 동일한 방식(.manual-slot-drop)으로 그려서 개별 교체 가능하게 함
       - 자리 4개가 다 차면 "세트 핸들" 칩이 함께 표시되어 통째로 코트에 드래그 가능
    */
    function renderPendingMatch() {
        const $box = $('#pendingMatchDrop');
        if ($box.length === 0) return;

        normalizePendingGroups();
        $box.empty();

        const totalFilled = pendingMatchGroups.reduce(function (sum, g) {
            return sum + g.seats.filter(function (s) { return s !== null; }).length;
        }, 0);
        $('#pendingMatchCount').text(totalFilled);

        let hasReadySet = false;

        pendingMatchGroups.forEach(function (group, groupIdx) {
            const filledCount = group.seats.filter(function (s) { return s !== null; }).length;
            const isReady = filledCount === PENDING_GROUP_SIZE;
            if (isReady) hasReadySet = true;

            const $groupBox = $('<div class="pending-match-group' + (isReady ? ' is-ready' : '') + '"></div>');
            const label = isReady ? '매칭 세트 준비 완료' : '매칭 세트 (' + filledCount + '/' + PENDING_GROUP_SIZE + ')';
            $groupBox.append('<div class="pending-match-group-label">' + label + '</div>');

            if (isReady) {
                const names = group.seats.map(function (id) {
                    const m = findAttendingMemberById(id);
                    return m ? m.name : '?';
                });
                const $handleWrap = $('<div class="pending-set-handle-drop" data-group-idx="' + groupIdx + '"></div>');
                $handleWrap.append(
                    '<div class="manual-drag-card pending-match-set-card" data-pending-set="true" data-group-idx="' + groupIdx + '" title="드래그해서 빈 코트에 한 번에 배정">' +
                    '  <i class="fa-solid fa-up-down-left-right me-1"></i>' +
                    '  <span class="manual-drag-name">' + names.map(function (n) { return escapeHtml(n); }).join(' · ') + '</span>' +
                    '</div>'
                );
                $groupBox.append($handleWrap);
            }

            const $seatRow = $('<div class="pending-match-seat-row"></div>');
            group.seats.forEach(function (memberId, seatIdx) {
                const member = memberId ? findAttendingMemberById(memberId) : null;
                const inner = member
                    ? '<div class="manual-drag-card" data-member-id="' + member.memberId + '" title="' + escapeHtml(member.name) + ' (' + (member.gender === 'M' ? '남성' : '여성') + ')">' +
                      '  <span class="manual-drag-gender-dot ' + (member.gender === 'M' ? 'male' : 'female') + '"></span>' +
                      '  <span class="manual-drag-name">' + escapeHtml(member.name) + '</span>' +
                      '  <button type="button" class="manual-slot-clear" title="빼기">' +
                      '    <i class="fa-solid fa-xmark"></i>' +
                      '  </button>' +
                      '</div>'
                    : '<span class="manual-slot-placeholder">빈 자리</span>';
                $seatRow.append(
                    '<div class="manual-slot-drop pending-seat-drop" data-group-idx="' + groupIdx + '" data-seat-idx="' + seatIdx + '">' +
                    inner +
                    '</div>'
                );
            });
            $groupBox.append($seatRow);

            $box.append($groupBox);
        });

        $('#pendingMatchReadyHint').toggle(hasReadySet);

        initManualDragDrop();
    }

    /* 대기 매칭 비우기 버튼 - 모든 그룹의 회원들을 전부 대기열로 되돌림 */
    $(document).on('click', '#btnClearPendingMatch', function () {
        const anyFilled = pendingMatchGroups.some(function (g) {
            return g.seats.some(function (s) { return s !== null; });
        });
        if (!anyFilled) return;
        if (!confirm('대기 매칭을 모두 비우고 회원들을 대기열로 되돌릴까요?')) return;
        pendingMatchGroups = [];
        renderManualWaiting();
    });

    /* 자리의 "빼기" 버튼 - 클릭 한 번으로 대기열로 되돌리기 (드래그가 번거로운 경우 대비, 코트/대기 매칭 자리 공용) */
    $(document).on('click', '.manual-slot-clear', function (e) {
        e.stopPropagation();
        const pos = classifyDropContainer($(this).closest('.manual-slot-drop'));
        if (!isPositional(pos)) return;
        setPositionValue(pos, null);
        renderManualCourts();
        renderManualWaiting();
    });

    /* 코트 삭제 버튼 - 상태(선수 선택/진행 중/완료) 상관없이 코트 자체를 통째로 제거 */
    $(document).on('click', '.btn-court-delete', function () {
        const idx = parseInt($(this).data('court-idx'));
        const court = manualCourts[idx];
        if (!court) return;
        if (!confirm('코트 ' + court.courtNo + '을(를) 삭제하시겠습니까?\n배정되어 있던 회원은 모두 대기열로 돌아갑니다.')) return;

        manualCourts.splice(idx, 1);
        // 남은 코트들의 courtNo 재정렬
        manualCourts.forEach(function (c, i) { c.courtNo = i + 1; });

        renderManualCourts();
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

    /* 경기 종료 (결과 입력 완료 → 코트 카드 제거 + 회원 통계 갱신 + 대기열 복귀) */
    $(document).on('click', '.btn-end-game', function () {
        const idx = parseInt($(this).data('court-idx'));
        const court = manualCourts[idx];
        if (!court) return;
        if (court.state !== 'done') {
            alert('승리팀을 먼저 선택해주세요.');
            return;
        }

        // 1) 통계 갱신 — 이 경기에 참여한 모든 회원
        const memberIds = court.players.map(function (p) { return p.memberId; });
        recordGameForMembers(memberIds);

        // 2) 경기 결과 서버 저장 (승리팀 +3점 / 패배팀 +1점 - 메인 페이지 순위표 집계용)
        //    화면 흐름을 막지 않도록 응답을 기다리지 않고 백그라운드로 저장, 실패 시에만 안내
        saveManualMatchResult(court);

        // 3) 코트 제거
        manualCourts.splice(idx, 1);

        // 4) 남은 코트들의 courtNo 재정렬
        manualCourts.forEach(function (c, i) { c.courtNo = i + 1; });

        // 5) 화면 갱신
        renderManualCourts();
        renderManualWaiting();
    });

    /* 수동 매칭 경기 결과 저장 (기존 /club/saveMatch 재사용, 단일 코트 + winnerSide 포함) */
    function saveManualMatchResult(court) {
        const teamAIds = court.players
            .filter(function (p) { return p.team === 'A'; })
            .map(function (p) { return p.memberId; });
        const teamBIds = court.players
            .filter(function (p) { return p.team === 'B'; })
            .map(function (p) { return p.memberId; });

        const payload = {
            clubId: clubId,
            matchType: court.type,
            criteria: 'MANUAL',
            courtCount: 1,
            courts: [{
                courtNo: 1,
                teamAIds: teamAIds,
                teamBIds: teamBIds,
                winnerSide: court.winner
            }],
            waitingIds: []
        };

        $.ajax({
            url: contextPath + '/club/saveMatch',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(payload),
            success: function (res) {
                if (res.result !== 'success') {
                    alert('경기 결과 저장 중 오류가 발생했습니다. (순위표에는 반영되지 않았습니다)');
                }
            },
            error: function () {
                alert('경기 결과 저장 중 서버 통신 오류가 발생했습니다. (순위표에는 반영되지 않았습니다)');
            }
        });
    }

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
        // selecting 슬롯은 그대로 두어 다시 시작하면 같은 회원 유지 가능
        court.players = [];

        renderManualCourts();
        renderManualWaiting();
    });

    /* 대기 회원 영역 갱신 */
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
        // 대기 매칭 박스에 미리 담아둔 회원도 일반 대기열에서는 제외
        pendingMatchGroups.forEach(function (g) {
            g.seats.forEach(function (id) { if (id) usedIds.add(String(id)); });
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
            $list.html('<span class="text-muted small">대기 중인 회원이 없습니다.</span>');
        } else {
            waiting.forEach(function (m) {
                const genderText = m.gender === 'M' ? '남' : '여';
                const cnt = getGameCount(m.memberId);
                const cntBadge = cnt > 0
                    ? ' <span class="badge-game-count">오늘 ' + cnt + '경기</span>'
                    : ' <span class="badge-game-count zero">오늘 0</span>';

                $list.append(
                    '<div class="manual-drag-card manual-waiting-card" data-member-id="' + m.memberId + '">' +
                    '  <i class="fa-solid fa-grip-vertical manual-drag-handle-icon"></i>' +
                    '  <span class="manual-drag-name">' + escapeHtml(m.name) + '</span>' +
                    '  <small class="text-muted">(' + genderText + ')</small>' +
                    cntBadge +
                    '</div>'
                );
            });
        }

        // 대기 매칭 영역도 함께 갱신 (드래그앤드롭 재초기화는 그 안에서 마지막에 처리)
        renderPendingMatch();
    }

    /* 초기 대기 회원 표시 */
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
        // 수동 매칭에서 이미 코트/대기 매칭에 배정된 회원을 해제하려는 경우 차단
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
            const isInPendingMatch = typeof pendingMatchGroups !== 'undefined' &&
                pendingMatchGroups.some(function (g) { return g.seats.indexOf(memberId) !== -1; });
            if (isInCourt || isInPendingMatch) {
                alert('이 회원은 현재 수동 매칭 코트(또는 대기 매칭)에 배정되어 있습니다.\n먼저 제외해주세요.');
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

    /* 전체 해제 — 수동 매칭 코트/대기 매칭에 배정된 회원은 유지 */
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
            const isInPendingMatch = typeof pendingMatchGroups !== 'undefined' &&
                pendingMatchGroups.some(function (g) { return g.seats.indexOf(memberId) !== -1; });
            if (isInCourt || isInPendingMatch) { blocked++; return; }
            $(this).prop('checked', false);
        });
        if (blocked > 0) {
            alert('수동 매칭 코트/대기 매칭에 배정된 ' + blocked + '명은 해제되지 않았습니다.');
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
   회원 관리 탭 - 이름 검색 + 페이지네이션
   (회원이 수백 명이 되어도 화면엔 한 페이지 분량만 보이도록,
    서버 재요청 없이 이미 로드된 표를 클라이언트에서 나눠서 보여줌)
   ───────────────────────────────────────── */
    $(function () {
        const $searchInput = $('#memberSearch');
        const $clearBtn    = $('#btnMemberSearchClear');
        const $countSpan   = $('#memberCount');
        const $tbody       = $('#memberTableBody');

        const MEMBER_PAGE_SIZE = 20;
        let memberCurrentPage = 1;

        // 매번 새로 조회 (kickMember()로 행이 삭제되는 등 DOM이 바뀔 수 있어서 캐시하지 않음)
        function getMemberRows() {
            return $tbody.find('tr[data-name]');
        }

        const $paginationBar = $('#memberPaginationBar');
        const $pageIndicator = $('#memberPageIndicator');
        const $btnPrevPage   = $('#btnMemberPrevPage');
        const $btnNextPage   = $('#btnMemberNextPage');

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

        /* 검색어에 맞는 행들을 DOM 순서 그대로 배열로 반환 (아직 화면 표시 여부는 안 건드림) */
        function getMatchingRows() {
            const keyword = $searchInput.val().trim().toLowerCase();
            const rows = getMemberRows().toArray();
            if (!keyword) return rows;
            return rows.filter(function (el) {
                const name = String($(el).data('name') || '').toLowerCase();
                return name.includes(keyword);
            });
        }

        /* 검색 필터링 + 현재 페이지 분량만 표시 + 페이지네이션 바 갱신 */
        function filterMembers() {
            const matching = getMatchingRows();
            const totalPages = Math.max(1, Math.ceil(matching.length / MEMBER_PAGE_SIZE));

            // 검색/필터 결과가 바뀌어 현재 페이지가 범위를 벗어나면 마지막 페이지로 보정
            if (memberCurrentPage > totalPages) memberCurrentPage = totalPages;
            if (memberCurrentPage < 1) memberCurrentPage = 1;

            const startIdx = (memberCurrentPage - 1) * MEMBER_PAGE_SIZE;
            const pageRows = matching.slice(startIdx, startIdx + MEMBER_PAGE_SIZE);
            const pageRowSet = new Set(pageRows);

            // 전체 행 우선 숨기고, 이번 페이지에 해당하는 행만 표시
            getMemberRows().each(function () {
                $(this).toggle(pageRowSet.has(this));
            });

            $countSpan.text(matching.length);
            // "검색 결과 없음" 문구는 회원이 원래 있는데 검색어에 안 걸린 경우에만 표시
            // (회원이 아예 0명이면 서버가 렌더링한 "등록된 회원이 없습니다" 행만 보이면 됨)
            $noResultRow.toggle(matching.length === 0 && getMemberRows().length > 0);

            // 페이지네이션 바: 한 페이지 안에 다 들어가면 굳이 안 보여줌
            if (matching.length <= MEMBER_PAGE_SIZE) {
                $paginationBar.hide();
            } else {
                $paginationBar.show();
                $pageIndicator.text(memberCurrentPage + ' / ' + totalPages + '페이지');
                $btnPrevPage.prop('disabled', memberCurrentPage <= 1);
                $btnNextPage.prop('disabled', memberCurrentPage >= totalPages);
            }
        }

        // 검색어가 바뀌면 1페이지로 되돌아가서 다시 필터링
        $searchInput.on('input', function () {
            memberCurrentPage = 1;
            filterMembers();
        });

        $btnPrevPage.on('click', function () {
            memberCurrentPage -= 1;
            filterMembers();
        });

        $btnNextPage.on('click', function () {
            memberCurrentPage += 1;
            filterMembers();
        });

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

        // kickMember() 등 외부에서 회원 행을 지운 뒤 목록/페이지네이션을 다시 계산할 때 사용
        window.refreshMemberList = filterMembers;

        filterMembers();
    });

});
