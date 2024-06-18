package kr.co.strato.mcmp.applications.controller;

import java.util.List;

import kr.co.strato.mcmp.api.response.ResponseWrapper;
import kr.co.strato.mcmp.applications.model.ArtifactHubPackage;
import kr.co.strato.mcmp.applications.model.ArtifactHubRespository;
import kr.co.strato.mcmp.applications.model.DockerHubCatalog;
import kr.co.strato.mcmp.applications.model.DockerHubNamespace;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.applications.service.ApplicationsService;


@Tag(name = "Applications", description = "어플리케이션 관리")
@RequestMapping("/applications")
@RestController
public class ApplicationsController {

    @Autowired
    private ApplicationsService appSvc;


    @Operation(summary = "artifactHub repository 목록 조회")
    @GetMapping("/search/artifacthub/repository/{keyword}")
    public ResponseWrapper<List<ArtifactHubRespository>> getRepositoryList(@PathVariable String keyword){
        https://artifacthub.io/api/v1/repositories/search?offset=0&limit=5&kind=0&name=argo
        if(keyword != null) {
            return new ResponseWrapper<>(appSvc.searchArtifactHubRepository(keyword));
        }else{
            return null;
        }
    }

    @Operation(summary = "artifactHub package 목록 조회(helm 조회)")
    @GetMapping("/search/artifacthub/package/{keyword}")
    public ResponseWrapper<ArtifactHubPackage> getPackageList(@PathVariable String keyword){
        if(keyword != null) {
            return new ResponseWrapper<>(appSvc.searchArtifactHubPackage(keyword));
        }else{
            return null;
        }
    }

    @Operation(summary = "dockerHub namespace 조회")
    @GetMapping("/search/dockerhub/namespace/{keyword}")
    public ResponseWrapper<DockerHubNamespace> getNamespaceInfo(@PathVariable String keyword){
        return new ResponseWrapper<>(appSvc.searchDockerHubNamespace(keyword));
    }

    @Operation(summary = "dockerHub catalog 조회(image 조회)")
    @GetMapping("/search/dockerhub/catalog/{keyword}")
    public ResponseWrapper<DockerHubCatalog> getCatalogList(@PathVariable String keyword){
        if(keyword != null) {
            return new ResponseWrapper<>(appSvc.searchDockerHubCatalog(keyword));
        }else{
            return null;
        }
    }

    @Operation(summary = "nexus 조회(repository 조회)")
    @GetMapping("/search/nexus/repository")
    public ResponseWrapper<DockerHubCatalog> getNexusRepository(@PathVariable String keyword){
        return null; //new ResponseWrapper<>(appSvc.searchNexusRepository(keyword));
    }


    /*
    @Operation(summary = "application 목록 조회")
    @GetMapping("/list")
    public String getApplicationList(){
        return null;
    }

    @Operation(summary = "application 내용 조회")
    @GetMapping("/{applicationIdx}}")
    public String getApplicationDetail(){
        return null;
    }

    @Operation(summary = "application 등록")
    @PostMapping("/app")
    public String setApplication() {
        return null;
    }

    @Operation(summary = "application 수정")
    @PutMapping("/{applicationIdx}}")
    public String editApplication() {
        return null;
    }

    @Operation(summary = "application 삭제")
    @DeleteMapping("/{applicationIdx}}")
    public String delApplication() {
        return null;
    }

    @Operation(summary = "application 설치")
    @GetMapping("/{applicationIdx}/{mcis}/install")
    public String installApplication() {
        return null;
    }

    @Operation(summary = "application 실행")
    @GetMapping("/{applicationIdx}}/{mcis}/run")
    public String runApplication() {
        return null;
    }

    @Operation(summary = "application 중지")
    @GetMapping("/{applicationIdx}}/{mcis}/stop")
    public String stopApplication() {
        return null;
    }

    @Operation(summary = "dockerHub 목록조회 - container")
    @GetMapping("/dockerhub")
    public ResponseWrapper<List<Catalog>> getCatalogListDockerHub(@RequestBody int nexusId) {
        return null;
    }

    @Operation(summary = "artifactHub 목록조회 - Helm")
    @GetMapping("/artifacthub")
    public ResponseWrapper<List<Catalog>> getCatalogListArtifactHub(@RequestBody int nexusId) {
        return null;
    }
*/

}
