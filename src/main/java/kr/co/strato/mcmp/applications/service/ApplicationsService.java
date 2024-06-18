package kr.co.strato.mcmp.applications.service;

import kr.co.strato.mcmp.applications.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ApplicationsService {

    @Autowired
    private ArtifactHubInteface atfInt;

    @Autowired
    private DockerHubInterface dohInt;

    public List<ArtifactHubRespository> searchArtifactHubRepository(String keyword){
        return atfInt.searchRepository(keyword);
    }

    public ArtifactHubPackage searchArtifactHubPackage(String keyword){
        return atfInt.searchPackage(keyword, "0");
    }

    public DockerHubNamespace searchDockerHubNamespace(String keyword){
        return dohInt.searchNamespace(keyword);
    }

    public DockerHubCatalog searchDockerHubCatalog(String keyword){
        return dohInt.searchCatalog(keyword);
    }

    public List<NexusRepository> searchNexusRepository(String keyword){
        return null;
    }


}

