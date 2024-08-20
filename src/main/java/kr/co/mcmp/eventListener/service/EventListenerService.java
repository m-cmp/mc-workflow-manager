package kr.co.mcmp.eventListener.service;

import kr.co.mcmp.eventListener.dto.reqDto.RequestEventListenerDto;
import kr.co.mcmp.eventListener.dto.resDto.ResponseEventListenerDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface EventListenerService {
    List<ResponseEventListenerDto> getEventListenerList();
    Long registEventListner(RequestEventListenerDto requestEventListenerDto);
    Boolean updateEventListener(RequestEventListenerDto requestEventListenerDto);
    Boolean deleteEventListener(Long eventListenerIdx);
    ResponseEventListenerDto detailEventListener(Long eventListenerIdx);
    Boolean runEventListener(Long eventListenerIdx);
}
