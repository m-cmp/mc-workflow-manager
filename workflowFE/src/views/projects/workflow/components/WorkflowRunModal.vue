<template>
  <el-dialog v-model="centerDialogVisible" title="Warning" width="500" align-center>
    <span>Open the dialog from the center from the screen</span>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="centerDialogVisible = false">Cancel</el-button>
        <el-button type="primary" @click="centerDialogVisible = false">
          Confirm
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>
<script lang="ts" setup>
import { computed, onMounted, ref, watch } from 'vue'

interface Props {
  flag: Boolean,
}
const props = defineProps<Props>()

const centerDialogVisible = computed(()=> props.flag)

watch(()=> props.flag, () => {
  alert('watch')
})
onMounted(() => {
  alert('test')
})

</script>