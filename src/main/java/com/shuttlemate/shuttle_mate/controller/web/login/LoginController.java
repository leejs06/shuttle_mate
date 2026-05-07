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

import java.util.HashMap;
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


        return "login/join";
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
        return "login/login";
    }

    // 로그인 처리
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

    // 로그인 페이지 > 아이디 찾기 - UI 개발 완료
    @RequestMapping("/find/id")
    public String findId() {
        return "find/findId";
    }

    // 로그인 페이지 > 아이디 찾기 처리 - 개발 완료
    @RequestMapping("/find/id/result")
    @ResponseBody
    public Map<String, Object> findIdResult(@RequestBody UserDto userDto) throws Exception {

        Map<String, Object> result = new HashMap<>();

        String foundId = loginService.findUserId(userDto);

        if (foundId != null && !foundId.isEmpty()) {
            result.put("success", true);
            result.put("userId", foundId);
        } else {
            result.put("success", false);
            result.put("message", "일치하는 회원 정보가 없습니다.");
        }

        return result;
    }

    // 로그인 페이지 > 비밀번호 변경 버튼 (본인 인증)
    @RequestMapping("/change/pw")
    public String changePw() {
        return "find/verifyIdentity";
    }

    // 로그인 페이지 > 비밀번호 변경 버튼 (본인 인증 처리)
    @RequestMapping("/change/pw/sendEmail")
    @ResponseBody
    public Map<String, Object> sendEmail(@RequestBody UserDto userDto) {

        Map<String, Object> result = new HashMap<>();

        try {
            int userCount = loginService.checkUserForPw(userDto);

            if (userCount > 0) {
                loginService.sendAuthEmail(userDto);
                result.put("success", true);
            } else {
                result.put("success", false);
                result.put("message", "일치하는 회원 정보가 없습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "메일 발송 중 오류가 발생했습니다.");
        }

        return result;
    }

    // 인증번호 검증
    @RequestMapping("/change/pw/verify")
    @ResponseBody
    public Map<String, Object> verify(@RequestBody Map<String, String> params) {
        Map<String, Object> result = new HashMap<>();

        String userId = params.get("userId");
        String authCode = params.get("authCode");

        boolean isOk = loginService.verifyCode(userId, authCode);

        if (isOk) {
            result.put("success", true);
        } else {
            result.put("success", false);
            result.put("message", "인증번호가 일치하지 않거나 만료되었습니다.");
        }
        return result;
    }

    // 비밀번호 재설정 페이지로 이동
    @RequestMapping("/change/pw/reset")
    public String pwResetPage(@RequestParam String userId, Model model) {
        model.addAttribute("userId", userId);
        return "find/passwordReset";
    }

    // 비밀번호 변경 처리
    @RequestMapping("/change/pw/resetUpdate")
    @ResponseBody
    public Map<String, Object> pwResetUpdate(@RequestBody UserDto userDto) {
        Map<String, Object> result = new HashMap<>();
        try {
            loginService.resetPassword(userDto);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "변경 중 오류가 발생했습니다.");
        }
        return result;
    }

    // 로그아웃 처리
    @RequestMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/index";
    }
}
