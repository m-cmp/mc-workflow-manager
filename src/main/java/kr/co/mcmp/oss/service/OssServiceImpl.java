package kr.co.mcmp.oss.service;

import kr.co.mcmp.oss.entity.Oss;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.workflow.Entity.Workflow;
import kr.co.mcmp.workflow.dto.resDto.WorkflowListResDto;
import kr.co.mcmp.workflow.repository.WorkflowRepository;
import kr.co.mcmp.workflow.service.WorkflowService;
import kr.co.mcmp.workflow.service.WorkflowServiceImpl;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsCredential;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.workflow.tumblebug.dto.TumblebugDto;
import kr.co.mcmp.workflow.tumblebug.service.TumblebugService;
import kr.co.mcmp.util.AES256Util;
import kr.co.mcmp.util.Base64Util;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.apache.commons.lang3.StringUtils;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.util.List;
import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class OssServiceImpl implements OssService {

	private final OssRepository ossRepository;

	private final OssTypeRepository ossTypeRepository;

	private final WorkflowRepository workflowRepository;

	private final JenkinsService jenkinsService;

	private final TumblebugService tumblebugService;

	private final WorkflowService workflowService;

	private final WorkflowServiceImpl workflowServiceImpl;

	/**
	 * OSS 목록 조회
	 * @return List<OssDto> ossDtoList
	 */
	@Override
	public List<OssDto> getAllOssList() {
		try {
			List<OssDto> ossList = ossRepository.findAll()
					.stream()
					.map(OssDto::from)
					.collect(Collectors.toList());

			if ( !CollectionUtils.isEmpty(ossList) ) {
				ossList = ossList.stream()
						.map(ossDto -> OssDto.setDecryptPassword(ossDto, decryptAesString(ossDto.getOssPassword())))
						.collect(Collectors.toList());
			}

			return ossList;
		} catch (Exception e) {
			log.error(e.getMessage());
			return null;
		}
	}

	/**
	 * OSS 목록 조회
	 * @param ossTypeName
	 * @return List<OssDto> ossDtoList
	 */
	@Override
	public List<OssDto> getOssList(String ossTypeName) {
		try {
			List<OssTypeDto> ossTypeList = ossTypeRepository.findByOssTypeName(ossTypeName)
					.stream()
					.map(OssTypeDto::from)
					.collect(Collectors.toList());

			// ossTypeList에서 ossTypeIdx 목록을 추출
			List<Long> ossTypeIdxList = ossTypeList
					.stream()
					.map(OssTypeDto::getOssTypeIdx)
					.collect(Collectors.toList());

			List<OssDto> ossList = ossRepository.findByOssTypeIdxIn(ossTypeIdxList)
					.stream()
					.map(OssDto::from)
					.collect(Collectors.toList());

			if ( !CollectionUtils.isEmpty(ossList) ) {
				ossList = ossList
						.stream()
						.map(ossDto -> OssDto.setDecryptPassword(ossDto, decryptAesString(ossDto.getOssPassword())))
						.collect(Collectors.toList());
			}

			return ossList;
		} catch (Exception e) {
			log.error(e.getMessage());
			return null;
		}

	}

	/**
	 * OSS 등록
	 * @param ossDto
	 * @return
	 */
	@Override
	@Transactional
	public Long registOss(OssDto ossDto) {
		try {
			OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx()));

			ossDto = ossDto.setEncryptPassword(ossDto, encryptAesString(ossDto.getOssPassword()));
			ossDto = OssDto.from(ossRepository.save(OssDto.toEntity(ossDto, ossTypeDto)));

			if("JENKINS".equals(ossTypeDto.getOssTypeName().toUpperCase()))
				workflowServiceImpl.createJenkinsJob(ossTypeDto, ossDto);

			return ossDto.getOssIdx();
		} catch (Exception e) {
			log.error(e.getMessage());
			return null;
		}
	}

	/**
	 * OSS 수정
	 * @param ossDto
	 * @return
	 */
	@Override
	public Boolean updateOss(OssDto ossDto) {
		Boolean result = false;
		try {
			OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx()));
			ossDto = ossDto.setEncryptPassword(ossDto, encryptAesString(ossDto.getOssPassword()));

			ossRepository.save(OssDto.toEntity(ossDto, ossTypeDto));

			if("JENKINS".equals(ossTypeDto.getOssTypeName().toUpperCase())) {
				managedJenkinsCredential(ossDto, "update");
				workflowServiceImpl.createJenkinsJob(ossTypeDto, ossDto);
			}

			result = true;
		} catch (Exception e) {
			log.error(e.getMessage());
		}
		return result;
	}

	/**
	 * OSS 삭제
	 * @param ossIdx
	 * @Desc
	 * 		false
	 * 		- Mapping 된 workflow가 존재 할 경우
	 * 		- Error
	 */
	@Override
	@Transactional
	public Boolean deleteOss(Long ossIdx) {
		Boolean result = false;
		try {
			Oss ossEntity = ossRepository.findByOssIdx(ossIdx);
			OssDto ossDto = OssDto.from(ossEntity);

			if(!workflowRepository.existsByOss_OssIdx(ossIdx)) {
				ossRepository.deleteByOssIdx(ossIdx);
				result = true;
			}

			OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx()));
			if("JENKINS".equals(ossTypeDto.getOssTypeName().toUpperCase())) {
				if(ossDto.getOssPassword() != null)
					managedJenkinsCredential(ossDto, "delete");
			}

		} catch (Exception e) {
			log.error(e.getMessage());
		}
		return result;
	}

	/**
	 * OSS 연결 확인
	 * @param ossDto
	 * TODO : 추후 OSS 추가
	 */
	@Transactional
	@Override
	public Boolean checkConnection(OssDto ossDto) {
		OssTypeDto osstypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx()));

		if(!osstypeDto.getOssTypeName().isEmpty()) {
			switch(osstypeDto.getOssTypeName().toUpperCase()) {
				case "JENKINS" :
					if (StringUtils.isBlank(ossDto.getOssUrl()) ||
							StringUtils.isBlank(ossDto.getOssUsername()) ||
							StringUtils.isBlank(ossDto.getOssPassword()) ) {
						log.error("접속정보 누락");
						return false;
					}
					// Front에서 Base64Encoding한 데이터를 복호화하여 AES256 암호화 함.
					ossDto = ossDto.setEncryptPassword(ossDto, encryptAesString(ossDto.getOssPassword()));
					return jenkinsService.isJenkinsConnect(ossDto);

				case "TUMBLEBUG" :
					if (StringUtils.isBlank(ossDto.getOssUrl()) ||
							StringUtils.isBlank(ossDto.getOssUsername()) ||
							StringUtils.isBlank(ossDto.getOssPassword()) ) {
						log.error("접속정보 누락");
						return false;
					}

					try {
						// Front에서 Base64Encoding한 데이터를 복호화하여 AES256 암호화 함.
						ossDto = ossDto.setEncryptPassword(ossDto, encryptAesString(ossDto.getOssPassword()));
						List<TumblebugDto> list = tumblebugService.getNamespaceList(ossDto);

						if(list.size() >= 0) return true;
						else return false;
					} catch (Exception e) {
						log.error("API CALL Fail");
					}
//			case "GITLAB" :
//				if (StringUtils.isBlank(ossDto.getOssUrl()) ||
//						StringUtils.isBlank(ossDto.getOssUsername()) ||
//						StringUtils.isBlank(ossDto.getOssPassword()) ) {
//					log.error("접속정보 누락");
//					return false;
//				}
//
//				// Front에서 Base64Encoding한 데이터를 복호화하여 AES256 암호화 함.
//				ossDto.withModifiedEncriptPassword(ossDto, encryptAesString(ossDto.getOssPassword()));
//				return gitlabService.isConnectByPw(ossDto);
//
//			case "NEXUS" :
//				if (StringUtils.isBlank(ossDto.getOssUrl()) ||
//						StringUtils.isBlank(ossDto.getOssUsername()) ) {
//					log.error("접속정보 누락");
//					return false;
//				}
//
//				// Front에서 Base64Encoding한 데이터를 복호화하여 AES256 암호화 함.
//				ossDto.withModifiedEncriptPassword(ossDto, encryptAesString(ossDto.getOssPassword()));
//				return nexusService.checkNexusConnection(ossDto);

				default:
					log.debug("[checkConnection] oss code >>> {}", osstypeDto.getOssTypeName());
					log.error("Code is not registered] ossTypeName >>> {}", osstypeDto.getOssTypeName());
					return false;
			}
		}
		else {
			log.debug("[checkConnection] oss code >>> {}", osstypeDto.getOssTypeName());
			log.error("[OssTypeName is Null] ossTypeIdx >>> {}", ossDto.getOssTypeIdx());
			return false;
		}
	}

	/**
	 * OSS 정보 상세 조회
	 * @param ossIdx
	 * @return
	 */
	public OssDto detailOss(Long ossIdx) {
		try {
			Oss ossEntity = ossRepository.findByOssIdx(ossIdx);
			OssDto ossDto = OssDto.from(ossEntity);
			return OssDto.setDecryptPassword(ossDto, decryptAesString(ossEntity.getOssPassword()));
		} catch (Exception e) {
			log.error(e.getMessage());
			return null;
		}
	}

	/**
	 * OSS 정보 중복 체크(ossName, ossUrl, ossUsername)
	 * @param ossDto
	 * 중복: true / 아니면 false
	 * @return
	 */
	public Boolean isOssInfoDuplicated(OssDto ossDto) {
		try {
			return ossRepository.existsByOssNameAndOssUrlAndOssUsername(
					ossDto.getOssName(),
					ossDto.getOssUrl(),
					ossDto.getOssUsername());
		} catch (Exception e) {
			log.error(e.getMessage());
			return false;
		}

	}

	/**
	 * 젠킨스 credential 수정 또는 삭제
	 * @param managedOss
	 * @param managedType
	 * TODO : 고도화 (같은 oss 여러개 입력받기)
	 */
	private void managedJenkinsCredential(OssDto managedOss, String managedType) {
		try {
			OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(managedOss.getOssTypeIdx()));

			if ( !StringUtils.equals("JENKINS", ossTypeDto.getOssTypeName()) ) {
				OssDto jenkins = OssDto.from(ossRepository.findByOssType_OssTypeName("JENKINS"));

				if ( StringUtils.equals("update", managedType) ) {
					jenkinsService.updateCredential(jenkins, managedOss, JenkinsCredential.getCredentialTypeByOss(ossTypeDto.getOssTypeName()));
				}
				else {
					jenkinsService.deleteCredential(jenkins, managedOss, JenkinsCredential.getCredentialTypeByOss(ossTypeDto.getOssTypeName()));
				}
			}
		} catch (Exception e) {
			log.error(e.getMessage());
		}
	}

	/**
	 * 패스워드 암호화 (Front로 Base64Encoding한 데이터를 보냄.)
	 * @param str
	 * @return
	 */
	public String encryptBase64String(String str) {
		if ( StringUtils.isNotBlank(str) ) {
			return Base64Util.base64Encoding(AES256Util.decrypt(str));
		}
		else {
			return null;
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
	 * 패스워드/토큰 암호화 (Front로 Base64Encoding한 데이터를 보내.)
	 * @param str
	 * @return
	 */
	public String encodingBase64String(String str) {
		if ( StringUtils.isNotBlank(str) ) {
			return Base64Util.base64Encoding(str);
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