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
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@Slf4j
@Service
public class McInfraManagerService {
    private static final Set<String> SUPPORTED_RESOURCE_TYPES = Set.of("image", "spec");
    private static final int DEFAULT_IMAGE_RESULT_LIMIT = 100;
    private static final int MAX_RESOURCE_RESULT_LIMIT = 500;
    private static final int DEFAULT_SPEC_RESULT_LIMIT = MAX_RESOURCE_RESULT_LIMIT;

    @Value("${mc-infra-manager.base-url}")
    private String baseUrl;

    @Value("${mc-infra-manager.username:}")
    private String username;

    @Value("${mc-infra-manager.password:}")
    private String password;

    private final RestTemplate restTemplate = new RestTemplate();

    public Object getNamespaces(MultiValueMap<String, String> queryParams) {
        try {
            return toCatalogList(get("/ns", queryParams));
        } catch (RestClientException e) {
            return handleCatalogLookupFailure("system", "/ns", e);
        }
    }

    public Object getRegionFromCsp(MultiValueMap<String, String> queryParams) {
        try {
            return toCatalogList(get("/regionFromCsp", queryParams));
        } catch (RestClientException e) {
            return handleCatalogLookupFailure("system", "/regionFromCsp", e);
        }
    }

    public Object getProviders(MultiValueMap<String, String> queryParams) {
        try {
            return toCatalogList(get("/provider", queryParams));
        } catch (RestClientException e) {
            return handleCatalogLookupFailure("system", "/provider", e);
        }
    }

    public Object getRegions(String providerName, MultiValueMap<String, String> queryParams) {
        try {
            return toCatalogList(get("/provider/" + providerName + "/region", queryParams));
        } catch (RestClientException e) {
            return handleCatalogLookupFailure("system", "/provider/" + providerName + "/region", e);
        }
    }

    public Object getConnConfigs(MultiValueMap<String, String> queryParams) {
        try {
            return filterConnectionConfigs(
                    toCatalogList(get("/connConfig", buildConnConfigQueryParams(queryParams))),
                    queryParams);
        } catch (RestClientException e) {
            return handleCatalogLookupFailure("system", "/connConfig", e);
        }
    }

    public Object getAvailableZones(MultiValueMap<String, String> queryParams) {
        if (!StringUtils.hasText(firstValue(queryParams, "specId"))) {
            return Collections.emptyList();
        }

        try {
            List<Object> result = toCatalogList(get("/availableZonesForSpec", queryParams));
            MultiValueMap<String, String> fallbackParams = buildAvailableZoneFallbackQueryParams(queryParams, result);
            if (fallbackParams != null) {
                return toCatalogList(get("/availableZonesForSpec", fallbackParams));
            }
            return result;
        } catch (RestClientException e) {
            return handleCatalogLookupFailure("system", "/availableZonesForSpec", e);
        }
    }

    public Object getResources(String nsId, String resourceType, MultiValueMap<String, String> queryParams) {
        if (!SUPPORTED_RESOURCE_TYPES.contains(resourceType)) {
            throw new IllegalArgumentException("Unsupported resource type: " + resourceType);
        }

        if ("image".equals(resourceType)) {
            Object searchResult = postResourceWithSystemFallback(nsId, "/resources/searchImage", buildImageSearchRequest(queryParams));
            if (hasImageMatchFilter(queryParams) || !isEmptyCatalogResult(searchResult)) {
                return normalizeResourceResult(resourceType, searchResult, queryParams);
            }
        }

        Object connectionLookupResult = lookupResourceByConnectionName(resourceType, queryParams);
        if (!isEmptyCatalogResult(connectionLookupResult)) {
            return normalizeResourceResult(resourceType, connectionLookupResult, queryParams);
        }

        if ("spec".equals(resourceType)) {
            Object result = postResourceWithSystemFallback(nsId, "/resources/filterSpecsByRange", buildSpecFilter(queryParams));
            return normalizeResourceResult(resourceType, result, queryParams);
        }
        Object result = getResourceWithSystemFallback(nsId, "/resources/" + resourceType, buildImageQueryParams(queryParams));
        return normalizeResourceResult(resourceType, result, queryParams);
    }

    public Object getInfraList(String nsId, MultiValueMap<String, String> queryParams) {
        if (!StringUtils.hasText(nsId)) {
            return Collections.emptyList();
        }
        try {
            return toCatalogList(get("/ns/" + nsId + "/infra", queryParams));
        } catch (RestClientException e) {
            return handleCatalogLookupFailure(nsId, "/infra", e);
        }
    }

    public Object getInfra(String nsId, String infraId, MultiValueMap<String, String> queryParams) {
        if (!StringUtils.hasText(nsId) || !StringUtils.hasText(infraId)) {
            return Collections.emptyList();
        }
        try {
            return get("/ns/" + nsId + "/infra/" + infraId, queryParams);
        } catch (RestClientException e) {
            return handleCatalogLookupFailure(nsId, "/infra/" + infraId, e);
        }
    }

