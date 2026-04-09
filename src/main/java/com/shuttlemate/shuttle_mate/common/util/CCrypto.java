package com.shuttlemate.shuttle_mate.common.util;

import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

@Component
public class CCrypto {
    private static final String SECRET_KEY = "12345678901234567890123456789012"; // 32바이트
    private static final String ALGO = "AES/GCM/NoPadding";

    // 고정된 IV (12바이트). 이 값이 바뀌면 기존에 암호화된 데이터는 복호화할 수 없으니 주의하세요!
    private static final byte[] FIXED_IV = "shuttlemate1".getBytes();

    // 개인정보 암호화 (전화번호 등)
    public String encrypt(String text) throws Exception {
        // SecureRandom 제거 -> FIXED_IV 사용
        Cipher cipher = Cipher.getInstance(ALGO);
        cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(SECRET_KEY.getBytes(), "AES"), new GCMParameterSpec(128, FIXED_IV));

        byte[] encrypted = cipher.doFinal(text.getBytes());

        // IV를 매번 결과에 포함시킬 필요가 없으므로 암호화된 데이터만 Base64로 인코딩
        return Base64.getEncoder().encodeToString(encrypted);
    }

    // 개인정보 복호화
    public String decrypt(String encryptedText) throws Exception {
        byte[] encrypted = Base64.getDecoder().decode(encryptedText);

        Cipher cipher = Cipher.getInstance(ALGO);
        // 복호화 시에도 동일한 FIXED_IV 사용
        cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(SECRET_KEY.getBytes(), "AES"), new GCMParameterSpec(128, FIXED_IV));

        return new String(cipher.doFinal(encrypted));
    }
}