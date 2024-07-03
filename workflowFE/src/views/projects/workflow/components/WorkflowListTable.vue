<template>
  <el-table :data="workflowList" class="list-table w-100" header-row-class-name="list-header" highlight-current-row
    row-class-name="link-deploy-row">

    <!-- 워크플로우명 -->
    <el-table-column :label="'워크플로우명'" align="left" width="400" prop="workflowName" sortable>
      <template v-slot="scope">
        {{ scope.row.workflowName }}
      </template>
    </el-table-column>

    <!-- 분류 -->
    <el-table-column :label="'분류'" align="left" width="220" prop="workflowPurpose" sortable>
      <template v-slot="scope">
        {{ scope.row.workflowPurpose }}
      </template>
    </el-table-column>

    <!-- 젠킨스 URL -->
    <el-table-column :label="'젠킨스'" align="left" width="400" prop="jenkinsName" sortable>
      <template v-slot="scope">
        {{ scope.row.jenkinsName }} ({{ scope.row.jenkinsUrl }})
      </template>
    </el-table-column>

    <!-- Action -->
    <el-table-column :label="'Action'" width="350" align="center">
      <template v-slot="scope">
        <div>

          <!-- 상세 -->
          <div class="mr-10 inlineBlock" @click="gotoEditPage(scope.row)">
            <span class="svg-icon svg-icon-5">
              <button class="btn btn-primary btn-sm">
                상세
              </button>
            </span>
          </div>

          <!-- 삭제 -->
          <div class="mr-10 inlineBlock">
            <span class="svg-icon svg-icon-3">
              <button class="btn btn-primary btn-sm" @click.prevent="onClickDelete(scope.row)">
                {{ $t('project.catalog.delete') }}
              </button>
            </span>
          </div>

          <!-- 이력 -->
          <div class="mr-10 inlineBlock" @click="onClickHistory(scope.row)">
            <span class="svg-icon svg-icon-5">
              <button class="btn btn-primary btn-sm">
                이력
              </button>
            </span>
          </div>
        </div>
      </template>
    </el-table-column>
  </el-table>
</template>

<script setup lang="ts">
import { defineComponent, onMounted, ref } from "vue";
import { getWorkflowList } from "@/api/workflow"

/* ============================================================================================================= */
// 초기 Set
/* ============================================================================================================= */
const emit = defineEmits(['set-total-count', 'goto-edit-page', 'on-click-delete', 'on-click-history'])

/* ============================================================================================================= */
// 라이프 사이클
/* ============================================================================================================= */
onMounted(async () => {
  await _getWorkflowList();
})


// 워크플로우 목록
const workflowList = ref([] as any)

const _getWorkflowList = (async () => {
  await getWorkflowList()
    .then((response) => {
      workflowList.value = response.data ? response.data : [];
      emit('set-total-count', workflowList.value.length)
    });
})

/* ============================================================================================================= */
// Event
/* ============================================================================================================= */
const gotoEditPage = value => {
  emit('goto-edit-page', value)
}
const onClickDelete = value => {
  emit('on-click-delete', value)
}
const onClickHistory = value => {
  emit('on-click-history', value)
}

/* ============================================================================================================= */
// Expose
/* ============================================================================================================= */
// 상위컴포넌트에서 해당 함수 사용
defineExpose({
  _getWorkflowList
})

</script>
<style scoped>
.mr-10 {
  margin-right: 10px;
}

.inlineBlock {
  display: inline-block;
}

.space-between {
  display: flex;
  justify-content: space-between;
}
</style>