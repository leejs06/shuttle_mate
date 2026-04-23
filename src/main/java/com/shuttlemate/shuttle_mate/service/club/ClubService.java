package com.shuttlemate.shuttle_mate.service.club;

import com.shuttlemate.shuttle_mate.model.ClubMemberDto;
import com.shuttlemate.shuttle_mate.model.ClubManageDto;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ClubService {

    @Autowired
    SqlSession sqlSessionTemplate;

    @Transactional
    public int createClubWithHost(ClubManageDto clubDto, ClubMemberDto hostMemberDto) {
        int result = sqlSessionTemplate.insert("club.insertClub", clubDto);

        if (result > 0) {
            hostMemberDto.setClubId(clubDto.getClubId());
            hostMemberDto.setUserRole("HOST");

            return sqlSessionTemplate.insert("club.insertClubMember", hostMemberDto);
        }
        return 0;
    }

    public List<ClubManageDto> getMyCreatedClubs(String userId) {
        return sqlSessionTemplate.selectList("club.selectMyClubs", userId);
    }
}
