# MC Workflow Manager

MC Workflow Manager is a workflow authoring and execution service for the
M-CMP platform. It provides a Spring Boot API, a Vue 3 web UI, seeded workflow
templates, Jenkins-backed execution, event listeners, run history, and
cb-tumblebug based multi-cloud parameter selection.

The production UI is built from `workflowFE` and served by Spring Boot from
`src/main/resources/static`.

## Quick Start

For a local backend run:

```bash
./gradlew bootRun
```

Open the application at `http://localhost:18083/web/workflows/workflow/list`.

For the frontend development server:

```bash
cd workflowFE
yarn install
yarn dev
```

For the containerized Jenkins + Workflow Manager stack:

```bash
docker compose up -d
```

Open Jenkins at `http://localhost:9800` and the Workflow Manager UI at
`http://localhost:18083/web/workflows/workflow/list`.

## What This Project Does

- Manages workflows: list, create, detail, edit, delete, run, logs, and history
- Manages workflow stages and reusable pipeline snippets
- Manages OSS/Jenkins connection settings
- Manages event listeners that can trigger workflows through HTTP requests
- Generates Jenkins pipeline scripts from selected workflow stages
- Runs Jenkins jobs with workflow parameters
- Provides Tumblebug Parameter Selection for namespace, CSP, region, connection,
  zone, image, VM/K8s spec, K8s image mode, and K8s version
- Proxies selected cb-tumblebug APIs through `/infra-manager`
- Seeds VM, K8s, multi-CSP deployment, and cleanup workflows from `import.sql`
- Uses an H2 file database for local and containerized development

## Architecture

```text
Browser
  -> Vue 3 UI
  -> Spring Boot API :18083
      -> H2 database
      -> Jenkins REST API
      -> cb-tumblebug API through mc-infra-manager proxy
  -> Jenkins pipeline jobs
      -> cb-tumblebug API
      -> cb-spider
      -> cloud providers
```

Important URL distinction:

- Backend proxy config `MC_INFRA_MANAGER_URL` includes `/tumblebug`.
  Example: `http://210.217.178.130:1323/tumblebug`
- Workflow parameter `TUMBLEBUG` is the host root without `/tumblebug` because
  seeded Jenkins pipelines append `/tumblebug`.
  Example: `http://mc-infra-manager:1323`

When Jenkins runs in Docker, `http://mc-infra-manager:1323` works only if a
container with that DNS name is reachable from the Jenkins container network.
Otherwise set the workflow `TUMBLEBUG` parameter to a reachable URL, such as
`http://210.217.178.130:1323`.

## Seed Data

`src/main/resources/import.sql` seeds OSS data, workflow stage types, workflow
stages, scenario workflows, workflow parameters, and workflow-stage mappings.

`DatabaseInitializer` behaves as follows:

- If the database is empty, it executes the full `import.sql`.
- If the database already has workflows, it refreshes the stage catalog and
  scenario workflow seed block.
- It resets H2 identity columns after seeding.
- It tries to synchronize seeded workflows to reachable Jenkins OSS entries.

Seeded workflows with purpose `test` are removed during import.

## Seeded Workflows

| ID | Workflow | Purpose | Tumblebug Selector |
| --- | --- | --- | --- |
| 101 | `vm-mariadb-backup-import-data-init` | For Deployment | Enabled |
| 102 | `multi-csp-vm-deploy` | For Deployment | Enabled |
| 103 | `k8s-mariadb-backup-import-data-init` | For Deployment | Enabled |
| 104 | `multi-csp-k8s-cluster-deploy` | For Deployment | Enabled |
| 105 | `vm-mariadb-data-init-cleanup` | For Cleanup | Disabled |
| 106 | `multi-csp-vm-cleanup` | For Cleanup | Disabled |
| 107 | `k8s-mariadb-data-init-cleanup` | For Cleanup | Disabled |
| 108 | `multi-csp-k8s-cluster-cleanup` | For Cleanup | Disabled |

`TUMBLEBUG_SELECTOR_YN` controls whether the run form displays Tumblebug
Parameter Selection for a workflow.

## Scenario Summary

