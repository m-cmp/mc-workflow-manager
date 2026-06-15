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

@Tag(name = "mc-infra-manager", description = "mc-infra-manager lookup proxy")
@RequiredArgsConstructor
@RequestMapping("/infra-manager")
@RestController
public class McInfraManagerController {
    private final McInfraManagerService mcInfraManagerService;

    @Operation(summary = "List namespaces")
    @GetMapping("/namespaces")
    public ResponseWrapper<Object> getNamespaces(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getNamespaces(queryParams));
    }

    @Operation(summary = "List CSP regions")
    @GetMapping("/region-from-csp")
    public ResponseWrapper<Object> getRegionFromCsp(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getRegionFromCsp(queryParams));
    }

    @Operation(summary = "List providers")
    @GetMapping("/providers")
    public ResponseWrapper<Object> getProviders(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getProviders(queryParams));
    }

    @Operation(summary = "List provider regions")
    @GetMapping("/providers/{providerName}/regions")
    public ResponseWrapper<Object> getRegions(
            @PathVariable String providerName,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getRegions(providerName, queryParams));
    }

    @Operation(summary = "List connection configs")
    @GetMapping("/conn-configs")
    public ResponseWrapper<Object> getConnConfigs(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getConnConfigs(queryParams));
    }

    @Operation(summary = "List available zones for spec")
    @GetMapping("/available-zones")
    public ResponseWrapper<Object> getAvailableZones(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getAvailableZones(queryParams));
    }

    @Operation(summary = "List K8s versions")
    @GetMapping("/k8s-versions")
    public ResponseWrapper<Object> getK8sVersions(@RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getK8sVersions(queryParams));
    }

    @Operation(summary = "List namespace image/spec resources")
    @GetMapping("/namespaces/{nsId}/resources/{resourceType}")
    public ResponseWrapper<Object> getResources(
            @PathVariable String nsId,
            @PathVariable String resourceType,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getResources(nsId, resourceType, queryParams));
    }

    @Operation(summary = "Review INFRA Dynamic creation")
    @PostMapping("/namespaces/{nsId}/infra-dynamic-review")
    public ResponseWrapper<Object> reviewInfraDynamic(
            @PathVariable String nsId,
            @RequestParam MultiValueMap<String, String> queryParams,
            @RequestBody Object requestBody) {
        return new ResponseWrapper<>(mcInfraManagerService.reviewInfraDynamic(nsId, queryParams, requestBody));
    }

    @Operation(summary = "List INFRA")
    @GetMapping("/namespaces/{nsId}/infra")
    public ResponseWrapper<Object> getInfraList(
            @PathVariable String nsId,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getInfraList(nsId, queryParams));
    }

    @Operation(summary = "Get single INFRA")
    @GetMapping("/namespaces/{nsId}/infra/{infraId}")
    public ResponseWrapper<Object> getInfra(
            @PathVariable String nsId,
            @PathVariable String infraId,
            @RequestParam MultiValueMap<String, String> queryParams) {
        return new ResponseWrapper<>(mcInfraManagerService.getInfra(nsId, infraId, queryParams));
    }
}
