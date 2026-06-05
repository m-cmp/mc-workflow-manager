package kr.co.mcmp.infraManager.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.nio.charset.StandardCharsets;
import java.util.Set;

@Slf4j
@Service
public class McInfraManagerService {
    private static final Set<String> SUPPORTED_RESOURCE_TYPES = Set.of("image", "spec");

    @Value("${mc-infra-manager.base-url}")
    private String baseUrl;

    @Value("${mc-infra-manager.username:}")
    private String username;

    @Value("${mc-infra-manager.password:}")
    private String password;

    private final RestTemplate restTemplate = new RestTemplate();

    public Object getRegionFromCsp(MultiValueMap<String, String> queryParams) {
        return get("/regionFromCsp", queryParams);
    }

    public Object getRegions(String providerName, MultiValueMap<String, String> queryParams) {
        return get("/provider/" + providerName + "/region", queryParams);
    }

    public Object getResources(String nsId, String resourceType, MultiValueMap<String, String> queryParams) {
        if (!SUPPORTED_RESOURCE_TYPES.contains(resourceType)) {
            throw new IllegalArgumentException("Unsupported resource type: " + resourceType);
        }
        return get("/ns/" + nsId + "/resources/" + resourceType, queryParams);
    }

    public Object getInfraList(String nsId, MultiValueMap<String, String> queryParams) {
        return get("/ns/" + nsId + "/infra", queryParams);
    }

    public Object getInfra(String nsId, String infraId, MultiValueMap<String, String> queryParams) {
        return get("/ns/" + nsId + "/infra/" + infraId, queryParams);
    }

    private Object get(String path, MultiValueMap<String, String> queryParams) {
        String url = UriComponentsBuilder
                .fromHttpUrl(normalizedBaseUrl() + path)
                .queryParams(queryParams)
                .build()
                .toUriString();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("application", "json", StandardCharsets.UTF_8));
        if (StringUtils.hasText(username) && StringUtils.hasText(password)) {
            headers.setBasicAuth(username, password);
        }

        log.debug("[mc-infra-manager] GET {}", url);
        ResponseEntity<Object> response = restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), Object.class);
        return response.getBody();
    }

    private String normalizedBaseUrl() {
        if (!StringUtils.hasText(baseUrl)) {
            throw new IllegalStateException("mc-infra-manager.base-url is empty");
        }
        return baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }
}
