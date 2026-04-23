package com.shuttlemate.shuttle_mate.model;

import java.time.LocalDate;

public class ClubMemberDto {
    private int memberSeq;
    private int clubId;
    private String userId;
    private String userRole;
    private String createDate;

    private String addr1Level;
    private String addr2Level;
    private String addr3Level;

    private String gender;
    private int birthYear;

    public int getAge() {
        if (this.birthYear <= 0) {
            return 0;
        }
        int currentYear = LocalDate.now().getYear();
        return (currentYear - this.birthYear) + 1;
    }


    public int getMemberSeq() {
        return memberSeq;
    }

    public void setMemberSeq(int memberSeq) {
        this.memberSeq = memberSeq;
    }

    public int getClubId() {
        return clubId;
    }

    public void setClubId(int clubId) {
        this.clubId = clubId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserRole() {
        return userRole;
    }

    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }

    public String getCreateDate() {
        return createDate;
    }

    public void setCreateDate(String createDate) {
        this.createDate = createDate;
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

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public int getBirthYear() {
        return birthYear;
    }

    public void setBirthYear(int birthYear) {
        this.birthYear = birthYear;
    }

}
