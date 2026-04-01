package com.shuttlemate.shuttle_mate.service.login;

import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.model.User;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@Transactional
public class LoginService {

    @Autowired
    SqlSession sqlSessionTemplate;

    // 전국 급수 리스트 전체 조회
    public List<Object> selectAddr1Level(String groupCode) {
        return sqlSessionTemplate.selectList("join.selectAddr1Level", groupCode);
    }

    // 시 급수 리스트 전체 조회
    public List<Object> selectAddr2Level(String groupCode) {
        return sqlSessionTemplate.selectList("join.selectAddr2Level", groupCode);
    }

    // 구 급수 리스트 전체 조회
    public List<Object> selectAddr3Level(String groupCode) {
        return sqlSessionTemplate.selectList("join.selectAddr3Level", groupCode);
    }

    // 회원가입 처리
    public int join(UserDto userDto) {
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
        return sqlSessionTemplate.insert("join.insertUser", user);
    }

}
