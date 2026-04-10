package com.shuttlemate.shuttle_mate.service.mail;

import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    public void sendAuthCode(String toEmail, String authCode) throws Exception {
        // MimeMessage 객체 생성
        MimeMessage message = mailSender.createMimeMessage();

        // 설정 도와주는 Helper 객체 생성 (UTF-8 인코딩 설정)
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setTo(toEmail);
        helper.setSubject("셔틀메이트(ShuttleMate) 본인확인 인증번호 테스트입니다.");

        // HTML 형식으로 보낼 수도 있고, 일반 텍스트도 가능
        String content = "안녕하세요. 셔틀메이트(ShuttleMate) 입니다. <br><br>"
                + "본인확인 인증번호는 <b>[" + authCode + "]</b> 입니다. <br>"
                + "3분 내에 입력해 주세요.";
        helper.setText(content, true); // true는 HTML 사용 여부

        // 핵심: 보내는 사람의 이메일과 "표시될 이름"을 함께 설정
        helper.setFrom(new InternetAddress("shuttlemate06@gmail.com", "셔틀메이트", "UTF-8"));

        mailSender.send(message);
    }


/*
    public void sendAuthCode(String toEmail, String authCode) throws Exception {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("[ShuttleMate] 본인확인 인증번호입니다.");
        message.setText("안녕하세요. 셔틀메이트 입니다. \n\n인증번호는 [" + authCode + "] 입니다. \n3분 내에 입력해 주세요.");
        message.setFrom("shuttlemate06@gmail.com");   // 보내는 사람 주소

        mailSender.send(message);
    }
*/

}
