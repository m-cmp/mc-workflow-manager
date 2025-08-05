package kr.co.mcmp.api.readyz.ReadyzService;

import kr.co.mcmp.api.readyz.ReadyzDto.ReadyzResDto;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.oss.service.OssService;
import kr.co.mcmp.oss.service.OssServiceImpl;
import kr.co.mcmp.util.AES256Util;
import kr.co.mcmp.workflow.service.WorkflowServiceImpl;
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

	private final OssServiceImpl ossService;
	private final OssRepository ossRepository;

	private final OssTypeRepository ossTypeRepository;

	private final JenkinsService jenkinsService;
	private final WorkflowServiceImpl workflowServiceImpl;

	/**
	 * OSS 연결 확인
	 * TODO : 추후 OSS 추가
	 */
	@Transactional
	@Override
	public ReadyzResDto checkConnection() {

		final String target = "jenkins";

		// Jenkins 정보를 가져오기 위한 ossTypeIdx 조회
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
			// jenkins oss 조회
			OssDto ossDto = OssDto.from(ossRepository.findByOssIdx(jenkinsTypeIdx));

			// 데이터 유무 검증
			if (StringUtils.isBlank(ossDto.getOssUrl()) || StringUtils.isBlank(ossDto.getOssUsername()) || StringUtils.isBlank(ossDto.getOssPassword())) {
				log.error("Workflow Engine miss information");
				return ReadyzResDto.setReadyzResponseDto(500, "Workflow Engine miss information!");
			}


			// initData insert
			ossDto = OssDto.setDecryptPassword(ossDto, ossDto.getOssPassword());
			ossService.managedJenkinsCredential(ossDto, "update");
			workflowServiceImpl.createJenkinsJob("JENKINS", ossDto);

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

	/**
	 * 패스워드 암호화 (Front에서 Base64Encoding한 데이터를 복호화하여 AES256 암호화 함.)
	 * @param str
	 * @return
	 */
	public String encryptAesString(String str) {
		if ( StringUtils.isNotBlank(str) ) {
			return AES256Util.encrypt(str);
		}
		else {
			return null;
		}
	}

	/**
	 * 패스워드 복호화
	 * @param encryptedStr
	 * @return
	 */
	public String decryptAesString(String encryptedStr) {
		if (StringUtils.isNotBlank(encryptedStr)) {
			// AES256으로 암호화된 문자열을 복호화
			String decrypted = AES256Util.decrypt(encryptedStr);
			// 복호화된 문자열을 Base64로 인코딩
			return decrypted;
		} else {
			return null;
		}
	}
}