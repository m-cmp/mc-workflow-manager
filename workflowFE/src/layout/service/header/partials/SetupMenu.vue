<template>
    <div
        class="
        menu
        menu-sub
        menu-sub-dropdown
        menu-column
        menu-rounded
        menu-gray-600
        menu-state-bg-light-primary
        fw-bold
        fs-6
        w-275px
        "
        data-kt-menu="true"
        >
        
        <!-- ---- TITLE ---- -->
        <div
            class="d-flex flex-column bgi-no-repeat rounded-top"
            style="background-image: url('media/misc/pattern-1.jpg')"
            >
            <h3 class="text-white fw-bold px-9 mt-4 mb-4">
            {{ $t("menu.config.title") }}
            </h3>
        </div>
    
        <div class="mt-4 mb-4">
            <!-- ---- 내 정보 ---- -->
            <!-- <div class="menu-item px-5">
            <router-link to="/configurations/mypage/view" class="menu-link px-5 text-gray-700 fw-bolder">
            {{ $t("menu.config.myInfo") }}
            </router-link>
            </div> -->
            
            <!-- ---- 알림 ---- -->
            <!-- <div class="menu-item px-5">
            <router-link
            to="/configurations/notifications/list"
            class="menu-link px-5 text-gray-700 fw-bolder"
            >
            {{ $t("menu.config.notification") }}
            </router-link>
            </div> -->
            
            <!-- ---- 일반 ---- -->
            <!-- <div class="menu-item px-5">
            <router-link to="/configurations/general" class="menu-link px-5 text-gray-700 fw-bolder">
            {{ $t("menu.config.general") }}
            </router-link>
            </div> -->
        
            <!-- ---- 커넥션 ---- -->
            <!-- <div
            class="menu-item px-5"
            data-kt-menu-trigger="hover"
            data-kt-menu-placement="left-start"
            data-kt-menu-flip="center, top"
            >
            <div class="menu-item">
                <div class="menu-link px-5 text-gray-700 fw-bolder">
                    {{ $t("menu.config.connection.title") }}
                    <span class="fs-8 rounded px-3 position-absolute translate-middle-y mt-5 end-0 me-4 " >
                        <img
                        class="w-15px h-15px rounded-1 ms-2"
                        src="images/icons/arrow/right_nobar.svg"
                        alt="metronic"
                        />
                    </span>
                </div>
            </div> -->
        
            <!-- submenu -->
            <!-- <div class="menu-sub menu-sub-dropdown w-175px py-4">
                <div class="menu-item px-5">
                    <router-link to="/configurations/gitLab" class="menu-link px-5"
                                 :class="[ true ? 'text-gray-700 fw-bolder' : 'text-gray-400 noperm' ]">
                    {{ $t("menu.config.connection.gitLab") }}
                    </router-link>
                </div>
                <div class="menu-item px-5">
                    <router-link to="/configurations/jenkins" class="menu-link px-5"
                                 :class="[ true ? 'text-gray-700 fw-bolder' : 'text-gray-400 noperm' ]">
                    {{ $t("menu.config.connection.jenkins") }}
                    </router-link>
                </div>
                <div class="menu-item px-5">
                    <router-link to="/configurations/argoCD" class="menu-link px-5"
                                 :class="[ true ? 'text-gray-700 fw-bolder' : 'text-gray-400 noperm' ]">
                    {{ $t("menu.config.connection.argoCD") }}
                    </router-link>
                </div>
                <div class="menu-item px-5">
                    <router-link to="/configurations/sonarQube" class="menu-link px-5"
                                 :class="[ true ? 'text-gray-700 fw-bolder' : 'text-gray-400 noperm' ]">
                    {{ $t("menu.config.connection.sonarQube") }}
                    </router-link>
                </div>
                <div class="menu-item px-5">
                    <router-link to="/configurations/anchore" class="menu-link px-5"
                                 :class="[ true ? 'text-gray-700 fw-bolder' : 'text-gray-400 noperm' ]">
                    {{ $t("menu.config.connection.anchore") }}
                    </router-link>
                </div>
                </div>
            </div> -->
        
            <!-- ---- 회원 ---- -->
            <!-- <div class="menu-item px-5">
                <router-link
                    to="/configurations/members/list"
                    class="menu-link px-5  "
                    >
                    {{ $t("menu.member") }}
                </router-link>
                
            </div> -->
        
            <!-- ---- 권한 ---- -->
            <!-- <div class="menu-item px-5">
            <router-link to="/configurations/authority" class="menu-link px-5">
            {{ $t("menu.authority") }}
            </router-link>
            </div> -->
        
            <!-- ---- 메시지 관리 ---- -->
            <!-- <div class="menu-item px-5">
            <router-link to="/pages/profile/overview" class="menu-link px-5">
            {{ $t("menu.message") }}
            </router-link>
            </div> -->
        
            <!-- ---- 승인 관리 ---- -->
            <!-- <div class="menu-item px-5">
            <router-link to="/configurations/statemachine" class="menu-link px-5">
            {{ $t("menu.statemachine") }}
            </router-link>
            </div> -->
        </div>
    </div>
</template>

<script lang="ts">
import {computed, defineComponent} from "vue";
import store from "@/store";

export default defineComponent({
  name: "notifications-menu",
  components: {},
  setup() {
    
      const authMenu = computed(()=>store.getters.authMenu);
    
      
      return {
          authMenu,
    };
  },
});
</script>

<style>

.noperm {
    pointer-events:none;
    cursor:default;
}

</style>
