package kr.co.strato.oss.repository;

import kr.co.strato.oss.dto.OssDto;
import kr.co.strato.oss.entity.Oss;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface OssRepository extends JpaRepository<Oss, Long> {
    List<Oss> findAll();
    List<Oss> findByOssName(String ossName);
    Boolean findByOssNameAndOssUrlAndOssUsername(String ossName, String ossUrl, String ossUsername);
    Oss save(OssDto ossDto);
    Oss findByOssType_OssTypeName(String ossTypeName);
    Oss findByOssIdx(Long ossIdx);
}
