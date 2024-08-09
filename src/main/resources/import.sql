-- Step 1: Insert into oss_type
INSERT INTO oss_type (oss_type_idx, oss_type_name, oss_type_desc) VALUES (1, 'JENKINS', 'init');

-- Step 2: Insert into oss
INSERT INTO oss (oss_idx, oss_type_idx, oss_name, oss_desc, oss_url, oss_username, oss_password) VALUES (1, 1, 'SampleOss', 'Sample Description', 'http://sample.com', 'root', '1234');

-- Step 3: Insert into workflow_stage_type (assuming this table exists and 1 is valid)
-- Note: No specific values provided for WorkflowStageType. Adjust as necessary.
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (1, 'Sample Type', 'Sample Description');

-- Step 4: Insert into workflow_stage
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'init Stage', 'init Data', 'test');

-- Step 5: Insert into workflow
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'Sample Workflow', 'Sample Purpose', 1, 'Sample Script');
-- INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'Sample Workflow', 'Sample Purpose', 1, 'Sample Script');

-- Step 6: Insert into workflow_param
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value) VALUES (1, 1, 'Sample Key', 'Sample Value');

-- Step 7: Insert into workflow_stage_mapping
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_type_idx, stage) VALUES (1, 1, 1, 1, 'Sample Stage Content');
