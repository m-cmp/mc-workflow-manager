<template>
  <div class="card-toolbar" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-trigger="hover">
    <div class="d-flex ms-3">
      <span class="svg-icon svg-icon-2 svg-icon-gray-700 position-absolute translate-middle-y ms-4 t-42">
        <inline-svg src="images/icons/search/list-search-light.svg" class="commit-detail-icon" />
      </span>
      <input class="form-control form-control-solid h-40px bg-body ps-13 fs-7"
        :placeholder="$t('common.searchPlaceHolder')" @input="executeFilter" />
      {{ searchData }}
    </div>
    <div class="btn btn-flex flex-center btn-primary btn-text-white w-md-auto h-40px px-0 px-md-6 ps-8 pe-8"
      :tooltip="toolTip" style="width:120px;" @click="gotoNewPage">
      <span class="svg-icon svg-icon-3">
        <inline-svg src="media/icons/duotune/arrows/arr075.svg" />
      </span>
      <span class="d-none d-md-inline">
        {{ newText }}
      </span>
    </div>
  </div>
</template>

<script>
export default {
  name: "tableTitle",
  emits: ["execute-filter", "goto-new-page", "search-data"],
  props: {
    title: String,
    toolTip: String,
    newText: String,
  },
  setup(props, { emit }) {
    const executeFilter = ((val) => {
      emit("execute-filter", val.target.value);
    })
    const gotoNewPage = (() => {
      emit("goto-new-page");
    })
    
    return {
      executeFilter,
      gotoNewPage
    }
  }
}
</script>

<style scoped>
  .t-42 {
    top: 42px
  }
</style>
