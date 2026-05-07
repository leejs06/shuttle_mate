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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

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

    // 홈 > 모임 만들기 뷰 처리
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

    // 모임 생성 처리
    @RequestMapping("/club/insertPro")
    public String insertClubPro(ClubManageDto clubDto, ClubMemberDto memberDto,
                                HttpSession session, Model model) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        clubDto.setHostId(loginUser.getUserId());
        memberDto.setUserId(loginUser.getUserId());

        int result = clubService.createClubWithHost(clubDto, memberDto);

        if (result > 0) {
            return "redirect:/club/manage?clubId=" + clubDto.getClubId();
        } else {
            model.addAttribute("msg", "모임 생성 중 오류가 발생했습니다.");
            return "common/error";
        }
    }

    // 모임 관리 UI (탭 ① 멤버 관리 + 탭 ② 모임 정보 수정)
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

        return "club/club_manage";
    }

    // 모임 정보 수정 처리 (탭 ② 수정 폼 submit)
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

    // 멤버 제외 처리 (AJAX)
    @RequestMapping("/club/kickMember")
    @ResponseBody
    public Map<String, String> kickMember(@RequestParam("memberId") int memberId,
                                          HttpSession session) {

        Map<String, String> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            clubService.kickMember(memberId);
            result.put("result", "success");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    // 멤버 검색 (AJAX)
    @RequestMapping("/club/searchUser")
    @ResponseBody
    public List<UserDto> searchUser(@RequestParam("keyword") String keyword,
                                    HttpSession session) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return null;
        }

        return clubService.searchUserByKeyword(keyword);
    }

    // 멤버 직접 추가 처리 (AJAX)
    @RequestMapping("/club/addMemberAjax")
    @ResponseBody
    public Map<String, String> addMemberAjax(@RequestParam("userId") String userId,
                                             @RequestParam("clubId") int clubId,
                                             HttpSession session) {

        Map<String, String> result = new HashMap<>();

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("result", "error");
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            boolean isDuplicate = clubService.isMemberDuplicate(userId, clubId);
            if (isDuplicate) {
                result.put("result", "duplicate");
                return result;
            }
            clubService.addMember(userId, clubId);
            result.put("result", "success");
        } catch (Exception e) {
            result.put("result", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    // 모임 멤버 수동 추가 처리 (폼 방식 - 기존 유지)
    @RequestMapping("/club/addMemberPro")
    public String addMemberPro(ClubMemberDto memberDto, HttpSession session, Model model) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        memberDto.setStatus("Y");
        clubService.insertClubMember(memberDto);
        return "redirect:/club/manage?clubId=" + memberDto.getClubId();
    }

    // 내 모임 리스트 조회
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
}