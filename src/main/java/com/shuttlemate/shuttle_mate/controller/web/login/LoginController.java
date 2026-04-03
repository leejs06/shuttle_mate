package com.shuttlemate.shuttle_mate.controller.web.login;

import com.shuttlemate.shuttle_mate.common.util.UserValidator;
import com.shuttlemate.shuttle_mate.model.UserDto;
import com.shuttlemate.shuttle_mate.service.login.LoginService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Controller
public class LoginController {

    @Resource(name = "loginService")
    private LoginService loginService;

    @Resource(name = "userValidator")
    private UserValidator userValidator;


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

    // 사용자 아이디 중복 체크
    @RequestMapping(value = "join/idCheck")
    @ResponseBody   // @ResponseBody: 페이지 이동 없이 데이터만 보냄
    public boolean idCheck(@RequestParam("userId") String userId) {

        // 사용자 아이디 정규식 체크
        if (!userValidator.isIdValidator(userId)) {
            return true;
        }

        // 사용자 아이디 중복 체크
        return loginService.isDuplicate(userId);
    }

    // 회원가입 처리
    @RequestMapping(value = "/join/add")
    public ResponseEntity<?> addUser(@RequestBody UserDto userDto) throws Exception {

        loginService.joinUser(userDto);

        return ResponseEntity.ok(Map.of("success", true));
    }


    // 로그인 UI 띄우기
    @RequestMapping(value = "/login")
    public String login() {
        return "jsp/login/login";
    }

    // TODO: 로그인 처리
    @RequestMapping(value = "/login/success")
    @ResponseBody
    public ResponseEntity<?> loginSuccess(@RequestBody UserDto userDto, HttpSession session) {

        UserDto loginUser = loginService.loginUser(userDto);

        if (loginUser != null) {
            session.setAttribute("loginUser", loginUser);
            return ResponseEntity.ok(Map.of("success", true));
        } else {
            return ResponseEntity.ok(Map.of("success", false, "message", "아이디 또는 비밀번호를 확인해주세요."));
        }

    }

}