| Scenario | Description |
| --- | --- |
| VM MariaDB data init | Create VM infra, get access info, connect by SSH, install MariaDB, import backup SQL, insert initial data |
| Multi-CSP VM deploy | Create VM infra for configured CSP targets |
| K8s MariaDB data init | Create a K8s cluster, get kubeconfig/token, install MariaDB by Helm, import backup SQL, insert data |
| Multi-CSP K8s deploy | Create K8s clusters for configured CSP targets |
| VM cleanup | Delete a single VM infra |
| Multi-CSP VM cleanup | Delete multi-CSP VM infra; absent infra is treated as already cleaned up |
| K8s cleanup | Delete node groups first when needed, then delete the K8s cluster |
| Multi-CSP K8s cleanup | Delete node groups and clusters for multi-CSP K8s workflows |

The create workflows include a namespace ensure stage so that a missing
Tumblebug namespace can be created before infra or cluster creation.

## Multi-CSP Defaults

Seeded multi-CSP VM workflows include:

```text
aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm,kt
```

Seeded multi-CSP K8s workflows include:

```text
aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm
```

OpenStack is not included in the seeded multi-CSP scenario lists.

## Tumblebug Parameter Selection

The run form can load selectable values from Tumblebug instead of requiring
users to manually type cloud resource IDs.

Supported selection fields:

- Namespace input
- CSP/provider
- Region
- Connection config
- Zone, when required by the provider
- VM/K8s spec
- Image
- K8s image mode through the K8s toggle
- K8s version
- Existing infra and host selection where applicable

Selection behavior:

- Spec lists are loaded before image lists.
- Image lists can be filtered by the selected spec.
- K8s image mode adds `isKubernetesImage=true` to image lookup.
- Lists are cleared immediately when upstream values change, then repopulated
  after the latest API response arrives.
- Run validation checks that selected `SPEC_ID` and `IMAGE_ID` still belong to
  the current region and connection.
- The run modal shows a progress bar while lookup, validation, review, and run
  requests are in progress.

## Tumblebug Proxy Endpoints

The frontend calls the local backend, and the backend proxies or normalizes
selected Tumblebug calls.

| Endpoint | Purpose |
| --- | --- |
| `GET /infra-manager/namespaces` | List namespaces |
| `GET /infra-manager/providers` | List providers |
| `GET /infra-manager/providers/{providerName}/regions` | List provider regions |
| `GET /infra-manager/conn-configs` | List connection configs |
| `GET /infra-manager/available-zones` | List zones for a selected spec or connection |
| `GET /infra-manager/k8s-versions` | List provider-specific K8s versions |
| `GET /infra-manager/namespaces/{nsId}/resources/spec` | List specs |
| `GET /infra-manager/namespaces/{nsId}/resources/image` | List images |
| `POST /infra-manager/namespaces/{nsId}/infra-dynamic-review` | Review INFRA Dynamic creation payload |
| `GET /infra-manager/namespaces/{nsId}/infra` | List infra |
| `GET /infra-manager/namespaces/{nsId}/infra/{infraId}` | Get infra detail |

For resource lookup, the backend falls back to Tumblebug lookup APIs where
provider catalog endpoints are unavailable or return empty data.

## Workflow Run Behavior

- Workflow list status polling runs every 30 seconds.
- Polling updates status data without replacing the visible table row order.
- Default table page size is 10.
- Run progress is rendered above the run modal content so long-running lookup
  and review calls do not look like a frozen screen.
- INFRA Dynamic review is used before VM creation workflows to detect invalid
  spec/image/connection combinations early.

## K8s Workflow Notes

- K8s versions are provider-specific. Select a version returned by Tumblebug
  for the selected provider and region.
- AWS requires a K8s node image such as `AL2023_x86_64_STANDARD`.
- Some providers use ordinary VM images for managed K8s node groups, while AWS
  exposes dedicated K8s node image values.
- The K8s MariaDB workflow uses the Groundhog2k MariaDB Helm chart by default:
  `groundhog2k/mariadb` version `4.5.0`.
- The workflow writes kubeconfig to the Jenkins workspace and, when possible,
  replaces AWS exec-plugin auth with a Tumblebug-issued token.
- Cleanup workflows try to delete node groups before deleting clusters.
- Cleanup workflows can use explicitly provided node group names first and then
  discovered node group names if available.

## 0.6.0 Pre-release CSP Test Matrix

The following values were verified during 0.6.0 pre-release testing with
cb-tumblebug based workflow scenarios.

Status legend:

