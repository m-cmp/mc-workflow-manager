<template>
    <div class="modal fade" tabindex="-1" id="kt_modal_1" data-bs-backdrop="static">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ $t("common.confirm") }}</h5>

            <!--begin::Close-->
            <div
              class="btn btn-icon btn-sm btn-active-light-primary ms-2"
              data-bs-dismiss="modal"
              aria-label="Close"
            >
              <span class="svg-icon svg-icon-2x"></span>
            </div>
            <!--end::Close-->
          </div>

          <div class="modal-body">
            <p>
                {{content}}
            </p>
          </div>

          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-light"
              data-bs-dismiss="modal"
              id="modalCancelBtn"
            >
              {{$t("common.cancel")}}
            </button>
            <button type="button" class="btn btn-primary"
                @click="$emit('fnParent')"
            >
              {{$t("common.ok")}}
            </button>
          </div>
        </div>
      </div>
    </div>
</template>

<script lang="ts">
import {useI18n} from "vue-i18n";

export default {
   name: "ConfirmModal",
   props: {
       content: String
   },
   setup(props) {
       /* ============================================================================================================= */
        // 다국어 설정
        /* ============================================================================================================= */
        
        let { t, locale } = useI18n();



       const closePop = () => {
           document.getElementById("modalCancelBtn")?.click();
       }
       return {
           closePop
       }
   }
};
</script>