    public Object reviewInfraDynamic(String nsId, MultiValueMap<String, String> queryParams, Object requestBody) {
        String namespace = StringUtils.hasText(nsId) ? nsId : "system";
        try {
            return post("/ns/" + namespace + "/infraDynamicReview" + buildRawQueryString(queryParams), requestBody);
        } catch (RestClientResponseException e) {
            Map<String, Object> error = new LinkedHashMap<>();
            error.put("reviewStatus", "Error");
            error.put("message", e.getResponseBodyAsString());
            error.put("statusCode", e.getStatusCode().value());
            return error;
        } catch (RestClientException e) {
            Map<String, Object> error = new LinkedHashMap<>();
            error.put("reviewStatus", "Error");
            error.put("message", e.getMessage());
            return error;
        }
    }

    private Object get(String path, MultiValueMap<String, String> queryParams) {
        String url = UriComponentsBuilder
                .fromHttpUrl(normalizedBaseUrl() + path)
                .queryParams(encodeQueryParams(queryParams))
                .build(true)
                .toUriString();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("application", "json", StandardCharsets.UTF_8));
        if (StringUtils.hasText(username) && StringUtils.hasText(password)) {
            headers.setBasicAuth(username, password);
        }

        URI uri = URI.create(url);
        log.debug("[mc-infra-manager] GET {}", uri);
        ResponseEntity<Object> response = restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(headers), Object.class);
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

    private String buildRawQueryString(MultiValueMap<String, String> queryParams) {
        if (queryParams == null || queryParams.isEmpty()) {
            return "";
        }

        StringBuilder queryString = new StringBuilder();
        queryParams.forEach((key, values) -> {
            if (values == null) {
                return;
            }
            for (String value : values) {
                if (!StringUtils.hasText(value)) {
                    continue;
                }
                if (queryString.length() == 0) {
                    queryString.append("?");
                } else {
                    queryString.append("&");
                }
                queryString
                        .append(URLEncoder.encode(key, StandardCharsets.UTF_8))
                        .append("=")
                        .append(URLEncoder.encode(value, StandardCharsets.UTF_8));
            }
        });
        return queryString.toString();
    }

    private Object getResourceWithSystemFallback(String nsId, String resourcePath, MultiValueMap<String, String> queryParams) {
        String namespace = StringUtils.hasText(nsId) ? nsId : "system";
        try {
            List<Object> result = toCatalogList(get("/ns/" + namespace + resourcePath, queryParams));
            if (result.isEmpty() && !"system".equals(namespace)) {
                log.debug("[mc-infra-manager] Resource lookup for namespace {} returned empty. Retry with system namespace.", namespace);
                return toCatalogList(get("/ns/system" + resourcePath, queryParams));
            }
            return result;
        } catch (RestClientException e) {
            if (!isNotFound(e) || "system".equals(namespace)) {
                return handleCatalogLookupFailure(namespace, resourcePath, e);
            }
            log.debug("[mc-infra-manager] Resource lookup failed for namespace {}. Retry with system namespace.", namespace);
            try {
                return toCatalogList(get("/ns/system" + resourcePath, queryParams));
            } catch (RestClientException fallbackException) {
                return handleCatalogLookupFailure("system", resourcePath, fallbackException);
            }
        }
    }

    private Object postResourceWithSystemFallback(String nsId, String resourcePath, Object requestBody) {
        String namespace = StringUtils.hasText(nsId) ? nsId : "system";
        try {
            List<Object> result = toCatalogList(post("/ns/" + namespace + resourcePath, requestBody));
            if (result.isEmpty() && !"system".equals(namespace)) {
                log.debug("[mc-infra-manager] Resource lookup for namespace {} returned empty. Retry with system namespace.", namespace);
                return toCatalogList(post("/ns/system" + resourcePath, requestBody));
            }
            return result;
        } catch (RestClientException e) {
            if (!isNotFound(e) || "system".equals(namespace)) {
                return handleCatalogLookupFailure(namespace, resourcePath, e);
            }
            log.debug("[mc-infra-manager] Resource lookup failed for namespace {}. Retry with system namespace.", namespace);
            try {
                return toCatalogList(post("/ns/system" + resourcePath, requestBody));
            } catch (RestClientException fallbackException) {
                return handleCatalogLookupFailure("system", resourcePath, fallbackException);
            }
        }
    }

    private Object handleCatalogLookupFailure(String nsId, String resourcePath, RestClientException e) {
        if (isNotFound(e)) {
            RestClientResponseException responseException = (RestClientResponseException) e;
            log.warn("[mc-infra-manager] Resource catalog lookup returned 404. namespace: {}, path: {}, body: {}",
                    nsId,
                    resourcePath,
                    responseException.getResponseBodyAsString());
            return Collections.emptyList();
        }

        log.warn("[mc-infra-manager] Resource catalog lookup failed. namespace: {}, path: {}, message: {}",
                nsId,
                resourcePath,
                e.getMessage());
        return Collections.emptyList();
    }

    private boolean isNotFound(RestClientException e) {
        return e instanceof RestClientResponseException responseException
                && responseException.getStatusCode().value() == 404;
    }

    private Map<String, Object> buildSpecFilter(MultiValueMap<String, String> queryParams) {
        Map<String, Object> filter = new LinkedHashMap<>();
        filter.put("limit", 0);

        putIfPresent(filter, "providerName", firstPresentValue(queryParams, "providerName", "provider", "csp"));
        putIfPresent(filter, "regionName", firstPresentValue(queryParams, "regionName", "region"));
        putIfPresent(filter, "connectionName", resolveConnectionName(queryParams));

        String filterKey = firstValue(queryParams, "filterKey");
        String filterVal = firstValue(queryParams, "filterVal");
        if (StringUtils.hasText(filterKey) && StringUtils.hasText(filterVal)) {
            filter.put(toSpecFilterKey(filterKey), filterVal);
        }

        return filter;
    }

    private MultiValueMap<String, String> buildAvailableZoneFallbackQueryParams(
            MultiValueMap<String, String> queryParams,
            List<Object> lookupResult) {
        if (!isEmptyOrSpecNotFoundResult(lookupResult)) {
            return null;
        }

        String normalizedSpecId = normalizeTencentZoneSpecId(firstValue(queryParams, "specId"));
        if (!StringUtils.hasText(normalizedSpecId)) {
            return null;
        }

        org.springframework.util.LinkedMultiValueMap<String, String> fallbackParams = new org.springframework.util.LinkedMultiValueMap<>();
        if (queryParams != null) {
            fallbackParams.addAll(queryParams);
        }
        fallbackParams.set("specId", normalizedSpecId);
        return fallbackParams;
    }

    @SuppressWarnings("unchecked")
    private boolean isEmptyOrSpecNotFoundResult(List<Object> lookupResult) {
        if (lookupResult == null || lookupResult.isEmpty()) {
            return true;
        }

        if (lookupResult.size() != 1 || !(lookupResult.get(0) instanceof Map<?, ?> resultMap)) {
            return false;
        }

        String errorCode = valueAsString(((Map<String, Object>) resultMap).get("errorCode"));
        return "SPEC_NOT_FOUND".equalsIgnoreCase(errorCode);
    }

    private String normalizeTencentZoneSpecId(String specId) {
        if (!StringUtils.hasText(specId)) {
            return null;
        }

        String[] parts = specId.split("\\+", 3);
        if (parts.length != 3 || !"tencent".equalsIgnoreCase(parts[0])) {
            return null;
        }

        String normalizedRegion = parts[1].replaceFirst("-\\d+$", "");
        if (normalizedRegion.equals(parts[1])) {
            return null;
        }

        return parts[0] + "+" + normalizedRegion + "+" + parts[2];
    }

    private MultiValueMap<String, String> buildConnConfigQueryParams(MultiValueMap<String, String> queryParams) {
        org.springframework.util.LinkedMultiValueMap<String, String> connConfigQueryParams = new org.springframework.util.LinkedMultiValueMap<>();
        copyIfPresent(connConfigQueryParams, queryParams, "filterCredentialHolder");
        copyIfPresent(connConfigQueryParams, queryParams, "filterVerified");
        copyIfPresent(connConfigQueryParams, queryParams, "filterRegionRepresentative");
        return connConfigQueryParams;
    }

    private MultiValueMap<String, String> buildImageQueryParams(MultiValueMap<String, String> queryParams) {
        org.springframework.util.LinkedMultiValueMap<String, String> imageQueryParams = new org.springframework.util.LinkedMultiValueMap<>();
        if (queryParams != null) {
            imageQueryParams.addAll(queryParams);
        }

        imageQueryParams.remove("providerName");
        imageQueryParams.remove("provider");
        imageQueryParams.remove("csp");
        imageQueryParams.remove("regionName");
        imageQueryParams.remove("region");
        imageQueryParams.remove("connectionName");
        imageQueryParams.remove("connConfigName");
        imageQueryParams.remove("configName");
        imageQueryParams.remove("limit");
        imageQueryParams.remove("maxResults");
        return imageQueryParams;
    }

    private Map<String, Object> buildImageSearchRequest(MultiValueMap<String, String> queryParams) {
        Map<String, Object> request = new LinkedHashMap<>();
        putIfPresent(request, "providerName", firstPresentValue(queryParams, "providerName", "provider", "csp"));
        putIfPresent(request, "regionName", firstPresentValue(queryParams, "regionName", "region"));
        putIfPresent(request, "osType", firstPresentValue(queryParams, "osType", "imageSearch", "keyword"));
        putIfPresent(request, "matchedSpecId", firstPresentValue(queryParams, "matchedSpecId", "specId", "SPEC_ID"));
        putIfPresent(request, "osArchitecture", firstPresentValue(queryParams, "osArchitecture", "architecture"));
        putIfPresent(request, "detailSearchKeys", splitDetailSearchKeys(queryParams));

        putIfPresent(request, "includeBasicImageOnly", firstBooleanValue(queryParams, "includeBasicImageOnly"));
        putIfPresent(request, "includeDeprecatedImage", firstBooleanValue(queryParams, "includeDeprecatedImage"));
        putIfPresent(request, "isGPUImage", firstBooleanValue(queryParams, "isGPUImage"));
        putIfPresent(request, "isKubernetesImage", firstBooleanValue(queryParams, "isKubernetesImage"));
        putIfPresent(request, "isRegisteredByAsset", firstBooleanValue(queryParams, "isRegisteredByAsset"));

        request.put("maxResults", resolveResultLimit(queryParams, DEFAULT_IMAGE_RESULT_LIMIT));
        return request;
    }

    private boolean hasImageMatchFilter(MultiValueMap<String, String> queryParams) {
        return StringUtils.hasText(firstPresentValue(queryParams, "matchedSpecId", "specId", "SPEC_ID"));
    }

    private Object normalizeResourceResult(String resourceType, Object result, MultiValueMap<String, String> queryParams) {
        List<Object> compacted = compactResourceList(resourceType, toCatalogList(result), queryParams);
        return filterCatalogList(compacted, queryParams);
    }

    @SuppressWarnings("unchecked")
    private List<Object> compactResourceList(String resourceType, List<Object> resourceList, MultiValueMap<String, String> queryParams) {
        if (resourceList.isEmpty()) {
            return resourceList;
        }

        int limit = resolveResultLimit(
                queryParams,
                "image".equals(resourceType) ? DEFAULT_IMAGE_RESULT_LIMIT : DEFAULT_SPEC_RESULT_LIMIT);

        if ("spec".equals(resourceType)) {
            List<Object> compacted = new ArrayList<>();
            for (Object item : resourceList) {
                if (!(item instanceof Map<?, ?> itemMap)) {
                    compacted.add(item);
                    continue;
                }

                Map<String, Object> typedItemMap = (Map<String, Object>) itemMap;
                compacted.add(compactSpec(typedItemMap, queryParams));
            }
            compacted.sort(this::compareSpecCatalogItems);
            return compacted.size() > limit ? new ArrayList<>(compacted.subList(0, limit)) : compacted;
        }

        List<Object> compacted = new ArrayList<>();
        for (Object item : resourceList) {
            if (compacted.size() >= limit) {
                break;
            }
            if (!(item instanceof Map<?, ?> itemMap)) {
                compacted.add(item);
                continue;
            }

            Map<String, Object> typedItemMap = (Map<String, Object>) itemMap;
            compacted.add(compactImage(typedItemMap, queryParams));
        }
        return compacted;
    }

    private Map<String, Object> compactImage(Map<String, Object> source, MultiValueMap<String, String> queryParams) {
        String providerName = firstNonBlank(
                valueAsString(source.get("providerName")),
                valueAsString(source.get("provider")),
                valueAsString(source.get("csp")),
                firstPresentValue(queryParams, "providerName", "provider", "csp"));
        String regionName = firstNonBlank(
                valueAsString(source.get("regionName")),
                valueAsString(source.get("region")),
                valueAsString(source.get("regionId")),
                valueAsString(source.get("regionZoneInfoName")),
                firstPresentValue(queryParams, "regionName", "region"));
        String connectionName = firstNonBlank(
                valueAsString(source.get("connectionName")),
                valueAsString(source.get("connConfigName")),
                valueAsString(source.get("configName")),
                resolveConnectionName(queryParams));

        String imageId = firstNonBlank(
                valueAsString(source.get("id")),
                valueAsString(source.get("imageId")),
                valueAsString(source.get("cspImageId")),
                valueAsString(source.get("imageName")),
                nestedString(source, "IId", "NameId"),
                nestedString(source, "iid", "nameId"),
                keyValueListString(source, "ImageId"),
                keyValueListString(source, "ImageID"),
                valueAsString(source.get("Name")),
                valueAsString(source.get("name")));
        String cspImageId = firstNonBlank(
                valueAsString(source.get("cspImageId")),
                nestedString(source, "IId", "SystemId"),
                nestedString(source, "iid", "systemId"),
                keyValueListString(source, "ImageId"),
                imageId);
        String osDistribution = firstNonBlank(
                valueAsString(source.get("osDistribution")),
                valueAsString(source.get("OSDistribution")));
        String guestOS = firstNonBlank(
                valueAsString(source.get("guestOS")),
                valueAsString(source.get("GuestOS")),
                valueAsString(source.get("guestOs")));
        String description = firstNonBlank(
                valueAsString(source.get("description")),
                valueAsString(source.get("Description")));
        String imageName = firstNonBlank(
                valueAsString(source.get("imageName")),
                valueAsString(source.get("cspImageName")),
                keyValueListString(source, "Name"),
                guestOS,
                osDistribution,
                description,
                valueAsString(source.get("name")),
                imageId);
        String label = imageId;
        if (StringUtils.hasText(imageId) && StringUtils.hasText(imageName) && !imageName.equals(imageId)) {
            label = imageId + " / " + imageName;
        } else if (!StringUtils.hasText(label)) {
            label = imageName;
        }

        Map<String, Object> target = new LinkedHashMap<>();
        putIfPresent(target, "id", imageId);
        putIfPresent(target, "name", label);
        putIfPresent(target, "displayName", imageName);
        putIfPresent(target, "imageId", imageId);
        putIfPresent(target, "imageName", imageName);
        putIfPresent(target, "cspImageId", cspImageId);
        putIfPresent(target, "cspImageName", firstNonBlank(valueAsString(source.get("cspImageName")), imageName));
        putIfPresent(target, "providerName", providerName);
        putIfPresent(target, "regionName", regionName);
        putIfPresent(target, "connectionName", connectionName);
        putIfPresent(target, "osArchitecture", firstNonBlank(valueAsString(source.get("osArchitecture")), valueAsString(source.get("OSArchitecture"))));
        putIfPresent(target, "osPlatform", firstNonBlank(valueAsString(source.get("osPlatform")), valueAsString(source.get("OSPlatform"))));
        putIfPresent(target, "osDistribution", osDistribution);
        putIfPresent(target, "guestOS", guestOS);
        putIfPresent(target, "description", description);
        putIfPresent(target, "imageStatus", firstNonBlank(valueAsString(source.get("imageStatus")), valueAsString(source.get("ImageStatus"))));
        putIfPresent(target, "creationDate", firstNonBlank(valueAsString(source.get("creationDate")), keyValueListString(source, "CreationDate")));
        return target;
    }

    private Map<String, Object> compactSpec(Map<String, Object> source, MultiValueMap<String, String> queryParams) {
        String providerName = firstNonBlank(
                valueAsString(source.get("providerName")),
                valueAsString(source.get("provider")),
                valueAsString(source.get("csp")),
                firstPresentValue(queryParams, "providerName", "provider", "csp"));
        String regionName = firstNonBlank(
                firstPresentValue(queryParams, "regionName", "region"),
                valueAsString(source.get("regionName")),
                valueAsString(source.get("region")),
                valueAsString(source.get("regionId")),
                valueAsString(source.get("Region")));
        String connectionName = firstNonBlank(
                valueAsString(source.get("connectionName")),
                valueAsString(source.get("connConfigName")),
                valueAsString(source.get("configName")),
                resolveConnectionName(queryParams));

        String cspSpecName = firstNonBlank(
                valueAsString(source.get("cspSpecName")),
                valueAsString(source.get("CspSpecName")),
                valueAsString(source.get("specName")),
                valueAsString(source.get("Name")),
                valueAsString(source.get("VMSpecName")),
                valueAsString(source.get("name")));
        String specId = firstNonBlank(
                valueAsString(source.get("id")),
                valueAsString(source.get("specId")),
                valueAsString(source.get("cspSpecId")),
                nestedString(source, "IId", "NameId"),
                nestedString(source, "iid", "nameId"),
                buildTumblebugResourceId(providerName, regionName, cspSpecName),
                cspSpecName);
        String specName = firstNonBlank(
                valueAsString(source.get("name")),
                valueAsString(source.get("specName")),
                valueAsString(source.get("cspSpecName")),
                valueAsString(source.get("CspSpecName")),
                valueAsString(source.get("Name")),
                valueAsString(source.get("VMSpecName")),
                specId);

        Map<String, Object> target = new LinkedHashMap<>();
        putIfPresent(target, "id", specId);
        putIfPresent(target, "name", specName);
        putIfPresent(target, "displayName", specName);
        putIfPresent(target, "specId", specId);
        putIfPresent(target, "specName", specName);
        putIfPresent(target, "cspSpecId", firstNonBlank(valueAsString(source.get("cspSpecId")), cspSpecName, specId));
        putIfPresent(target, "cspSpecName", cspSpecName);
        putIfPresent(target, "providerName", providerName);
        putIfPresent(target, "regionName", regionName);
        putIfPresent(target, "connectionName", connectionName);
        putIfPresent(target, "vCpu", firstNonBlank(valueAsString(source.get("vCpu")), nestedString(source, "VCpu", "Count"), valueAsString(source.get("vCPU")), valueAsString(source.get("num_vCPU"))));
        putIfPresent(target, "memoryGiB", firstNonBlank(valueAsString(source.get("memoryGiB")), valueAsString(source.get("mem_GiB")), mibToGiB(source.get("MemSizeMib"))));
        return target;
    }

    @SuppressWarnings("unchecked")
    private int compareSpecCatalogItems(Object left, Object right) {
        if (!(left instanceof Map<?, ?> leftMap) || !(right instanceof Map<?, ?> rightMap)) {
            return 0;
        }

        Map<String, Object> leftSpec = (Map<String, Object>) leftMap;
        Map<String, Object> rightSpec = (Map<String, Object>) rightMap;

        int cpuCompare = Double.compare(specNumericValue(leftSpec, "vCpu"), specNumericValue(rightSpec, "vCpu"));
        if (cpuCompare != 0) {
            return cpuCompare;
        }

        int memoryCompare = Double.compare(specNumericValue(leftSpec, "memoryGiB"), specNumericValue(rightSpec, "memoryGiB"));
        if (memoryCompare != 0) {
            return memoryCompare;
        }

        String leftName = firstNonBlank(valueAsString(leftSpec.get("specName")), valueAsString(leftSpec.get("name")), valueAsString(leftSpec.get("id")), "");
        String rightName = firstNonBlank(valueAsString(rightSpec.get("specName")), valueAsString(rightSpec.get("name")), valueAsString(rightSpec.get("id")), "");
        return leftName.compareToIgnoreCase(rightName);
    }

    private double specNumericValue(Map<String, Object> spec, String key) {
        String value = valueAsString(spec.get(key));
        if (!StringUtils.hasText(value)) {
            return Double.MAX_VALUE;
        }

        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return Double.MAX_VALUE;
        }
    }

    private String buildTumblebugResourceId(String providerName, String regionName, String resourceName) {
        if (!StringUtils.hasText(providerName) || !StringUtils.hasText(regionName) || !StringUtils.hasText(resourceName)) {
            return null;
        }
        return providerName + "+" + regionName + "+" + resourceName;
    }

    private String mibToGiB(Object value) {
        String text = valueAsString(value);
        if (!StringUtils.hasText(text)) {
            return null;
        }
        try {
            double gib = Double.parseDouble(text) / 1024D;
            if (gib == Math.rint(gib)) {
                return String.valueOf((long) gib);
            }
            return String.format(java.util.Locale.US, "%.2f", gib);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Object lookupResourceByConnectionName(String resourceType, MultiValueMap<String, String> queryParams) {
        String connectionName = resolveConnectionName(queryParams);
        if (!StringUtils.hasText(connectionName)) {
            return Collections.emptyList();
        }

        String path = "spec".equals(resourceType) ? "/lookupSpecs" : "/lookupImages";
        try {
            return toCatalogList(post(path, Map.of("connectionName", connectionName)));
        } catch (RestClientException e) {
            log.warn("[mc-infra-manager] {} lookup failed. connectionName: {}, message: {}",
                    resourceType,
                    connectionName,
                    e.getMessage());
            return Collections.emptyList();
        }
    }

    private boolean isEmptyCatalogResult(Object result) {
        return toCatalogList(result).isEmpty();
    }

    private String resolveConnectionName(MultiValueMap<String, String> queryParams) {
        String connectionName = firstPresentValue(queryParams, "connectionName", "connConfigName", "configName");
        if (StringUtils.hasText(connectionName)) {
            return connectionName;
        }

        String providerName = firstPresentValue(queryParams, "providerName", "provider", "csp");
        String regionName = firstPresentValue(queryParams, "regionName", "region");
        if (StringUtils.hasText(providerName) && StringUtils.hasText(regionName)) {
            return providerName + "-" + regionName;
        }
        return "";
    }

    @SuppressWarnings("unchecked")
    private List<Object> filterCatalogList(List<Object> resourceList, MultiValueMap<String, String> queryParams) {
        if (resourceList.isEmpty() || queryParams == null) {
            return resourceList;
        }

        String providerName = firstPresentValue(queryParams, "providerName", "provider", "csp");
        String regionName = firstPresentValue(queryParams, "regionName", "region");
        if (!StringUtils.hasText(providerName) && !StringUtils.hasText(regionName)) {
            return resourceList;
        }

        return resourceList.stream()
                .filter(item -> {
                    if (!(item instanceof Map<?, ?> itemMap)) {
                        return true;
                    }

                    Map<String, Object> map = (Map<String, Object>) itemMap;
                    boolean providerMatched = !StringUtils.hasText(providerName)
                            || equalsIgnoreCase(valueAsString(map.get("providerName")), providerName)
                            || equalsIgnoreCase(valueAsString(map.get("provider")), providerName)
                            || equalsIgnoreCase(valueAsString(map.get("csp")), providerName);
                    boolean regionMatched = !StringUtils.hasText(regionName) || containsRegion(map, regionName);
                    return providerMatched && regionMatched;
                })
                .collect(java.util.stream.Collectors.toList());
    }

    @SuppressWarnings("unchecked")
    private List<Object> filterConnectionConfigs(List<Object> connConfigs, MultiValueMap<String, String> queryParams) {
        if (connConfigs.isEmpty() || queryParams == null) {
            return connConfigs;
        }

        String providerName = firstPresentValue(queryParams, "providerName", "provider", "csp");
        String regionName = firstPresentValue(queryParams, "regionName", "region");
        String connectionName = firstPresentValue(queryParams, "connectionName", "connConfigName", "configName");
        if (!StringUtils.hasText(providerName) && !StringUtils.hasText(regionName) && !StringUtils.hasText(connectionName)) {
            return connConfigs;
        }

        return connConfigs.stream()
                .filter(item -> {
                    if (!(item instanceof Map<?, ?> itemMap)) {
                        return true;
                    }

                    Map<String, Object> map = (Map<String, Object>) itemMap;
                    boolean providerMatched = !StringUtils.hasText(providerName)
                            || equalsIgnoreCase(valueAsString(map.get("providerName")), providerName)
                            || equalsIgnoreCase(valueAsString(map.get("provider")), providerName)
                            || equalsIgnoreCase(valueAsString(map.get("csp")), providerName);
                    boolean regionMatched = !StringUtils.hasText(regionName) || containsRegion(map, regionName);
                    boolean connectionMatched = !StringUtils.hasText(connectionName)
                            || equalsIgnoreCase(valueAsString(map.get("configName")), connectionName)
                            || equalsIgnoreCase(valueAsString(map.get("connectionName")), connectionName);
                    return providerMatched && regionMatched && connectionMatched;
                })
                .collect(java.util.stream.Collectors.toList());
    }

    @SuppressWarnings("unchecked")
    private boolean containsRegion(Map<String, Object> map, String regionName) {
        if (matchesRegionName(valueAsString(map.get("regionName")), regionName)
                || matchesRegionName(valueAsString(map.get("region")), regionName)
                || matchesRegionName(valueAsString(map.get("regionId")), regionName)
                || matchesRegionName(valueAsString(map.get("regionZoneInfoName")), regionName)) {
            return true;
        }

        if (containsRegionInNestedMap(map.get("regionZoneInfo"), regionName)
                || containsRegionInNestedMap(map.get("regionDetail"), regionName)) {
            return true;
        }

        Object regionList = map.get("regionList");
        if (regionList instanceof List<?> list) {
            return list.stream().anyMatch(region -> {
                if (region instanceof Map<?, ?> regionMap) {
                    Map<String, Object> typedRegionMap = (Map<String, Object>) regionMap;
                    return matchesRegionName(valueAsString(typedRegionMap.get("regionName")), regionName)
                            || matchesRegionName(valueAsString(typedRegionMap.get("region")), regionName)
                            || matchesRegionName(valueAsString(typedRegionMap.get("regionId")), regionName);
                }
                return matchesRegionName(valueAsString(region), regionName);
            });
        }

        return false;
    }

    @SuppressWarnings("unchecked")
    private boolean containsRegionInNestedMap(Object value, String regionName) {
        if (!(value instanceof Map<?, ?> nestedMap)) {
            return false;
        }

        Map<String, Object> map = (Map<String, Object>) nestedMap;
        return matchesRegionName(valueAsString(map.get("assignedRegion")), regionName)
                || matchesRegionName(valueAsString(map.get("regionName")), regionName)
                || matchesRegionName(valueAsString(map.get("region")), regionName)
                || matchesRegionName(valueAsString(map.get("regionId")), regionName);
    }

    private boolean matchesRegionName(String actual, String expected) {
        if (!StringUtils.hasText(actual) || !StringUtils.hasText(expected)) {
            return false;
        }

        String normalizedActual = actual.trim();
        String normalizedExpected = expected.trim();
        return normalizedActual.equalsIgnoreCase(normalizedExpected)
                || normalizedActual.toLowerCase(Locale.ROOT).startsWith(normalizedExpected.toLowerCase(Locale.ROOT) + "-");
    }

    private boolean equalsIgnoreCase(String actual, String expected) {
        return actual != null && expected != null && actual.equalsIgnoreCase(expected);
    }

    private String valueAsString(Object value) {
        return value == null ? null : String.valueOf(value);
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

    private int resolveResultLimit(MultiValueMap<String, String> queryParams, int defaultLimit) {
        String configuredLimit = firstPresentValue(queryParams, "maxResults", "limit");
        if (!StringUtils.hasText(configuredLimit)) {
            return defaultLimit;
        }

        try {
            int limit = Integer.parseInt(configuredLimit);
            if (limit <= 0) {
                return defaultLimit;
            }
            return Math.min(limit, MAX_RESOURCE_RESULT_LIMIT);
        } catch (NumberFormatException e) {
            return defaultLimit;
        }
    }

    private List<String> splitDetailSearchKeys(MultiValueMap<String, String> queryParams) {
        String detailSearchKeys = firstPresentValue(queryParams, "detailSearchKeys", "detailSearchKey", "keywords");
        if (!StringUtils.hasText(detailSearchKeys)) {
            return Collections.emptyList();
        }

        String[] parts = detailSearchKeys.split(",");
        List<String> result = new ArrayList<>();
        for (String part : parts) {
            if (StringUtils.hasText(part)) {
                result.add(part.trim());
            }
        }
        return result;
    }

    private Boolean firstBooleanValue(MultiValueMap<String, String> queryParams, String key) {
        String value = firstValue(queryParams, key);
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return Boolean.parseBoolean(value);
    }

    @SuppressWarnings("unchecked")
    private String nestedString(Map<String, Object> source, String objectKey, String nestedKey) {
        Object nested = source.get(objectKey);
        if (!(nested instanceof Map<?, ?> nestedMap)) {
            return null;
        }

        return valueAsString(((Map<String, Object>) nestedMap).get(nestedKey));
    }

    @SuppressWarnings("unchecked")
    private String keyValueListString(Map<String, Object> source, String key) {
        Object keyValueList = source.get("KeyValueList");
        if (!(keyValueList instanceof List<?> list)) {
            keyValueList = source.get("keyValueList");
        }
        if (!(keyValueList instanceof List<?> list)) {
            return null;
        }

        for (Object item : list) {
            if (!(item instanceof Map<?, ?> itemMap)) {
                continue;
            }

            Map<String, Object> typedItemMap = (Map<String, Object>) itemMap;
            String itemKey = firstNonBlank(
                    valueAsString(typedItemMap.get("Key")),
                    valueAsString(typedItemMap.get("key")),
                    valueAsString(typedItemMap.get("Name")),
                    valueAsString(typedItemMap.get("name")));
            if (equalsIgnoreCase(itemKey, key)) {
                return firstNonBlank(
                        valueAsString(typedItemMap.get("Value")),
                        valueAsString(typedItemMap.get("value")));
            }
        }
        return null;
    }

    private String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }

        for (String value : values) {
            if (StringUtils.hasText(value)) {
                return value;
            }
        }
        return null;
    }

    private void putIfPresent(Map<String, Object> target, String key, String value) {
        if (StringUtils.hasText(value)) {
            target.put(key, value);
        }
    }

    private void putIfPresent(Map<String, Object> target, String key, Object value) {
        if (value == null) {
            return;
        }
        if (value instanceof String stringValue && !StringUtils.hasText(stringValue)) {
            return;
        }
        if (value instanceof List<?> listValue && listValue.isEmpty()) {
            return;
        }
        target.put(key, value);
    }

    private void copyIfPresent(
            org.springframework.util.LinkedMultiValueMap<String, String> target,
            MultiValueMap<String, String> source,
            String key) {
        if (source == null) {
            return;
        }

        List<String> values = source.get(key);
        if (values != null) {
            target.put(key, new ArrayList<>(values));
        }
    }

    private MultiValueMap<String, String> encodeQueryParams(MultiValueMap<String, String> queryParams) {
        org.springframework.util.LinkedMultiValueMap<String, String> encodedParams = new org.springframework.util.LinkedMultiValueMap<>();
        if (queryParams == null) {
            return encodedParams;
        }

        queryParams.forEach((key, values) -> {
            if (values == null) {
                return;
            }
            for (String value : values) {
                encodedParams.add(key, value == null ? null : encodeQueryParamValue(value));
            }
        });
        return encodedParams;
    }

    private String encodeQueryParamValue(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8).replace("+", "%20");
    }

    private List<Object> toCatalogList(Object response) {
        List<Object> list = findFirstList(response);
        if (list != null) {
            return list;
        }

        if (response == null) {
            return Collections.emptyList();
        }

        return Collections.singletonList(response);
    }

    @SuppressWarnings("unchecked")
    private List<Object> findFirstList(Object value) {
        if (value instanceof List<?>) {
            return new ArrayList<>((List<Object>) value);
        }

        if (!(value instanceof Map<?, ?> map)) {
            return null;
        }

        String[] preferredKeys = {
                "ns", "namespace", "namespaces", "namespaceList",
                "provider", "providers", "providerList",
                "connectionconfig", "connConfig", "connConfigs", "connectionConfig", "connectionConfigs",
                "regions", "region", "regionList",
                "availableZones", "allVerifiedZones", "zones", "zoneList",
                "images", "image", "imageList", "customImage",
                "specs", "spec", "specList", "vmspec", "vmSpec", "VMSpec", "vmSpecs", "VMSpecs",
                "infra", "infras", "infraList",
                "K8sClusterInfo", "k8sCluster", "k8sClusterList",
                "output", "idList",
                "resources", "resource", "resourceList",
                "items", "list", "result"
        };

        for (String key : preferredKeys) {
            if (!map.containsKey(key)) {
                continue;
            }
            Object nested = map.get(key);
            if (nested == null) {
                return new ArrayList<>();
            }
            if (nested instanceof List<?>) {
                return new ArrayList<>((List<Object>) nested);
            }
        }

        for (Object nested : map.values()) {
            List<Object> nestedList = findFirstList(nested);
            if (nestedList != null) {
                return nestedList;
            }
        }

        return null;
    }

    private String firstValue(MultiValueMap<String, String> queryParams, String key) {
        return queryParams == null ? null : queryParams.getFirst(key);
    }

    private String firstPresentValue(MultiValueMap<String, String> queryParams, String... keys) {
        if (queryParams == null) {
            return null;
        }
        for (String key : keys) {
            String value = queryParams.getFirst(key);
            if (StringUtils.hasText(value)) {
                return value;
            }
        }
        return null;
    }

    private String normalizedBaseUrl() {
        if (!StringUtils.hasText(baseUrl)) {
            throw new IllegalStateException("mc-infra-manager.base-url is empty");
        }
        return baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }
}
