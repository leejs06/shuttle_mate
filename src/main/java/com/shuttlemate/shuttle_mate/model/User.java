package com.shuttlemate.shuttle_mate.model;

public class User {

    private String userId;          // 회원 ID
    private String userPw;          // 회원 PW
    private String userName;        // 회원명
    private String userHp;          // 회원 휴대폰번호
    private String userEmail;       // 회원 이메일
    private String userBirth;       // 회원 생년월일
    private String userGender;      // 회원 성별
    private String addr1Level;      // 회원의 전국 급수
    private String addr2Level;      // 회원의 시 급수
    private String addr3Level;      // 회원의 구 급수
    private String status;          // 현재 상태

    public User(String userId, String userPw, String userName,
                String userHp, String userEmail, String userBirth,
                String userGender,
                String addr1Level, String addr2Level, String addr3Level,
                String status) {
        this.userId = userId;
        this.userPw = userPw;
        this.userName = userName;
        this.userHp = userHp;
        this.userEmail = userEmail;
        this.userBirth = userBirth;
        this.userGender = userGender;
        this.addr1Level = addr1Level;
        this.addr2Level = addr2Level;
        this.addr3Level = addr3Level;
        this.status = status;
    }
}
