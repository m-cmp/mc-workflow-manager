package kr.co.strato.mcmp.catalog.model;

import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.jenkins.model.JenkinsWorkflow;
import kr.co.strato.mcmp.workflow.model.Workflow;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Tag(name = "ApplicationCatalog", description = "SW 카탈로그 정보 상세")
public class SwCatalogDetail extends SwCatalog {

    public String scReference;

    public String scDescription;

    public List<Workflow> workflows;

    public List<SwCatalog> relationSwCatalog;

}
