package com.shuttlemate.shuttle_mate.controller.web.login;

import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.service.login.LoginService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Controller
public class LoginController {

    @Resource(name = "loginService")
    public LoginService loginService;


    // 회원가입 UI 띄우기
    @RequestMapping(value = "/join")
    public String join(HttpServletRequest request, Model model) {

        // 전국 급수 리스트 전체 조회
        List<Object> addr1Level = loginService.selectAddr1Level("NAT");
        model.addAttribute("addr1Level", addr1Level);

        // 시 급수 리스트 전체 조회
        List<Object> addr2Level = loginService.selectAddr2Level("PRV");
        model.addAttribute("addr2Level", addr2Level);

        // 구 급수 리스트 전체 조회
        List<Object> addr3Level = loginService.selectAddr3Level("DST");
        model.addAttribute("addr3Level", addr3Level);


        return "jsp/login/join";
    }

    // TODO: 회원가입 처리
    @RequestMapping(value = "/join/add")
    public ResponseEntity<?> addUser(@RequestBody UserDto userDto) {
        // TODO: 암호화 작업 필요한 항목 암호화 작업 진행
        // TODO: 암호화 기법 선택



        userDto.setStatus("정상");

        loginService.join(userDto);

        return ResponseEntity.ok(Map.of("success", true));
    }


    // 로그인 UI 띄우기
    @RequestMapping(value = "/login")
    public String login() {
        return "jsp/login/login";
    }

    // TODO: 로그인 처리
    @RequestMapping(value = "/login/success")
    public String loginSuccess() {



        return "/index";
    }

}
