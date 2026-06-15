# MC Workflow Manager Wiki

MC Workflow Manager is an M-CMP component for creating, managing, and running
Jenkins-backed workflows. It provides workflow CRUD APIs, reusable workflow
stages, event listeners, Jenkins OSS settings, run logs, run history, and
Tumblebug-based multi-cloud resource selection.

## Main Flow

1. Register OSS settings such as Jenkins.
2. Manage reusable workflow stages.
3. Create a workflow from selected stages or a direct pipeline script.
4. Configure workflow parameters.
5. Run the workflow from the UI, API, or an event listener.
6. Check Jenkins logs and workflow run history.

## Main Domains

| Domain | Purpose |
| --- | --- |
| OSS Type | Defines supported OSS categories, such as Jenkins |
| OSS | Stores Jenkins connection information |
| Workflow Stage Type | Groups workflow stages by category |
| Workflow Stage | Stores reusable Jenkins pipeline stage snippets |
| Workflow | Stores pipeline scripts, parameters, and stage mappings |
| Workflow Param | Stores workflow runtime parameters |
| Workflow History | Stores Jenkins run history and stage logs |
| Event Listener | Exposes HTTP endpoints that can trigger workflows |
| Infra Manager Proxy | Loads Tumblebug namespaces, providers, regions, specs, images, zones, K8s versions, and infra review results |

## Important UI Routes

| Page | URL |
| --- | --- |
| Workflow list | `/web/workflows/workflow/list` |
| New workflow | `/web/workflows/workflow/new` |
| Workflow detail | `/web/workflows/workflow/detail/{workflowIdx}` |
| Event listener list | `/web/workflows/eventListener/list` |
| Workflow stage list | `/web/workflowStage/list` |
| OSS list | `/web/oss/list` |

## Important API Groups

| API Group | Base Path |
| --- | --- |
| Workflow | `/workflow` |
| Workflow Param | `/workflow/param` |
| Workflow History | `/workflow/history` |
| Workflow Stage | `/workflowStage` |
| Workflow Stage Type | `/workflowStageType` |
| OSS | `/oss` |
| OSS Type | `/ossType` |
| Event Listener | `/eventlistener` |
| Jenkins Log | `/jenkins/log` |
| Tumblebug Proxy | `/infra-manager` |
| Health Check | `/readyz` |

## Seeded Scenario Workflows

| Workflow | Purpose |
| --- | --- |
| `vm-mariadb-backup-import-data-init` | Create VM infra, install MariaDB, import backup SQL, and insert initial data |
| `multi-csp-vm-deploy` | Create VM infra across multiple CSPs |
| `k8s-mariadb-backup-import-data-init` | Create K8s cluster, deploy MariaDB by Helm, import backup SQL, and insert initial data |
| `multi-csp-k8s-cluster-deploy` | Create K8s clusters across multiple CSPs |
| `vm-mariadb-data-init-cleanup` | Delete single VM infra |
| `multi-csp-vm-cleanup` | Delete VM infra created by the multi-CSP VM workflow |
| `k8s-mariadb-data-init-cleanup` | Delete K8s node groups and cluster |
| `multi-csp-k8s-cluster-cleanup` | Delete K8s node groups and clusters created by the multi-CSP K8s workflow |

## Tumblebug Parameter Selection

Workflow run forms can use Tumblebug data instead of manually typed resource
IDs. The selector supports namespace, provider, region, connection, zone, spec,
image, K8s image mode, K8s version, existing infra, and host selections.

Spec options are loaded before image options. Image options can be filtered by
the selected spec. When upstream selections change, dependent lists are cleared
immediately and reloaded after the latest API response arrives.

## Notes

- Jenkins must be reachable from the backend when creating or updating Jenkins jobs.
- The `TUMBLEBUG` workflow parameter must be reachable from Jenkins.
- The backend `MC_INFRA_MANAGER_URL` includes `/tumblebug`; workflow parameter `TUMBLEBUG` does not.
- K8s versions are provider-specific and should be selected from Tumblebug results.
- Cleanup workflows should delete K8s node groups before deleting clusters when the provider requires it.
