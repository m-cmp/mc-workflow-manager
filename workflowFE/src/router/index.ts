import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/web',
      name: 'rootOssList',
      component: () => import('@/views/oss/OssList.vue' as any)
    },
    {
      path: '/web/oss/list',
      name: 'ossList',
      component: () => import('@/views/oss/OssList.vue' as any)
    },
    {
      path: '/web/workflowStage/list',
      name: 'workflowStageList',
      component: () => import('@/views/workflowStage/WorkflowStageList.vue' as any)
    },
    {
      path: '/web/eventListener/list',
      name: 'eventListenerList',
      component: () => import('@/views/eventListener/EventListenerList.vue' as any)
    },
    {
      path: '/web/workflow/list',
      name: 'workflowList',
      component: () => import('@/views/workflow/WorkflowList.vue' as any)
    },
    {
      path: '/web/workflow/new',
      name: 'workflowNew',
      component: () => import('@/views/workflow/WorkflowForm.vue' as any)
    },
    {
      path: `/web/workflow/detail/:workflowIdx`,
      name: 'workflowDetail',
      component: () => import('@/views/workflow/WorkflowForm.vue' as any)
    }
  ]
})

export default router
