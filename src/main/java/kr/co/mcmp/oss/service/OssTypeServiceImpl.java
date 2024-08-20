package kr.co.mcmp.oss.service;

import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class OssTypeServiceImpl implements OssTypeService {

	private final OssTypeRepository ossTypeRepository;

	private final OssRepository ossRepository;

	/**
	 * OSS Type 목록 조회
	 * @return List<OssTypeDto> ossTypeDtoList
	 */
	@Override
	public List<OssTypeDto> getAllOssTypeList() {
		try {
			List<OssTypeDto> ossTypeList = ossTypeRepository.findAll()
					.stream()
					.map(OssTypeDto::from)
					.collect(Collectors.toList());
			return ossTypeList;
		} catch (Exception e) {
			log.error(e.getMessage());
			return null;
		}
	}

	/**
	 * OSS Type 등록
	 * @param ossTypeDto
	 * @return
	 */
	@Override
	public Long registOssType(OssTypeDto ossTypeDto) {
		try {
			OssType ossTypeEntity = OssTypeDto.toEntity(ossTypeDto);
			ossTypeEntity = ossTypeRepository.save(ossTypeEntity);

			return ossTypeEntity.getOssTypeIdx();
		} catch (Exception e) {
			log.error(e.getMessage());
			return null;
		}
	}

	/**
	 * OSS Type 수정
	 * @param ossTypeDto
	 * @return
	 */
	@Override
	public Boolean updateOssType(OssTypeDto ossTypeDto) {
		Boolean result = false;
		try {
			OssType ossTypeEntity = OssTypeDto.toEntity(ossTypeDto);
			ossTypeRepository.save(ossTypeEntity);

			result = true;
		} catch (Exception e) {
			log.error(e.getMessage());
		}
		return result;
	}

	/**
	 * OSS Type삭제
	 * @param ossTypeIdx
	 */
	@Override
	@Transactional
	public Boolean deleteOssType(Long ossTypeIdx) {
		Boolean result = false;
		try {
			OssType ossTypeEntity = ossTypeRepository.findByOssTypeIdx(ossTypeIdx);

			if(ossRepository.existsByOssType(ossTypeEntity)) {
				ossTypeRepository.deleteById(ossTypeIdx);
				result = true;
			}
		} catch (Exception e) {
			log.error(e.getMessage());
		}
		return result;
	}

	/**
	 * OSS Type 상세
	 * @param ossTypeIdx
	 */
	@Transactional
	@Override
	public OssTypeDto detailOssType(Long ossTypeIdx) {
		try {
			OssType ossTypeEntity = ossTypeRepository.findByOssTypeIdx(ossTypeIdx);

			return OssTypeDto.from(ossTypeEntity);
		} catch (Exception e) {
			return null;
		}
	}
}