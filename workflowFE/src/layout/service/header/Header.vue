<template>
    <!--begin::Header-->
    <div
        id="kt_header"
        class="header h-75px"
        :data-kt-sticky="isHeaderSticky"
        data-kt-sticky-name="header"
        data-kt-sticky-offset="{default: '200px', lg: '300px'}"  >
        
        <!--begin::Container-->
        <!--      :class="{-->
        <!--        'container-fluid': headerWidthFluid,-->
        <!--        'container-xxl': !headerWidthFluid,-->
        <!--      }"-->
        <div class="d-flex align-items-center justify-content-between container-xxl h-50px mt-3 pt-0"
             id="kt_header_container" >
    
            <div class="docs-page-title d-flex flex-column flex-lg-row align-items-lg-center py-0 mb-lg-0" data-kt-swapper="true" data-kt-swapper-mode="prepend" data-kt-swapper-parent="{default: '#kt_docs_content_container', 'lg': '#kt_docs_header_title'}">
                
                <!-- ==== TITLE ==== -->
                <h1 class="d-flex align-items-center text-dark my-3 mt-6 fs-3 fw-boldest">
                    {{ title }}
                </h1>
    
                <!--
                //구분선
                <span class="d-none d-lg-block bullet h-20px w-1px bg-secondary mt-3 mx-4"></span>
                
                //패스
                <ul v-if="breadcrumbs" class="breadcrumb fw-bold fs-base my-1 mt-5">
                    <li class="breadcrumb-item text-muted">
                        <router-link to="/" class="text-muted"> Home </router-link>
                    </li>
                    <template v-for="(item, index) in breadcrumbs" :key="index">
                        <li class="breadcrumb-item text-dark">
                            {{ item }}
                        </li>
                    </template>
                    <li class="breadcrumb-item text-dark">
                        {{ title }}
                    </li>
                </ul>
                -->
            </div>
            
            <div class="d-flex d-lg-none align-items-center ms-n2 me-2">
                <div class="btn btn-icon btn-active-icon-primary" id="kt_aside_toggle">
                    <span class="svg-icon svg-icon-2x">
                        <inline-svg src="media/icons/duotune/abstract/abs015.svg" />
                    </span>
                </div>
                
                <a href="#" class="d-flex align-items-center">
                    <img alt="Logo" src="images/logo/strato_logo_v.png" class="h-50px" />
                </a>
            </div>
            
            <component v-bind:is="state.topbar.name" v-bind="state.topbar.props" hidden> </component>
            
        </div>
        
    </div>
    <div class="container-xxl ms-auto me-auto">
        <div class="container-xxl border-gray-300 border-bottom border-bottom-dashed mt-0 pt-0 ms-0 " > </div>
    </div>
    
</template>

<script lang="ts">
import {defineComponent, computed, getCurrentInstance, ref, onMounted, nextTick} from "vue";
import { headerWidthFluid } from "@/core/helpers/config";
import { headerFixed, headerFixedOnMobile } from "@/core/helpers/config";

import TopbarController from "@/layout/service/header/TopbarController";

export default defineComponent({
    name: "KTHeader",
    props: {
        title: String,
        breadcrumbs: Array,
    },
    components: {

    },
    setup() {
        /* ============================================================================================================= */
        // DATA
        /* ============================================================================================================= */
        const instance = getCurrentInstance();
        const state = ref({
            topbar: {
                name: "",
                props: {}
            }
        });

        const organization = ref();
        const project = ref(null);
        const service = ref(null);
        
        /* ============================================================================================================= */
        // LIFECYCLE
        /* ============================================================================================================= */
        onMounted( () => {
            nextTick(() => {
                TopbarController.init();
            });
        });
    

        /* ============================================================================================================= */
        
        const isHeaderSticky = computed(() => {
            if (window.innerWidth > 768) {
                return headerFixed.value;
            } else {
                return headerFixedOnMobile.value;
            }
        });
        
        
        /* ================================================================================================================= */
        // TOPBAR 제어
        /* ================================================================================================================= */
    
        function setTopbar(compName, compProps) {
            state.value.topbar.name = compName;
            state.value.topbar.props = compProps;
        }
        
        /* ================================================================================================================= */
        
        return {
            headerWidthFluid,
            isHeaderSticky,
            instance,
            state,
            setTopbar,
        };
    },
});
</script>
