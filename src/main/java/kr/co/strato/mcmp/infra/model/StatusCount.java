package kr.co.strato.mcmp.infra.model;

import lombok.Getter;
import lombok.ToString;

@Getter
@ToString
public class StatusCount {
    public Integer countTotal;
    public Integer countCreating;
    public Integer countRunning;
    public Integer countFailed;
    public Integer countSuspended;
    public Integer countRebooting;
    public Integer countTerminated;
    public Integer countSuspending;
    public Integer countResuming;
    public Integer countTerminating;
    public Integer countUndefined;
}
