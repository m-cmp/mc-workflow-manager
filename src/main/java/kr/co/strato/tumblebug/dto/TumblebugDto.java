package kr.co.strato.tumblebug.dto;

import lombok.Builder;
import lombok.Getter;


@Getter
@Builder
public class TumblebugDto {
    private String id;
    private String name;
    private String k8s;
    private String description;
}
