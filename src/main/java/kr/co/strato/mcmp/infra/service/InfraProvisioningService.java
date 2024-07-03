package kr.co.strato.mcmp.infra.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.strato.mcmp.infra.model.InfraCommon;
import kr.co.strato.mcmp.infra.model.InfraNameSpace;
import kr.co.strato.mcmp.infra.model.Mcis;
import kr.co.strato.mcmp.oss.mapper.OssMapper;
import kr.co.strato.mcmp.oss.model.Oss;
import kr.co.strato.mcmp.util.AES256Util;
import lombok.Getter;
import org.apache.commons.collections4.CollectionUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class InfraProvisioningService {
    @Autowired
    private InfraRestClient client;

    @Autowired
    private OssMapper ossMapper;
    public String getVMName(int vmIdx){
        return "";
    }

    public List<Mcis> getInfraList(String userName, String passWord) {
        String baseUrl = getBaseUrl();

        List<Mcis> infraList = new ArrayList<>();
        List<InfraNameSpace> namespaceList = getNamespaceList(userName, passWord, null);

        CollectionUtils.emptyIfNull(namespaceList).stream().forEach(nameSpaceInfo -> {
            String apiUrl = String.format("%s/tumblebug/ns/%s/mcis?option=status", baseUrl, nameSpaceInfo.getId());

            ResponseEntity<Object> response = client.requestByBasicAuth(apiUrl, userName, passWord, HttpMethod.GET, null, Object.class);

            ObjectMapper mapper = new ObjectMapper();
            Map<String, List<Mcis>> infraResponse = mapper.convertValue(response.getBody(), new HashMap<String, ArrayList<Mcis>>().getClass());

            if(infraResponse.get("mcis") != null) {
                List<Mcis> mcisList = mapper.convertValue(infraResponse.get("mcis"), new TypeReference<>(){});

                for (Mcis mcis : mcisList) {
                    mcis.setNamespace(nameSpaceInfo.getName());
                    infraList.add(mcis);
                }
            }
        });

        return infraList;
    }

    public List<InfraNameSpace> getNamespaceList(String userName, String passWord, String baseurl) {
        String baseUrl = "";
        if(baseurl.isBlank()) {
            baseUrl = getBaseUrl();
        }
        else {
            baseUrl = baseurl;
        }
        List<InfraNameSpace> namespaceList = null;

        String plainTextPassword = AES256Util.decrypt(passWord);
        try {
            String apiUrl = String.format("%s/tumblebug/ns", baseUrl);
            ResponseEntity<Object> response = client.requestByBasicAuth(apiUrl, userName, plainTextPassword, HttpMethod.GET, null, Object.class);

            ObjectMapper mapper = new ObjectMapper();
            Map<String, List<InfraNameSpace>> namespaceResponse = mapper.convertValue(response.getBody(), new HashMap<String, List<InfraNameSpace>>().getClass());

            namespaceList = mapper.convertValue(namespaceResponse.get("ns"), new TypeReference<List<InfraNameSpace>>(){});
        } catch (Exception e) {
            new RuntimeException();
        }
        return namespaceList;
    }

    private String getBaseUrl() {
        Oss oss = null;

        try {
            oss = ossMapper.selectOssByOssCd("TUMBLEBUG");
        } catch (Exception e) {
            System.err.println(e);
        }
        return oss.getOssUrl();
    }
}
