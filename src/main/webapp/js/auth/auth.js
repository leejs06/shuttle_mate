document.addEventListener('DOMContentLoaded', function() {
    const signupForm = document.getElementById('signupForm');

    if (signupForm) {
        signupForm.addEventListener('submit', function(e) {
            const password = document.getElementById('regPw').value;
            const userId = document.getElementById('regId').value;

            if (userId.length < 6) {
                alert('아이디는 6자 이상이어야 합니다.');
                e.preventDefault();
                return;
            }

            if (password.length < 8) {
                alert('비밀번호는 8자 이상이어야 합니다.');
                e.preventDefault();
                return;
            }
        });
    }
});