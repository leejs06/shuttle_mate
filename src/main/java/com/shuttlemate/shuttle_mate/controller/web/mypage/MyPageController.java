package com.shuttlemate.shuttle_mate.controller.web.mypage;

import com.shuttlemate.shuttle_mate.model.ClubManageDto;
import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.service.club.ClubService;
import com.shuttlemate.shuttle_mate.service.user.UserService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@RequiredArgsConstructor
@Controller
@RequestMapping("/mypage")
public class MyPageController {

    @Resource(name = "clubService")
    private ClubService clubService;

    @Resource(name = "userService")
    private UserService userService;

    @RequestMapping("/main")
    public String myPageMain(HttpSession session, Model model) {

        String userId = (String) session.getAttribute("userId");

        if (userId == null) {
            return "redirect:/login";
        }

        UserDto userProfile = userService.getUserProfile(userId);
        model.addAttribute("user", userProfile);

/*
        List<ClubManageDto> myClubs = clubService.getMyCreatedClubs("userId");
        model.addAttribute("myClubs", myClubs);
*/

        return "mypage/main";
    }



}
