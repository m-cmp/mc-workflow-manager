package kr.co.mcmp.workflowStage.dto;

import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflowStage.Entity.WorkflowStage;
import lombok.Builder;
import lombok.Getter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Getter
@Builder
public class WorkflowStageDto {
    private static final String DEFAULT_SCHEMA_SQL_CONTENT = "CREATE TABLE IF NOT EXISTS sample_data (id INT PRIMARY KEY, name VARCHAR(100));";
    private static final String DEFAULT_INSERT_SQL = "INSERT INTO sample_data (id, name) VALUES (1, 'sample row');";

    private Long workflowStageIdx;
    private Long workflowStageTypeIdx;
    private String workflowStageTypeName;
    private Integer workflowStageOrder;
    private String workflowStageName;
    private String workflowStageDesc;
    private String workflowStageContent;
    private List<WorkflowParamDto> defaultParams;


    // Comment translated to English.
    public static WorkflowStageDto from(WorkflowStage workflowStage) {
        return WorkflowStageDto.builder()
                .workflowStageIdx(workflowStage.getWorkflowStageIdx())
                .workflowStageTypeIdx(workflowStage.getWorkflowStageType().getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStage.getWorkflowStageType().getWorkflowStageTypeName())
                .workflowStageOrder(workflowStage.getWorkflowStageOrder())
                .workflowStageName(workflowStage.getWorkflowStageName())
                .workflowStageDesc(workflowStage.getWorkflowStageDesc())
                .workflowStageContent(workflowStage.getWorkflowStageContent())
                .defaultParams(defaultParamsFor(workflowStage.getWorkflowStageName()))
                .build();
    }

    // Comment translated to English.
    public static WorkflowStageDto of(WorkflowStageDto workflowStageDto) {
        return WorkflowStageDto.builder()
                .workflowStageIdx(workflowStageDto.getWorkflowStageIdx())
                .workflowStageTypeIdx(workflowStageDto.getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStageDto.getWorkflowStageTypeName())
                .workflowStageOrder(workflowStageDto.getWorkflowStageOrder())
                .workflowStageName(workflowStageDto.getWorkflowStageName())
                .workflowStageDesc(workflowStageDto.getWorkflowStageDesc())
                .workflowStageContent(workflowStageDto.getWorkflowStageContent())
                .defaultParams(workflowStageDto.getDefaultParams())
                .build();
    }

    // Comment translated to English.
    public static WorkflowStage toEntity(WorkflowStageDto workflowStageDto, WorkflowStageTypeDto workflowStageTypeDto) {
        return WorkflowStage.builder()
                .workflowStageIdx(workflowStageDto.getWorkflowStageIdx())
                .workflowStageType(WorkflowStageTypeDto.toEntity(workflowStageTypeDto))
                .workflowStageOrder(workflowStageDto.getWorkflowStageOrder())
                .workflowStageName(workflowStageDto.getWorkflowStageName())
                .workflowStageDesc(workflowStageDto.getWorkflowStageDesc())
                .workflowStageContent(workflowStageDto.getWorkflowStageContent())
                .build();
    }

