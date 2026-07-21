# ShuttleMate(셔틀메이트)

## 배드민턴 모임/회원 관리 및 경기 매칭 시스템

### 기술 스택(버전 명시)
    - SpringBoot 3.2.5, Java 17
    - JSP + MyBatis(뷰 렌더링, ORM 아님)
    - jQuery + Bootstrap 5.3 (프론트)
    - MySQL
    - Tomcat 10.1.54

### 실행 / 빌드
    - 실행: Run(shift + F10)
    - 빌드: clean > package > .war 파일 생성

### 프로젝트 구조
    - src/main/java/.../controller/     # 컨트롤러
    - src/main/java/.../service/        # 서비스
    - src/main/resources/mapper/        # MyBatis XML 매퍼
    - src/main/WEB-INF/views/           # JSP

### 컨벤션 (기본값과 다른 부분만)
    - MyBatis: map-underscore-to-camel-case: true 적용됨 -> DB snake_case, Java camelCase 대로 매핑됨. 수동 alias 불필요.
    - 이메일: Gmail SMTP, 앱 비밀번호는 setenv.bat에 환경변수로 설정 (코드에 하드코딩 금지).
    - 브랜드 컬러: blue #3B9EE8, green #39B54A, 배경 yellow-green #E8EBA0, footer navy #1C2B3A

### 반복적으로 발생했던 버그 패턴 (주의)
    - JS DOM ID 불일치: 모듈 간 prefix 통일 확인할 것 (예: #participant- vs #attend- 처럼 다른 접두사를 쓰다가 발생한 버그 이력 있음). JS 수정 시 관련 HTML의 실제 id/class를 먼저 확인.
    - NPE: param.get("X").equals(...) 같은 패턴 금지. null 체크 먼저하거나 Objects.equals() 사용.
    - 타입 비교: Integer/String을 .equals()로 비교할 때 타입 일치 여부 먼저 확인.
    - 폼 검증: 이벤트 바인딩 시 onchange vs mousedown 차이로 검증 타이밍 이슈 발생 이력 있음. 어떤 이벤트가 적절한지 상황별로 판단.

### 작업 방식
    - 기존 코드 스타일을 따라 수정할 것. 새 패턴 임의 도입 금지.
    - 수정은 반드시 기존 파일에 직접 반영 (별도 스니펫으로 제시하지 말것).
    - 원인 파악 전에 "이게 원인일 것 같다"고 단정하지 말고, 관련 코드(매퍼 XML, 컨트롤러, JS전체)를 먼저 확인.
    - DB 컬럼명/테이블 구조가 불확실하면 추측하지 말고 매퍼 XML이나 스키마를 먼저 확인.