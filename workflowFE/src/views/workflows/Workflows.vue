<template>
  <div class="workflows-page">
    <ul class="workflow-tabs">
      <li class="nav-item">
        <RouterLink
          class="workflow-tab"
          :class="{ active: activeTab === 'workflow' }"
          to="/web/workflows/workflow/list"
        >
          <svg class="tab-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <rect x="3" y="3" width="7" height="7" rx="1.5" />
            <rect x="14" y="3" width="7" height="7" rx="1.5" />
            <rect x="3" y="14" width="7" height="7" rx="1.5" />
            <path d="M17.5 14v7" />
            <path d="M14 17.5h7" />
          </svg>
          Workflow
        </RouterLink>
      </li>
      <li class="nav-item">
        <RouterLink
          class="workflow-tab"
          :class="{ active: activeTab === 'eventListener' }"
          to="/web/workflows/eventListener/list"
        >
          <svg class="tab-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M3 12h4l2.5-6 5 12 2.5-6h4" />
          </svg>
          Event Listener
        </RouterLink>
      </li>
    </ul>

    <RouterView />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'

const route = useRoute()
const activeTab = computed(() => {
  if (route.path.includes('/eventListener/')) {
    return 'eventListener'
  }

  return 'workflow'
})
</script>

<style scoped>
.workflows-page {
  min-width: 0;
}

.workflow-tabs {
  display: flex;
  align-items: flex-end;
  gap: 0.25rem;
  padding: 0.75rem 1rem 0;
  margin: 0 0 1rem;
  list-style: none;
  background: #f8fafc;
  border: 1px solid #dbe1ea;
  border-left: 0;
  border-right: 0;
  border-top: 0;
}

.workflow-tab {
  display: inline-flex;
  align-items: center;
  gap: 0.625rem;
  min-height: 3.25rem;
  padding: 0 1.25rem;
  color: #64748b;
  font-size: 0.95rem;
  font-weight: 600;
  text-decoration: none;
  border: 1px solid transparent;
  border-bottom: 0;
  border-radius: 0.375rem 0.375rem 0 0;
  background: transparent;
  transform: translateY(1px);
}

.workflow-tab:hover {
  color: #334155;
  background: #f1f5f9;
}

.workflow-tab.active {
  color: #1f2937;
  background: #ffffff;
  border-color: #dbe1ea;
  box-shadow: 0 -1px 0 rgba(15, 23, 42, 0.03);
}

.tab-icon {
  width: 1.25rem;
  height: 1.25rem;
  flex: 0 0 auto;
}
</style>
