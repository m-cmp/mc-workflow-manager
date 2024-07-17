package kr.co.strato.oss.repository;

import kr.co.strato.oss.dto.OssTypeDto;
import kr.co.strato.oss.entity.OssType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OssTypeRepository extends JpaRepository<OssType, Long> {
    OssTypeDto findByOssTypeIdx(Long ossTypeIdx);
}
