package kr.co.strato.mcmp.infra.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.api.response.ResponseWrapper;
import kr.co.strato.mcmp.catalog.model.Catalog;
import kr.co.strato.mcmp.infra.model.InfraCommon;
import kr.co.strato.mcmp.infra.model.InfraNameSpace;
import kr.co.strato.mcmp.infra.model.Mcis;
import kr.co.strato.mcmp.infra.service.InfraProvisioningService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

//@Tag(name = "InfraProvisioning", description = "인프라 생성")
@RestController
public class InfraProvisioningController {

//    @Autowired
//    private InfraProvisioningService infraSvc;
//
//    @Operation(summary = "인프라 생성")
//    @PostMapping("/infra")
//    public ResponseWrapper<List<InfraCommon>> setInfra(InfraCommon infra) {
//        //infra; = new InfraCommon();
//        return new ResponseWrapper(infra);
//    }
//
//    @Operation(summary = "인프라 목록")
//    @GetMapping("/infra")
//    public ResponseWrapper<List<Mcis>> getInfra(@RequestParam String userName, @RequestParam String passWord) {
//        return new ResponseWrapper<>(infraSvc.getInfraList(userName, passWord));
//    }
//
//    @Operation(summary = "인프라 생성 및 카탈로그 배포")
//    @GetMapping("/infra/deploy")
//    public ResponseWrapper<List<InfraCommon>> setInfraDeploy(InfraCommon infra) {
//        //InfraCommon infra = new InfraCommon();
//
//        return new ResponseWrapper(infra);
//    }
//
//    @Operation(summary = "네임스페이스 목록")
//    @GetMapping("/ns")
//    public ResponseWrapper<List<InfraNameSpace>> getNamesapce(@RequestParam String userName, @RequestParam String passWord) {
//        return new ResponseWrapper<>(infraSvc.getNamespaceList(userName, passWord, null));
//    }
}
