/**
 * club_manage.js
 * 모임 관리 페이지 (멤버 관리 탭 + 모임 정보 수정 탭)
 */

$(function () {

    /* ─────────────────────────────────────────
       1. 출생 연도 셀렉트 초기화
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
       2. 수정 폼 초기화 버튼
       ───────────────────────────────────────── */
    $('#btnResetForm').on('click', function () {
        if (confirm('변경 내용을 모두 초기화하시겠습니까?')) {
            document.getElementById('clubEditForm').reset();
            // 출생연도는 reset()으로 안 돌아오므로 직접 복원
            $birthYear.val(selectedYear);
        }
    });

    /* ─────────────────────────────────────────
       3. 수정 폼 제출 확인
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
        alert('수정이 완료되었습니다.');
    });

    /* ─────────────────────────────────────────
       4. 멤버 제외 (kick)
       ───────────────────────────────────────── */
    window.kickMember = function (memberId, userName) {
        if (!confirm('"' + userName + '" 님을 모임에서 제외하시겠습니까?')) return;

        $.ajax({
            url: contextPath + '/club/kickMember',
            type: 'POST',
            data: { memberId: memberId },
            success: function (res) {
                if (res.result === 'success') {
                    // 해당 행 제거
                    $('button[onclick*="' + memberId + '"]').closest('tr').fadeOut(300, function () {
                        $(this).remove();
                        // 멤버 수 갱신
                        const count = $('#memberTableBody tr').length;
                        $('#memberCount').text(count);
                        if (count === 0) {
                            $('#memberTableBody').html(
                                '<tr><td colspan="5" class="text-center text-muted py-4">등록된 멤버가 없습니다.</td></tr>'
                            );
                        }
                    });
                } else {
                    alert('제외 처리 중 오류가 발생했습니다.');
                }
            },
            error: function () {
                alert('서버 통신 오류가 발생했습니다.');
            }
        });
    };

    /* ─────────────────────────────────────────
       5. 멤버 검색
       ───────────────────────────────────────── */
    $('#btnSearchMember').on('click', searchMember);
    $('#searchMemberInput').on('keydown', function (e) {
        if (e.key === 'Enter') searchMember();
    });

    function searchMember() {
        const keyword = $('#searchMemberInput').val().trim();
        if (!keyword) {
            alert('검색어를 입력하세요.');
            return;
        }

        $.ajax({
            url: contextPath + '/club/searchUser',
            type: 'GET',
            data: { keyword: keyword },
            success: function (res) {
                renderSearchResult(res);
            },
            error: function () {
                alert('검색 중 오류가 발생했습니다.');
            }
        });
    }

    function renderSearchResult(users) {
        const $result = $('#searchResult');
        $result.empty();

        if (!users || users.length === 0) {
            $result.html('<p class="text-muted text-center py-2">검색 결과가 없습니다.</p>');
            return;
        }

        users.forEach(function (u) {
            const item = $('<div class="search-user-item">' +
                '<span><strong>' + u.userName + '</strong> (' + u.userId + ')</span>' +
                '<button class="btn-add-confirm" data-userid="' + u.userId + '">추가</button>' +
                '</div>');
            $result.append(item);
        });

        // 추가 버튼 이벤트
        $result.find('.btn-add-confirm').on('click', function () {
            const userId = $(this).data('userid');
            addMember(userId, $(this));
        });
    }

    /* ─────────────────────────────────────────
       6. 멤버 추가
       ───────────────────────────────────────── */
    function addMember(userId, $btn) {
        const clubId = $('input[name="clubId"]').val() ||
            new URLSearchParams(location.search).get('clubId');

        $.ajax({
            url: contextPath + '/club/addMember',
            type: 'POST',
            data: { userId: userId, clubId: clubId },
            success: function (res) {
                if (res.result === 'success') {
                    alert('멤버가 추가되었습니다.');
                    location.reload();
                } else if (res.result === 'duplicate') {
                    alert('이미 등록된 멤버입니다.');
                } else {
                    alert('추가 중 오류가 발생했습니다.');
                }
            },
            error: function () {
                alert('서버 통신 오류가 발생했습니다.');
            }
        });
    }

});
