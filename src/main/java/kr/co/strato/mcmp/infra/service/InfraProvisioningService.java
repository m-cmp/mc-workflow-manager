package kr.co.strato.mcmp.infra.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.strato.mcmp.infra.model.InfraCommon;
import kr.co.strato.mcmp.infra.model.InfraNameSpace;
import kr.co.strato.mcmp.infra.model.Mcis;
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

    private final String baseUrl = "http://3.35.167.122:1323";
    @Autowired
    private InfraRestClient client;
    public String getVMName(int vmIdx){
        return "";
    }

    public List<Mcis> getInfraList(String userName, String passWord) {
        List<Mcis> infraList = new ArrayList<>();
        List<InfraNameSpace> namespaceList = getNamespaceList(userName, passWord);

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

    public List<InfraNameSpace> getNamespaceList(String userName, String passWord) {
        String apiUrl = String.format("%s/tumblebug/ns", baseUrl);

        ResponseEntity<Object> response = client.requestByBasicAuth(apiUrl, userName, passWord, HttpMethod.GET, null, Object.class);

        ObjectMapper mapper = new ObjectMapper();
        Map<String, List<InfraNameSpace>> namespaceResponse = mapper.convertValue(response.getBody(), new HashMap<String, List<InfraNameSpace>>().getClass());

        List<InfraNameSpace> namespaceList = mapper.convertValue(namespaceResponse.get("ns"), new TypeReference<List<InfraNameSpace>>(){});

        return namespaceList;
    }
}
