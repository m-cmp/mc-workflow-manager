<template>
    <div
        v-if="asideSecondaryDisplay"
        class="aside-secondary d-flex flex-row-fluid">
        <div class="aside-workspace my-5 p-5" id="kt_aside_wordspace">
            <div class="d-flex h-100 flex-column">
                <div
                    class="flex-column-fluid hover-scroll-y"
                    data-kt-scroll="true"
                    data-kt-scroll-activate="true"
                    data-kt-scroll-height="auto"
                    data-kt-scroll-wrappers="#kt_aside_wordspace"
                    data-kt-scroll-dependencies="#kt_aside_secondary_footer"
                    data-kt-scroll-offset="0px">
                    <div class="tab-content">
                        
                        <div
                            class="tab-pane fade active show"
                            id="kt_aside_nav_tab_menu"
                            role="tabpanel">
                            
                            <KTMenu ref="menu"></KTMenu>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- =============================================================================================================== -->
    <!-- 축소/확장 버튼 -->
    <!-- =============================================================================================================== -->
    <button
        id="BtnMinimize"
        ref="BtnMinimize"
        :class="{ active: minimizedAsideSecondary }"
        class="btn btn-sm btn-icon btn-white btn-active-primary position-absolute translate-middle start-100 end-0 bottom-0 shadow-sm d-none d-lg-flex"
        data-kt-toggle="true"
        data-kt-toggle-state="active"
        data-kt-toggle-target="body"
        data-kt-toggle-name="aside-minimize"
        style="margin-bottom: 1.35rem">
        
        <span class="svg-icon svg-icon-2 rotate-180">
          <inline-svg src="media/icons/duotune/arrows/arr063.svg" />
        </span>
        
    </button>
    
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import {defineComponent, getCurrentInstance, nextTick, onMounted, ref} from "vue";
import KTMenu from "@/layout/service/aside/Menu.vue";
// import KTNotifications from "@/layout/aside/tabs/Notifications.vue";
// import KTTasksOverview from "@/layout/aside/tabs/TasksOverview.vue";
import App, {setAsideSecondary} from "@/main"


import {
  minimizedAsideSecondary,
  asideSecondaryDisplay,
  minimizationEnabled,
} from "@/core/helpers/config";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";

export default defineComponent({
    name: "kt-aside-secondary",
    components: {
        KTMenu,
        // KTTasksOverview,
        // KTNotifications,
    },
    setup() {
        const instance = getCurrentInstance();
        const state = ref({
            visible: false,
        })
        setAsideSecondary(instance);
      
        
        /* ============================================================================================================= */
        // MINIMIZE
        /* ============================================================================================================= */
        
        const isOpened = () => {
            console.dir(instance?.refs.BtnMinimize);
            if(document.getElementById("BtnMinimize")?.classList.contains("active")) return false;
            else return true;
        }
        
        const animateOpen = (isVisible) => {
            if(isOpened() == true) return;
            
            // (instance?.refs.BtnMinimize as any).click();
            document.getElementById("BtnMinimize")?.click();
        }
        
        const animateClose = (isVisible) => {
            console.log("isOpen ................................... " + isOpened());
            console.dir((instance?.refs.BtnMinimize as any));
            
            if(isOpened() == false) return;
            (instance?.refs.BtnMinimize as any).click();
            
        }
        
        /* ============================================================================================================= */
        return {
            state,
            instance,
            minimizedAsideSecondary,
            asideSecondaryDisplay,
            minimizationEnabled,
            isOpened,
            animateOpen,
            animateClose,
        };
    },
});
</script>
