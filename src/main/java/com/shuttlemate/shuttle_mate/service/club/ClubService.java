package com.shuttlemate.shuttle_mate.service.club;

import com.shuttlemate.shuttle_mate.model.ClubMemberDto;
import com.shuttlemate.shuttle_mate.model.ClubManageDto;
import com.shuttlemate.shuttle_mate.model.UserDto;
import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("clubService")
@RequiredArgsConstructor
public class ClubService {

    private final SqlSessionTemplate sqlSession;

    private static final String NS = "club.";

    /* ─────────────────────────────────────────
       모임 생성 (기존)
    ───────────────────────────────────────── */
    @Transactional
    public int createClubWithHost(ClubManageDto clubDto, ClubMemberDto memberDto) {
        int result = sqlSession.insert(NS + "insertClub", clubDto);
        memberDto.setClubId(clubDto.getClubId());
        memberDto.setUserRole("HOST");
        memberDto.setStatus("Y");
        sqlSession.insert(NS + "insertClubMember", memberDto);
        return result;
    }

    /* ─────────────────────────────────────────
       모임 단건 조회
    ───────────────────────────────────────── */
    public ClubManageDto selectClubById(int clubId) {
        return sqlSession.selectOne(NS + "selectClubById", clubId);
    }

    /* ─────────────────────────────────────────
       모임 기본 정보 수정 (신규)
    ───────────────────────────────────────── */
    @Transactional
    public void updateClub(ClubManageDto clubDto) {
        sqlSession.update(NS + "updateClub", clubDto);
    }

    /* ─────────────────────────────────────────
       관리자 프로필 단건 조회 (신규)
    ───────────────────────────────────────── */
    public ClubMemberDto selectAdminMember(int clubId, String userId) {
        Map<String, Object> param = new HashMap<>();
        param.put("clubId", clubId);
        param.put("userId", userId);
        return sqlSession.selectOne(NS + "selectAdminMember", param);
    }

    /* ─────────────────────────────────────────
       관리자 프로필 수정 (신규)
    ───────────────────────────────────────── */
    @Transactional
    public void updateAdminMember(ClubMemberDto memberDto) {
        sqlSession.update(NS + "updateAdminMember", memberDto);
    }

    /* ─────────────────────────────────────────
       멤버 목록 조회
    ───────────────────────────────────────── */
    public List<ClubMemberDto> selectClubMemberList(int clubId) {
        return sqlSession.selectList(NS + "selectClubMemberList", clubId);
    }

    /* ─────────────────────────────────────────
       멤버 수동 추가 (기존 폼 방식)
    ───────────────────────────────────────── */
    @Transactional
    public void insertClubMember(ClubMemberDto memberDto) {
        sqlSession.insert(NS + "insertClubMember", memberDto);
    }

    /* ─────────────────────────────────────────
       멤버 제외 (신규 AJAX)
    ───────────────────────────────────────── */
    @Transactional
    public void kickMember(int memberId) {
        sqlSession.delete(NS + "kickMember", memberId);
    }

    /* ─────────────────────────────────────────
       멤버 중복 체크 (신규 AJAX)
    ───────────────────────────────────────── */
    public boolean isMemberDuplicate(String userId, int clubId) {
        Map<String, Object> param = new HashMap<>();
        param.put("userId", userId);
        param.put("clubId", clubId);
        int count = sqlSession.selectOne(NS + "countMember", param);
        return count > 0;
    }

    /* ─────────────────────────────────────────
       멤버 추가 (신규 AJAX)
    ───────────────────────────────────────── */
    @Transactional
    public void addMember(String userId, int clubId) {
        Map<String, Object> param = new HashMap<>();
        param.put("userId", userId);
        param.put("clubId", clubId);
        sqlSession.insert(NS + "addMember", param);
    }

    /* ─────────────────────────────────────────
       유저 검색 (신규 AJAX)
    ───────────────────────────────────────── */
    public List<UserDto> searchUserByKeyword(String keyword) {
        return sqlSession.selectList(NS + "searchUserByKeyword", "%" + keyword + "%");
    }

    /* ─────────────────────────────────────────
       급수 목록 조회
    ───────────────────────────────────────── */
    public List<ClubMemberDto> getAddr1Level() {
        return sqlSession.selectList(NS + "selectAddr1Level");
    }

    public List<ClubMemberDto> getAddr2Level() {
        return sqlSession.selectList(NS + "selectAddr2Level");
    }

    public List<ClubMemberDto> getAddr3Level() {
        return sqlSession.selectList(NS + "selectAddr3Level");
    }

    /* ─────────────────────────────────────────
       내 모임 리스트 조회 (기존)
    ───────────────────────────────────────── */
    public List<ClubManageDto> selectMyOwnedClubs(String userId) {
        return sqlSession.selectList(NS + "selectMyOwnedClubs", userId);
    }
}