package kr.co.mcmp.infraManager.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.infraManager.service.McInfraManagerService;
import lombok.RequiredArgsConstructor;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "mc-infra-manager", description = "mc-infra-manager 조회 프록시")
@RequiredArgsConstructor
@RequestMapping("/infra-manager")
@RestController
public class McInfraManagerController {
    private final McInfraManagerService mcInfraManagerService;

    @Operation(summary = "Namespace 목록 조회")
    @GetMapping("/namespaces")
    public ResponseWrapper<Object> getNamespaces(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getNamespaces(queryParams));
    }

    @Operation(summary = "CSP Region 목록 조회")
    @GetMapping("/region-from-csp")
    public ResponseWrapper<Object> getRegionFromCsp(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getRegionFromCsp(queryParams));
    }

    @Operation(summary = "Provider 목록 조회")
    @GetMapping("/providers")
    public ResponseWrapper<Object> getProviders(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getProviders(queryParams));
    }

    @Operation(summary = "Provider Region 목록 조회")
    @GetMapping("/providers/{providerName}/regions")
    public ResponseWrapper<Object> getRegions(
            @PathVariable String providerName,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getRegions(providerName, queryParams));
    }

    @Operation(summary = "ConnConfig 목록 조회")
    @GetMapping("/conn-configs")
    public ResponseWrapper<Object> getConnConfigs(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getConnConfigs(queryParams));
    }

    @Operation(summary = "Spec 사용 가능 Zone 목록 조회")
    @GetMapping("/available-zones")
    public ResponseWrapper<Object> getAvailableZones(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getAvailableZones(queryParams));
    }

    @Operation(summary = "K8s Version 목록 조회")
    @GetMapping("/k8s-versions")
    public ResponseWrapper<Object> getK8sVersions(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getK8sVersions(queryParams));
    }

    @Operation(summary = "Namespace Image/Spec 목록 조회")
    @GetMapping("/namespaces/{nsId}/resources/{resourceType}")
    public ResponseWrapper<Object> getResources(
            @PathVariable String nsId,
            @PathVariable String resourceType,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getResources(nsId, resourceType, queryParams));
    }

    @Operation(summary = "INFRA Dynamic 생성 사전 검증")
    @PostMapping("/namespaces/{nsId}/infra-dynamic-review")
    public ResponseWrapper<Object> reviewInfraDynamic(
            @PathVariable String nsId,
            @RequestParam MultiValueMap<String, String> queryParams,
            @RequestBody Object requestBody) {
        return new ResponseWrapper<>(mcInfraManagerService.reviewInfraDynamic(nsId, queryParams, requestBody));
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
