package com.shuttlemate.shuttle_mate.controller.web.mypage;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@RequiredArgsConstructor
@Controller
public class MyPageController {

    @RequestMapping("/mypage")
    public String myPage() {



        return "jsp/mypage/my_page";
    }
}
