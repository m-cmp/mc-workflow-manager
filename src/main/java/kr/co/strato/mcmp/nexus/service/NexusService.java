package kr.co.strato.mcmp.nexus.service;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import kr.co.strato.mcmp.catalog.model.Catalog;
import kr.co.strato.mcmp.nexus.api.NexusComponentsApi;
import kr.co.strato.mcmp.nexus.api.NexusRepositoryApi;
import kr.co.strato.mcmp.nexus.api.NexusStatusApi;
import kr.co.strato.mcmp.nexus.exception.NexusException;
import kr.co.strato.mcmp.nexus.model.NexusPageComponent;
import kr.co.strato.mcmp.nexus.model.NexusRepository;
import kr.co.strato.mcmp.oss.mapper.OssMapper;
import kr.co.strato.mcmp.oss.model.Oss;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class NexusService {
	
	private static final String DEFAULT_NEXUS_HELMCHART_REPO = "helm_repo";

	@Autowired
	private NexusComponentsApi componentApi;
	
	@Autowired
	private NexusRepositoryApi repositoryApi;
	
	@Autowired
	private NexusStatusApi statusApi;
	
	@Autowired
	private OssMapper ossMapper;
	
	/**
	 * 넥서스의 Helm Chart Repository에 등록된 카탈로그 목록 조회 
	 * @param nexusId
	 * @param repositoryName
	 * @return
	 */
	public List<Catalog> getCatalogList(Integer nexusId) {
		List<Catalog> catalogList = new ArrayList<>();
		
		Oss nexus = ossMapper.selectOss(nexusId);
 		NexusPageComponent response = (NexusPageComponent) componentApi.listComponents(nexus, DEFAULT_NEXUS_HELMCHART_REPO, NexusPageComponent.class);
		if ( response != null ) {
			CollectionUtils.emptyIfNull(response.getItems()).stream().forEach(component -> {
				Catalog catalog = new Catalog();
				catalog.setCatalogName(component.getName());
				catalog.setCatalogVersion(component.getVersion());
				catalog.setCatalogTypeCd("HELMCHART");
				
				catalogList.add(catalog);
			});
		}
		
		return catalogList;
	}
	
	/**
	 * 넥서스의 Helm Chart Repository의 접근 URL 조회
	 * @param nexusId
	 * @param repositoryName
	 * @return
	 */
	public String getNexusRepositoryUrl(Integer nexusId) {
		String repoUrl = null;

		Oss nexus = ossMapper.selectOss(nexusId);
		NexusRepository response = (NexusRepository) repositoryApi.getRepositoryDetails(nexus, DEFAULT_NEXUS_HELMCHART_REPO, NexusRepository.class);
		if ( response != null ) {
			repoUrl = response.getUrl();
		}
		
		return repoUrl;
	}
	
	/**
	 * 넥서스 URL 연결 체크
	 * @param nexus
	 * @return
	 */
	public boolean checkNexusConnection(Oss nexus) {
		boolean checked = false;
		try {
			HttpStatus httpStatus = statusApi.statusEndpoint(nexus);
			if ( httpStatus == HttpStatus.OK ) {
				checked = true;
			}			
		} catch (NexusException e) {
			log.error("[getNexusRepositoryUrl] nexus error : {}", e.getMessage()); 
		} catch (Exception e) {
			log.error("[getNexusRepositoryUrl] error : {}", e.getMessage()); 
		} 
		
		return checked;
	}
}
