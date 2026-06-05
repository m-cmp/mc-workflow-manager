package kr.co.mcmp.eventListener.entity;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "event_listener_param")
public class EventListenerParam {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "event_listener_param_idx")
    private Long eventListenerParamIdx;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_listener_idx", nullable = false)
    private EventListener eventListener;

    @Column(name = "param_key", nullable = false)
    private String paramKey;

    @Column(name = "param_value")
    private String paramValue;
}
