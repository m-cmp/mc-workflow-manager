<!--
    :
    : PAGINATION의 하나의 페이지 번호 컴포넌트
    :
-->

<!-- ################################################################################################################### -->

<template>
  <li
    class="page-item"
    v-bind:class="{ active: isActive }"
    ref="node">

    <a href="#" class="page-link">{{ pageNo }}</a>

  </li>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">

export default {
  name: "PaginationPage",
  props: {
    pageNo: Number,
    isActive: Boolean
  },
  setup() {

  }
}
</script>

