package kr.co.mcmp.oss.dto;

import kr.co.mcmp.oss.entity.OssType;
import lombok.Builder;
import lombok.Getter;


@Getter
@Builder
public class OssTypeDto {

    private Long ossTypeIdx;
    private String ossTypeName;
    private String ossTypeDesc;

    // Comment translated to English.
    public static OssTypeDto from(OssType ossType) {
        return OssTypeDto.builder()
                .ossTypeIdx(ossType.getOssTypeIdx())
                .ossTypeName(ossType.getOssTypeName())
                .ossTypeDesc(ossType.getOssTypeDesc())
                .build();
    }

    // Comment translated to English.
    public static OssTypeDto of(OssTypeDto ossTypeDto) {
        return OssTypeDto.builder()
                .ossTypeIdx(ossTypeDto.getOssTypeIdx())
                .ossTypeName(ossTypeDto.getOssTypeName())
                .ossTypeDesc(ossTypeDto.getOssTypeDesc())
                .build();
    }

    // Comment translated to English.
    public static OssType toEntity(OssTypeDto ossTypeDto) {
        return OssType.builder()
                .ossTypeIdx(ossTypeDto.getOssTypeIdx())
                .ossTypeName(ossTypeDto.getOssTypeName())
                .ossTypeDesc(ossTypeDto.getOssTypeDesc())
                .build();
    }
}
