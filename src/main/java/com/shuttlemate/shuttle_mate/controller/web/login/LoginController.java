package com.shuttlemate.shuttle_mate.controller.web.login;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@RequiredArgsConstructor
@Controller
public class LoginController {

    // TODO: 회원가입, 로그인 페이지 개발
    @GetMapping("/join")
    public String join() {
        return "jsp/login/join";
    }

    @GetMapping("/login")
    public String login() {
        return "jsp/login/login";
    }

}
