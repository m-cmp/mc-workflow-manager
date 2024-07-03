<template>
  <div class="page d-flex flex-row flex-column-fluid">
    <!-- ==== LEFT SIDE MENU ==== -->
    <!-- <KTAside v-if="asideEnabled" :lightLogo="themeLightLogo" :darkLogo="themeDarkLogo" ref="aside">
    </KTAside> -->

    <div id="kt_wrapper" class="wrapper d-flex flex-column flex-row-fluid ">

      <!-- ==== CONTENT LAYER ==== -->
      <div class="flex-fill"><!-- d-flex 화면 사이즈로 인해 제거 22.04.15 -->

        <div id="kt_content" class="content d-flex flex-column flex-column-fluid vld-parent" ref="kt_content">

          <!-- ==== PAGE LOADING ==== -->
          <VueLoading v-model:active="state.isPageLoading" :isFullPage="state.isFullFlag" opacity="0.9" width="40"
            height="40" />

          <!-- ==== TOP HEADER ==== -->
          <KTHeader :title="pageTitle" :breadcrumbs="breadcrumbs" ref="header"></KTHeader>

          <div id="kt_content_container" class="mt-4 pt-4 container-xxl">
            <router-view />
          </div>
        </div>

      </div>
    </div>
  </div>

  <KTScrollTop></KTScrollTop>
  <KTUserMenu></KTUserMenu>

</template>

<script lang="ts">
import {computed, defineComponent, getCurrentInstance, nextTick, onMounted, ref, watch} from "vue";
import {useStore} from "vuex";
import {useRoute, useRouter} from "vue-router";
import KTAside from "@/layout/service/aside/Aside.vue";
import KTHeader from "@/layout/service/header/Header.vue";
import HtmlClass from "@/core/services/LayoutService";
import KTScrollTop from "@/layout/service/extras/ScrollTop.vue";
import KTUserMenu from "@/layout/service/header/partials/ActivityDrawer.vue";
import KTLoader from "@/components/Loader.vue";
import KTCreateApp from "@/components/base/modals/wizards/CreateAppModal.vue";
import KTInviteFriendsModal from "@/components/base/modals/general/InviteFriendsModal.vue";
import KTUpgradePlanModal from "@/components/base/modals/general/UpgradePlanModal.vue";
import {Actions} from "@/store/enums/StoreEnums";
import {MenuComponent} from "@/assets/ts/components";
import {reinitializeComponents} from "@/core/plugins/keenthemes";
import {removeModalBackdrop} from "@/core/helpers/dom";
import {
    asideEnabled,
    contentWidthFluid,
    loaderEnabled,
    loaderLogo,
    subheaderDisplay,
    themeDarkLogo,
    themeLightLogo,
    toolbarDisplay,
} from "@/core/helpers/config";
import VueLoading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';
import {useI18n} from "vue-i18n";
import {useCookies} from "vue3-cookies";

export default defineComponent({
    name: "Layout",
    components: {
        KTAside,
        KTHeader,
        KTScrollTop,
        KTUserMenu,
        KTLoader,
        VueLoading
    },
    setup() {
        const store = useStore();
        const route = useRoute();
        const router = useRouter();
        const i18n = useI18n();
        const { cookies } = useCookies();
        
        const instance = getCurrentInstance();
        const state = ref({
            isPageLoading: computed(() => store.getters.isPageLoading),
            isFullFlag: false,
        });
        
        // show page loading
        store.dispatch(Actions.ADD_BODY_CLASSNAME, "page-loading");
        
        // initialize html element classes
        HtmlClass.init();
        
        const pageTitle = computed(() => {
            return store.getters.pageTitle;
        });
        
        const breadcrumbs = computed(() => {
            return store.getters.pageBreadcrumbPath;
        });
        
        /* ============================================================================================================= */
        // 다국어 설정
        /* ============================================================================================================= */
        if(cookies.get("locale") == null) {
            let localeBrowser = navigator.language
            i18n.locale.value = localeBrowser.substring(0, 2);
            
            console.log("########### unsetted : locale = ", i18n.locale.value);
        }
        else {
            i18n.locale.value = cookies.get("locale");
            console.log("########### setted : locale = ", i18n.locale.value);
        }
        
        
        
        
        onMounted(() => {
            //check if current user is authenticated
            if (!router.options.history.state.back) {
                // router.push({ name: "SignIn" });
                // router.push({ name: "ProjectList" });
                router.push({ name: "ConfigurationConnectionList" });
            }
            
            nextTick(() => {
                reinitializeComponents();
            });
            
            // Simulate the delay page loading
            setTimeout(() => {
                // Remove page loader after some time
                store.dispatch(Actions.REMOVE_BODY_CLASSNAME, "page-loading");
            }, 500);
        });
        
        watch(
            () => route.path,
            () => {
                MenuComponent.hideDropdowns(undefined);
                
                // check if current user is authenticated
                // if (!store.getters.isUserAuthenticated) {
                //     router.push({ name: "SignIn" });
                // }
                
                nextTick(() => {
                    reinitializeComponents();
                });
                removeModalBackdrop();
            }
        );
        
        return {
            toolbarDisplay,
            loaderEnabled,
            contentWidthFluid,
            loaderLogo,
            asideEnabled,
            subheaderDisplay,
            pageTitle,
            breadcrumbs,
            state,
            themeLightLogo,
            themeDarkLogo,
        };
    },
});
</script>

<style>


</style>
