package kr.co.strato.userAction.Entity;

import lombok.AccessLevel;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "user_actions_log")
public class UserActionLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_actions_log_idx")
    private Long userActionsLogIdx;

    @Column(name = "action_user_id", nullable = false)
    private String actionUserId;

    @Column(name = "action_type", nullable = false)
    private String actionType;

    @Column(name = "action_date")
    private LocalDateTime actionDate;

    @Column(name = "mapping_table", nullable = false)
    private String mappingTable;

    @Column(name = "table_idx", nullable = false)
    private Long tableIdx;
}