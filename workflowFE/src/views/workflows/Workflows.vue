<template>
  <div class="workflows-page">
    <RouterView />
  </div>
</template>

<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<style scoped>
.workflows-page {
  min-width: 0;
}
</style>
