package kr.co.mcmp.api.readyz.ReadyzService;

import kr.co.mcmp.api.readyz.ReadyzDto.ReadyzResDto;
import org.springframework.stereotype.Service;

@Service
public interface ReadyzService {
    ReadyzResDto checkConnection();
}