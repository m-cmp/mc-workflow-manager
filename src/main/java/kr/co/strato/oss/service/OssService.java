package kr.co.strato.oss.service;

import kr.co.strato.oss.dto.OssDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public interface OssService {
    List<OssDto> getAllOssList();
    List<OssDto> getOssList(String ossName);
    Boolean isOssInfoDuplicated(OssDto ossDto);
    Long createOss(OssDto ossDto);
    Long updateOss(OssDto ossDto);
    @Transactional
    void deleteOss(Long ossIdx);
    Boolean checkConnection(OssDto ossDto);
}