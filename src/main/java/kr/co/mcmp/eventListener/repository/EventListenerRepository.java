package kr.co.mcmp.eventListener.repository;


import kr.co.mcmp.eventListener.dto.reqDto.RequestEventListenerDto;
import kr.co.mcmp.eventListener.entity.EventListener;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventListenerRepository extends JpaRepository<EventListener, Long> {
    List<EventListener> findAll();
    EventListener save(EventListener eventListener);
    void deleteByEventListenerIdx(Long eventListenerIdx);
    EventListener findByEventListenerIdx(Long eventListenerIdx);
    Boolean existsByEventListenerName(String eventlistenerName);
}
