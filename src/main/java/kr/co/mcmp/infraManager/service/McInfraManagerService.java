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
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
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

    public Object getNamespaces(MultiValueMap<String, String> queryParams) {
        try {
            return get("/ns", queryParams);
        } catch (RestClientResponseException e) {
            return handleCatalogLookupFailure("system", "/ns", e);
        }
    }

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
        if ("spec".equals(resourceType)) {
            return postResourceWithSystemFallback(nsId, "/resources/filterSpecsByRange", buildSpecFilter(queryParams));
        }
        return getResourceWithSystemFallback(nsId, "/resources/" + resourceType, queryParams);
    }

    public Object getInfraList(String nsId, MultiValueMap<String, String> queryParams) {
        if (!StringUtils.hasText(nsId)) {
            return Collections.emptyList();
        }
        try {
            return get("/ns/" + nsId + "/infra", queryParams);
        } catch (RestClientResponseException e) {
            return handleCatalogLookupFailure(nsId, "/infra", e);
        }
    }

    public Object getInfra(String nsId, String infraId, MultiValueMap<String, String> queryParams) {
        if (!StringUtils.hasText(nsId) || !StringUtils.hasText(infraId)) {
            return Collections.emptyList();
        }
        try {
            return get("/ns/" + nsId + "/infra/" + infraId, queryParams);
        } catch (RestClientResponseException e) {
            return handleCatalogLookupFailure(nsId, "/infra/" + infraId, e);
        }
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

    private Object post(String path, Object requestBody) {
        String url = UriComponentsBuilder
                .fromHttpUrl(normalizedBaseUrl() + path)
                .build()
                .toUriString();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("application", "json", StandardCharsets.UTF_8));
        if (StringUtils.hasText(username) && StringUtils.hasText(password)) {
            headers.setBasicAuth(username, password);
        }

        log.debug("[mc-infra-manager] POST {}", url);
        ResponseEntity<Object> response = restTemplate.exchange(url, HttpMethod.POST, new HttpEntity<>(requestBody, headers), Object.class);
        return response.getBody();
    }

    private Object getResourceWithSystemFallback(String nsId, String resourcePath, MultiValueMap<String, String> queryParams) {
        String namespace = StringUtils.hasText(nsId) ? nsId : "system";
        try {
            return get("/ns/" + namespace + resourcePath, queryParams);
        } catch (RestClientResponseException e) {
            if (!isNotFound(e) || "system".equals(namespace)) {
                return handleCatalogLookupFailure(namespace, resourcePath, e);
            }
            log.debug("[mc-infra-manager] Resource lookup failed for namespace {}. Retry with system namespace.", namespace);
            try {
                return get("/ns/system" + resourcePath, queryParams);
            } catch (RestClientResponseException fallbackException) {
                return handleCatalogLookupFailure("system", resourcePath, fallbackException);
            }
        }
    }

    private Object postResourceWithSystemFallback(String nsId, String resourcePath, Object requestBody) {
        String namespace = StringUtils.hasText(nsId) ? nsId : "system";
        try {
            return post("/ns/" + namespace + resourcePath, requestBody);
        } catch (RestClientResponseException e) {
            if (!isNotFound(e) || "system".equals(namespace)) {
                return handleCatalogLookupFailure(namespace, resourcePath, e);
            }
            log.debug("[mc-infra-manager] Resource lookup failed for namespace {}. Retry with system namespace.", namespace);
            try {
                return post("/ns/system" + resourcePath, requestBody);
            } catch (RestClientResponseException fallbackException) {
                return handleCatalogLookupFailure("system", resourcePath, fallbackException);
            }
        }
    }

    private Object handleCatalogLookupFailure(String nsId, String resourcePath, RestClientResponseException e) {
        if (isNotFound(e)) {
            log.warn("[mc-infra-manager] Resource catalog lookup returned 404. namespace: {}, path: {}, body: {}",
                    nsId,
                    resourcePath,
                    e.getResponseBodyAsString());
            return Collections.emptyList();
        }
        throw e;
    }

    private boolean isNotFound(RestClientResponseException e) {
        return e.getStatusCode().value() == 404;
    }

    private Map<String, Object> buildSpecFilter(MultiValueMap<String, String> queryParams) {
        Map<String, Object> filter = new LinkedHashMap<>();
        filter.put("limit", 0);

        putIfPresent(filter, "providerName", firstValue(queryParams, "providerName"));
        putIfPresent(filter, "regionName", firstValue(queryParams, "regionName"));

        String filterKey = firstValue(queryParams, "filterKey");
        String filterVal = firstValue(queryParams, "filterVal");
        if (StringUtils.hasText(filterKey) && StringUtils.hasText(filterVal)) {
            filter.put(toSpecFilterKey(filterKey), filterVal);
        }

        return filter;
    }

    private String toSpecFilterKey(String filterKey) {
        if ("region".equalsIgnoreCase(filterKey)) {
            return "regionName";
        }
        if ("provider".equalsIgnoreCase(filterKey)) {
            return "providerName";
        }
        return filterKey;
    }

    private void putIfPresent(Map<String, Object> target, String key, String value) {
        if (StringUtils.hasText(value)) {
            target.put(key, value);
        }
    }

    private String firstValue(MultiValueMap<String, String> queryParams, String key) {
        return queryParams == null ? null : queryParams.getFirst(key);
    }

    private String normalizedBaseUrl() {
        if (!StringUtils.hasText(baseUrl)) {
            throw new IllegalStateException("mc-infra-manager.base-url is empty");
        }
        return baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }
}
