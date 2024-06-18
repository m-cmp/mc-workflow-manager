package kr.co.strato.mcmp.infra.model;

import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
public class VM implements Serializable {


    private static final long serialVersionUID = 0;

    private String commonImage;
    private String commonSpec;
    private String description;
    private String label;
    private String rootDiskType;
    private String rootDiskSize;
    private Integer subGroupSize;
    private String name;
}
