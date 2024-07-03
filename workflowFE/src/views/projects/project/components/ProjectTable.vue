
<template>
  <div class="dz-clickable cursor-pointer">
    <el-table 
      class="list-table" 
      header-row-class-name="list-header" 
      :data="props.tableData"
    >
      <el-table-column
        prop="projectName" 
        :label="'프로젝트명'"
      >
        <template v-slot="scope">
          <div class="link-item" @click="props.clickRow(scope.row)">
            {{ scope.row.projectName }}          
          </div>
        </template>
      </el-table-column>
      
      <el-table-column
        prop="" 
        :label="'Gitlab URL'"
        width="550"
      >
        <template v-slot="scope">
          <div @click="props.clickRow(scope.row)">
            {{ scope.row.gitlabCloneHttpUrl }}          
          </div>
        </template>
      </el-table-column>

      <el-table-column
        prop="" 
        :label="'그룹명'"
      >
        <template v-slot="scope">
          <div @click="props.clickRow(scope.row)">
            {{ scope.row.gitlab.groupName }}          
          </div>
        </template>
      </el-table-column>

      <el-table-column
        prop="" 
        :label="'생성일시'"
      >
        <template v-slot="scope">
          <div @click="props.clickRow(scope.row)">
            {{ scope.row.regDate }}                    
          </div>
        </template>
      </el-table-column>

      <el-table-column
        prop="" 
        :label="'액션'"
      >
        <template v-slot="scope">
          <!-- {{ scope.row.projectName }} -->
          <button 
            class="btn btn-primary me-5"
            data-bs-toggle="modal"
            data-bs-target="#modalProjectEdit"
            @click="props.clickView(scope.row)"
          >
            상세
          </button>

          <button 
            class="btn btn-primary"
            @click="props.clickDelete(scope.row.projectId)"
              >삭제</button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    tableData: Object,
    clickView: Function,
    clickRow: Function,
    clickDelete: Function
  }>() as any;
</script>

<style>
.dz-clickable {
  cursor: pointer;
}
</style>