| Value | Meaning |
| --- | --- |
| `O` | Tested successfully |
| `X` | Not available for this scenario |
| `Testing` | Still under test |
| `△` | Known scenario limitation remains |
| `Not Support` | Not supported in this release |

### VM Workflow Test Values

| Item | Alibaba | AWS | Azure | GCP | IBM | KT | NCP | NHN | OpenStack | Tencent |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| VM | O | O | O | O | O | Testing | O | O | Not Support | O |
| VM Spec | `alibaba+ap-northeast-2+ecs.e-c1m1.large` / `ecs.e-c1m1.large` | `aws+ap-northeast-1+t3.small` / `t3.small` | `azure+koreacentral+Standard_D2s_v3` / `Standard_D2s_v3` | `gcp+asia-northeast3+e2-medium` / `e2-medium` | `ibm+jp-osa+bxf-2x8` / `bxf-2x8` | Testing | `ncp+kr+c2-g3` / `c2-g3` | `nhn+kr1+m2.c1m2` / `m2.c1m2` | Not Support | `tencent+ap-seoul+BF1.MEDIUM2` / `BF1.MEDIUM2` |
| VM Image | `ubuntu_22_04_x64_20G_alibase_20260522.vhd` / Ubuntu 22.04 64 bit | `ami-00b4561fe1d28c285` / ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20260602 | `Canonical:ubuntu-22_04-lts:server:22.04.202603110` / Server LTS | `https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20260612` / Canonical, Ubuntu, 22.04 LTS, amd64 jammy image built on 2026-06-12 | `r034-ed053bf7-43c9-4b64-844b-77918ac3d597` / Ubuntu Linux 22.04 LTS Jammy Jellyfish Minimal Install (amd64) | Testing | `104630229` / ubuntu-24.04-base (Hypervisor:KVM) | `0f07c795-2a46-44fc-a61b-fa0d96763ce2` / Ubuntu Server 22.04.5 LTS (2026.03.10) | Not Support | `img-487zeit5` / Ubuntu Server 22.04 LTS 64bit |
| VM Zone | `ap-northeast-2a` | `ap-northeast-1a` | `1` | `asia-northeast3-a` | `jp-osa-1` | Testing | `KR-1` | `kr-pub-a` | Not Support | `ap-seoul-1` |

### K8s Workflow Test Values

| Item | Alibaba                                                                                                                         | AWS | Azure | GCP | IBM | KT | NCP | NHN | OpenStack | Tencent |
| --- |---------------------------------------------------------------------------------------------------------------------------------| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| K8s | O                                                                                                                               | O | O | O | X | Testing | △ (app install issue) | O | Not Support | O |
| K8s Spec | `alibaba+ap-northeast-1+ecs.c7.xlarge` / `ecs.c7.xlarge`                                                                        | `aws+ap-northeast-1+t3.small` / `t3.small` | `azure+koreacentral+Standard_A2_v2` / `Standard_A2_v2` | `gcp+asia-northeast3+e2-medium` / `e2-medium` | `ibm+jp-osa+bx2-2x8` / `bx2-2x8` | Testing | `ncp+kr+c2-g3` / `c2-g3` | `nhn+kr1+m2.c1m2` / `m2.c1m2` | Not Support | `tencent+ap-seoul+BF1.MEDIUM2` / `BF1.MEDIUM2` |
| K8s Image | `aliyun_3_x64_20G_container_optimized_alibase_20260513.vhd` / Alibaba Cloud Linux 3.2104 LTS 64 bit Container-Optimized Edition | `AL2023_x86_64_STANDARD` / EKS Node - AL2023, containerd, x86_64 | `Canonical:ubuntu-22_04-lts:server:22.04.202603110` / Server LTS | `UBUNTU_CONTAINERD` / GKE Node - Ubuntu 22.04, containerd, x86_64/ARM64 | `r034-ed053bf7-43c9-4b64-844b-77918ac3d597` / Ubuntu Linux 22.04 LTS Jammy Jellyfish Minimal Install (amd64) | Testing | `23214590` / ubuntu-22.04-base (Hypervisor:KVM) | `0f07c795-2a46-44fc-a61b-fa0d96763ce2` / Ubuntu Server 22.04.5 LTS (2026.03.10) | Not Support | `img-487zeit5` / Ubuntu Server 22.04 LTS 64bit |
| K8s Zone | `ap-northeast-1b`                                                                                                               | `ap-northeast-1a` | `1` | `asia-northeast3-a` | `jp-osa-1` | Testing | `KR-1` | `kr-pub-a` | Not Support | `ap-seoul-1` |
| K8s Version | `1.34.3-aliyun.1` / `1.34`                                                                                                      | `1.33` | `1.33.3` / `1.33` | `1.34.3-gke.1051003` / `1.34` | `1.33.6` / `1.33` | Testing | `1.33.4-nks.1` / `1.33` | `v1.33.4` / `1.33` | Not Support | `1.30.0` / `1.30` |

