package com.shuttlemate.shuttle_mate.service.login;

import com.shuttlemate.shuttle_mate.common.util.CCrypto;
import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.model.User;
import com.shuttlemate.shuttle_mate.service.mail.EmailService;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;


@Service
@Transactional
public class LoginService {

    @Autowired
    SqlSession sqlSessionTemplate;

    private final BCryptPasswordEncoder passwordEncoder;
    private final CCrypto crypto;
    @Autowired
    private EmailService emailService;

    public LoginService(BCryptPasswordEncoder passwordEncoder, CCrypto crypto) {
        this.passwordEncoder = passwordEncoder;
        this.crypto = crypto;
    }


    // 전국 급수 리스트 전체 조회
    public List<Object> selectAddr1Level(String groupCode) {
        return sqlSessionTemplate.selectList("login.selectAddr1Level", groupCode);
    }

    // 시 급수 리스트 전체 조회
    public List<Object> selectAddr2Level(String groupCode) {
        return sqlSessionTemplate.selectList("login.selectAddr2Level", groupCode);
    }

    // 구 급수 리스트 전체 조회
    public List<Object> selectAddr3Level(String groupCode) {
        return sqlSessionTemplate.selectList("login.selectAddr3Level", groupCode);
    }

    // 사용자 아이디 중복 체크
    public boolean isDuplicate(String userId) {
        int cnt = sqlSessionTemplate.selectOne("login.userIdCheck", userId);
        return cnt > 0;
    }

    // 회원가입 처리
    public int joinUser(UserDto userDto) throws Exception {

        // 사용자 비밀번호 암호화(해시화)
        if (userDto.getUserPw() != null && !userDto.getUserPw().isEmpty()) {
            userDto.setUserPw(passwordEncoder.encode(userDto.getUserPw()));
        }

        // 휴대폰번호 AES256 암호화 처리
        if (userDto.getUserHp() != null && !userDto.getUserHp().isEmpty()) {
            userDto.setUserHp(crypto.encrypt(userDto.getUserHp()));
        }

        // 현재 상태가 빈값일때 '정상' 데이터 주입
        if (userDto.getStatus() == null || userDto.getStatus().isEmpty()) {
            userDto.setStatus("정상");
        }

        User user = new User(
                userDto.getUserId(),
                userDto.getUserPw(),
                userDto.getUserName(),
                userDto.getUserHp(),
                userDto.getUserEmail(),
                userDto.getUserBirth(),
                userDto.getUserGender(),
                userDto.getAddr1Level(),
                userDto.getAddr2Level(),
                userDto.getAddr3Level(),
                userDto.getStatus()
        );

        // 회원 정보 인서트
        return sqlSessionTemplate.insert("login.insertUser", user);
    }

    // 로그인 처리
    public UserDto loginUser(UserDto userDto) {

        UserDto dbUser = sqlSessionTemplate.selectOne("login.selectUserById", userDto.getUserId());

        if (dbUser != null) {
            if (passwordEncoder.matches(userDto.getUserPw(), dbUser.getUserPw())) {

                // 회원별 가장 최근에 로그인한 시간 업데이트 (LastLoginAt)
                sqlSessionTemplate.update("login.updateLastLogin", dbUser.getUserId());

                dbUser.setUserPw(null); // 보안을 위해 비밀번호 제거
                return dbUser;
            }
        }

        return null;
    }

    // 로그인 > 아이디 찾기
    public String findUserId(UserDto userDto) throws Exception {

        // 휴대폰 번호 암호화
        if (userDto.getUserHp() != null && !userDto.getUserHp().isEmpty()) {
            userDto.setUserHp(crypto.encrypt(userDto.getUserHp()));
        }

        // 아이디 찾기
        return sqlSessionTemplate.selectOne("login.selectFindUserId", userDto);

    }

    // 로그인 > 비밀번호 찾기 사용자 존재 여부 확인
    public int checkUserForPw(UserDto userDto) {
        return sqlSessionTemplate.selectOne("login.checkUserForPw", userDto);
    }

    // 인증 메일 발송 및 DB 저장
    public void sendAuthEmail(UserDto userDto) throws Exception {
        String authCode = String.format("%06d", new Random().nextInt(1000000));

        Map<String, Object> map = new HashMap<>();
        map.put("userId", userDto.getUserId());         // 아이디
        map.put("userEmail", userDto.getUserEmail());   // 이메일
        map.put("authCode", authCode);                  // 인증번호

        sqlSessionTemplate.insert("login.insertEmailAuth", map);

        emailService.sendAuthCode(userDto.getUserEmail(), authCode);
    }

    // 인증번호 검증
    public boolean verifyCode(String userId, String authCode) {
        Map<String, Object> map = new HashMap<>();
        map.put("userId", userId);
        map.put("authCode", authCode);

        int result = sqlSessionTemplate.selectOne("login.checkEmailAuth", map);

        if (result == 1) {
            sqlSessionTemplate.update("login.updateAuthStatus", map);
            return true;
        }
        return false;
    }

    // 비밀번호 변경
    public void resetPassword(@RequestBody UserDto userDto) {
        Map<String, Object> map = new HashMap<>();
        map.put("userId", userDto.getUserId());

        // 변경할 비밀번호 암호화 (해시화)
        if (userDto.getUserPw() != null && !userDto.getUserPw().isEmpty()) {
            userDto.setUserPw(passwordEncoder.encode(userDto.getUserPw()));
        }

        map.put("userPw", userDto.getUserPw());

        sqlSessionTemplate.update("login.updatePassword", map);
    }

}
