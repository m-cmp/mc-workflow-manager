<template>
    <div
        id="kt_aside_menu_wrapper"
        ref="scrollElRef"
        class="hover-scroll-overlay-y my-0 my-lg-0"
        data-kt-scroll="true"
        data-kt-scroll-activate="{default: false, lg: true}"
        data-kt-scroll-dependencies="#kt_aside_logo, #kt_aside_footer"
        data-kt-scroll-offset="0"
        data-kt-scroll-wrappers="#kt_aside_menu">

        <div
            id="#kt_header_menu"
            class="menu menu-column menu-title-gray-800 pt-0 mt-0 menu-state-title-primary menu-state-icon-primary menu-state-bullet-primary menu-arrow-gray-500"
            data-kt-menu="true" >
            
            <div class="fs-3 text-gray-700 mt-0 pt-4 ps-4 pb-4 mb-8 bg-light rounded" style="font-weight: 600;">
                {{ translate(state.title) }}
            </div>
            
            <template v-for="(item, i) in state.menuConfigs" :key="i">
                <div v-if="item.heading" class="menu-item mt-7 pt-8">
                    <div class="menu-content pt-8 pb-2">
                        <span class="menu-section text-muted text-uppercase fs-7 fw-bolder ls-1">
                            {{ translate(item.heading) }}
                        </span>
                    </div>
                </div>
                <div class="mt-4"></div>
                <template v-for="(menuItem, j) in item.pages" :key="j">
                    <template v-if="menuItem.heading">
                        <div class="menu-item">
                            <router-link
                                v-if="!menuItem.isDisabled"
                                class="menu-link"
                                active-class="active"
                                :to="menuItem.route"
                                >
                                <span
                                    v-if="menuItem.svgIcon || menuItem.fontIcon"
                                    class="menu-icon"
                                    >
                                    <i
                                        v-if="asideMenuIcons === 'font'"
                                        :class="menuItem.fontIcon"
                                        class="bi fs-3">
                                    </i>
                                    <span
                                        v-else-if="asideMenuIcons === 'svg'"
                                        class="svg-icon svg-icon-4"
                                        >
                                        <inline-svg :src="menuItem.svgIcon" />
                                    </span>
                                    
                                </span>
                                
                                <span class="menu-title-gray-700 ms-2 fs-6 fw-bolder " >
                                    {{ translate(menuItem.heading) }}
                                </span>
                            </router-link>
    
                            <router-link
                                v-if="menuItem.isDisabled"
                                class="menu-link"
                                active-class="active"
                                :to="menuItem.route"
                                style="pointer-events:none; cursor:default;" >
                                <span
                                    v-if="menuItem.svgIcon || menuItem.fontIcon"
                                    class="menu-icon">
                                    <i
                                        v-if="asideMenuIcons === 'font'"
                                        :class="menuItem.fontIcon"
                                        class="bi fs-3">
                                    </i>
                                    <span
                                        v-else-if="asideMenuIcons === 'svg'"
                                        class="svg-icon svg-icon-4"
                                    >
                                        <inline-svg :src="menuItem.svgIcon" />
                                    </span>
                                    
                                </span>
        
                                <span class="text-gray-400 ms-2 fs-6 fw-bolder " >
                                    {{ translate(menuItem.heading) }}
                                </span>
                            </router-link>
                        </div>
                    </template>
                    <div
                        v-if="menuItem.sectionTitle"
                        :class="{ show: hasActiveChildren(menuItem.route) }"
                        class="menu-item menu-accordion"
                        data-kt-menu-sub="accordion"
                        data-kt-menu-trigger="click"  >
                        <span class="menu-link">
                            <span
                            v-if="menuItem.svgIcon || menuItem.fontIcon"
                            class="menu-icon"
                            >
                            <i
                            v-if="asideMenuIcons === 'font'"
                            :class="menuItem.fontIcon"
                            class="bi fs-3"
                            ></i>
                            <span
                            v-else-if="asideMenuIcons === 'svg'"
                            class="svg-icon svg-icon-4"
                            >
                            <inline-svg :src="menuItem.svgIcon" />
                            </span>
                            </span>
                            <span class="menu-title menu-title-gray-700 ms-2 fs-6 fw-bolder ">{{
                            translate(menuItem.sectionTitle)
                            }}</span>
                            <span class="menu-arrow"></span>
                        </span>
                        <div
                            :class="{ show: hasActiveChildren(menuItem.route) }"
                            class="menu-sub menu-sub-accordion" >
                            <template v-for="(item2, k) in menuItem.sub" :key="k">
                                <div v-if="item2.heading" class="menu-item">
                                    <router-link
                                        v-if="!item2.isDisabled"
                                        class="menu-link"
                                        active-class="active"
                                        :to="item2.route"
                                        >
                                        <span class="menu-bullet">
                                        <span class="bullet bullet-dot"></span>
                                        </span>
                                        <span class="menu-title menu-title-gray-700 ms-2 fs-6 fw-bolder ">{{
                                        translate(item2.heading)
                                        }}</span>
                                    </router-link>
    
                                    <router-link
                                        v-if="item2.isDisabled"
                                        class="menu-link"
                                        active-class="active"
                                        :to="item2.route"
                                        style="pointer-events:none; cursor:default;"
                                        >
                                        <span class="menu-bullet">
                                            <span class="bullet bullet-dot"></span>
                                        </span>
                                        <span class="menu-title text-gray-400 ms-2 fs-6 fw-bolder ">
                                            {{ translate(item2.heading) }}
                                        </span>
                                    </router-link>
                                    
                                </div>
                                <div
                                    v-if="item2.sectionTitle"
                                    :class="{ show: hasActiveChildren(item2.route) }"
                                    class="menu-item menu-accordion"
                                    data-kt-menu-sub="accordion"
                                    data-kt-menu-trigger="click" >
                                    <span class="menu-link">
                                        <span class="menu-bullet">
                                        <span class="bullet bullet-dot"></span>
                                        </span>
                                        <span class="menu-title menu-title-gray-700 ms-2 fs-6 fw-bolder">{{
                                        translate(item2.sectionTitle)
                                        }}</span>
                                        <span class="menu-arrow"></span>333
                                    </span>
                                    <div
                                        :class="{ show: hasActiveChildren(item2.route) }"
                                        class="menu-sub menu-sub-accordion">
                                        <template v-for="(item3, k) in item2.sub" :key="k">
                                            <div v-if="item3.heading" class="menu-item">
                                                <router-link
                                                    class="menu-link"
                                                    active-class="active"
                                                    :to="item3.route" >
                                                    <span class="menu-bullet">
                                                    <span class="bullet bullet-dot"></span>
                                                    </span>
                                                    <span class="menu-title menu-title-gray-700 ms-2 fs-6 fw-bolder" >{{
                                                    translate(item3.heading)
                                                    }}</span>
                                                </router-link>
                                            </div>
                                        </template>
                                    </div>
                                </div>
                            </template>
                        </div>
                    </div>
                </template>
            </template>
        </div>
    </div>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import {defineComponent, getCurrentInstance, onMounted, ref} from "vue";
