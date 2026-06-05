package kr.co.mcmp.eventListener.repository;

import kr.co.mcmp.eventListener.entity.EventListenerParam;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventListenerParamRepository extends JpaRepository<EventListenerParam, Long> {
    List<EventListenerParam> findByEventListener_EventListenerIdx(Long eventListenerIdx);
    void deleteByEventListener_EventListenerIdx(Long eventListenerIdx);
}
