package com.shuttlemate.shuttle_mate.controller.web.error;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController {
    @RequestMapping("/error-404")
    public String handle404() {
        return "error/error";
    }

    @RequestMapping("/error-500")
    public String handle500() {
        return "error/error";
    }
}
