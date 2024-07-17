package kr.co.strato.oss.service;

import kr.co.strato.oss.dto.OssTypeDto;
import kr.co.strato.oss.entity.OssType;
import kr.co.strato.oss.repository.OssTypeRepository;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;


@Log4j2
@Service
public class OssTypeServiceImpl implements OssTypeService {

	@Autowired
	private OssTypeRepository ossTypeRepository;

	/**
	 * OSS Type 목록 조회
	 * @return List<OssTypeDto> ossTypeDtoList
	 */
	@Override
	public List<OssTypeDto> getAllOssTypeList() {
		List<OssTypeDto> ossTypeList = ossTypeRepository.findAll()
				.stream()
				.map(OssTypeDto::from)
				.collect(Collectors.toList());
		return ossTypeList;
	}

	/**
	 * OSS Type 등록
	 * @param ossTypeDto
	 * @return
	 */
	@Override
	public Long registOssType(OssTypeDto ossTypeDto) {
		ossTypeRepository.save(OssTypeDto.toEntity(ossTypeDto));
		return ossTypeDto.getOssTypeIdx();
	}

	/**
	 * OSS Type 수정
	 * @param ossTypeDto
	 * @return
	 */
	@Override
	public Long updateOssType(OssTypeDto ossTypeDto) {
		ossTypeRepository.save(OssTypeDto.toEntity(ossTypeDto));
		return ossTypeDto.getOssTypeIdx();
	}

	/**
	 * OSS Type삭제
	 * @param ossTypeIdx
	 */
	@Transactional
	@Override
	public void deleteOssType(Long ossTypeIdx) {
		OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossTypeIdx));
		if(ossTypeDto.getOssTypeIdx() != 0) {
			ossTypeRepository.deleteById(ossTypeIdx);
		}
	}

	/**
	 * OSS Type 상세
	 * @param ossTypeIdx
	 */
	@Transactional
	@Override
	public OssTypeDto detailOssType(Long ossTypeIdx) {
		return OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossTypeIdx));
	}

}