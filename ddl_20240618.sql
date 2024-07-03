
DROP TABLE IF EXISTS `argocd_app`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `argocd_app` (
  `catalog_application_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ArgoCd 어플리케이션 일련번호 ',
  `catalog_deploy_id` bigint(20) NOT NULL COMMENT '카탈로그 배포 일련번호 ',
  `application_name` varchar(100) DEFAULT NULL COMMENT '어플리케이션 명',
  `project_name` varchar(100) NOT NULL COMMENT '프로젝트 명',
  `repo_url` varchar(255) DEFAULT NULL COMMENT '레파지토리 URL',
  `repo_target_revision` varchar(255) DEFAULT NULL COMMENT 'git_target_revision',
  `repo_path` varchar(255) DEFAULT NULL COMMENT 'git path',
  `server` varchar(255) DEFAULT NULL COMMENT 'k8s 접속 서버 url',
  `namespace` varchar(255) DEFAULT NULL COMMENT '네임스페이스',
  PRIMARY KEY (`catalog_application_id`),
  KEY `fk_argocd_app_idx1` (`catalog_deploy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='카탈로그_argocd 어플리케이션 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catalog_deploy`
--

DROP TABLE IF EXISTS `catalog_deploy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_deploy` (
  `catalog_deploy_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '카탈로그 일련번호',
  `k8s_id` bigint(20) DEFAULT NULL COMMENT 'K8S_일련번호',
  `vm_ids` varchar(100) DEFAULT NULL,
  `nexus_id` bigint(20) NOT NULL COMMENT 'Nexus_일련번호',
  `gitlab_id` bigint(20) DEFAULT NULL,
  `jenkins_id` bigint(20) DEFAULT NULL,
  `catalog_name` varchar(100) NOT NULL COMMENT '카탈로그 명',
  `catalog_version` varchar(50) DEFAULT NULL COMMENT '카탈로그 버전',
  `deploy_name` varchar(100) NOT NULL COMMENT '배포 명',
  `jenkins_job_name` varchar(100) DEFAULT NULL,
  `catalog_type_cd` varchar(10) NOT NULL COMMENT '배포 형태 구분 (IMAGE / HELMCHART / BM)',
  `catalog_deploy_yaml` text DEFAULT NULL COMMENT '배포 Yaml 내용',
  `catalog_deploy_pipeline` text DEFAULT NULL COMMENT '배포 pipeline 내용 ',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`catalog_deploy_id`),
  UNIQUE KEY `uk_catalog_deploy_idx1` (`deploy_name`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='카탈로그_배포 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catalog_deploy_history`
--

DROP TABLE IF EXISTS `catalog_deploy_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_deploy_history` (
  `catalog_deploy_history_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '카탈로그 배포 이력 일련번호',
  `catalog_deploy_id` bigint(20) NOT NULL COMMENT '카탈로그 일련번호',
  `catalog_deploy_yaml` text DEFAULT NULL COMMENT '배포 Yaml 내용',
  `catalog_deploy_pipeline` text DEFAULT NULL COMMENT '배포 Pipeline 내용',
  `deploy_result` varchar(100) NOT NULL DEFAULT 'BUILDING' COMMENT '배포 결과',
  `deploy_desc` varchar(255) DEFAULT NULL COMMENT '배포 설명',
  `deploy_user_id` varchar(50) NOT NULL COMMENT '배포 작업자 아이디',
  `deploy_user_name` varchar(100) DEFAULT NULL COMMENT '배포 작업자 명',
  `deploy_date` datetime DEFAULT NULL COMMENT '배포일시',
  PRIMARY KEY (`catalog_deploy_history_id`),
  KEY `fk_catalog_deploy_history_idx1` (`catalog_deploy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='카탈로그_배포 이력 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `common_code`
--

DROP TABLE IF EXISTS `common_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `common_code` (
  `common_group_cd` varchar(20) NOT NULL COMMENT '그룹 코드',
  `common_cd` varchar(255) NOT NULL COMMENT '공통 코드',
  `code_order` int(10) DEFAULT NULL COMMENT '코드 조회 순서',
  `code_name` varchar(255) NOT NULL COMMENT '코드 명',
  `code_desc` varchar(255) DEFAULT NULL COMMENT '코드 설명',
  `protected_yn` char(1) DEFAULT 'Y',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`common_group_cd`,`common_cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='공통_코드 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_info`
--

DROP TABLE IF EXISTS `image_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_info` (
  `imginfo_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '일련번호',
  `imginfo_cd` varchar(20) NOT NULL COMMENT '구분 코드',
  `imginfo_c_port` varchar(100) NOT NULL COMMENT '접속 포트',
  `imginfo_b_port` varchar(100) DEFAULT NULL COMMENT '바인딩 포트',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`imginfo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='IMAGE 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jenkins_pipeline`
--

DROP TABLE IF EXISTS `jenkins_pipeline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jenkins_pipeline` (
  `pipeline_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '파이프라인 일련번호',
  `pipeline_cd` varchar(256) NOT NULL COMMENT '파이프라인 타입 코드',
  `pipeline_name` varchar(100) NOT NULL COMMENT '파이프라인 명',
  `pipeline_script` varchar(3000) NOT NULL COMMENT '파이프라인 스크립트',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`pipeline_id`),
  UNIQUE KEY `uk_jenkins_pipeline_idx1` (`pipeline_cd`,`pipeline_name`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='빌드_젠킨스 파이프라인';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `k8s`
--

DROP TABLE IF EXISTS `k8s`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `k8s` (
  `k8s_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'K8S_일련번호',
  `k8s_name` varchar(100) NOT NULL COMMENT 'K8S 명',
  `provider_cd` varchar(45) NOT NULL DEFAULT 'K8S' COMMENT '프로바이더 코드(ex. K8S / VM)',
  `k8s_desc` varchar(255) DEFAULT NULL COMMENT 'K8S 설명',
  `content` mediumtext DEFAULT NULL COMMENT 'K8S Config 내용',
  `argocd_url` varchar(255) NOT NULL COMMENT 'ArgoCd 접속 URL ',
  `argocd_username` varchar(255) DEFAULT NULL COMMENT 'ArgoCd 접속 아이디',
  `argocd_password` varchar(255) DEFAULT NULL COMMENT 'ArgoCd 접속 비밀번호',
  `argocd_token` varchar(500) DEFAULT NULL COMMENT 'ArgoCd 접속 토큰',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`k8s_id`),
  UNIQUE KEY `uk_k8s_idx1` (`k8s_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='설정_k8s 접속 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oss`
--

DROP TABLE IF EXISTS `oss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oss` (
  `oss_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'oss 일련번호',
  `oss_cd` varchar(20) NOT NULL COMMENT 'oss 구분 코드',
  `oss_name` varchar(100) NOT NULL COMMENT 'oss 명',
  `oss_desc` varchar(255) DEFAULT NULL COMMENT 'oss 설명',
  `oss_url` varchar(255) NOT NULL COMMENT 'oss 접속 url',
  `oss_username` varchar(255) DEFAULT NULL COMMENT 'oss 접속 아이디',
  `oss_password` varchar(255) DEFAULT NULL COMMENT 'oss 접속 비밀번호',
  `oss_token` varchar(255) DEFAULT NULL COMMENT 'oss 접속 토큰',
  `jenkins_connected_yn` char(1) DEFAULT 'N' COMMENT '젠킨스 등록 여부(젠킨스에서 실행할 때 사용하는 설정 관련 값을 등록했는 지 여부)',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`oss_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='설정_oss 접속 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sw_catalog`
--

DROP TABLE IF EXISTS `sw_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sw_catalog` (
  `sc_idx` int(11) NOT NULL AUTO_INCREMENT,
  `sc_title` varchar(200) NOT NULL,
  `sc_version` varchar(100) NOT NULL,
  `sc_icon` varchar(100) DEFAULT NULL,
  `sc_summary` varchar(500) DEFAULT NULL,
  `sc_url` varchar(100) DEFAULT NULL,
  `sc_reference` varchar(100) DEFAULT NULL,
  `sc_description` text DEFAULT NULL,
  `sc_category` varchar(20) NOT NULL DEFAULT '0',
  `sc_regdate` datetime DEFAULT NULL,
  PRIMARY KEY (`sc_idx`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sw_catalog_relation_catalog`
--

DROP TABLE IF EXISTS `sw_catalog_relation_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sw_catalog_relation_catalog` (
  `sc_idx` int(11) NOT NULL,
  `ref_idx` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sw_catalog_relation_workflow`
--

DROP TABLE IF EXISTS `sw_catalog_relation_workflow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sw_catalog_relation_workflow` (
  `sc_idx` int(11) NOT NULL,
  `ref_idx` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vm`
--

DROP TABLE IF EXISTS `vm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vm` (
  `vm_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'VM_일련번호',
  `vm_name` varchar(100) NOT NULL COMMENT 'VM 명',
  `provider_cd` varchar(45) NOT NULL DEFAULT 'VM' COMMENT '프로바이더 코드(ex. K8S / VM)',
  `vm_ip` varchar(255) NOT NULL COMMENT 'VM 접속 IP',
  `vm_port` bigint(20) NOT NULL COMMENT 'VM 접속 Port',
  `vm_username` varchar(255) DEFAULT NULL COMMENT 'VM 접속 아이디',
  `vm_password` varchar(255) DEFAULT NULL COMMENT 'VM 접속 비밀번호',
  `vm_privatekey` mediumtext DEFAULT NULL COMMENT 'VM Private Key',
  `vm_desc` varchar(255) DEFAULT NULL COMMENT 'VM 설명',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`vm_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='설정_vm 접속 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workflow`
--

DROP TABLE IF EXISTS `workflow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow` (
  `workflow_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '배포 일련번호 ',
  `jenkins_id` bigint(20) NOT NULL COMMENT 'JENKINS_일련번호',
  `gitlab_id` bigint(20) DEFAULT NULL COMMENT 'GITLAB_일련번호',
  `k8s_id` bigint(20) DEFAULT NULL COMMENT 'K8S_일련번호',
  `vm_ids` varchar(100) DEFAULT NULL,
  `workflow_name` varchar(256) NOT NULL COMMENT '워크플로우 명',
  `gitlab_project_path` varchar(255) DEFAULT NULL COMMENT 'GitLab 프로젝트 경로(ex./strato-product/m-cmp-backend.git)',
  `group_name` varchar(255) DEFAULT NULL COMMENT 'GitLab 그룹 명',
  `project_name` varchar(255) DEFAULT NULL COMMENT 'GitLab 프로젝트 명',
  `branch` varchar(100) DEFAULT NULL COMMENT '브랜치',
  `workflow_yaml` text DEFAULT NULL COMMENT '배포 Yaml 내용',
  `jenkins_job_name` varchar(100) DEFAULT NULL COMMENT '젠킨스 작업 명',
  `pipeline_script` text DEFAULT NULL COMMENT '젠킨스 파이프라인 스크립트',
  `catalog_yn` varchar(100) DEFAULT 'N' COMMENT '카탈로그 템플릿 Y/N',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`workflow_id`),
  KEY `fk_deploy_idx2` (`jenkins_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='배포_정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workflow_history`
--

DROP TABLE IF EXISTS `workflow_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_history` (
  `workflow_history_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '배포 이력 일련번호',
  `workflow_id` bigint(20) NOT NULL,
  `workflow_yaml` text DEFAULT NULL COMMENT '배포 Yaml 내용',
  `pipeline_script` text DEFAULT NULL COMMENT '배포 젠킨스 파이프라인 스크립트',
  `jenkins_build_id` bigint(20) DEFAULT NULL COMMENT '젠킨스 빌드 일련번호',
  `build_number` bigint(20) DEFAULT NULL COMMENT '젠킨스 빌드 넘버',
  `run_result` varchar(100) DEFAULT 'BUILDING' COMMENT '배포 결과',
  `run_message` mediumtext DEFAULT NULL COMMENT '배포 결과 상세',
  `run_user_id` varchar(50) NOT NULL COMMENT '배포 작업자 아이디',
  `run_user_name` varchar(100) DEFAULT NULL COMMENT '배포 작업자 명',
  `run_date` datetime DEFAULT NULL COMMENT '배포일시',
  PRIMARY KEY (`workflow_history_id`),
  KEY `fk_deploy_history_idx1` (`workflow_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='배포_k8s 배포 이력 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workflow_jenkins_pipeline_mapping`
--

DROP TABLE IF EXISTS `workflow_jenkins_pipeline_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_jenkins_pipeline_mapping` (
  `mapping_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '빌드 별 젠킨스 파이프라인 매핑 일련번호',
  `workflow_id` bigint(20) NOT NULL COMMENT '빌드 일련번호',
  `pipeline_order` tinyint(4) DEFAULT NULL COMMENT '파이프라인 순서',
  `pipeline_cd` varchar(50) DEFAULT NULL COMMENT '파이프라인 구분(CHECKOUTBUILD/JUNIT/SONARQUBE/SPARROW/FILEUPLOAD)',
  `pipeline_script` varchar(2000) DEFAULT NULL COMMENT '파이프라인 스크립트',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '둥록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  PRIMARY KEY (`mapping_id`),
  KEY `fk_deploy_jenkins_pipeline_mapping_idx1` (`workflow_id`)
) ENGINE=InnoDB AUTO_INCREMENT=362 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='배포 젠킨스 파이프라인 매핑';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workflow_new`
--

DROP TABLE IF EXISTS `workflow_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_new` (
  `workflow_type` varchar(50) NOT NULL COMMENT '배포 유형(Application/Catalog)',
  `workflow_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '워크플로우 일련번호',
  `workflow_name` varchar(256) NOT NULL COMMENT '워크플로우 명',
  `infra_id` varchar(100) NOT NULL COMMENT '인프라(mcis명/cluster명)',
  `gitlab_id` bigint(20) DEFAULT NULL COMMENT 'GITLAB 일련번호',
  `group_name` varchar(255) DEFAULT NULL COMMENT 'GitLab 그룹 명',
  `project_name` varchar(255) DEFAULT NULL COMMENT 'GitLab 프로젝트 명',
  `branch` varchar(100) DEFAULT NULL COMMENT '브랜치',
  `gitlab_project_path` varchar(255) DEFAULT NULL COMMENT 'GitLab 프로젝트 경로(ex./strato-product/m-cmp-backend.git)',
  `nexus_id` bigint(20) DEFAULT NULL COMMENT 'Nexus 일련번호',
  `catalog_name` varchar(100) DEFAULT NULL COMMENT '카탈로그 명',
  `catalog_version` varchar(50) DEFAULT NULL COMMENT '카탈로그 버전',
  `catalog_type_cd` varchar(10) DEFAULT NULL COMMENT '배포 형태 구분 (IMAGE / HELMCHART / BM)',
  `infra_type` varchar(20) NOT NULL COMMENT '인프라 구분(VM/K8S)',
  `k8s_id` bigint(20) DEFAULT NULL COMMENT 'K8S_일련번호',
  `workflow_yaml` text DEFAULT NULL COMMENT '배포 Yaml 내용',
  `jenkins_id` bigint(20) NOT NULL COMMENT 'JENKINS_일련번호',
  `jenkins_job_name` varchar(100) DEFAULT NULL COMMENT '젠킨스 작업 명',
  `pipeline_script` text DEFAULT NULL COMMENT '젠킨스 파이프라인 스크립트',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`workflow_id`),
  KEY `fk_deploy_idx2` (`jenkins_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='워크플로우_정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workflow_param`
--

DROP TABLE IF EXISTS `workflow_param`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_param` (
  `param_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '파라미터 일련번호',
  `workflow_id` bigint(20) NOT NULL COMMENT '워크플로우 일련번호',
  `param_key` varchar(255) DEFAULT NULL COMMENT '파라미터 Key',
  `param_value` varchar(255) DEFAULT NULL COMMENT '파라미터 Value',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`param_id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='워크플로우_파라미터_정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workflow_stage`
--

DROP TABLE IF EXISTS `workflow_stage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_stage` (
  `common_group_cd` varchar(20) NOT NULL COMMENT '그룹 코드',
  `workflow_stage_cd` varchar(255) NOT NULL COMMENT '워크플로우 스테이지 코드',
  `stage_order` int(10) DEFAULT NULL COMMENT '워크플로우 스테이지 조회 순서',
  `stage_name` varchar(255) NOT NULL COMMENT '워크플로우 스테이지 명',
  `stage_desc` varchar(255) DEFAULT NULL COMMENT '워크플로우 스테이지 설명',
  `protected_yn` char(1) DEFAULT 'Y',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`common_group_cd`,`workflow_stage_cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='워크플로_스테이지 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workflow_v2`
--

DROP TABLE IF EXISTS `workflow_v2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_v2` (
  `workflow_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '워크플로우 일련번호',
  `workflow_name` varchar(256) NOT NULL COMMENT '워크플로우 명',
  `workflow_purpose` varchar(50) NOT NULL COMMENT '배포 용도(배포용/실행용/테스트용/웹훅용)',
  `jenkins_id` bigint(20) NOT NULL COMMENT 'JENKINS_일련번호',
  `jenkins_job_name` varchar(100) DEFAULT NULL COMMENT '젠킨스 작업 명',
  `pipeline_script` text DEFAULT NULL COMMENT '젠킨스 파이프라인 스크립트',
  `reg_id` varchar(50) DEFAULT NULL COMMENT '등록자 아이디',
  `reg_name` varchar(100) DEFAULT NULL COMMENT '등록자 명',
  `reg_date` datetime DEFAULT NULL COMMENT '등록일시',
  `mod_id` varchar(50) DEFAULT NULL COMMENT '수정자 아이디',
  `mod_name` varchar(100) DEFAULT NULL COMMENT '수정자 명',
  `mod_date` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`workflow_id`),
  KEY `fk_deploy_idx2` (`jenkins_id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='워크플로우_정보';
/*!40101 SET character_set_client = @saved_cs_client */;
