<template>
    <div
        class="menu menu-sub menu-sub-dropdown menu-column menu-rounded menu-gray-600 menu-state-bg-light-primary fw-bold py-4 fs-6 w-275px"
        data-kt-menu="true">
        
        <!-- =========================================================================================================== -->
        <!-- 프로필 -->
        <!-- =========================================================================================================== -->
        <div class="menu-item px-3">
            <div class="menu-content d-flex align-items-center px-3">
                <div class="symbol symbol-50px me-5">
                    <img alt="Logo" src="images/icons/person/square-user.svg" />
                </div>
                
                <div class="d-flex flex-column">
                    <div class="fw-bolder d-flex align-items-center fs-5">
                        {{ userId }}
                    </div>
                    <a href="#" class="fw-bold text-muted text-hover-primary fs-7"> {{ userName }}</a>
                </div>
            </div>
        </div>
        
        <div class="separator my-2"></div>
        
    
        <!-- =========================================================================================================== -->
        <!-- 언어 선택 -->
        <!-- =========================================================================================================== -->
        <div
            class="menu-item px-5"
            data-kt-menu-trigger="hover"
            data-kt-menu-placement="left-start"
            data-kt-menu-flip="center, top">
            
            <router-link to="#" class="menu-link px-5">
                <span class="menu-title position-relative">
                Language
                <span class="fs-8 rounded bg-light px-3 py-2 position-absolute translate-middle-y top-50 end-0">
                    {{ currentLanguageLocale.name }}
                    <img
                        class="w-15px h-15px rounded-1 ms-2"
                        :src="currentLanguageLocale.flag"
                        alt="metronic"
                    />
                </span>
                </span>
            </router-link>
            
            <div class="menu-sub menu-sub-dropdown w-175px py-4">
                <div class="menu-item px-3">
                    <a
                        @click="setLang('ko')"
                        href="#"
                        class="menu-link d-flex px-5"
                        :class="{ active: currentLanguage('ko') }">
                        <span class="symbol symbol-20px me-4">
                            <img
                                class="rounded-1"
                                src="media/flags/south-korea.svg"
                                alt="metronic"
                            />
                        </span>
                        Korea
                    </a>
                </div>
                
                <div class="menu-item px-3">
                    <a
                        @click="setLang('en')"
                        href="#"
                        class="menu-link d-flex px-5"
                        :class="{ active: currentLanguage('en') }"
                        >
                        <span class="symbol symbol-20px me-4">
                            <img
                                class="rounded-1"
                                src="media/flags/united-states.svg"
                                alt="metronic"
                                />
                        </span>
                        English
                    </a>
                </div>
                <!--end::Menu item-->
            
            </div>
        </div>

        <!-- =========================================================================================================== -->
        <!-- 로그아웃 -->
        <!-- =========================================================================================================== -->
        <div class="menu-item px-5">
            <a @click="signOut()" class="menu-link px-5"> Sign Out </a>
        </div>
    
    </div>
    
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useI18n } from "vue-i18n/index";
import { useStore } from "vuex";
import { useRouter } from "vue-router";
import { Actions } from "@/store/enums/StoreEnums";
import store from "@/store";
import {useCookies} from "vue3-cookies";

export default defineComponent({
    name: "kt-user-menu",
    components: {},
    setup() {
        const router = useRouter();
        const i18n = useI18n();
        const store = useStore();
        const userName = computed(()=>store.getters.userName);
        const userId = computed(()=>store.getters.userId);
        const { cookies } = useCookies();
        
        // i18n.locale.value = localStorage.getItem("lang") ? (localStorage.getItem("lang") as string) : "en";
        
        const countries = {
            en: {
                flag: "media/flags/united-states.svg",
                name: "English",
            },
            ko: {
                flag: "media/flags/south-korea.svg",
                name: "Korea",
            },
        };
        
        const signOut = () => {
            store
                .dispatch(Actions.LOGOUT)
                .then(() => router.push({ name: "SignIn" }));
        };
        
        const setLang = (lang) => {
            localStorage.setItem("lang", lang);
            i18n.locale.value = lang;
            cookies.set("locale", lang);
        };
        
        const currentLanguage = (lang) => {
            return i18n.locale.value === lang;
        };
        
        const currentLanguageLocale = computed(() => {
            return countries[i18n.locale.value];
        });
        
        function showMyProfile() {
            router.push({
                name: "MemberView",
                params: {
                    userId: userId.value
                }
            })
        }
        
        return {
            userId,
            userName,
            signOut,
            setLang,
            currentLanguage,
            currentLanguageLocale,
            countries,
            showMyProfile,
        };
    },
});
</script>
