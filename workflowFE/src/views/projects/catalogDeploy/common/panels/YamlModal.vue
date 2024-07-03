<template>
  <el-dialog
    v-model="dialogVisible"
    title="Yaml preview"
    width="700px"
    :before-close="handleClose"
  >
    <pre class="yaml-data-view">{{ yamlData }}</pre>
  </el-dialog>
  <!-- <template v-if="dialogVisible">
    <el-dialog @click="onClickBG($event)" title="Yaml preview" width="700px">
      <pre class="yaml-data-view">{{ yamlData }}</pre>
    </el-dialog>
  </template> -->
</template>

<script>
export default {
  data() {
    return {
      dialogVisible: false,
      yamlData: "",
    };
  },

  methods: {
    show(data) {
      console.log(data);
      this.yamlData = data;
      this.dialogVisible = true;
    },
    onClickBG(event) {
      event.preventDefault();
      event.stopPropagation();
    },

    hide() {
      this.dialogVisible = false;
    },
  },
};
</script>

<style lang="scss">
.yaml-data-view {
  height: 500px;
  overflow: auto;
  padding: 0;
}
</style>