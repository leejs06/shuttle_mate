package com.shuttlemate.shuttle_mate.controller.web.club;

import com.shuttlemate.shuttle_mate.model.ClubMemberDto;
import com.shuttlemate.shuttle_mate.model.ClubManageDto;
import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.service.club.ClubService;
import com.shuttlemate.shuttle_mate.service.login.LoginService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RequiredArgsConstructor
@Controller
public class ClubController {

    @Resource(name = "loginService")
    private LoginService loginService;

    @Resource(name = "clubService")
    private ClubService clubService;

    // 홈 > 모임 만들기 뷰 처리
    @RequestMapping("/club/create")
    public String createClub(HttpSession session, Model model) {
        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        // 계정당 모임 1개 제한: 이미 운영 중인 모임이 있으면 생성 화면 진입 자체를 막고
        // 운영 중인 모임 목록(myClubs) 페이지를 거치지 않고 바로 내 모임 관리 페이지로 보냄
        List<ClubManageDto> myOwnedClubs = clubService.selectMyOwnedClubs(loginUser.getUserId());
        if (!myOwnedClubs.isEmpty()) {
            return "redirect:/club/manage?clubId=" + myOwnedClubs.get(0).getClubId() + "&blocked=club";
        }

        List<Object> addr1Level = loginService.selectAddr1Level("NAT");
        model.addAttribute("addr1Level", addr1Level);

        List<Object> addr2Level = loginService.selectAddr2Level("PRV");
        model.addAttribute("addr2Level", addr2Level);

        List<Object> addr3Level = loginService.selectAddr3Level("DST");
        model.addAttribute("addr3Level", addr3Level);

        return "club/club_create";
    }

    // 2. 모임 생성 처리
    @RequestMapping("/club/insertPro")
    public String insertClubPro(ClubManageDto clubDto, ClubMemberDto memberDto,
                                HttpSession session, Model model) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        // 계정당 모임 1개 제한: 직접 URL/폼 재전송으로 우회 시도하는 경우 서버에서 재검증
        List<ClubManageDto> myOwnedClubs = clubService.selectMyOwnedClubs(loginUser.getUserId());
        if (!myOwnedClubs.isEmpty()) {
            return "redirect:/club/manage?clubId=" + myOwnedClubs.get(0).getClubId() + "&blocked=club";
        }

        clubDto.setHostId(loginUser.getUserId());
        memberDto.setUserId(loginUser.getUserId());
        memberDto.setStatus("Y");

        int result = clubService.createClubWithHost(clubDto, memberDto);

