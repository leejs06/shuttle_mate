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

import java.util.List;

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
        // 전국 급수 리스트 조회
        List<Object> addr1Level = loginService.selectAddr1Level("NAT");
        model.addAttribute("addr1Level", addr1Level);

        // 시 급수 리스트 전체 조회
        List<Object> addr2Level = loginService.selectAddr2Level("PRV");
        model.addAttribute("addr2Level", addr2Level);

        // 구 급수 리스트 전체 조회
        List<Object> addr3Level = loginService.selectAddr3Level("DST");
        model.addAttribute("addr3Level", addr3Level);

        return "club/club_create";
    }

    // TODO: 모임 생성 처리
    @RequestMapping("/club/insertPro")
    public String insertClubPro(ClubManageDto clubDto, ClubMemberDto memberDto,
                                HttpSession session, Model model) {

        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        clubDto.setHostId(loginUser.getUserId());
        memberDto.setUserId(loginUser.getUserId());

        // 생성한 모임 정보 인서트
        int result = clubService.createClubWithHost(clubDto, memberDto);

        if (result > 0) {

            return "redirect:/club/manage?clubId=" + clubDto.getClubId();
        } else {
            model.addAttribute("msg", "모임 생성 중 오류가 발생했습니다.");
            return "common/error";
        }
    }

    // 모임 관리 UI 띄우기
    @RequestMapping("/club/manage")
    public String manageClub(@RequestParam("clubId") int clubId, HttpSession session, Model model) {
        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login";
        }

        ClubManageDto club = clubService.selectClubDetail(clubId);

        List<ClubMemberDto> memberList = clubService.selectClubMemberList(clubId);

        model.addAttribute("addr1Level", loginService.selectAddr1Level("NAT"));
        model.addAttribute("addr2Level", loginService.selectAddr2Level("PRV"));
        model.addAttribute("addr3Level", loginService.selectAddr3Level("DST"));

        model.addAttribute("club", club);
        model.addAttribute("memberList", memberList);

        return "club/club_manage";
    }

    // 모임 멤버 수동 추가 처리 (Ajax 또는 From)
    @RequestMapping("/club/addMemberPro")
    public String addMemberPro(ClubMemberDto memberDto) {
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

        // 본인이 방장인 모임 리스트만 조회
        List<ClubManageDto> myOwnedClubs = clubService.selectMyOwnedClubs(loginUser.getUserId());
        model.addAttribute("clubList", myOwnedClubs);

        return "myclub/myclub";
    }
}
