<template>
  <div class="change-pw-field-wrap d-flex">
    <el-input
      @blur="onBlur"
      @change="onChange"
      show-password
      type="password"
      :placeholder="placeholder"
      :disabled="!isEdit"
      v-model="editData[propName]"
      style="margin-right: 20px"
    />
    <el-button
      class="btn btn-primary"
      v-if="isEdit === false"
      @click="onClickEdit"
      >{{ $t("common.edit") }}</el-button
    >
    <el-button
      class="btn btn-success"
      v-if="isEdit === true"
      @click="onClickReset"
      >{{ $t("common.reset") }}</el-button
    >
  </div>
</template>

<script>
export default {
  props: {
    placeholder: {
      type: String,
      default: "",
    },
    propName: {
      type: String,
      default: "password",
    },
    editData: { _isPwEdit: false },
  },
  data() {
    return {};
  },

  computed: {
    isEdit: function () {
      return this.editData._isPwEdit;
    },
  },

  methods: {
    onBlur($event) {
      this.$emit("blur", $event);
    },

    onChange($event) {
      this.$emit("change", $event);
    },

    onClickEdit() {
      this.editData._isPwEdit = true;
      this.editData[this.propName] = "";
      this.onChange("");
    },

    onClickReset() {
      this.editData._isPwEdit = false;
      this.editData[this.propName] = "";
      this.onChange("");
    },
  },
};
</script>
