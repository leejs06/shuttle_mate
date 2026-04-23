package com.shuttlemate.shuttle_mate.common.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.servlet.HandlerInterceptor;


public class LoginCheckInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        HttpSession session = request.getSession();

        // 세션에 "loginUser"가 없으면 접근 차단
        if (session.getAttribute("loginUser") == null) {
            response.sendRedirect("/login");

            return false;
        }
        return true;
    }
}
