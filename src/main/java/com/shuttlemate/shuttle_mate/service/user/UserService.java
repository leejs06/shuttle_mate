package com.shuttlemate.shuttle_mate.service.user;

import com.shuttlemate.shuttle_mate.model.UserDto;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserService {

    @Autowired
    SqlSession sqlSessionTemplate;

    public UserDto getUserProfile(String userId) {
        return sqlSessionTemplate.selectOne("user.selectUserProfile", userId);
    }


}
