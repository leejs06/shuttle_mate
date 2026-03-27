package com.shuttlemate.shuttle_mate.service.login;

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

    // 연령대 리스트 전체 조회
    public List<Object> selectUserAgeGroup(String groupCode) {
        return sqlSessionTemplate.selectList("join.selectUserAgeGroup", groupCode);
    }

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

}
