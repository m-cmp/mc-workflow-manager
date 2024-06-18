package kr.co.strato.mcmp.infra.model;

import lombok.Getter;
import lombok.ToString;

import java.util.List;

@Getter
@ToString
public class InfraNameSpace {
    public String id;
    public String name;
    public String k8s;
    public String description;
}
