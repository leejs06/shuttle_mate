package com.shuttlemate.shuttle_mate.controller.web.club;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@RequiredArgsConstructor
@Controller
public class ClubCreateController {

    // 홈 > 모임 만들기 뷰 처리
    @GetMapping("/club/create")
    public String createClub() {
        return "jsp/club/club_create";
    }


}
