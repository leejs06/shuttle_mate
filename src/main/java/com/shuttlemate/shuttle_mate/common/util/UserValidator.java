package com.shuttlemate.shuttle_mate.common.util;

import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

@Component
public class UserValidator {

    // 정규식 패턴: 영문/숫자 포함 6~20자
    private static final String ID_PATTERN = "^[a-zA-Z0-9]{6,20}$";

    // 비밀번호 패턴: 영문/숫자/특수문자 포함 8자 이상
    private static final String PW_PATTERN = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,20}$";

    /**
     * 백단에서 아이디 중복체크를 하면서, 유효성 검사도 함께 진행 - 2026.04.03
     * @param userId: userId 유효성 검사 진행
     * @return
     */
    public boolean isIdValidator(String userId) {
        if (userId == null || userId.trim().isEmpty()) return false;
        return Pattern.matches(ID_PATTERN, userId);
    }

    public String isPwValidator(String userPw) {
        // 비밀번호 유효성 검사
        if (!Pattern.matches(PW_PATTERN, userPw)) {
            return "비밀번호는 영문, 숫자, 특수문자를 포함하여 8~20자로 입력해주세요.";
        }
        return null;
    }

}
