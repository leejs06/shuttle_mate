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

@RequiredArgsConstructor
@Controller
public class ClubController {

    @Resource(name = "loginService")
    private LoginService loginService;

    @Resource(name = "clubService")
    private ClubService clubService;

    /* ─────────────────────────────────────────
       1. 홈 > 모임 만들기 뷰 처리
       ───────────────────────────────────────── */
    @RequestMapping("/club/create")
    public String createClub(Model model) {
        List<Object> addr1Level = loginService.selectAddr1Level("NAT");
        model.addAttribute("addr1Level", addr1Level);

        List<Object> addr2Level = loginService.selectAddr2Level("PRV");
        model.addAttribute("addr2Level", addr2Level);

        List<Object> addr3Level = loginService.selectAddr3Level("DST");
        model.addAttribute("addr3Level", addr3Level);

        return "club/club_create";
    }

    /* ─────────────────────────────────────────
       2. 모임 생성 처리
       ───────────────────────────────────────── */
    @RequestMapping("/club/insertPro")
    public String insertClubPro(ClubManageDto clubDto, ClubMemberDto memberDto,
                                HttpSession session, Model model) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
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

    /* ─────────────────────────────────────────
       3. 모임 관리 UI (탭: 경기 매칭 / 멤버 관리 / 모임 정보 수정)
       ───────────────────────────────────────── */
    @RequestMapping("/club/manage")
    public String manageClub(@RequestParam("clubId") int clubId,
                             HttpSession session, Model model) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        ClubManageDto clubManage = clubService.selectClubById(clubId);
        if (clubManage == null) {
            return "redirect:/club/myClubs";
        }

        if (!clubManage.getHostId().equals(loginUser.getUserId())) {
            return "redirect:/club/myClubs";
        }

        List<ClubMemberDto> memberList = clubService.selectClubMemberList(clubId);
        ClubMemberDto adminMember = clubService.selectAdminMember(clubId, loginUser.getUserId());

        List<ClubMemberDto> addr1Level = clubService.getAddr1Level();
        List<ClubMemberDto> addr2Level = clubService.getAddr2Level();
        List<ClubMemberDto> addr3Level = clubService.getAddr3Level();

        model.addAttribute("club", clubManage);
        model.addAttribute("memberList", memberList);
        model.addAttribute("adminMember", adminMember);
        model.addAttribute("addr1Level", addr1Level);
        model.addAttribute("addr2Level", addr2Level);
        model.addAttribute("addr3Level", addr3Level);

        // 매칭 히스토리 (추후 구현 - 일단 빈 리스트로 내려서 JSP NPE 방지)
        model.addAttribute("matchHistory", clubService.selectMatchHistory(clubId));

        return "club/club_manage";
    }

    /* ─────────────────────────────────────────
       4. 모임 정보 수정 처리 (탭 ③ 수정 폼 submit)
       ───────────────────────────────────────── */
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

    /* ─────────────────────────────────────────
       5. 멤버 제외 처리 (AJAX, soft delete)
       ───────────────────────────────────────── */
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
            clubService.kickMember(memberSeq);
            result.put("result", "success");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    /* ─────────────────────────────────────────
       6. 멤버 직접 추가 처리 (AJAX)
          - 회원가입한 사용자 검색이 아니라
            관리자가 이름/성별/생년/급수를 직접 입력해 등록
          - 등록된 멤버는 해당 모임 내에서만 사용됨 (USER_ID = NULL)
       ───────────────────────────────────────── */
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
            // 같은 모임 내 동명 멤버 체크
            boolean isDuplicate = clubService.isMemberNameDuplicate(clubId, userName.trim());
            if (isDuplicate) {
                result.put("result", "duplicate");
                return result;
            }

            // 최대 인원 초과 검증 (maxMembers 는 String 타입이라 파싱)
            int maxMembers = parseMaxMembers(clubManage.getMaxMembers());
            int currentCount = clubService.selectClubMemberList(clubId).size();
            if (maxMembers > 0 && currentCount >= maxMembers) {
                result.put("result", "maxExceeded");
                return result;
            }

            // DTO 구성 - 비회원 멤버이므로 USER_ID 는 NULL
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

    /* ─────────────────────────────────────────
       6-2. 멤버 정보 수정 처리 (AJAX)
            - 멤버 관리 탭의 "수정" 버튼 → 모달 폼 제출
            - memberSeq 로 대상 식별, 이름/성별/생년/급수 갱신
       ───────────────────────────────────────── */
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
            // 본인 제외하고 같은 모임 내 동명 멤버 체크
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

    /* ─────────────────────────────────────────
       7. 내 모임 리스트 조회
       ───────────────────────────────────────── */
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

    /* ═════════════════════════════════════════
       ★ 경기 매칭 관련 엔드포인트 (stub - 추후 구현) ★
       JS 가 호출하므로 404 방지용 임시 응답만 반환
       ═════════════════════════════════════════ */

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
