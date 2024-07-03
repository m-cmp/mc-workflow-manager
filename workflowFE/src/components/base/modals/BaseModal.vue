<template>
  <!-- teleport: 렌더링 시 위치를 지정합니다. -->
  <teleport to="body">
    <!-- Modal의 열리고 닫힘을 관리합니다. -->
    <transition name="fade">
      <div class="modalin" v-if="isVisible">
        <div class="modalfadein modal-dialog modal-dialog-centered mw-650px">
          <!--begin::Modal content-->
          <div class="modal-content">
            <!-- slot을 통해 BaseComponent를 확장시킵니다. -->
            <slot></slot>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>

<script lang="ts">
import { ref } from "vue";
export default {
  name: "Modal",
  setup() {
    const isVisible = ref(false);

    // 부모 컴포넌트에서 접근하기 위한 함수를 선언합니다.
    const open = () => {
      isVisible.value = true;
    };

    const close = () => {
      isVisible.value = false;
    };

    // setup 함수에서 리턴해주어야, 부모 컴포넌트에서 접근이 가능합니다.
    return {
      isVisible,
      open,
      close,
    };
  },
};
</script>

<style scoped>
.modalin {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1060;
  width: 100%;
  height: 100%;
  overflow-x: hidden;
  overflow-y: auto;
  outline: 0;
  background: rgba(0, 0, 0, 0.25);
  /* animation: FadeIn .3s ease-in; */
}

.fade-enter-from,
.fade-leave-to {
  /*transform: translateY(-150px);*/
  opacity: 0;
}
.fade-enter-active,
.fade-leave-active {
  transition: all 0.4s;
}
.fade-enter-to,
.fade-leave-from {
  /*transform: translateY(0px);*/
  opacity: 1;
}

.modalfadein {
  animation: FadeIn 0.2s ease-in;
}

@keyframes FadeIn {
  0% {
    opacity: 0;
  }
  1% {
    opacity: 0;
    transform: translateY(-5%);
  }
  100% {
    opacity: 1;
  }
}

@keyframes FadeOut {
  0% {
    opacity: 1;
  }
  1% {
    opacity: 1;
  }
  100% {
    transform: translateY(-5%);
    opacity: 0;
  }
}

.modal-content {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 100%;
  pointer-events: auto;
  background-color: #ffffff;
  background-clip: padding-box;
  border: 0 solid rgba(0, 0, 0, 0.2);
  border-radius: 0.475rem;
  box-shadow: 0 0.25rem 0.5rem rgb(0 0 0/10%);
  outline: 0;
}
</style>
