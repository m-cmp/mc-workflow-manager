<!--
    :
    : 타이틀, 메시지, 버턴(확인, 취소)으로 구성되는 메시지 팝업
    :
-->


<!-- ################################################################################################################### -->

<template>
  <div class="modal fade" tabindex="-1" id="kt_modal_1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title"> {{ state.title }} </h5>

          <!--begin::Close-->
          <div class="btn btn-icon btn-sm btn-active-light-primary ms-2" data-bs-dismiss="modal" aria-label="Close">
            <span class="svg-icon svg-icon-2x"></span>
          </div>
          <!--end::Close-->
        </div>

        <div class="modal-body">
          <p> {{ state.message }} </p>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-light" data-bs-dismiss="modal" v-on:click="state.button1Prop.callback(state.button1Prop.param)">
            {{ state.button1Prop.caption }}
          </button>
          <button type="button" class="btn btn-primary" data-bs-dismiss="modal" v-on:click="state.button2Prop.callback(state.button2Prop.param)">
            {{ state.button2Prop.caption }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">

import {defineComponent, ref} from "vue";
import { MessageBoxButtonProp } from "@/components/messagebox/MessageBoxButtonProp"


export default defineComponent ({
  name: "ConfirmMessageBox",
  components: {},
  
  setup() {
    const state = ref({
      title: "title",
      message: "message",
      button1Prop: new MessageBoxButtonProp('', (param)=>{}, null),
      button2Prop: new MessageBoxButtonProp('', (param)=>{}, null)
    });
    
    const setProps = (title, message, btn1Prop: MessageBoxButtonProp, btn2Prop: MessageBoxButtonProp) => {
      state.value.title = title;
      state.value.message = message;
      state.value.button1Prop = btn1Prop;
      state.value.button2Prop = btn2Prop;
    }
    
    return {
      state,
      setProps
    }
  }

});

</script>


