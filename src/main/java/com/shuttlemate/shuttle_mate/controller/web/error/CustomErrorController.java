package com.shuttlemate.shuttle_mate.controller.web.error;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController implements ErrorController {

    // ErrorConfig에서 404 → /error-404 로 포워딩
    @RequestMapping("/error-404")
    public String error404() {
        return "error/error-404";  // WEB-INF/jsp/error/error-404.jsp
    }

    // ErrorConfig에서 500 → /error-500 로 포워딩
    @RequestMapping("/error-500")
    public String error500() {
        return "error/error-500";  // WEB-INF/jsp/error/error-500.jsp
    }

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request) {

        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);

        if (status != null) {
            return "error/error";
        }

        return "error/error";
    }
}
