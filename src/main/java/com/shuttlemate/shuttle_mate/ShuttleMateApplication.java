package com.shuttlemate.shuttle_mate;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.awt.*;
import java.net.URI;

@SpringBootApplication
@MapperScan("com.shuttlemate.shuttle_mate")
public class ShuttleMateApplication {

    public static void main(String[] args) {
        SpringApplication.run(ShuttleMateApplication.class, args);

/*
        try {
            if (!GraphicsEnvironment.isHeadless()) {
                Desktop.getDesktop().browse(new URI("http://localhost:8080"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
*/
    }

}
