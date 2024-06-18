package kr.co.strato.mcmp.infra.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.List;

@Setter
@Getter
@ToString
public class Mcis {
    public String namespace;
    public String id;
    public String name;
    public String status;
    public StatusCount statusCount;
    public String targetStatus;
    public String targetAction;
    public String installMonAgent;
    public String masterVmId;
    public String masterIp;
    public String masterSSHPort;
    public String label;
    public String systemLabel;
    public List<VM> vm;



    @Getter
    @Setter
    public static class VM {
        private String id;
        private String name;
        private String cspVmId;
        private String status;
        private String targetStatus;
        private String targetAction;
        private String nativeStatus;
        private String monAgentStatus;
        private String systemMessage;
        private String createdTime;
        private String publicIp;
        private String privateIp;
        private String sshPort;
        private Location location;
    }
    @Getter
    @Setter
    public static class Location {
        private String display;
        private Double latitude;
        private Double longitude;
    }
}
