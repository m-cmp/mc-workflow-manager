<template>
  <div ref="table" />
</template>

<script setup lang="ts">
import {ref, onBeforeUnmount, onMounted, watch} from 'vue';
import {TabulatorFull as Tabulator, type ColumnDefinition} from 'tabulator-tables';

interface Props {
  columns: Array<ColumnDefinition>
  tableData: any
}

const props = defineProps<Props>()
// const emit = defineEmits(['on-click-close-history'])

const table = ref(null) as any;
const tabulator = ref(null) as any;

watch(()=> props.columns, () => {
  if (!hasColumns()) {
    return
  }

  if (tabulator.value) {
    tabulator.value.destroy()
    tabulator.value = null
  }

  makeTable()
})
watch(()=> props.tableData, () => {
  updateTableData()
})

onMounted(() => {
  makeTable()
})

onBeforeUnmount(() => {
  if (tabulator.value) {
    tabulator.value.destroy()
    tabulator.value = null
  }
})

const makeTable = () => {
  if (tabulator.value || !table.value || !hasColumns()) {
    return
  }

  tabulator.value = new Tabulator(table.value, {
    data: props.tableData,
    reactiveData:true,
    columns: props.columns,
    pagination: true,
    paginationSize:6,
    paginationSizeSelector:[3, 6, 8, 10],
    movableColumns:true,
    paginationCounter:"rows",
  });
}

const hasColumns = () => {
  return Array.isArray(props.columns) && props.columns.length > 0
}

const updateTableData = async () => {
  if (!tabulator.value) {
    makeTable()
    return
  }

  const currentPage = tabulator.value.getPage()
  const currentPageSize = tabulator.value.getPageSize()
  const currentSorters = tabulator.value.getSorters()
  const currentFilters = tabulator.value.getFilters()

  await tabulator.value.replaceData(props.tableData || [])

  if (currentSorters.length > 0) {
    tabulator.value.setSort(currentSorters)
  }
  if (currentFilters.length > 0) {
    tabulator.value.setFilter(currentFilters)
  }
  if (currentPageSize) {
    tabulator.value.setPageSize(currentPageSize)
  }

  const maxPage = tabulator.value.getPageMax()
  if (currentPage && maxPage) {
    tabulator.value.setPage(Math.min(currentPage, maxPage))
  }
}

</script>
<style>
.tabulator .tabulator-header {
  position: relative;
  box-sizing: border-box;
  width: 100%;
  /* font-size: $textSize*0.8; */
  font-weight: unset;
  white-space: nowrap;
  overflow: hidden;
  outline: none;
  /* border-top: 1px solid $border-color; */
}

.tabulator .tabulator-header .tabulator-col .tabulator-col-content .tabulator-col-title{
	/* padding: 0 $headerMargin*3 0 $headerMargin*3; */
}

.tabulator-row .tabulator-cell {
  display: inline-block;
  position: relative;
  box-sizing: border-box;
  /* padding: $headerMargin*2 $headerMargin*4 $headerMargin*2 $headerMargin*4;
  border-bottom: 1px solid $border-color; */
  vertical-align: middle;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  outline: none;
}

.tabulator .tabulator-footer{
	font-weight: unset;
}

.tabulator-page{
  &.active{
    font-weight: bold;
  }
}
</style>
