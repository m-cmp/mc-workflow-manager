<template>
  <div
    class="d-flex flex-column flex-column-fluid bgi-position-y-bottom position-x-center bgi-no-repeat bgi-size-contain bgi-attachment-fixed"
    style="background-image: url('images/login/login_bg.png')"
  >
    <!--begin::Content-->
    <div class="d-flex flex-center flex-column flex-column-fluid p-10 pb-lg-20">
      <!--begin::Logo-->
      <a href="#" class="mb-12">
        <img alt="Logo" src="images/logo/strato_logo_h.png" class="h-45px" />
      </a>
      <!--end::Logo-->

      <router-view></router-view>
    </div>
    <!--end::Content-->

  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, onUnmounted } from "vue";
import { useStore } from "vuex";
import { Actions } from "@/store/enums/StoreEnums";
import {useCookies} from "vue3-cookies";
import {useI18n} from "vue-i18n";
import { useRouter } from "vue-router";

export default defineComponent({
    name: "auth",
    components: {},
    setup() {
        const store = useStore();
        const { cookies } = useCookies();
        const i18n = useI18n();
        const router = useRouter();
        
        /* ============================================================================================================= */
        // 다국어 설정
        /* ============================================================================================================= */
        if(cookies.get("locale") == null) {
            let localeBrowser = navigator.language
            i18n.locale.value = localeBrowser.substring(0, 2);
        
            console.log("########### unsetted : locale = ", i18n.locale.value);

            // router.push({ name: "ProjectList" });
        }
        else {
            i18n.locale.value = cookies.get("locale");
            console.log("########### setted : locale = ", i18n.locale.value);
        }
        
        
        
        onMounted(() => {
            store.dispatch(Actions.ADD_BODY_CLASSNAME, "bg-body");
        });
        
        onUnmounted(() => {
            store.dispatch(Actions.REMOVE_BODY_CLASSNAME, "bg-body");
        });
    },
});
</script>
