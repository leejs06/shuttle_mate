package com.shuttlemate.shuttle_mate.controller.web.main;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@RequiredArgsConstructor
@Controller
@RequestMapping({"/", "/main", "/index", "/main/index"})
public class MainController {

    @GetMapping
    public String index() {
        return "index";
    }
}
