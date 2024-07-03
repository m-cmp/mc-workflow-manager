<template>
  <div
    id="kt_aside"
    class="aside aside-extended bg-white"
    data-kt-drawer="true"
    data-kt-drawer-name="aside"
    data-kt-drawer-activate="{default: true, lg: false}"
    data-kt-drawer-overlay="true"
    data-kt-drawer-width="auto"
    data-kt-drawer-direction="start"
    data-kt-drawer-toggle="#kt_aside_toggle"
  >
    <KTAsidePrimary ref="asidePrimary" id="asidePrimary"></KTAsidePrimary>
    <KTAsideSecondary ref="asideSecondary" id="asideSecondary"></KTAsideSecondary>
  </div>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import {defineComponent, getCurrentInstance, onMounted} from "vue";
import KTAsidePrimary from "@/layout/service/aside/AsidePrimary.vue";
import KTAsideSecondary from "@/layout/service/aside/AsideSecondary.vue";

export default defineComponent({
  name: "KTAside",
  components: {
    KTAsidePrimary,
    KTAsideSecondary,
  },
  props: {
    lightLogo: String,
    darkLogo: String,
  },
  setup() {
    const instance = getCurrentInstance();
    console.log("Aside...setup() =====================================================================");
    
    return {
      instance
    }
  }
});
</script>
