/**
 * 내 모임 목록 페이지 관련 스크립트
 */
document.addEventListener('DOMContentLoaded', function() {
    console.log("My Clubs page loaded.");

    // 관리 버튼 클릭 시 로딩 애니메이션 등 추가 기능이 필요하면 작성
    const manageButtons = document.querySelectorAll('.manage-btn');

    manageButtons.forEach(button => {
        button.addEventListener('click', function() {
            // 필요 시 클릭 시 로딩 상태 표시 등 처리
            // this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> 이동 중...';
        });
    });
});