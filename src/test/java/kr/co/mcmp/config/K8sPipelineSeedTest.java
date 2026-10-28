package kr.co.mcmp.config;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Map;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootTest(properties = {
        "spring.datasource.url=jdbc:h2:mem:k8s-pipeline-seed;DB_CLOSE_DELAY=-1",
        "spring.jpa.hibernate.ddl-auto=create-drop"
})
class K8sPipelineSeedTest {
    private static final Map<Integer, Integer> WORKFLOW_CREATE_STAGES = Map.of(
            101, 17, 102, 50, 103, 26, 104, 51, 109, 17);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private DatabaseInitializer initializer;

    @MockBean
    private JenkinsService jenkinsService;

    @Test
    void seedsFreshDatabaseAndRefreshesExistingPipeline() throws Exception {
        assertNodeGroupPipelineSeeded();
        assertDiskDefaultsSeeded();

        for (int stageId : WORKFLOW_CREATE_STAGES.values()) {
            jdbcTemplate.update("UPDATE workflow_stage SET workflow_stage_content = ? WHERE workflow_stage_idx = ?", "old stage", stageId);
        }
        for (var entry : WORKFLOW_CREATE_STAGES.entrySet()) {
            jdbcTemplate.update("UPDATE workflow SET script = ? WHERE workflow_idx = ?", "old workflow", entry.getKey());
            jdbcTemplate.update("UPDATE workflow_stage_mapping SET stage = ? WHERE workflow_idx = ? AND workflow_stage_idx = ?",
                    "old mapping", entry.getKey(), entry.getValue());
        }
        initializer.run();

        assertNodeGroupPipelineSeeded();
        assertDiskDefaultsSeeded();
    }

    private void assertNodeGroupPipelineSeeded() {
        String stage = jdbcTemplate.queryForObject(
                "SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 51", String.class);
        String workflow = jdbcTemplate.queryForObject(
                "SELECT script FROM workflow WHERE workflow_idx = 104", String.class);
        String mappedStage = jdbcTemplate.queryForObject(
                "SELECT stage FROM workflow_stage_mapping WHERE workflow_idx = 104 AND stage_order = 3", String.class);

        assertTrue(stage.contains("/k8sNodeGroupDynamic"));
        assertTrue(stage.contains("nodeCount >= payloadMap.desiredNodeSize"));
        assertTrue(workflow.replaceAll("(?m)^[ \\t]+", "").contains(stage.replaceAll("(?m)^[ \\t]+", "").strip()));
        assertEquals(stage, mappedStage);
    }

    private void assertDiskDefaultsSeeded() {
        for (var entry : WORKFLOW_CREATE_STAGES.entrySet()) {
            String stage = jdbcTemplate.queryForObject(
                    "SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = ?", String.class, entry.getValue());
            String workflow = jdbcTemplate.queryForObject(
                    "SELECT script FROM workflow WHERE workflow_idx = ?", String.class, entry.getKey());
            String mappedStage = jdbcTemplate.queryForObject(
                    "SELECT stage FROM workflow_stage_mapping WHERE workflow_idx = ? AND workflow_stage_idx = ?",
                    String.class, entry.getKey(), entry.getValue());

            assertTrue(stage.contains("CLOUD_BSSD"));
            assertTrue(stage.contains("cloud_essd"));
            assertTrue(workflow.replaceAll("(?m)^[ \\t]+", "").contains(stage.replaceAll("(?m)^[ \\t]+", "").strip()));
            assertEquals(stage, mappedStage);
        }
        assertEquals("tencent+ap-seoul+S8.MEDIUM8", jdbcTemplate.queryForObject(
                "SELECT param_value FROM workflow_param WHERE workflow_idx = 102 AND param_key = 'TENCENT_SPEC_ID'", String.class));
        assertEquals("tencent+ap-seoul+S8.LARGE8", jdbcTemplate.queryForObject(
                "SELECT param_value FROM workflow_param WHERE workflow_idx = 104 AND param_key = 'TENCENT_SPEC_ID'", String.class));
    }
}