import { useI18n } from "vue-i18n/index";
import { useRoute } from "vue-router";
import { version } from "@/core/helpers/documentation";
import { asideMenuIcons } from "@/core/helpers/config";
import MainMenuConfig from "@/core/config/MainMenuConfig";
// import organizationListDocMenuConfig from "@/views/organizations/submenu/OrganizationListSubmenu";
import App, {setAsideSecondaryMenu} from "@/main"

export default defineComponent({
    name: "kt-menu",
    components: {},
    setup() {
        const { t, te } = useI18n();
        const route = useRoute();
        const scrollElRef = ref<null | HTMLElement>(null);
        const state = ref({
            // menuConfigs: organizationListDocMenuConfig,
            menuConfigs: "",
            title: "",
        })
        setAsideSecondaryMenu(getCurrentInstance());
        
        onMounted(() => {
            if (scrollElRef.value) {
                scrollElRef.value.scrollTop = 0;
            }
            console.log(scrollElRef);
        });
        
        const translate = (text) => {
            if (te(text)) {
                return t(text);
            } else {
                return text;
            }
        };
        
        const hasActiveChildren = (match) => {
            return route.path.indexOf(match) !== -1;
        };
        
        function setMenu(title, menuList) {
            state.value.menuConfigs = menuList;
            state.value.title = title;
        }
        
        return {
            state,
            hasActiveChildren,
            MainMenuConfig,
            asideMenuIcons,
            version,
            translate,
            setMenu,
        };
    },
});

</script>
