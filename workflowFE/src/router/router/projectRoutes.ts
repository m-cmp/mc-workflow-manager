export const projectRoutes = {
  // path: "/",
  // redirect: '/projects/connection',
  // component: () => import("@/layout/service/ServiceLayout.vue"),
  name: 'project',
  children: [
    // =====================================================================================
    // Connection (ToolChain)
    // =====================================================================================
    {
      path: "/projects/connection",
      name: "ConfigurationConnectionList",
      component: () => import("@/views/projects/connection/ConfigurationConnectionList.vue"),
    },

    // =====================================================================================
    // Cluster (Kubernetes Config)
    // =====================================================================================
    {
      path: "/projects/kubernetes/list",
      name: "KubernetesList",
      component: () => import("@/views/projects/kubernetes_config/KubernetesList.vue")
    },
    {
      path: "/projects/kubernetes/new",
      name: "KubernetesNew",
      component: () => import("@/views/projects/kubernetes_config/KubernetesNew.vue")
    },
    {
      path: "/projects/kubernetes/edit/:k8sId",
      name: "KubernetesEdit",
      component: () => import("@/views/projects/kubernetes_config/KubernetesEdit.vue")
    },
    {
      path: "/projects/kubernetes/view/:k8sId",
      name: "CredentialView",
      component: () => import("@/views/projects/kubernetes_config/KubernetesView.vue")
    },


    // =====================================================================================
    // Infra
    // =====================================================================================
    {
      path: "/projects/infra/list",
      name: "InfraList",
      component: () => import("@/views/projects/infra/InfraList.vue")
    },
    {
      path: "/projects/infra/new",
      name: "InfraNew",
      component: () => import("@/views/projects/infra/InfraNew.vue")
    },
    {
      path: "/projects/infra/edit/:infraId",
      name: "InfraEdit",
      component: () => import("@/views/projects/infra/InfraEdit.vue")
    },
    {
      path: "/projects/infra/view/:infraId",
      name: "InfraView",
      component: () => import("@/views/projects/infra/InfraView.vue")
    },

    // =====================================================================================
    // Jenkins Pipeline (Pipeline Config)
    // =====================================================================================
    {
      path: "/projects/pipeLine",
      name: "PipeLineConfigList",
      component: () => import("@/views/projects/pipeline_config/PipeLineConfigList.vue"),
    },

    // =====================================================================================
    // Catalog Deploy
    // =====================================================================================
    {
      path: "/projects/catalogDeploy/list",
      name: "CatalogDeployList",
      component: () => import("@/views/projects/catalogDeploy/CatalogDeployList.vue"),
    },
    {
      path: "/projects/catalogDeploy/new",
      name: "CatalogDeployNew",
      component: () => import("@/views/projects/catalogDeploy/CatalogDeployNew.vue"),
    },
    {
      path: "/projects/catalogDeploy/edit/:catalogDeployId",
      name: "CatalogDeployEdit",
      component: () => import("@/views/projects/catalogDeploy/CatalogDeployEdit.vue"),
    },

    // =====================================================================================
    // Workflow
    // =====================================================================================
    {
      path: "/projects/workflow/list",
      name: "WorkflowList",
      component: () => import("@/views/projects/workflow/WorkflowList.vue"),
    },
    {
      path: "/projects/workflow/new",
      name: "WorkflowNew",
      component: () => import("@/views/projects/workflow/Workflow.vue"),
    },
    {
      path: "/projects/workflow/edit/:workflowId",
      name: "WorkflowEdit",
      component: () => import("@/views/projects/workflow/Workflow.vue"),
    },
  ]
}