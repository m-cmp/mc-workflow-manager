package kr.co.mcmp.api.readyz.ReadyzService;

import kr.co.mcmp.api.readyz.ReadyzDto.ReadyzResDto;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.util.AES256Util;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Objects;

@Log4j2
@RequiredArgsConstructor
@Service
public class ReadyzServiceImpl implements ReadyzService {

	private final OssRepository ossRepository;

	private final OssTypeRepository ossTypeRepository;

	private final JenkinsService jenkinsService;

	/* Comment translated to English. */
	@Transactional
	@Override
	public ReadyzResDto checkConnection() {

		final String target = "jenkins";

		// Comment translated to English.
		Long jenkinsTypeIdx = ossTypeRepository.findByOssTypeName(target.toUpperCase())
				.stream()
				.map(OssType::getOssTypeIdx)
				.findFirst()
				.orElse(null);

		// Idx null Check
		if(Objects.isNull(jenkinsTypeIdx)) {
			return ReadyzResDto.setReadyzResponseDto(500, "No workflow engine information!");
		}
		// Idx data Check
		else if(!Objects.equals(jenkinsTypeIdx, 0L)) {
			// Comment translated to English.
			OssDto ossDto = OssDto.from(ossRepository.findByOssIdx(jenkinsTypeIdx));

			// Comment translated to English.
			if (StringUtils.isBlank(ossDto.getOssUrl()) || StringUtils.isBlank(ossDto.getOssUsername()) || StringUtils.isBlank(ossDto.getOssPassword())) {
				log.error("Workflow Engine miss information");
				return ReadyzResDto.setReadyzResponseDto(500, "Workflow Engine miss information!");
			}


			// connection Check
			if(jenkinsService.isJenkinsConnect(ossDto))
				return ReadyzResDto.setReadyzResponseDto(200, "Workflow Manager Ready!");
			else
				return ReadyzResDto.setReadyzResponseDto(500, "Connection failed");

		}
		else {
			log.debug("[checkConnection] oss code >>> {}", target);
			log.error("[OssTypeName is Null] ossTypeIdx >>> {}", jenkinsTypeIdx);
			return ReadyzResDto.setReadyzResponseDto(500, "Connection Check Error");
		}
	}

	/* Comment translated to English. */
	public String encryptAesString(String str) {
		if ( StringUtils.isNotBlank(str) ) {
			return AES256Util.encrypt(str);
		}
		else {
			return null;
		}
	}

	/* Comment translated to English. */
	public String decryptAesString(String encryptedStr) {
		if (StringUtils.isNotBlank(encryptedStr)) {
			// Comment translated to English.
			String decrypted = AES256Util.decrypt(encryptedStr);
			// Comment translated to English.
			return decrypted;
		} else {
			return null;
		}
	}
}
