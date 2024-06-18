package kr.co.strato.mcmp.catalog.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.strato.mcmp.catalog.model.Catalog;
import kr.co.strato.mcmp.nexus.service.NexusService;

@Service
public class CatalogService {
	
	@Autowired
	private NexusService nexusService;

	/**
	 * Nexus에 등록된 카탈로그 조회
	 * @return
	 */
	public List<Catalog> getCatalogList(int nexusId) {
		// Nexus > Helm Chart 목록 
		return nexusService.getCatalogList(nexusId);
	}
}
