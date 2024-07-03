<template>
  <div class="aside-primary d-flex flex-column align-items-lg-center flex-row-auto" >

    <!-- =============================================================================================================== -->
    <!-- 로고 -->
    <!-- =============================================================================================================== -->
    <div class="aside-logo d-none d-lg-flex flex-column align-items-center flex-column-auto py-10" id="kt_aside_logo">
      <a href="#">
        <img alt="Logo" src="images/logo/strato_logo_v.png" class="h-60px" />
      </a>
    </div>


    <!-- =============================================================================================================== -->
    <!-- 상단 메뉴 -->
    <!-- =============================================================================================================== -->
    <div class="aside-nav d-flex flex-column align-items-center flex-column-fluid w-100 pt-5 pt-lg-0" id="kt_aside_nav" >
      
      <div
        class="hover-scroll-y mb-10"
        data-kt-scroll="true"
        data-kt-scroll-activate="{default: false, lg: true}"
        data-kt-scroll-height="auto"
        data-kt-scroll-wrappers="#kt_aside_nav"
        data-kt-scroll-dependencies="#kt_aside_logo, #kt_aside_footer"
        data-kt-scroll-offset="0px">
        <ul class="nav flex-column" v-for="(serviceProp, index) in serviceProps" :key="serviceProp">
          <AsideButton
            :key="serviceProp"
            v-bind="serviceProp"
            :isActive="serviceProp.isActive"
            v-on:click.prevent="onClickButton(index)"
            ref="asideButton"></AsideButton>

        </ul>
      </div>

    </div>


    <!-- =============================================================================================================== -->
    <!-- 하단 메뉴 -->
    <!-- =============================================================================================================== -->
    <div class="aside-footer d-flex flex-column align-items-center flex-column-auto" id="kt_aside_footer" >

      <!-- 설정 -->
      <!-- <div class="d-flex align-items-center mb-2">
        <div
          class="btn btn-icon btn-active-color-primary btn-color-gray-400 btn-active-light"
          data-kt-menu-trigger="click"
          data-kt-menu-overflow="true"
          data-kt-menu-placement="top-start"
          data-kt-menu-flip="top-end"
          data-bs-toggle="tooltip"
          data-bs-placement="right"
          data-bs-dismiss="click"
          title="Configuration">
          <span class="svg-icon svg-icon-2 svg-icon-lg-1">
            <inline-svg src="images/icons/common/setup.svg" />
          </span>
        </div>
        <SetupMenu></SetupMenu>
      </div> -->



      <!-- 사용자 -->
      <!-- <div
        class="d-flex align-items-center mb-10"
        id="kt_header_user_menu_toggle">
        <div
          class="cursor-pointer symbol symbol-40px"
          data-kt-menu-trigger="click"
          data-kt-menu-overflow="true"
          data-kt-menu-placement="top-start"
          data-kt-menu-flip="top-end"
          data-bs-toggle="tooltip"
          data-bs-placement="right"
          data-bs-dismiss="click"
          title="User profile">
          <img src="images/icons/person/square-user.svg" alt="metronic" />
        </div>
        <KTUserMenu></KTUserMenu>
      </div> -->
    </div>
  </div>
</template>

<script lang="ts">
import {defineComponent, getCurrentInstance, nextTick, onMounted, ref} from "vue";
import KTQuickLinksMenu from "@/layout/service/header/partials/QuickLinksMenu.vue";
import SetupMenu from "@/layout/service/header/partials/SetupMenu.vue";
import KTUserMenu from "@/layout/service/header/partials/UserMenu.vue";
import AsideButton from "../../../components/base/menu/AsideButton.vue";
import { AsideButtonProp } from "@/components/base/menu/AsideButtonProp";
import asidePrimaryController from '@/layout/service/aside/AsidePrimaryController'
import { useRouter } from "vue-router";
import App, {setAsidePrimary} from "@/main"

export default defineComponent({
    name: "kt-aside-primary",
    components: {
        KTQuickLinksMenu,
        SetupMenu,
        KTUserMenu,
        AsideButton,
    },
    setup() {
        const serviceProps = ref(new Array<AsideButtonProp>());
        const instance = getCurrentInstance();
        const router = useRouter();
    
        console.log("AsidePrimary...setup() =====================================================================");
        setAsidePrimary(instance as any);
        
   
    
        /* ================================================================================================================= */
        // 서비스 메뉴 등록 관리
        /* ================================================================================================================= */
        
        const clear = () => {
          serviceProps.value.length = 0;
          
        }
        
        const push = (prop: AsideButtonProp) => {
          serviceProps.value.push(prop);
        }
        
        const pop = () => {
          serviceProps.value.pop();
        }
        
        const size = () => {
          return serviceProps.value.length;
        }
        
        
        /* ================================================================================================================= */
        // 이벤트
        /* ================================================================================================================= */
        
        const onClickButton = (clickedIndex: number) => {
            if(serviceProps.value[clickedIndex].isActive == true) return;
            
            serviceProps.value.forEach((prop, index) => {
                prop.isActive = false;
                if(index == clickedIndex) prop.isActive = true;
                
                (instance?.refs.asideButton as any)[index].setActive(prop.isActive)
            })
    
            if(serviceProps.value[clickedIndex].routerName != null) {
                // router.push(serviceProps.value[clickedIndex].path || "");
                router.push({
                    name: serviceProps.value[clickedIndex].routerName,
                    params: serviceProps.value[clickedIndex].params
                });
            }
        };
        
        /* ================================================================================================================= */
        
        return {
            serviceProps,
            clear,
            push,
            pop,
            size,
            onClickButton
        }
    
    },

});
</script>
