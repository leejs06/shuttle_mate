package com.shuttlemate.shuttle_mate.service.login;

import com.shuttlemate.shuttle_mate.common.util.CCrypto;
import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.model.User;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@Transactional
public class LoginService {

    @Autowired
    SqlSession sqlSessionTemplate;

    private final BCryptPasswordEncoder passwordEncoder;
    private final CCrypto crypto;

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

    public UserDto loginUser(UserDto userDto) {

        UserDto dbUser = sqlSessionTemplate.selectOne("login.selectUserById", userDto.getUserId());

        if (dbUser != null) {
            if (passwordEncoder.matches(userDto.getUserPw(), dbUser.getUserPw())) {
                dbUser.setUserPw(null);
                return dbUser;
            }
        }

        return null;
    }

}
