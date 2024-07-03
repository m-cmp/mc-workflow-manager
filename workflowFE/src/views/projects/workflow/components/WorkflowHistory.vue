<template>
  <el-dialog v-model="props.popupFlag" title="History" style="width: 500px; align-content: center;">
    <div>
      <el-collapse accordion v-if="totalCount > 0">
        <el-collapse-item v-for="(history, idx) in historyList">
          <template #title>
            <span>
              {{ history.runResult ? history.runResult.toUpperCase() : 'NULL' }}
            </span>
            <span>
              (BuildNumber : {{ history.buildNumber }})
            </span>
          </template>
          <div>
            <el-input type="textarea" :value="history.log" rows="10" />
          </div>
        </el-collapse-item>
      </el-collapse>
      <div v-else>워크플로우 실행 이력이 없습니다.</div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="onClickClose">Cancel</el-button>
      </div>
    </template>
  </el-dialog>
</template>
<script lang="ts" setup>
import { computed, onMounted, ref, watch } from 'vue'
import { workflowHistoryList, deleteWorkflowDeploy } from "@/api/workflow"
import { useToast } from 'vue-toastification';
import { History } from '../type/type'

const toast = useToast();

interface Props {
  popupFlag: Boolean,
  workflowId: Number
}
const props = defineProps<Props>()
const emit = defineEmits(['on-click-close-history'])

onMounted(async () => {
  if (props.popupFlag) await getWorkflowHistoryList()
})
watch(() => props.popupFlag, async () => {
  clickedHistoryNumber.value = 0
  if (props.popupFlag) await getWorkflowHistoryList()
})

const historyList = ref([] as Array<History>)
const totalCount = ref(0)
const getWorkflowHistoryList = async() => {
  try {
    const { data } = await workflowHistoryList(props.workflowId);
    historyList.value = data ? data : []
    totalCount.value = historyList.value.length
  } catch (error) {
    console.log(error);
  }
}

const clickedHistoryNumber = ref(0)
const onClickHistoryNumber = idx => {
  clickedHistoryNumber.value = idx
}





const onClickClose = () => {
  historyList.value = []
  emit('on-click-close-history')
}
</script>