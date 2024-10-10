package kr.co.mcmp.api.readyz.ReadyzDto;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.Oss;
import lombok.Builder;
import lombok.Getter;


@Getter
@Builder
public class ReadyzResDto {
    private int code;
    private String message;

    public static ReadyzResDto setReadyzResponseDto(Integer  code, String message) {
        return ReadyzResDto.builder()
                .code(code)
                .message(message)
                .build();
    }
}
