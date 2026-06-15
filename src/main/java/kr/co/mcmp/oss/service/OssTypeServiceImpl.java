package kr.co.mcmp.oss.service;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class OssTypeServiceImpl implements OssTypeService {

	private final OssTypeRepository ossTypeRepository;

	private final OssRepository ossRepository;

	/* Comment translated to English. */
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

	@Override
	public List<OssTypeDto> getOssTypeFilteredList() {
		try {
			List<OssTypeDto> ossTypeList = ossTypeRepository.findAll()
					.stream()
					.map(OssTypeDto::from)
					.collect(Collectors.toList());

			List<OssDto> ossList = ossRepository.findAll()
					.stream()
					.map(OssDto::from)
					.collect(Collectors.toList());

			// Comment translated to English.
			Set<Long> ossTypeIdxSet = ossList.stream()
					.map(OssDto::getOssTypeIdx)
					.collect(Collectors.toSet());

			// Comment translated to English.
			return ossTypeList.stream()
					.filter(ossType -> !ossTypeIdxSet.contains(ossType.getOssTypeIdx()))
					.collect(Collectors.toList());
		} catch (Exception e) {
			log.error(e.getMessage());
			return null;
		}
	}

	/* Comment translated to English. */
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

	/* Comment translated to English. */
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

	/* Comment translated to English. */
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

	/* Comment translated to English. */
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