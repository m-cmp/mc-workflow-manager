<template>
  <div v-show="state.visible" class="modal-wrapper s-modal">
    <div class="modal-bg" @click="onClickModalBG" />
    <div class="modal-panel" :class="panelClass" @click.stop>
      <header class="header propsHeader">
        <slot name="header">
          <div class="title">{{ title }}</div>
        </slot>
        <button v-if="showClose" class="btn-close" @click="onClickClose">
          <i class="el-icon-close" />
        </button>
      </header>
      <main>
        <slot name="default" />
      </main>
      <div v-if="hasFooter" class="footer">
        <slot name="footer" />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { useI18n } from "vue-i18n";
import {
  getCurrentInstance,
  nextTick,
  computed,
  defineComponent,
  onMounted,
  ref,
  onUnmounted,
  reactive,
} from "vue";
import { useToast } from "vue-toastification";

export default {
  props: {
    useDimd: {
      type: Boolean,
      default: true,
    },

    hasFooter: {
      type: Boolean,
      default: false,
    },

    title: {
      type: String,
      default: "",
    },

    panelClass: {
      type: String,
      default: "",
    },

    showClose: {
      type: Boolean,
      default: true,
    },

    closeOnClickModal: {
      type: Boolean,
      default: true,
    },

    closeOnPressEscape: {
      type: Boolean,
      default: true,
    },
  },

  setup(props, { emit }) {
    const state = ref({
      visible: false,
      escHandler: null,
    });
    const instance = getCurrentInstance();

    onUnmounted(() => {
      removeEscEventListener();
    });

    function show() {
      //console.log('show', this.visible)
      if (state.value.visible) {
        return;
      }
      state.value.visible = true;
      emit("before-open");
      _attachElement();
      addEscEventListenerCall();
      emit("opened");
    }

    function hide() {
      //console.log('hide', this.visible)
      if (!state.value.visible) {
        return;
      }
      state.value.visible = false;
      emit("before-close");
      _dettachElement();
      removeEscEventListener();
      emit("closed");
    }

    function onClickClose() {
      // confirm msg가 필요하다면 여기서..
      hide();
    }

    function addEscEventListenerCall() {
      //console.log('--add')
      (state.value.escHandler as any) = onEscKeyEvent.bind(instance);
      document.addEventListener("keydown", (state.value as any).escHandler);
    }

    function removeEscEventListener() {
      //console.log('--remove')
      if (state.value.escHandler) {
        document.removeEventListener(
          "keydown",
          (state.value as any).escHandler
        );
        state.value.escHandler = null;
      }
    }

    function onEscKeyEvent(evt) {
      if (props.closeOnPressEscape) {
        evt = evt || {};
        if (evt.keyCode === 27) {
          hide();
        }
      }
    }

    function onClickModalBG() {
      if (props.closeOnClickModal) {
        hide();
      }
    }
    const oldOverflow = ref("");

    function _attachElement() {
      //console.log('attach')

      if(instance?.refs.el !== undefined){
        document.body.append(instance?.refs.el as any);
      }

      if (props.useDimd === false) {
        oldOverflow.value = document.body.style.overflow;
        document.body.style.overflow = "hidden";
      }
    }

    function _dettachElement() {
      //console.log('_dettachElement')

      if(instance?.refs.el !== undefined){
        document.body.removeChild(instance?.refs.el as any);
      }
      
      if (props.useDimd === false) {
        document.body.style.overflow = oldOverflow.value;
      }
    }

    return {
      state,
      onClickModalBG,
      onClickClose,
      show,
      hide,
      onEscKeyEvent,
    };
  },
};
</script>