## Requirements

- Java 17
- Gradle wrapper included in this repository
- Node.js 20 compatible runtime for the frontend
- Yarn 1.22.x for frontend builds
- Docker and Docker Compose for container deployment
- Jenkins 2.x with Pipeline support
- Reachable cb-tumblebug or mc-infra-manager endpoint

The Gradle project version is currently `0.2.1`.

## Configuration

### Backend Environment Variables

| Variable | Default | Description |
| --- | --- | --- |
| `DB_INIT_YN` | `update` | Hibernate DDL mode: `create`, `update`, `create-drop`, or `none` |
| `DB_ID` | `workflow` | H2 database username |
| `DB_PW` | `workflow!23` | H2 database password |
| `MC_INFRA_MANAGER_URL` | `http://210.217.178.130:1323/tumblebug` | Backend proxy base URL for Tumblebug API |
| `MC_INFRA_MANAGER_USERNAME` | `default` | Tumblebug basic auth username |
| `MC_INFRA_MANAGER_PASSWORD` | `default` | Tumblebug basic auth password |
| `SQL_DATA_INIT` | Compose default: `always` | Spring SQL initialization mode when used by the runtime image |

The H2 database file is created under `./document/test/workflow`.

### Common Workflow Parameters

Most deployment workflows use these parameters:

| Parameter | Description |
| --- | --- |
| `TUMBLEBUG` | Tumblebug host root used by Jenkins pipelines, without `/tumblebug` |
| `USER`, `USERPASS` | Tumblebug basic auth credentials used by Jenkins pipelines |
| `NAMESPACE` | Tumblebug namespace |
| `INFRA_ID` or `K8S_CLUSTER_ID` | Target infra or K8s cluster name |
| `PROVIDER` / `CSP` | Cloud provider key |
| `REGION` | Cloud provider region |
| `CONNECTION_NAME` | Tumblebug connection config name |
| `ZONE` | Cloud availability zone when required |
| `SPEC_ID` | Tumblebug VM or K8s node spec ID |
| `IMAGE_ID` | Tumblebug VM image or K8s node image ID |
| `K8S_VERSION` | Provider-specific K8s version |

Cleanup workflows usually disable Tumblebug Parameter Selection because they
only need target IDs, namespace, credentials, and delete options.

## Run with Docker Compose

```bash
docker compose up -d
```

The included `docker-compose.yaml` starts Jenkins and MC Workflow Manager:

| Service | Container | Port |
| --- | --- | --- |
| Jenkins | `we-jenkins` | `9800:8080`, `8080:8080` |
| Workflow Manager | `workflow-manager` | `18083:18083` |

Default Jenkins admin credentials in compose:

```text
admin / 1234567
```

After startup, verify the registered OSS/Jenkins settings from the UI. The seed
data may point to an internal Jenkins URL, so update the OSS URL if your runtime
topology is different.

Stop services:

```bash
docker compose down
```

## Local Development

### Backend

Compile:

```bash
./gradlew compileJava
```

Run:

```bash
./gradlew bootRun
```

Build jar:

```bash
./gradlew bootJar
```

The backend listens on `http://localhost:18083`.

Run backend checks:

```bash
./gradlew processResources compileJava testClasses
```

### Frontend

Install dependencies:

```bash
cd workflowFE
yarn install
```

Run the Vite dev server:

```bash
cd workflowFE
yarn dev
```

Build the frontend:

```bash
cd workflowFE
yarn build
```

To serve the built frontend from Spring Boot:

```bash
rm -rf src/main/resources/static/assets src/main/resources/static/index.html
cp -R workflowFE/dist/. src/main/resources/static/
./gradlew processResources
```

`yarn build` runs Vue type checking before creating the Vite production bundle.

## Useful URLs