        if (result > 0) {
            return "redirect:/club/manage?clubId=" + clubDto.getClubId();
        } else {
            model.addAttribute("msg", "모임 생성 중 오류가 발생했습니다.");
            return "common/error";
        }
    }

    // 3. 모임 관리 UI (탭: 경기 매칭 / 회원 관리 / 모임 정보 수정)
    @RequestMapping("/club/manage")
    public String manageClub(@RequestParam(value = "clubId", required = false) Integer clubId,
                             HttpSession session, Model model) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        // clubId 없이 진입하는 경우 (예: 모바일 메뉴 "검색"처럼 clubId를 모르는 진입점)
        // 계정당 모임 1개 정책이라 내가 호스트인 모임으로 대체
        if (clubId == null) {
            List<ClubManageDto> myOwnedClubs = clubService.selectMyOwnedClubs(loginUser.getUserId());
            if (myOwnedClubs.isEmpty()) {
                return "redirect:/club/create";
            }
            clubId = myOwnedClubs.get(0).getClubId();
        }

        ClubManageDto clubManage = clubService.selectClubById(clubId);
        if (clubManage == null) {
            return "redirect:/club/myClubs";
        }

        if (!clubManage.getHostId().equals(loginUser.getUserId())) {
            return "redirect:/club/myClubs";
        }

        // 게스트(USER_ROLE=GUEST)는 정회원으로 집계되지 않지만, "오늘 참석 회원 선택"에는 함께 노출되어야 하므로
        // memberList(전체 풀)는 그대로 유지하고, 회원 관리 탭 목록/게스트 목록은 별도로 분리해서 내려줌
        List<ClubMemberDto> memberList = clubService.selectClubMemberList(clubId);
        List<ClubMemberDto> regularMemberList = memberList.stream()
                .filter(m -> !"GUEST".equals(m.getUserRole()))
                .collect(Collectors.toList());
        List<ClubMemberDto> guestList = memberList.stream()
                .filter(m -> "GUEST".equals(m.getUserRole()))
                .collect(Collectors.toList());

        ClubMemberDto adminMember = clubService.selectAdminMember(clubId, loginUser.getUserId());

        List<ClubMemberDto> addr1Level = clubService.getAddr1Level();
        List<ClubMemberDto> addr2Level = clubService.getAddr2Level();
        List<ClubMemberDto> addr3Level = clubService.getAddr3Level();

        model.addAttribute("club", clubManage);
        model.addAttribute("memberList", memberList);
        model.addAttribute("regularMemberList", regularMemberList);
        model.addAttribute("guestList", guestList);
        model.addAttribute("adminMember", adminMember);
        model.addAttribute("addr1Level", addr1Level);
        model.addAttribute("addr2Level", addr2Level);
        model.addAttribute("addr3Level", addr3Level);

        // 매칭 히스토리 (추후 구현 - 일단 빈 리스트로 내려서 JSP NPE 방지)
        model.addAttribute("matchHistory", clubService.selectMatchHistory(clubId));

        return "club/club_manage";
    }

    // 4. 모임 정보 수정 처리
    @RequestMapping("/club/update")
    public String updateClub(ClubManageDto clubDto, ClubMemberDto memberDto,
                             HttpSession session,
                             RedirectAttributes redirectAttributes) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        // 세션에서 userId 보완 (폼에 hidden 없이도 안전하게 처리)
        memberDto.setUserId(loginUser.getUserId());
        memberDto.setClubId(clubDto.getClubId());

        try {
            // 모임 기본 정보 수정 (clubTitle, location, maxMembers, description)
            clubService.updateClub(clubDto);

            // 관리자 프로필 수정 (birthYear, gender, addr1Level, addr2Level, addr3Level)
            clubService.updateAdminMember(memberDto);

            redirectAttributes.addFlashAttribute("successMsg", "모임 정보가 수정되었습니다.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMsg", "수정 중 오류가 발생했습니다.");
        }

        return "redirect:/club/manage?clubId=" + clubDto.getClubId();
    }

    /**
     * 4-2. 회원 단건 상세 조회 (AJAX)
     *           - 메인 페이지 "최근 가입 회원" 이름 클릭 시 읽기 전용 팝업으로 표시
     *           - 이 회원이 속한 모임의 방장 본인만 조회 가능 (다른 모임 회원 정보 무단 조회 차단)
     */
    @RequestMapping(value = "/club/memberDetail", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> memberDetail(@RequestParam("memberSeq") int memberSeq, HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        ClubMemberDto member = clubService.selectClubMemberDetail(memberSeq);
        if (member == null) {
            result.put("result", "error");
            result.put("message", "존재하지 않는 회원입니다.");
            return result;
        }

        ClubManageDto clubManage = clubService.selectClubById(member.getClubId());
        if (clubManage == null || !clubManage.getHostId().equals(loginUser.getUserId())) {
            result.put("result", "error");
            result.put("message", "권한이 없습니다.");
            return result;
        }

        result.put("result", "success");
        result.put("member", member);
        return result;
    }

    // 5. 회원 제외 처리 (AJAX, soft delete)
    @RequestMapping(value = "/club/kickMember", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, String> kickMember(@RequestParam("memberId") int memberSeq,
                                          @RequestParam(value = "clubId", required = false) Integer clubId,
                                          HttpSession session) {

        Map<String, String> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            clubService.kickMember(memberSeq); // update 처리
            result.put("result", "success");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    /**
     * 6. 회원 직접 추가 처리 (AJAX)
     *           - 회원가입한 사용자 검색이 아니라
     *             관리자가 이름/성별/생년/급수를 직접 입력해 등록
     *           - 등록된 회원은 해당 모임 내에서만 사용됨 (USER_ID = NULL)
     */
    @RequestMapping(value = "/club/addMember", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, String> addMember(@RequestParam("clubId") int clubId,
                                         @RequestParam("userName") String userName,
                                         @RequestParam("gender") String gender,
                                         @RequestParam("birthYear") int birthYear,
                                         @RequestParam(value = "addr1Level", required = false) String addr1Level,
                                         @RequestParam(value = "addr2Level", required = false) String addr2Level,
                                         @RequestParam(value = "addr3Level", required = false) String addr3Level,
                                         HttpSession session) {

        Map<String, String> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        // 호스트 검증
        ClubManageDto clubManage = clubService.selectClubById(clubId);
        if (clubManage == null || !clubManage.getHostId().equals(loginUser.getUserId())) {
            result.put("result", "error");
            result.put("message", "권한이 없습니다.");
            return result;
        }

        // 입력값 검증
        if (userName == null || userName.trim().length() < 2) {
            result.put("result", "error");
            result.put("message", "이름은 2자 이상이어야 합니다.");
            return result;
        }
        if (!"M".equals(gender) && !"F".equals(gender)) {
            result.put("result", "error");
            result.put("message", "성별이 올바르지 않습니다.");
            return result;
        }

        try {
            // 같은 모임 내 동명 회원 체크
            boolean isDuplicate = clubService.isMemberNameDuplicate(clubId, userName.trim());
            if (isDuplicate) {
                result.put("result", "duplicate");
                return result;
            }

            // 최대 인원 초과 검증 (maxMembers 는 String 타입이라 파싱, 게스트는 정원에서 제외)
            int maxMembers = parseMaxMembers(clubManage.getMaxMembers());
            long currentCount = clubService.selectClubMemberList(clubId).stream()
                    .filter(m -> !"GUEST".equals(m.getUserRole()))
                    .count();
            if (maxMembers > 0 && currentCount >= maxMembers) {
                result.put("result", "maxExceeded");
                return result;
            }

            // DTO 구성 - 비회원 회원이므로 USER_ID 는 NULL
            ClubMemberDto memberDto = new ClubMemberDto();
            memberDto.setClubId(clubId);
            memberDto.setUserId(null);
            memberDto.setUserName(userName.trim());
            memberDto.setUserRole("MEMBER");
            memberDto.setGender(gender);
            memberDto.setBirthYear(birthYear);
            memberDto.setAddr1Level(addr1Level);
            memberDto.setAddr2Level(addr2Level);
            memberDto.setAddr3Level(addr3Level);
            memberDto.setStatus("Y");

            clubService.insertClubMember(memberDto);

            result.put("result", "success");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    /**
     * 6-2. 회원 정보 수정 처리 (AJAX)
     *    - 회원 관리 탭의 "수정" 버튼 → 모달 폼 제출
     *    - memberSeq 로 대상 식별, 이름/성별/생년/급수 갱신
     */
    @RequestMapping(value = "/club/updateMember", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, String> updateMember(@RequestParam("clubId") int clubId,
                                            @RequestParam("memberSeq") int memberSeq,
                                            @RequestParam("userName") String userName,
                                            @RequestParam("gender") String gender,
                                            @RequestParam("birthYear") int birthYear,
                                            @RequestParam(value = "addr1Level", required = false) String addr1Level,
                                            @RequestParam(value = "addr2Level", required = false) String addr2Level,
                                            @RequestParam(value = "addr3Level", required = false) String addr3Level,
                                            HttpSession session) {

        Map<String, String> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        // 호스트 검증
        ClubManageDto clubManage = clubService.selectClubById(clubId);
        if (clubManage == null || !clubManage.getHostId().equals(loginUser.getUserId())) {
            result.put("result", "error");
            result.put("message", "권한이 없습니다.");
            return result;
        }

        // 입력값 검증
        if (userName == null || userName.trim().length() < 2) {
            result.put("result", "error");
            result.put("message", "이름은 2자 이상이어야 합니다.");
            return result;
        }
        if (!"M".equals(gender) && !"F".equals(gender)) {
            result.put("result", "error");
            result.put("message", "성별이 올바르지 않습니다.");
            return result;
        }

        try {
            // 본인 제외하고 같은 모임 내 동명 회원 체크
            boolean isDuplicate = clubService.isMemberNameDuplicate(clubId, userName.trim(), memberSeq);
            if (isDuplicate) {
                result.put("result", "duplicate");
                return result;
            }

            ClubMemberDto memberDto = new ClubMemberDto();
            memberDto.setMemberSeq(memberSeq);
            memberDto.setClubId(clubId);
            memberDto.setUserName(userName.trim());
            memberDto.setGender(gender);
            memberDto.setBirthYear(birthYear);
            memberDto.setAddr1Level(addr1Level);
            memberDto.setAddr2Level(addr2Level);
            memberDto.setAddr3Level(addr3Level);

            clubService.updateClubMember(memberDto);
            result.put("result", "success");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    /**
     * 6-3. 게스트 추가 처리 (AJAX)
     *           - 그날 하루만 함께 운동하는 회원의 지인을 게스트로 등록
     *           - 정회원으로 집계되지 않음: 최대 관리 인원(maxMembers) 검증 미적용, 월간 순위표 집계 제외
     *           - "오늘 참석 회원 선택"에는 정회원과 함께 그대로 노출되어 매칭에 참여 가능
     */
    @RequestMapping(value = "/club/addGuest", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, String> addGuest(@RequestParam("clubId") int clubId,
                                        @RequestParam("userName") String userName,
                                        @RequestParam("gender") String gender,
                                        @RequestParam("birthYear") int birthYear,
                                        @RequestParam(value = "addr1Level", required = false) String addr1Level,
                                        @RequestParam(value = "addr2Level", required = false) String addr2Level,
                                        @RequestParam(value = "addr3Level", required = false) String addr3Level,
                                        HttpSession session) {

        Map<String, String> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        // 호스트 검증
        ClubManageDto clubManage = clubService.selectClubById(clubId);
        if (clubManage == null || !clubManage.getHostId().equals(loginUser.getUserId())) {
            result.put("result", "error");
            result.put("message", "권한이 없습니다.");
            return result;
        }

        // 입력값 검증
        if (userName == null || userName.trim().length() < 2) {
            result.put("result", "error");
            result.put("message", "이름은 2자 이상이어야 합니다.");
            return result;
        }
        if (!"M".equals(gender) && !"F".equals(gender)) {
            result.put("result", "error");
            result.put("message", "성별이 올바르지 않습니다.");
            return result;
        }

        try {
            // 같은 모임 내 동명 회원/게스트 체크
            boolean isDuplicate = clubService.isMemberNameDuplicate(clubId, userName.trim());
            if (isDuplicate) {
                result.put("result", "duplicate");
                return result;
            }

            ClubMemberDto memberDto = new ClubMemberDto();
            memberDto.setClubId(clubId);
            memberDto.setUserId(null);
            memberDto.setUserName(userName.trim());
            memberDto.setUserRole("GUEST");
            memberDto.setGender(gender);
            memberDto.setBirthYear(birthYear);
            memberDto.setAddr1Level(addr1Level);
            memberDto.setAddr2Level(addr2Level);
            memberDto.setAddr3Level(addr3Level);
            memberDto.setStatus("Y");

            clubService.insertClubMember(memberDto);

            result.put("result", "success");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    /**
     * maxMembers (String 타입) 안전 파싱.
     * 비어있거나 숫자가 아니면 0 반환 → 컨트롤러에서 0일 때 제한 없음으로 해석.
     */
    private int parseMaxMembers(String raw) {
        if (raw == null || raw.trim().isEmpty()) return 0;
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    /**
     * 7. 모임 삭제 처리 (AJAX)
     *           - 관리자만 삭제 가능, 연관된 회원/매칭 데이터까지 전부 삭제
     */
    @RequestMapping(value = "/club/delete", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, String> deleteClub(@RequestParam("clubId") int clubId, HttpSession session) {
        Map<String, String> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        ClubManageDto clubManage = clubService.selectClubById(clubId);
        if (clubManage == null || !clubManage.getHostId().equals(loginUser.getUserId())) {
            result.put("result", "error");
            result.put("message", "권한이 없습니다.");
            return result;
        }

        try {
            clubService.deleteClub(clubId);
            result.put("result", "success");
            result.put("message", "모임이 삭제되었습니다.");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", "모임 삭제 중 오류가 발생했습니다.");
        }
        return result;
    }

    /**
     * 7-2. 매칭 내역 페이지 (모바일 하단 메뉴 "매칭 내역" 진입점)
     *           - 계정당 모임 1개 정책이라 내가 호스트인 모임 기준으로 최근 매칭 내역을 보여줌
     *           - 모임이 없거나 매칭 기록이 없으면 JSP에서 단계별 빈 상태 표시
     */
    @RequestMapping("/club/matchHistory")
    public String matchHistory(@RequestParam(value = "page", defaultValue = "1") int page,
                               HttpSession session, Model model) {
        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        List<ClubManageDto> myOwnedClubs = clubService.selectMyOwnedClubs(loginUser.getUserId());
        if (myOwnedClubs.isEmpty()) {
            return "club/match_history";
        }

        ClubManageDto myClub = myOwnedClubs.get(0);
        model.addAttribute("myClub", myClub);

        int pageSize = 10;
        int totalCount = clubService.selectMatchHistoryDateCount(myClub.getClubId());
        int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        model.addAttribute("matchHistory", clubService.selectMatchHistoryGrouped(myClub.getClubId(), page, pageSize));
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        return "club/match_history";
    }

    // 8. 내 모임 리스트 조회
    @RequestMapping("/club/myClubs")
    public String myClubs(HttpSession session, Model model) {
        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        List<ClubManageDto> myOwnedClubs = clubService.selectMyOwnedClubs(loginUser.getUserId());
        model.addAttribute("clubList", myOwnedClubs);

        return "myclub/myclub";
    }

    /**
     * 매칭 결과 저장 (AJAX, JSON body)
     * payload 구조:
     * {
     *   clubId, matchType, criteria, courtCount,
     *   courts: [{ courtNo, teamAIds:[...], teamBIds:[...] }, ...],
     *   waitingIds: [...]
     * }
     */
    @RequestMapping(value = "/club/saveMatch", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> saveMatch(@RequestBody Map<String, Object> payload,
                                         HttpSession session) {

        Map<String, Object> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            // 호스트 검증
            int clubId = payload.get("clubId") instanceof Number
                    ? ((Number) payload.get("clubId")).intValue()
                    : Integer.parseInt(String.valueOf(payload.get("clubId")));

            ClubManageDto clubManage = clubService.selectClubById(clubId);
            if (clubManage == null || !clubManage.getHostId().equals(loginUser.getUserId())) {
                result.put("result", "error");
                result.put("message", "권한이 없습니다.");
                return result;
            }

            int matchId = clubService.saveMatch(payload);
            result.put("result", "success");
            result.put("matchId", matchId);
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    /**
     * 매칭 상세 조회 (AJAX)
     */
    @RequestMapping(value = "/club/matchDetail", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> matchDetail(@RequestParam("matchId") int matchId,
                                           HttpSession session) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("courts", new ArrayList<>());
            return empty;
        }

        Map<String, Object> detail = clubService.selectMatchDetail(matchId);
        if (detail == null) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("courts", new ArrayList<>());
            return empty;
        }
        return detail;
    }
}
