package kr.co.mcmp.config;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.stream.Collectors;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.entity.Oss;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.workflow.service.WorkflowServiceImpl;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StreamUtils;

@Component
public class DatabaseInitializer implements CommandLineRunner{
    private static final String IMPORT_SQL = "classpath:import.sql";
    private static final String STAGE_CATALOG_START_MARKER = "-- Step 4-1: Insert category-managed workflow stages";
    private static final String STAGE_CATALOG_END_MARKER = "-- Step 5: Insert into workflow";
    private static final String SCENARIO_WORKFLOW_START_MARKER = "-- Step 8: Insert scenario workflows";
    private static final String SCENARIO_WORKFLOW_END_MARKER = "-- End Step 8";
    private static final String STAGE_TYPE_INSERT_PREFIX =
            "INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES";
    private static final String STAGE_TYPE_MERGE_PREFIX =
            "MERGE INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) KEY(workflow_stage_type_idx) VALUES";
    private static final String STAGE_INSERT_PREFIX =
            "INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES";
    private static final String STAGE_MERGE_PREFIX =
            "MERGE INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) KEY(workflow_stage_idx) VALUES";
    private static final List<IdentityColumn> IDENTITY_COLUMNS = List.of(
            new IdentityColumn("oss_type", "oss_type_idx"),
            new IdentityColumn("oss", "oss_idx"),
            new IdentityColumn("workflow_stage_type", "workflow_stage_type_idx"),
            new IdentityColumn("workflow_stage", "workflow_stage_idx"),
            new IdentityColumn("workflow", "workflow_idx"),
            new IdentityColumn("workflow_param", "param_idx"),
            new IdentityColumn("workflow_stage_mapping", "mapping_idx"),
            new IdentityColumn("workflow_history", "workflow_history_idx"),
            new IdentityColumn("workflow_param_history", "workflow_param_history_idx"),
            new IdentityColumn("event_listener", "event_listener_idx"),
            new IdentityColumn("event_listener_param", "event_listener_param_idx"),
            new IdentityColumn("user_actions_log", "user_actions_log_idx")
    );
    private static final List<LargeTextColumn> LARGE_TEXT_COLUMNS = List.of(
            new LargeTextColumn("workflow_param", "param_value"),
            new LargeTextColumn("event_listener_param", "param_value")
    );

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private ResourceLoader resourceLoader;

    @Autowired
    private OssRepository ossRepository;

    @Autowired
    private OssTypeRepository ossTypeRepository;

    @Autowired
    private WorkflowServiceImpl workflowService;

    @Autowired
    private JenkinsService jenkinsService;

    @Override
    public void run(String... args) throws Exception {
        ensureLargeTextColumns();
        if (isDatabaseEmpty()) {
            jdbcTemplate.execute(loadImportSql());
            resetIdentityColumns();
        } else {
            jdbcTemplate.execute(loadWorkflowStageCatalogMergeSql());
            resetIdentityColumns();
            jdbcTemplate.execute(loadScenarioWorkflowSeedSql());
            resetIdentityColumns();
        }
        synchronizeJenkinsJobs();
    }

    private void ensureLargeTextColumns() {
        for (LargeTextColumn largeTextColumn : LARGE_TEXT_COLUMNS) {
            try {
                jdbcTemplate.execute("ALTER TABLE " + largeTextColumn.tableName()
                        + " ALTER COLUMN " + largeTextColumn.columnName() + " CLOB");
            } catch (Exception e) {
                System.out.println("[DatabaseInitializer] Large text column migration skipped. table="
                        + largeTextColumn.tableName()
                        + ", column="
                        + largeTextColumn.columnName()
                        + ", message="
                        + e.getMessage());
            }
        }
    }

    private boolean isDatabaseEmpty() {
        Long count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM workflow", Long.class);
        return count != null && count == 0;
    }

    private String loadWorkflowStageCatalogSql() throws Exception {
        String sql = loadImportSql();
        int start = sql.indexOf(STAGE_CATALOG_START_MARKER);
        int end = sql.indexOf(STAGE_CATALOG_END_MARKER, start);

        if (start < 0 || end < 0) {
            throw new IllegalStateException("Workflow stage catalog block was not found in import.sql");
        }

        return sql.substring(start, end);
    }

    private String loadWorkflowStageCatalogMergeSql() throws Exception {
        return loadWorkflowStageCatalogSql()
                .replace(STAGE_TYPE_INSERT_PREFIX, STAGE_TYPE_MERGE_PREFIX)
                .replace(STAGE_INSERT_PREFIX, STAGE_MERGE_PREFIX);
    }

    private String loadScenarioWorkflowSeedSql() throws Exception {
        String sql = loadImportSql();
        int start = sql.indexOf(SCENARIO_WORKFLOW_START_MARKER);
        int end = sql.indexOf(SCENARIO_WORKFLOW_END_MARKER, start);

        if (start < 0 || end < 0) {
            throw new IllegalStateException("Scenario workflow seed block was not found in import.sql");
        }

        return removeIdentityRestartStatements(sql.substring(start, end));
    }

    private String loadImportSql() throws Exception {
        Resource resource = resourceLoader.getResource(IMPORT_SQL);
        return StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
    }

    private void synchronizeJenkinsJobs() {
        try {
            List<Long> jenkinsTypeIdxList = ossTypeRepository.findByOssTypeName("JENKINS")
                    .stream()
                    .map(OssType::getOssTypeIdx)
                    .collect(Collectors.toList());
            if (CollectionUtils.isEmpty(jenkinsTypeIdxList)) {
                return;
            }

            List<Oss> jenkinsList = ossRepository.findByOssTypeIdxIn(jenkinsTypeIdxList);
            if (CollectionUtils.isEmpty(jenkinsList)) {
                return;
            }

            for (Oss jenkins : jenkinsList) {
                OssDto jenkinsDto = OssDto.from(jenkins);
                if (!jenkinsService.isJenkinsConnect(jenkinsDto)) {
                    System.out.println("[DatabaseInitializer] Jenkins job synchronization skipped. Jenkins is not reachable: " + jenkinsDto.getOssUrl());
                    continue;
                }
                workflowService.createJenkinsJob("JENKINS", jenkinsDto);
            }
        } catch (Exception e) {
            // Jenkins may not be reachable during local startup. The readyz and OSS update paths can retry this sync.
            System.out.println("[DatabaseInitializer] Jenkins job synchronization skipped: " + e.getMessage());
        }
    }

    private String removeIdentityRestartStatements(String sql) {
        return sql
                .replaceAll("(?m)^ALTER TABLE workflow_param ALTER COLUMN param_idx RESTART WITH .+;\\R?", "")
                .replaceAll("(?m)^ALTER TABLE workflow_stage_mapping ALTER COLUMN mapping_idx RESTART WITH .+;\\R?", "");
    }

    private void resetIdentityColumns() {
        for (IdentityColumn identityColumn : IDENTITY_COLUMNS) {
            resetIdentityColumn(identityColumn.tableName(), identityColumn.columnName());
        }
    }

    private void resetIdentityColumn(String tableName, String columnName) {
        Long nextValue = jdbcTemplate.queryForObject(
                "SELECT COALESCE(MAX(" + columnName + "), 0) + 1 FROM " + tableName,
                Long.class);
        jdbcTemplate.execute("ALTER TABLE " + tableName + " ALTER COLUMN " + columnName + " RESTART WITH " + nextValue);
    }

    private record IdentityColumn(String tableName, String columnName) {
    }

    private record LargeTextColumn(String tableName, String columnName) {
    }
}
