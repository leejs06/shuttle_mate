package com.shuttlemate.shuttle_mate.model;

public class UserDto {

    private String userId;          // 회원 ID
    private String userPw;          // 회원 PW
    private String userName;        // 회원명
    private String userHp;          // 회원 휴대폰번호
    private String userBirth;       // 회원 생년월일
    private String userGender;      // 회원 성별
    private String addr1Level;      // 회원의 전국 급수
    private String addr2Level;      // 회원의 시 급수
    private String addr3Level;      // 회원의 구 급수
    private String status;          // 현재 상태

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserPw() {
        return userPw;
    }

    public void setUserPw(String userPw) {
        this.userPw = userPw;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserHp() {
        return userHp;
    }

    public void setUserHp(String userHp) {
        this.userHp = userHp;
    }

    public String getUserBirth() {
        return userBirth;
    }

    public void setUserBirth(String userBirth) {
        this.userBirth = userBirth;
    }

    public String getUserGender() {
        return userGender;
    }

    public void setUserGender(String userGender) {
        this.userGender = userGender;
    }

    public String getAddr1Level() {
        return addr1Level;
    }

    public void setAddr1Level(String addr1Level) {
        this.addr1Level = addr1Level;
    }

    public String getAddr2Level() {
        return addr2Level;
    }

    public void setAddr2Level(String addr2Level) {
        this.addr2Level = addr2Level;
    }

    public String getAddr3Level() {
        return addr3Level;
    }

    public void setAddr3Level(String addr3Level) {
        this.addr3Level = addr3Level;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

}
