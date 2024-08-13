import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/oss/list',
      name: 'ossList',
      component: () => import('@/views/oss/OssList.vue' as any)
    },
    {
      path: '/workflowStage/list',
      name: 'workflowStageList',
      component: () => import('@/views/workflowStage/WorkflowStageList.vue' as any)
    },
    {
      path: '/workflow/list',
      name: 'workflowList',
      component: () => import('@/views/workflow/WorkflowList.vue' as any)
    },
    {
      path: '/workflow/new',
      name: 'workflowNew',
      component: () => import('@/views/workflow/WorkflowForm.vue' as any)
    },
    {
      path: `/workflow/edit/:workflowIdx`,
      name: 'workflowEdit',
      component: () => import('@/views/workflow/WorkflowForm.vue' as any)
    }
  ]
})

export default router