    private static List<WorkflowParamDto> defaultParamsFor(String stageName) {
        if (stageName == null) {
            return List.of();
        }

        return switch (stageName) {
            case "infra-create" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("PROVIDER", ""),
                    param("CSP", ""),
                    param("REGION", ""),
                    param("CONNECTION_NAME", ""),
                    param("ZONE", ""),
                    param("INFRA_ID", ""),
                    param("IMAGE", ""),
                    param("IMAGE_ID", ""),
                    param("SPEC", ""),
                    param("SPEC_ID", ""),
                    param("SSH_USER", "cb-user"),
                    param("INFRA_NODEGROUP_NAME", "g1"),
                    param("INFRA_NODEGROUP_SIZE", "1"),
                    param("ROOT_DISK_TYPE", "default"),
                    param("ROOT_DISK_SIZE", "50"),
                    param("INSTALL_MON_AGENT", "no"),
                    param("POLICY_ON_PARTIAL_FAILURE", "continue"),
                    param("INFRA_ACCESS_INFO_MAX_ATTEMPTS", "30"),
                    param("INFRA_ACCESS_INFO_INTERVAL_SECONDS", "10"));
            case "multi-csp-vm-deploy" -> multiCspVmParams();
            case "multi-csp-vm-delete" -> multiCspVmDeleteParams();
            case "infra-get" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("INFRA_ID", ""),
                    param("INFRA_GET_OPTION", ""));
            case "infra-list" -> tumblebugParams(
                    param("NAMESPACE", ""));
            case "infra-update" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("INFRA_ID", ""),
                    param("INFRA_UPDATE_METHOD", "PUT"),
                    param("INFRA_UPDATE_PATH", ""),
                    param("INFRA_UPDATE_PAYLOAD", "{}"));
            case "infra-delete" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("INFRA_ID", ""),
                    param("INFRA_DELETE_OPTION", "terminate"));
            case "infra-start", "infra-stop", "infra-reboot" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("INFRA_ID", ""),
                    param("INFRA_CONTROL_FORCE", "false"));
            case "infra-ssh-connect-check" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("INFRA_ID", ""),
                    param("SSH_HOST", ""),
                    param("SSH_USER", "cb-user"),
                    param("SSH_KEY_FILE", ""));
            case "k8s-cluster-create" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("PROVIDER", ""),
                    param("CSP", ""),
                    param("REGION", ""),
                    param("CONNECTION_NAME", ""),
                    param("ZONE", ""),
                    param("K8S_CLUSTER_ID", ""),
                    param("K8S_NODEGROUP_NAME", "ng1"),
                    param("IMAGE", ""),
                    param("IMAGE_ID", ""),
                    param("SPEC", ""),
                    param("SPEC_ID", ""),
                    param("K8S_VERSION", "1.33"),
                    param("K8S_DESIRED_NODE_SIZE", "1"),
                    param("K8S_MIN_NODE_SIZE", "1"),
                    param("K8S_MAX_NODE_SIZE", "3"),
                    param("ROOT_DISK_TYPE", "default"),
                    param("ROOT_DISK_SIZE", "30"),
                    param("K8S_CREATE_OPTION", ""),
                    param("K8S_NODEGROUP_CREATE_IF_MISSING", "true"),
                    param("K8S_STATUS_MAX_ATTEMPTS", "360"),
                    param("K8S_STATUS_INTERVAL_SECONDS", "10"),
                    param("K8S_READY_STATUS", "Active,Running"));
            case "multi-csp-k8s-cluster-deploy" -> multiCspK8sParams();
            case "multi-csp-k8s-cluster-delete" -> multiCspK8sDeleteParams();
            case "k8s-cluster-get" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("K8S_CLUSTER_ID", ""));
            case "k8s-cluster-list" -> tumblebugParams(
                    param("NAMESPACE", ""));
            case "k8s-cluster-update" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("K8S_CLUSTER_ID", ""),
                    param("K8S_UPDATE_METHOD", "PUT"),
                    param("K8S_UPDATE_PATH", ""),
                    param("K8S_UPDATE_PAYLOAD", "{}"),
                    param("K8S_SKIP_VERSION_CHECK", "false"));
            case "k8s-cluster-delete" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("K8S_CLUSTER_ID", ""));
            case "k8s-nodegroup-add" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("PROVIDER", ""),
                    param("CSP", ""),
                    param("REGION", ""),
                    param("K8S_CLUSTER_ID", ""),
                    param("K8S_NODEGROUP_NAME", "ng1"),
                    param("ZONE", ""),
                    param("IMAGE", ""),
                    param("IMAGE_ID", ""),
                    param("SPEC", ""),
                    param("SPEC_ID", ""),
                    param("K8S_DESIRED_NODE_SIZE", "1"),
                    param("K8S_MIN_NODE_SIZE", "1"),
                    param("K8S_MAX_NODE_SIZE", "3"),
                    param("K8S_STATUS_MAX_ATTEMPTS", "360"),
                    param("K8S_STATUS_INTERVAL_SECONDS", "10"),
                    param("K8S_READY_STATUS", "Active,Running"));
            case "k8s-nodegroup-remove" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("K8S_CLUSTER_ID", ""),
                    param("K8S_NODEGROUP_NAME", "ng1"));
            case "k8s-kubeconfig-get" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("K8S_CLUSTER_ID", ""),
                    param("K8S_KUBECONFIG_MAX_ATTEMPTS", "30"),
                    param("K8S_KUBECONFIG_INTERVAL_SECONDS", "10"),
                    param("KUBECONFIG_CONTENT", ""));
            case "app-deploy-helm" -> params(
                    param("KUBECONFIG_CONTENT", ""),
                    param("KUBE_NAMESPACE", "default"),
                    param("RELEASE_NAME", "mariadb"),
                    param("HELM_REPO_NAME", "groundhog2k"),
                    param("HELM_REPO_URL", "https://groundhog2k.github.io/helm-charts"),
                    param("HELM_CHART", "groundhog2k/mariadb"),
                    param("HELM_CHART_VERSION", "4.5.0"),
                    param("HELM_VERSION", "v3.18.6"),
                    param("KUBECTL_VERSION", ""),
                    param("K8S_API_READY_MAX_ATTEMPTS", "360"),
                    param("K8S_API_READY_INTERVAL_SECONDS", "10"),
                    param("K8S_NODE_READY_MIN_COUNT", "1"),
                    param("HELM_RECREATE_ON_IMMUTABLE_ERROR", "true"),
                    param("HELM_VALUES_ARGS", "--set settings.rootPassword.value=mariadb_pass --set userDatabase.name.value=testdb --set userDatabase.user.value=mariadb_user --set userDatabase.password.value=mariadb_pass --wait --timeout 10m"),
                    param("DB_EXEC_MODE", "k8s"),
                    param("DB_POD_SELECTOR", "app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb"));
            case "app-deploy-manifest" -> params(
                    param("KUBECONFIG_CONTENT", ""),
                    param("KUBE_NAMESPACE", "default"),
                    param("K8S_MANIFEST", ""));
            case "app-deploy-status-check" -> params(
                    param("KUBECONFIG_CONTENT", ""),
                    param("KUBE_NAMESPACE", "default"),
                    param("DEPLOYMENT_NAME", ""),
                    param("ROLLOUT_TIMEOUT", "300s"));
            case "app-undeploy" -> params(
                    param("KUBECONFIG_CONTENT", ""),
                    param("KUBE_NAMESPACE", "default"),
                    param("APP_DEPLOY_TYPE", "helm"),
                    param("RELEASE_NAME", ""),
                    param("K8S_MANIFEST", ""));
            case "app-rollback" -> params(
                    param("KUBECONFIG_CONTENT", ""),
                    param("KUBE_NAMESPACE", "default"),
                    param("RELEASE_NAME", ""),
                    param("HELM_REVISION", ""));
            case "mariadb-install" -> params(
                    param("NAMESPACE", ""),
                    param("INFRA_ID", ""),
                    param("DB_EXEC_MODE", "ssh"),
                    param("DB_HOST", ""),
                    param("DB_PORT", "3306"),
                    param("DB_NAME", "testdb"),
                    param("DB_USER", "mariadb_user"),
                    param("DB_PASSWORD", "mariadb_pass"),
                    param("SSH_HOST", ""),
                    param("SSH_USER", "cb-user"),
                    param("SSH_KEY_FILE", ""));
            case "db-backup-export" -> databaseParams(
                    param("DB_BACKUP_FILE", ""),
                    param("KUBE_NAMESPACE", "default"),
                    param("RELEASE_NAME", "mariadb"),
                    param("DB_POD_SELECTOR", "app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb"));
            case "db-backup-import" -> databaseParams(
                    param("DB_BACKUP_FILE", "schema.sql"),
                    param("SCHEMA_SQL_CONTENT", DEFAULT_SCHEMA_SQL_CONTENT),
                    param("KUBE_NAMESPACE", "default"),
                    param("RELEASE_NAME", "mariadb"),
                    param("DB_POD_SELECTOR", "app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb"));
            case "db-schema-import" -> databaseParams(
                    param("SCHEMA_SQL_FILE", "schema.sql"),
                    param("SCHEMA_SQL_CONTENT", DEFAULT_SCHEMA_SQL_CONTENT),
                    param("KUBE_NAMESPACE", "default"),
                    param("RELEASE_NAME", "mariadb"),
                    param("DB_POD_SELECTOR", "app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb"));
            case "db-data-insert" -> databaseParams(
                    param("INSERT_SQL", DEFAULT_INSERT_SQL),
                    param("KUBE_NAMESPACE", "default"),
                    param("RELEASE_NAME", "mariadb"),
                    param("DB_POD_SELECTOR", "app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb"));
            case "db-data-verify" -> databaseParams(
                    param("VERIFY_SQL", "SELECT 1"),
                    param("KUBE_NAMESPACE", "default"),
                    param("RELEASE_NAME", "mariadb"),
                    param("DB_POD_SELECTOR", "app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb"));
            case "ssh-command-exec" -> params(
                    param("SSH_HOST", ""),
                    param("SSH_USER", "cb-user"),
                    param("SSH_KEY_FILE", ""),
                    param("SSH_COMMAND", ""));
            case "http-request" -> params(
                    param("HTTP_METHOD", "GET"),
                    param("HTTP_URL", ""),
                    param("HTTP_HEADERS", ""),
                    param("HTTP_BODY", ""));
            case "wait-for-condition" -> params(
                    param("WAIT_METHOD", "GET"),
                    param("WAIT_URL", ""),
                    param("WAIT_HTTP_STATUS", "200"),
                    param("WAIT_CONTAINS", ""),
                    param("WAIT_MAX_ATTEMPTS", "30"),
                    param("WAIT_INTERVAL_SECONDS", "10"));
            case "notification-send" -> params(
                    param("NOTIFICATION_WEBHOOK_URL", ""),
                    param("NOTIFICATION_MESSAGE", "Workflow finished"),
                    param("NOTIFICATION_PAYLOAD", ""));
            case "script-exec" -> params(
                    param("SCRIPT_CONTENT", "echo no script"));
            case "namespace-ensure" -> tumblebugParams(
                    param("NAMESPACE", ""),
                    param("NAMESPACE_DESC", "Workflow created namespace"));
            default -> List.of();
        };
    }

    private static List<WorkflowParamDto> tumblebugParams(WorkflowParamDto... additionalParams) {
        List<WorkflowParamDto> result = new ArrayList<>();
        result.add(param("TUMBLEBUG", "http://mc-infra-manager:1323"));
        result.add(param("USER", "default"));
        result.add(param("USERPASS", "default"));
        result.addAll(Arrays.asList(additionalParams));
        return result;
    }

    private static List<WorkflowParamDto> databaseParams(WorkflowParamDto... additionalParams) {
        List<WorkflowParamDto> result = new ArrayList<>();
        result.add(param("DB_EXEC_MODE", "auto"));
        result.add(param("DB_HOST", ""));
        result.add(param("DB_PORT", "3306"));
        result.add(param("DB_NAME", "testdb"));
        result.add(param("DB_USER", "mariadb_user"));
        result.add(param("DB_PASSWORD", "mariadb_pass"));
        result.addAll(Arrays.asList(additionalParams));
        return result;
    }

    private static List<WorkflowParamDto> multiCspVmParams() {
        List<WorkflowParamDto> result = tumblebugParams(
                param("NAMESPACE", ""),
                param("CSP_LIST", "aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm,kt"),
                param("INFRA_PREFIX", "multi-csp-vm"),
                param("INFRA_NODEGROUP_NAME", "g1"),
                param("INFRA_NODEGROUP_SIZE", "1"),
                param("ROOT_DISK_TYPE", "default"),
                param("ROOT_DISK_SIZE", "50"),
                param("INSTALL_MON_AGENT", "no"),
                param("POLICY_ON_PARTIAL_FAILURE", "continue"));

        addCspVmParams(result, "ALIBABA", "ap-northeast-2", "alibaba-ap-northeast-2", "ap-northeast-2a",
                "alibaba+ap-northeast-2+ecs.e-c1m1.large", "ubuntu_22_04_x64_20G_alibase_20260522.vhd");
        addCspVmParams(result, "AWS", "ap-northeast-1", "aws-ap-northeast-1", "ap-northeast-1a",
                "aws+ap-northeast-1+t3.small", "ami-091de58da07595152");
        addCspVmParams(result, "AZURE", "koreacentral", "azure-koreacentral", "1",
                "azure+koreacentral+Standard_D2s_v3", "Canonical:ubuntu-22_04-lts:server:22.04.202606110");
        addCspVmParams(result, "GCP", "asia-northeast3", "gcp-asia-northeast3", "asia-northeast3-a",
                "gcp+asia-northeast3+e2-medium",
                "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20260612");
        addCspVmParams(result, "IBM", "jp-osa", "ibm-jp-osa", "jp-osa-1",
                "ibm+jp-osa+bxf-2x8", "r034-3cb1bb72-002d-45fe-8ac1-6e36906963c4");
        addCspVmParams(result, "KT", "kr1", "kt-kr1", "", "", "");
        addCspVmParams(result, "NCP", "kr", "ncp-kr", "KR-1",
                "ncp+kr+c2-g3", "104630229");
        addCspVmParams(result, "NHN", "kr1", "nhn-kr1", "kr-pub-a",
                "nhn+kr1+m2.c1m2", "0f07c795-2a46-44fc-a61b-fa0d96763ce2");
        addCspVmParams(result, "TENCENT", "ap-seoul", "tencent-ap-seoul", "ap-seoul-1",
                "tencent+ap-seoul+BF1.MEDIUM2", "img-487zeit5");
        return result;
    }

    private static List<WorkflowParamDto> multiCspVmDeleteParams() {
        return tumblebugParams(
                param("NAMESPACE", ""),
                param("CSP_LIST", "aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm,kt"),
                param("INFRA_PREFIX", "multi-csp-vm"),
                param("INFRA_ID_LIST", ""),
                param("INFRA_DELETE_OPTION", "terminate"));
    }

    private static List<WorkflowParamDto> multiCspK8sParams() {
        List<WorkflowParamDto> result = tumblebugParams(
                param("NAMESPACE", ""),
                param("CSP_LIST", "aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm"),
                param("CLUSTER_PREFIX", "multi-csp-k8s"),
                param("K8S_NODEGROUP_PREFIX", "ng"),
                param("K8S_VERSION", "1.33"),
                param("K8S_DESIRED_NODE_SIZE", "1"),
                param("K8S_MIN_NODE_SIZE", "1"),
                param("K8S_MAX_NODE_SIZE", "3"),
                param("ROOT_DISK_TYPE", "default"),
                param("ROOT_DISK_SIZE", "30"),
                param("K8S_CREATE_OPTION", ""),
                param("K8S_STATUS_MAX_ATTEMPTS", "360"),
                param("K8S_STATUS_INTERVAL_SECONDS", "10"),
                param("K8S_READY_STATUS", "Active,Running"));

        addCspK8sParams(result, "AWS", "ap-northeast-1", "aws-ap-northeast-1", "ap-northeast-1a",
                "aws+ap-northeast-1+t3.small", "AL2023_x86_64_STANDARD", "1.33");
        addCspK8sParams(result, "AZURE", "koreacentral", "azure-koreacentral", "1",
                "azure+koreacentral+Standard_A2_v2", "Canonical:ubuntu-22_04-lts:server:22.04.202606110", "1.33.3");
        addCspK8sParams(result, "GCP", "asia-northeast3", "gcp-asia-northeast3", "asia-northeast3-a",
                "gcp+asia-northeast3+e2-medium", "UBUNTU_CONTAINERD", "1.33.12-gke.1000000");
        addCspK8sParams(result, "NCP", "kr", "ncp-kr", "KR-1",
                "ncp+kr+c2-g3", "23214590", "1.33.4-nks.1");
        addCspK8sParams(result, "NHN", "kr1", "nhn-kr1", "kr-pub-a",
                "nhn+kr1+m2.c1m2", "0f07c795-2a46-44fc-a61b-fa0d96763ce2", "v1.33.4");
        addCspK8sParams(result, "ALIBABA", "ap-northeast-1", "alibaba-ap-northeast-1", "ap-northeast-1b",
                "alibaba+ap-northeast-1+ecs.u1-c1m4.xlarge", "Ubuntu", "1.34.3-aliyun.1");
        addCspK8sParams(result, "TENCENT", "ap-seoul", "tencent-ap-seoul", "Ap-seoul-2",
                "tencent+ap-seoul+BF1.MEDIUM2", "ubuntu22.04x86_64", "1.32.2");
        addCspK8sParams(result, "IBM", "jp-osa", "ibm-jp-osa", "jp-osa-1",
                "ibm+jp-osa+bx2-2x8", "r034-ed053bf7-43c9-4b64-844b-77918ac3d597", "1.33.6");
        return result;
    }

    private static List<WorkflowParamDto> multiCspK8sDeleteParams() {
        return tumblebugParams(
                param("NAMESPACE", ""),
                param("CSP_LIST", "aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm"),
                param("CLUSTER_PREFIX", "multi-csp-k8s"),
                param("K8S_CLUSTER_ID_LIST", ""),
                param("K8S_NODEGROUP_PREFIX", "ng"),
                param("K8S_NODEGROUP_NAME_LIST", ""),
                param("K8S_DELETE_OPTION", "force"),
                param("K8S_NODEGROUP_DELETE_MAX_ATTEMPTS", "120"),
                param("K8S_CLUSTER_DELETE_MAX_ATTEMPTS", "120"),
                param("K8S_DELETE_INTERVAL_SECONDS", "10"));
    }

    private static void addCspVmParams(List<WorkflowParamDto> result, String prefix, String region, String connectionName,
                                       String zone, String specId, String imageId) {
        result.add(param(prefix + "_REGION", region));
        result.add(param(prefix + "_CONNECTION_NAME", connectionName));
        result.add(param(prefix + "_ZONE", zone));
        result.add(param(prefix + "_SPEC_ID", specId));
        result.add(param(prefix + "_IMAGE_ID", imageId));
    }

    private static void addCspK8sParams(List<WorkflowParamDto> result, String prefix, String region, String connectionName) {
        addCspK8sParams(result, prefix, region, connectionName, "");
    }

    private static void addCspK8sParams(List<WorkflowParamDto> result, String prefix, String region, String connectionName, String k8sVersion) {
        addCspK8sParams(result, prefix, region, connectionName, "", "", "", k8sVersion);
    }

    private static void addCspK8sParams(List<WorkflowParamDto> result, String prefix, String region, String connectionName,
                                        String zone, String specId, String imageId, String k8sVersion) {
        result.add(param(prefix + "_REGION", region));
        result.add(param(prefix + "_CONNECTION_NAME", connectionName));
        result.add(param(prefix + "_ZONE", zone));
        result.add(param(prefix + "_SPEC_ID", specId));
        result.add(param(prefix + "_IMAGE_ID", imageId));
        result.add(param(prefix + "_K8S_VERSION", k8sVersion));
    }

    private static List<WorkflowParamDto> params(WorkflowParamDto... params) {
        return Arrays.asList(params);
    }

    private static WorkflowParamDto param(String key, String value) {
        return WorkflowParamDto.builder()
                .paramKey(key)
                .paramValue(value)
                .eventListenerYn("N")
                .build();
    }

    // default Script Set
    public static WorkflowStageDto setWorkflowStageDefaultScript(Long workflowStageTypeIdx,String workflowStageContent) {
        return WorkflowStageDto.builder()
                .workflowStageTypeIdx(workflowStageTypeIdx)
                .workflowStageContent(workflowStageContent)
                .build();
    }

    // default Script List Set
    public static List<WorkflowStageDto> setWorkflowStageDefaultScriptList(Long workflowStageTypeIdx, String workflowStageContent) {
        WorkflowStageDto workflowStageDto = WorkflowStageDto.builder()
                .workflowStageTypeIdx(workflowStageTypeIdx)
                .workflowStageContent(workflowStageContent)
                .build();
        return List.of(workflowStageDto);
    }
}
