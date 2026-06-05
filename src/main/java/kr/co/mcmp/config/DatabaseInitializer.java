package kr.co.mcmp.config;

import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
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

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private ResourceLoader resourceLoader;

    @Override
    public void run(String... args) throws Exception {
        if (isDatabaseEmpty()) {
            jdbcTemplate.execute(loadImportSql());
        } else {
            jdbcTemplate.execute(loadWorkflowStageCatalogMergeSql());
            jdbcTemplate.execute(loadScenarioWorkflowSeedSql());
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

        return sql.substring(start, end);
    }

    private String loadImportSql() throws Exception {
        Resource resource = resourceLoader.getResource(IMPORT_SQL);
        return StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
    }
}
