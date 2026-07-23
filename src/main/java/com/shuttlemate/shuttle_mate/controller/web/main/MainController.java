package com.shuttlemate.shuttle_mate.controller.web.main;

import com.shuttlemate.shuttle_mate.model.ClubManageDto;
import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.service.club.ClubService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Controller
public class MainController {

    @Resource(name = "clubService")
    private ClubService clubService;

    // 메인 > 모임 현황 통계 섹션 데이터 조합
    // - 로그인 + 모임 보유 시에만 실제 통계 조회, 그 외에는 myClub 미설정 -> JSP에서 단계별 빈 상태 표시
    @RequestMapping("/")
    public String index(HttpSession session, Model model) {
        UserDto loginUser = (UserDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "index";
        }

        List<ClubManageDto> myOwnedClubs = clubService.selectMyOwnedClubs(loginUser.getUserId());
        if (myOwnedClubs.isEmpty()) {
            return "index";
        }

        // 계정당 모임 1개 제한 정책이라 첫 번째(유일한) 모임 기준으로 통계 구성
        ClubManageDto myClub = myOwnedClubs.get(0);
        model.addAttribute("myClub", myClub);

        int clubId = myClub.getClubId();

        // 최근 가입 회원 (최대 5명)
        model.addAttribute("recentMembers", clubService.getRecentJoinedMembers(clubId));

        // 최근 수동 매칭 경기 내역 (최대 5건, 승/패 결과가 저장된 경기만)
        List<Map<String, Object>> recentMatches = clubService.getRecentMatchResults(clubId);
        model.addAttribute("recentMatches", recentMatches);

        // 이번 달 순위표 (최대 5명, 승리 +3점 / 패배(참여) +1점)
        List<Map<String, Object>> monthlyRanking = clubService.getMonthlyRanking(clubId);
        model.addAttribute("monthlyRanking", monthlyRanking);

        return "index";
    }
}
