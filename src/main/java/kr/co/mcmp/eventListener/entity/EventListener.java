package kr.co.mcmp.eventListener.entity;

import kr.co.mcmp.workflow.Entity.Workflow;
import lombok.*;

import javax.persistence.*;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "event_listener")
public class EventListener {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "event_listener_idx", nullable = false, updatable = false)
    private Long eventListenerIdx;

    @Column(name = "event_listener_name", nullable = false, length = 50)
    private String eventListenerName;

    @Column(name = "event_listener_desc", length = 100)
    private String eventListenerDesc;

    @Column(name = "event_listener_url", nullable = false, length = 200)
    private String eventListenerUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workflow_idx", nullable = false)
    private Workflow workflow;
}

