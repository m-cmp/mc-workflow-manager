package kr.co.strato.userAction.dto;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
public class UserActionDto {
    private Long userActionsLogIdx;
    private String actionUserId;
    private String actionType;
    private LocalDateTime actionDate;
    private String mappingTable;
    private Long tableIdx;
}
