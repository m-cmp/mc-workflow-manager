<!--
    :
    : 최상위 메뉴의 서비스 버턴(상단) 컴포넌트
    :
-->

<!-- ################################################################################################################### -->

<template>
  <li class="nav-item mb-2" data-bs-toggle="tooltip" data-bs-trigger="hover" data-bs-placement="right" data-bs-dismiss="click" title="organization">
    <a ref="myBtn"
        class="nav-link btn btn-icon btn-active-color-primary btn-color-gray-400 btn-active-light"
        v-bind:class="{active: state.isActive}"
        data-bs-toggle="tab"
        @click.prevent>
              <span class="svg-icon svg-icon-2x">
                <inline-svg :src="iconPath" />
              </span>
    </a>
  </li>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">

import {defineComponent, getCurrentInstance, nextTick, ref} from "vue";

export default defineComponent ({
  name: "AsideButton",
  components: {},
  props: {
    id: Number,
    isActive: Boolean,
    iconPath: String,
  },
  
  setup(props) {
    const state = ref({
      isActive: props.isActive
    });
    const instance = getCurrentInstance();
    
    const setActive = (flag: boolean) => {
      state.value.isActive = flag;
    }
    
    return {
      state,
      setActive
    }
  }
});

</script>

