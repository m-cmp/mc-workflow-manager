package kr.co.mcmp.workflow.tumblebug.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.workflow.tumblebug.dto.TumblebugDto;
import kr.co.mcmp.util.AES256Util;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Service
public class TumblebugService {
    private final TumblebugRestClient client;

    public List<TumblebugDto> getNamespaceList(OssDto ossDto) {

        List<TumblebugDto> namespaceList = null;
        try {
            String apiUrl = String.format("%s/tumblebug/ns", ossDto.getOssUrl());
            ResponseEntity<Object> response =
                client.requestByBasicAuth(apiUrl, ossDto.getOssUsername(), AES256Util.decrypt(ossDto.getOssPassword()), HttpMethod.GET, null, Object.class);

            Map<String, List<TumblebugDto>> namespaceResponse =
                new ObjectMapper().convertValue(response.getBody(), new HashMap<String, List<TumblebugDto>>().getClass());

            namespaceList =
                new ObjectMapper().convertValue(namespaceResponse.get("ns"), new TypeReference<List<TumblebugDto>>(){});
        } catch (Exception e) {
            new RuntimeException();
        }
        return namespaceList;
    }
}