| Page | URL |
| --- | --- |
| Workflow list | `http://localhost:18083/web/workflows/workflow/list` |
| New workflow | `http://localhost:18083/web/workflows/workflow/new` |
| Event listener list | `http://localhost:18083/web/workflows/eventListener/list` |
| Workflow stage list | `http://localhost:18083/web/workflowStage/list` |
| OSS list | `http://localhost:18083/web/oss/list` |
| Swagger UI | `http://localhost:18083/swagger-ui/index.html` |
| H2 console | `http://localhost:18083/h2-console` |
| Health check | `http://localhost:18083/readyz` |
| Jenkins UI | `http://localhost:9800` |

Legacy UI routes under `/web/workflow/*` and `/web/eventListener/list` redirect
to the current `/web/workflows/*` routes.

## Main API Groups

| Group | Base Path | Purpose |
| --- | --- | --- |
| Workflow | `/workflow` | Workflow CRUD, run, log, history, templates |
| Workflow parameters | `/workflow/param` | Workflow parameter list |
| Workflow history | `/workflow/history` | Workflow execution history |
| Workflow stages | `/workflowStage` | Stage CRUD and default stage scripts |
| Workflow stage types | `/workflowStageType` | Stage type CRUD |
| OSS | `/oss`, `/ossType` | Jenkins/OSS configuration |
| Event listener | `/eventlistener` | Event listener CRUD and trigger execution |
| Tumblebug proxy | `/infra-manager` | Namespace, provider, region, spec, image, zone, K8s version, infra review |
| Health | `/readyz` | Application health check |

## Project Structure

```text
mc-workflow-manager/
|-- build.gradle
|-- docker-compose.yaml
|-- Dockerfile
|-- README.md
|-- src/main/java/kr/co/mcmp
|   |-- api/readyz
|   |-- config
|   |-- eventListener
|   |-- infraManager
|   |-- oss
|   |-- workflow
|   `-- workflowStage
|-- src/main/resources
|   |-- application.yaml
|   |-- import.sql
|   `-- static
|-- workflowFE
|   |-- src
|   |-- package.json
|   `-- yarn.lock
|-- script
|-- document
|-- swagger.json
`-- api-docs.json
```

## Troubleshooting

### Jenkins cannot resolve `mc-infra-manager`

The workflow `TUMBLEBUG` parameter is being used from inside Jenkins. Update it
to a URL reachable from Jenkins, for example `http://210.217.178.130:1323`.

### UI shows `Not valid namespace`

Check that:

- `MC_INFRA_MANAGER_URL` points to the correct Tumblebug base URL including
  `/tumblebug`
- `MC_INFRA_MANAGER_USERNAME` and `MC_INFRA_MANAGER_PASSWORD` are valid
- the target Tumblebug server is reachable from the backend process

Create workflows include namespace ensure logic, but the UI still needs a
reachable backend proxy to load resource lists and run pre-validation.

### `SPEC_ID` or `IMAGE_ID` must be reselected

The selected value does not match the current provider, region, connection, or
K8s image mode. Select spec first, then image.

### K8s version error

K8s versions are provider-specific. Use the version list returned by
`/infra-manager/k8s-versions` for the current provider and region.

### K8s node group is missing

Some providers create a control plane before the node group is available. The
pipeline waits for cluster readiness and can create or delete node groups as a
separate step when required.

### GCP resource lookup returns Compute Engine API errors

Enable Compute Engine API for the configured GCP project. Repeated provider
failures may trigger Tumblebug circuit breaker protection until it resets.

### Provider says image/spec is available but provisioning still fails

Tumblebug resource availability and real CSP provisioning can differ. Use
`infra-dynamic-review`, select a compatible spec/image/zone, and clean failed
infra before retrying.

### Jenkins Groovy CPS serialization errors

Pipeline scripts should avoid keeping non-serializable Groovy objects, such as
LazyMap instances, across Jenkins pipeline steps.

## Maintenance Notes

- Keep seeded workflow scripts in `src/main/resources/import.sql` synchronized
  with frontend default workflow parameters in `workflowFE/src/views/workflow`.
- After frontend changes, run one frontend build at the end and copy `dist` into
  `src/main/resources/static`.
- When changing seeded SQL, verify startup with a fresh H2 database and with an
  existing H2 database because `DatabaseInitializer` has separate empty and
  update paths.
- When adding a new CSP default, update both the seeded workflow parameters and
  the CSP test matrix in this README.
