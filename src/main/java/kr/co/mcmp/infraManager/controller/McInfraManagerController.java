package kr.co.mcmp.infraManager.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.infraManager.service.McInfraManagerService;
import lombok.RequiredArgsConstructor;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "mc-infra-manager", description = "mc-infra-manager 조회 프록시")
@RequiredArgsConstructor
@RequestMapping("/infra-manager")
@RestController
public class McInfraManagerController {
    private final McInfraManagerService mcInfraManagerService;

    @Operation(summary = "CSP Region 목록 조회")
    @GetMapping("/region-from-csp")
    public ResponseWrapper<Object> getRegionFromCsp(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getRegionFromCsp(queryParams));
    }

    @Operation(summary = "Provider Region 목록 조회")
    @GetMapping("/providers/{providerName}/regions")
    public ResponseWrapper<Object> getRegions(
            @PathVariable String providerName,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getRegions(providerName, queryParams));
    }

    @Operation(summary = "Namespace Image/Spec 목록 조회")
    @GetMapping("/namespaces/{nsId}/resources/{resourceType}")
    public ResponseWrapper<Object> getResources(
            @PathVariable String nsId,
            @PathVariable String resourceType,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getResources(nsId, resourceType, queryParams));
    }

    @Operation(summary = "INFRA 목록 조회")
    @GetMapping("/namespaces/{nsId}/infra")
    public ResponseWrapper<Object> getInfraList(
            @PathVariable String nsId,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getInfraList(nsId, queryParams));
    }

    @Operation(summary = "INFRA 단건 조회")
    @GetMapping("/namespaces/{nsId}/infra/{infraId}")
    public ResponseWrapper<Object> getInfra(
            @PathVariable String nsId,
            @PathVariable String infraId,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getInfra(nsId, infraId, queryParams));
    }
}
