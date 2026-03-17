package com.shuttlemate.shuttle_mate.controller.web.random;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@RequiredArgsConstructor
@Controller
public class RandomMatchController {

    @RequestMapping("/random")
    public String randomMatch() {
        return "jsp/random_match";
    }


}
