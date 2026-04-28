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

    // 내 모임 목록 특정 유저가 생성한 모임 리스트 조회
    public List<ClubManageDto> getMyCreatedClubs(String userId) {
        return sqlSessionTemplate.selectList("club.selectMyClubs", userId);
    }

    // 모임 상세 조회 모임 관리 페이지 진입 시 기본 정보 조회
    public ClubManageDto selectClubDetail(int clubId) {
        return sqlSessionTemplate.selectOne("club.selectClubDetail", clubId);
    }

    // [멤버 목록 조회] 모임 내 등록된 모든 회원 리스트 (매칭용 데이터)
    public List<ClubMemberDto> selectClubMemberList(int clubId) {
        return sqlSessionTemplate.selectList("club.selectClubMemberList", clubId);
    }

    // [멤버 직접 추가] 운영자가 모임 내에 회원을 수동으로 등록
    @Transactional
    public int insertClubMember(ClubMemberDto memberDto) {
        memberDto.setStatus("Y");
        memberDto.setUserRole("MEMBER");

        return sqlSessionTemplate.insert("club.insertClubMember", memberDto);
    }

    // [모임 정보 수정] 모임명, 장소 등 변경
    public int updateClubInfo(ClubManageDto clubDto) {
        return sqlSessionTemplate.update("club.updateClubInfo", clubDto);
    }

    public List<ClubManageDto> selectMyOwnedClubs(String userId) {
        return sqlSessionTemplate.selectList("club.selectMyOwnedClubs", userId);
    }

}
