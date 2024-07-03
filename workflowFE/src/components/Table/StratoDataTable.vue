<template>
  <el-table class="list-table" header-row-class-name="list-header" row-class-name="link-deploy-row" :data="data"
    width="100%" highlight-current-row stripe>
    <el-table-column v-for="(header, index) in headers" :key="index" :label="header.title" :width="header.width"
      :align="header.align">
      <template v-slot="scope">
        <!-- Text -->
        <div v-if="header.type === 'text'">
          {{ scope.row[header.column] }}
        </div>

        <!-- Action -->
        <div v-else v-for="(action, idx) in header.type" :key="idx" style="display: inline-flex;">
          <div v-if="action === 'edit'">
            <a @click="onEditItem(scope.row.k8sId)">
              <span class="svg-icon svg-icon-3">
                <button class="btn btn-primary btn-sm" style="margin-right: 10px;">수정</button>
              </span>
            </a>
          </div>
          <div v-if="action === 'delete'">
            <!-- <a data-bs-toggle="modal" data-bs-target="#kt_modal_1" @click="deleteVal(item.k8sId)"> -->
            <a @click="onDeleteItem(scope.row.k8sId)">
              <span class="svg-icon svg-icon-3">
                <button class="btn btn-primary btn-sm">삭제</button>
              </span>
            </a>
          </div>
        </div>
      </template>
    </el-table-column>
  </el-table>
</template>

<script>
export default {
  name: "tableTitle",
  emits: ["on-edit-item", "on-delete-item"],
  props: {
    data: Object,
    headers: Object
  },
  setup(props, { emit }) {
    const onEditItem = ((val) => {
      console.log(val)
      emit("on-edit-item", val)
    })

    const onDeleteItem = ((val) => {
      console.log(val)
      emit("on-delete-item", val)
    })

    return {
      onEditItem,
      onDeleteItem
    }
  }
}
</script>
