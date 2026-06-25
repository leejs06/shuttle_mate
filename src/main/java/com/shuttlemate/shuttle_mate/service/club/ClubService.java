package com.shuttlemate.shuttle_mate.service.club;

import com.shuttlemate.shuttle_mate.model.ClubMemberDto;
import com.shuttlemate.shuttle_mate.model.ClubManageDto;
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

    // 모임 생성 (방장 자동 등록)
    @Transactional
    public int createClubWithHost(ClubManageDto clubDto, ClubMemberDto memberDto) {
        int result = sqlSession.insert(NS + "insertClub", clubDto);
        memberDto.setClubId(clubDto.getClubId());
        memberDto.setUserRole("HOST");
        memberDto.setStatus("Y");
        sqlSession.insert(NS + "insertClubMember", memberDto);
        return result;
    }

    // 모임 단건 조회
    public ClubManageDto selectClubById(int clubId) {
        return sqlSession.selectOne(NS + "selectClubById", clubId);
    }

    // 모임 기본 정보 수정
    @Transactional
    public void updateClub(ClubManageDto clubDto) {
        sqlSession.update(NS + "updateClub", clubDto);
    }

    // 관리자 프로필 단건 조회
    public ClubMemberDto selectAdminMember(int clubId, String userId) {
        Map<String, Object> param = new HashMap<>();
        param.put("clubId", clubId);
        param.put("userId", userId);
        return sqlSession.selectOne(NS + "selectAdminMember", param);
    }

    // 관리자 프로필 수정
    @Transactional
    public void updateAdminMember(ClubMemberDto memberDto) {
        sqlSession.update(NS + "updateAdminMember", memberDto);
    }

    // 멤버 목록 조회 (STATUS='Y' 활성 멤버만)
    public List<ClubMemberDto> selectClubMemberList(int clubId) {
        return sqlSession.selectList(NS + "selectClubMemberList", clubId);
    }

    /**
     * 멤버 추가
     *        - 모임 생성 시 방장 자동 등록 (USER_ID 채움)
     *        - 관리자가 직접 입력해 추가하는 비회원 멤버 (USER_ID = null)
     *        공용 메서드
     */
    @Transactional
    public void insertClubMember(ClubMemberDto memberDto) {
        sqlSession.insert(NS + "insertClubMember", memberDto);
    }

    /**
     * 멤버 정보 수정 (관리자가 "수정" 버튼으로 정보 변경)
     *         - 이름/성별/생년/급수 모두 갱신
     */
    @Transactional
    public void updateClubMember(ClubMemberDto memberDto) {
        sqlSession.update(NS + "updateClubMember", memberDto);
    }

    // 멤버 제외 (soft delete: STATUS='N')
    @Transactional
    public void kickMember(int memberSeq) {
        sqlSession.delete(NS + "kickMember", memberSeq);
    }

    /**
     * 모임 내 동명 멤버 중복 체크 (추가용)
     *        - 같은 모임 내 같은 이름의 활성 멤버가 존재하는지 검사
     */
    public boolean isMemberNameDuplicate(int clubId, String userName) {
        return isMemberNameDuplicate(clubId, userName, null);
    }

    /**
     * 모임 내 동명 멤버 중복 체크 (수정용 - 본인 제외)
     *        - memberSeq 를 넘기면 자기 자신은 검사에서 제외
     *        - 수정 시 본인 이름을 그대로 두면 중복으로 잡히지 않도록 함
     */
    public boolean isMemberNameDuplicate(int clubId, String userName, Integer memberSeq) {
        Map<String, Object> param = new HashMap<>();
        param.put("clubId", clubId);
        param.put("userName", userName);
        param.put("memberSeq", memberSeq); // null 이면 매퍼에서 본인 제외 조건 없이 검사
        Integer count = sqlSession.selectOne(NS + "countMemberByName", param);
        return count != null && count > 0;
    }

    // 급수 목록 조회
    public List<ClubMemberDto> getAddr1Level() {
        return sqlSession.selectList(NS + "selectAddr1Level");
    }

    public List<ClubMemberDto> getAddr2Level() {
        return sqlSession.selectList(NS + "selectAddr2Level");
    }

    public List<ClubMemberDto> getAddr3Level() {
        return sqlSession.selectList(NS + "selectAddr3Level");
    }

    // 내 모임 리스트 조회
    public List<ClubManageDto> selectMyOwnedClubs(String userId) {
        return sqlSession.selectList(NS + "selectMyOwnedClubs", userId);
    }


    // 경기 매칭 관련

    /**
     * 매칭 결과 저장 (헤더 > 코트 > 팀멤버 > 대기자 순차 INSERT)
     * 트랜잭션 처리: 중간 실패 시 전부 롤백
     *
     * payload 구조:
     * {
     *   clubId, matchType, criteria, courtCount,
     *   courts: [ { courtNo, teamAIds:[...], teamBIds:[...] }, ... ],
     *   waitingIds: [...]
     * }
     *
     * @return 생성된 matchId
     */
    @Transactional
    @SuppressWarnings("unchecked")
    public int saveMatch(Map<String, Object> payload) {
        // 1) 페이로드에서 필드 추출
        int clubId         = toInt(payload.get("clubId"));
        String matchType   = String.valueOf(payload.get("matchType"));
        String criteria    = String.valueOf(payload.get("criteria"));
        int courtCount     = toInt(payload.get("courtCount"));

        List<Map<String, Object>> courts =
                (List<Map<String, Object>>) payload.getOrDefault("courts", new java.util.ArrayList<>());
        List<Object> waitingIds =
                (List<Object>) payload.getOrDefault("waitingIds", new java.util.ArrayList<>());

        // 2) 참여 인원 수 계산 (팀멤버 + 대기자)
        int memberCount = waitingIds.size();
        for (Map<String, Object> c : courts) {
            List<Object> a = (List<Object>) c.getOrDefault("teamAIds", new java.util.ArrayList<>());
            List<Object> b = (List<Object>) c.getOrDefault("teamBIds", new java.util.ArrayList<>());
            memberCount += a.size() + b.size();
        }

        // 3) 매칭 헤더 INSERT (matchId 자동 생성)
        Map<String, Object> header = new HashMap<>();
        header.put("clubId",      clubId);
        header.put("matchType",   matchType);
        header.put("criteria",    criteria);
        header.put("courtCount",  courtCount);
        header.put("memberCount", memberCount);
        sqlSession.insert(NS + "insertMatch", header);
        int matchId = toInt(header.get("matchId"));

        // 4) 코트 + 팀멤버 INSERT
        for (Map<String, Object> c : courts) {
            Map<String, Object> courtParam = new HashMap<>();
            courtParam.put("matchId", matchId);
            courtParam.put("courtNo", toInt(c.get("courtNo")));
            sqlSession.insert(NS + "insertMatchCourt", courtParam);
            int courtId = toInt(courtParam.get("courtId"));

            insertTeamMembers(courtId, "A",
                    (List<Object>) c.getOrDefault("teamAIds", new java.util.ArrayList<>()));
            insertTeamMembers(courtId, "B",
                    (List<Object>) c.getOrDefault("teamBIds", new java.util.ArrayList<>()));
        }

        // 5) 대기자 INSERT
        for (Object wid : waitingIds) {
            Map<String, Object> waitParam = new HashMap<>();
            waitParam.put("matchId",   matchId);
            waitParam.put("memberSeq", toInt(wid));
            sqlSession.insert(NS + "insertMatchWaiting", waitParam);
        }

        return matchId;
    }

    /** 팀별 멤버 INSERT 헬퍼 */
    private void insertTeamMembers(int courtId, String teamSide, List<Object> memberIds) {
        for (Object mid : memberIds) {
            Map<String, Object> tmParam = new HashMap<>();
            tmParam.put("courtId",   courtId);
            tmParam.put("teamSide",  teamSide);
            tmParam.put("memberSeq", toInt(mid));
            sqlSession.insert(NS + "insertMatchTeamMember", tmParam);
        }
    }

    /** Object → int 안전 변환 (JSON 파싱 시 Number / String 어느 쪽이든 처리) */
    private int toInt(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return ((Number) o).intValue();
        try { return Integer.parseInt(String.valueOf(o)); }
        catch (NumberFormatException e) { return 0; }
    }

    /**
     * 최근 매칭 내역 (manage 페이지 진입 시 표시)
     */
    public List<Map<String, Object>> selectMatchHistory(int clubId) {
        return sqlSession.selectList(NS + "selectMatchHistory", clubId);
    }

    /**
     * 매칭 상세 조회 (모달 표시용)
     * 반환: { matchId, matchDate, matchType, criteria,
     *         courts:[{ courtNo, teamA:[...], teamB:[...] }, ...],
     *         waiting:[...] }
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> selectMatchDetail(int matchId) {
        Map<String, Object> header = sqlSession.selectOne(NS + "selectMatchHeader", matchId);
        if (header == null) return null;

        List<Map<String, Object>> rows    = sqlSession.selectList(NS + "selectMatchCourtDetails", matchId);
        List<Map<String, Object>> waiting = sqlSession.selectList(NS + "selectMatchWaiting", matchId);

        // 코트별로 그룹핑 (코트 번호 기준)
        Map<Integer, Map<String, Object>> courtMap = new java.util.LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            int courtNo = toInt(row.get("courtNo"));
            Map<String, Object> court = courtMap.computeIfAbsent(courtNo, k -> {
                Map<String, Object> c = new HashMap<>();
                c.put("courtNo", k);
                c.put("teamA", new java.util.ArrayList<Map<String, Object>>());
                c.put("teamB", new java.util.ArrayList<Map<String, Object>>());
                return c;
            });

            Map<String, Object> player = new HashMap<>();
            player.put("memberId",  row.get("memberSeq"));
            player.put("name",      row.get("userName"));
            player.put("gender",    row.get("gender"));
            player.put("addr1",     row.get("addr1Level"));
            player.put("addr2",     row.get("addr2Level"));
            player.put("addr3",     row.get("addr3Level"));

            String side = String.valueOf(row.get("teamSide"));
            if ("A".equals(side)) {
                ((List<Map<String, Object>>) court.get("teamA")).add(player);
            } else {
                ((List<Map<String, Object>>) court.get("teamB")).add(player);
            }
        }

        // 대기자 정리
        List<Map<String, Object>> waitingOut = new java.util.ArrayList<>();
        for (Map<String, Object> w : waiting) {
            Map<String, Object> player = new HashMap<>();
            player.put("memberId", w.get("memberSeq"));
            player.put("name",     w.get("userName"));
            player.put("gender",   w.get("gender"));
            player.put("addr1",    w.get("addr1Level"));
            player.put("addr2",    w.get("addr2Level"));
            player.put("addr3",    w.get("addr3Level"));
            waitingOut.add(player);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("matchId",   header.get("matchId"));
        result.put("matchDate", header.get("matchDate"));
        result.put("matchType", header.get("matchType"));
        result.put("criteria",  header.get("criteria"));
        result.put("courts",    new java.util.ArrayList<>(courtMap.values()));
        result.put("waiting",   waitingOut);
        return result;
    }
}
