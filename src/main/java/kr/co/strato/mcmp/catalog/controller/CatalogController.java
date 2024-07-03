package kr.co.strato.mcmp.catalog.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.api.response.ResponseWrapper;
import kr.co.strato.mcmp.catalog.model.Catalog;
import kr.co.strato.mcmp.catalog.service.CatalogService;

//@Tag(name = "Catalog", description = "카탈로그 관리")
@RequestMapping("/catalog")
@RestController
public class CatalogController {
	
//	@Autowired
//	private CatalogService calgSvc;
//
//	@Operation(summary = "카탈로그 목록 조회")
//	@GetMapping("/list")
//	public ResponseWrapper<List<Catalog>> getCatalogList(@RequestParam int nexusId) {
//		return null;
//	}
//
//	@Operation(summary = "nexus repository 목폭조회")
//	@GetMapping("/nexus/{nexusId}")
//	public ResponseWrapper<List<Catalog>> getNexusRepository(@PathVariable int nexusId) {
//		return null;
//	}
//
//	@Operation(summary = "nexus repository 구성 목록조회")
//	@GetMapping("/nexus/{nexusId}/{repository}")
//	public ResponseWrapper<List<Catalog>> getNexusRepositoryIn(@PathVariable int nexusId, @PathVariable String repository) {
//		return null;
//	}
//
//	@Operation(summary = "nexus file 등록(lib/jar/tar/etc...)")
//	@PostMapping("/nexus/{nexusId}/{repository}")
//	public ResponseWrapper<List<Catalog>> setLibNexus() {
//		return null;
//	}
}
