<template>
  <!-- <div class="title-layout"> -->
  <h3 class="card-title align-items-start flex-column">
    <span class="card-label fw-bolder fs-3 mb-1">
      {{ title }}
    </span>
  </h3>
  <el-radio-group v-if="radioData.length > 0" v-model="mapFlag">
    <el-radio-button v-for="(data, index) in radioData" :key="index" :label="data.label" :value="data.value" />
  </el-radio-group>
  <!-- </div> -->
</template>

<script>
import { onMounted, ref, watch } from 'vue'
export default {
  name: "tableTitle",
  emits: ["toggle-view"],
  props: {
    title: String,
    radioData: Array,
  },
  setup(props, { emit }) {
    
    const mapFlag = ref('')
    if (props.radioData.length > 0) props.radioData[0].value
    
    watch(() => mapFlag.value, (val) => {
      emit("toggle-view", val)
    })

    onMounted(() => {
      if (props.radioData.length > 0) emit("toggle-view", props.radioData[0].value)
    })

    return {
      mapFlag
    }
  }
}
</script>

<style scoped>
.title-layout {
  /* display: flex;
  justify-content: flex-start; */
}
</style>
