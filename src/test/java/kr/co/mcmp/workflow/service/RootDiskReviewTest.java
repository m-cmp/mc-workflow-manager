package kr.co.mcmp.workflow.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.CALLS_REAL_METHODS;
import static org.mockito.Mockito.mock;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

class RootDiskReviewTest {
    private final WorkflowServiceImpl service = mock(WorkflowServiceImpl.class, CALLS_REAL_METHODS);

    @Test
    void resolvesDefaultAndBlankDiskTypesForEachProvider() {
        Map<String, String> expectedTypes = Map.of(
                "tencent", "CLOUD_BSSD", "alibaba", "cloud_essd", "aws", "default", "gcp", "default");
        expectedTypes.forEach((provider, expected) -> {
            for (String diskType : List.of("", "   ", "default", " DeFaUlT ")) {
                Map<String, String> params = baseParams(provider);
                params.put("ROOT_DISK_TYPE", diskType);
                String expectedType = expected.equals("default") && !diskType.isBlank() ? diskType.trim() : expected;
                assertEquals(expectedType, reviewGroups(params).get(0).get("rootDiskType"), provider + "/" + diskType);
            }
            assertEquals(expected, reviewGroups(baseParams(provider)).get(0).get("rootDiskType"));
        });
    }

    @Test
    void preservesExplicitTypesAndUsesProviderBeforeSpecPrefix() {
        for (String provider : List.of("tencent", "alibaba", "aws", "gcp")) {
            Map<String, String> params = baseParams(provider);
            params.put("ROOT_DISK_TYPE", " custom-disk-type ");
            assertEquals("custom-disk-type", reviewGroups(params).get(0).get("rootDiskType"));
        }
        Map<String, String> params = baseParams("aws");
        params.put("SPEC_ID", "tencent+region+spec");
        assertEquals("default", reviewGroups(params).get(0).get("rootDiskType"));
    }

    @Test
    void infersProviderFromSpecWhenProviderIsMissing() {
        for (String provider : List.of("tencent", "alibaba")) {
            Map<String, String> params = baseParams(provider);
            params.remove("CSP");
            assertEquals(provider.equals("tencent") ? "CLOUD_BSSD" : "cloud_essd",
                    reviewGroups(params).get(0).get("rootDiskType"));
        }
    }

    @Test
    void resolvesEachProviderIndependentlyInMixedCspReview() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("CSP_LIST", "alibaba,tencent,aws,gcp");
        params.put("ROOT_DISK_TYPE", "default");
        for (String provider : List.of("ALIBABA", "TENCENT", "AWS", "GCP")) {
            params.put(provider + "_SPEC_ID", provider.toLowerCase() + "+region+spec");
            params.put(provider + "_IMAGE_ID", "test-image");
        }
        assertEquals(List.of("cloud_essd", "CLOUD_BSSD", "default", "default"),
                reviewGroups(params).stream().map(group -> group.get("rootDiskType")).toList());
    }

    private Map<String, String> baseParams(String provider) {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("CSP", provider);
        params.put("SPEC_ID", provider + "+region+spec");
        params.put("IMAGE_ID", "test-image");
        return params;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> reviewGroups(Map<String, String> params) {
        List<WorkflowParamDto> workflowParams = new ArrayList<>();
        params.forEach((key, value) -> workflowParams.add(WorkflowParamDto.builder()
                .paramKey(key).paramValue(value).build()));
        WorkflowReqDto request = WorkflowReqDto.builder().workflowParams(workflowParams).build();
        Map<String, Object> payload = ReflectionTestUtils.invokeMethod(service, "buildInfraDynamicReviewPayload", request);
        return (List<Map<String, Object>>) payload.get("nodeGroups");
    }
}
