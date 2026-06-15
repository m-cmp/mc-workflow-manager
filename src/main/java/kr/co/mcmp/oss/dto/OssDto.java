package kr.co.mcmp.oss.dto;

import kr.co.mcmp.oss.entity.Oss;
import lombok.*;


@Getter
@Builder
public class OssDto {

    private Long ossIdx;
    private Long ossTypeIdx;
    private String ossName;
    private String ossDesc;
    private String ossUrl;
    private String ossUsername;
    private String ossPassword;

    // Comment translated to English.
    public static OssDto from(Oss oss) {
        return OssDto.builder()
                .ossIdx(oss.getOssIdx())
                .ossTypeIdx(oss.getOssType().getOssTypeIdx())
                .ossName(oss.getOssName())
                .ossDesc(oss.getOssDesc())
                .ossUrl(oss.getOssUrl())
                .ossUsername(oss.getOssUsername())
                .ossPassword(oss.getOssPassword())
                .build();
    }

    // Comment translated to English.
    public static OssDto of(OssDto ossDto) {
        return OssDto.builder()
                .ossIdx(ossDto.getOssIdx())
                .ossTypeIdx(ossDto.getOssTypeIdx())
                .ossName(ossDto.getOssName())
                .ossDesc(ossDto.getOssDesc())
                .ossUrl(ossDto.getOssUrl())
                .ossUsername(ossDto.getOssUsername())
                .ossPassword(ossDto.getOssPassword())
                .build();
    }

    // Comment translated to English.
    public static Oss toEntity(OssDto ossDto, OssTypeDto ossTypeDto) {
        return Oss.builder()
                .ossIdx(ossDto.getOssIdx())
                .ossType(OssTypeDto.toEntity(ossTypeDto))
                .ossName(ossDto.getOssName())
                .ossDesc(ossDto.getOssDesc())
                .ossUrl(ossDto.getOssUrl())
                .ossUsername(ossDto.getOssUsername())
                .ossPassword(ossDto.getOssPassword())
                .build();
    }

    // Comment translated to English.
    public static OssDto setEncryptPassword(OssDto ossDto, String password) {
        return OssDto.builder()
                .ossIdx(ossDto.getOssIdx())
                .ossTypeIdx(ossDto.getOssTypeIdx())
                .ossName(ossDto.getOssName())
                .ossDesc(ossDto.getOssDesc())
                .ossUrl(ossDto.getOssUrl())
                .ossUsername(ossDto.getOssUsername())
                .ossPassword(password)
                .build();
    }
    // Comment translated to English.
    public static OssDto setDecryptPassword(OssDto ossDto, String password) {
        return OssDto.builder()
                .ossIdx(ossDto.getOssIdx())
                .ossTypeIdx(ossDto.getOssTypeIdx())
                .ossName(ossDto.getOssName())
                .ossDesc(ossDto.getOssDesc())
                .ossUrl(ossDto.getOssUrl())
                .ossUsername(ossDto.getOssUsername())
                .ossPassword(password)
                .build();
    }    // Duplicate Object set
    public static OssDto setOssAttributesDuplicate(String ossName, String ossUrl, String ossUsername) {
        return OssDto.builder()
                .ossName(ossName)
                .ossUrl(ossUrl)
                .ossUsername(ossUsername)
                .build();
    }
}
