document.addEventListener('DOMContentLoaded', function() {
    // 출생 연도 Select 박스 자동 채우기
    const birthYearSelect = document.getElementById('birthYear');
    const currentYear = new Date().getFullYear();
    const startYear = 1900;

    for (let i = currentYear; i >= startYear; i--) {
        const option = document.createElement('option');
        option.value = i;
        option.textContent = i + '년';
        if (i === 2000) option.selected = true; // 기본값
        birthYearSelect.appendChild(option);
    }

    // 폼 제출 시 유효성 검사
    const createForm = document.getElementById('clubCreateForm');
    createForm.addEventListener('submit', function(e) {
        const clubTitle = document.getElementsByName('clubTitle')[0].value;
        const location = document.getElementsByName('location')[0].value;

        if (clubTitle.trim().length < 2) {
            alert('모임명을 2자 이상 입력해 주세요.');
            e.preventDefault();
            return;
        }

        if (location.trim().length === 0) {
            alert('활동 장소를 입력해 주세요.');
            e.preventDefault();
            return;
        }

        // 중복 클릭 방지
        const submitBtn = document.querySelector('.btn-submit');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> 처리 중...';
    });
});

$(document).ready(function() {
    // 1. 출생 연도 (1980~2010) 셀렉트 박스 채우기
    const birthYearSelect = $('#birthYear');
    const currentYear = new Date().getFullYear();

    for (let i = 2010; i >= 1980; i--) {
        birthYearSelect.append(`<option value="${i}">${i}년</option>`);
    }

    // 2. 폼 제출 시 유효성 검사 및 중복 방지
    $('#clubCreateForm').on('submit', function(e) {
        const clubTitle = $('input[name="clubTitle"]').val().trim();
        const location = $('input[name="location"]').val().trim();

        if (!clubTitle || !location) {
            alert("모임명과 활동 장소는 필수 입력 사항입니다.");
            e.preventDefault();
            return false;
        }

        // 중복 클릭 방지 (버튼 비활성화)
        const submitBtn = $(this).find('button[type="submit"]');
        submitBtn.attr('disabled', true).html('<i class="fa-solid fa-spinner fa-spin"></i> 생성 중...');

        return true;
    });
});