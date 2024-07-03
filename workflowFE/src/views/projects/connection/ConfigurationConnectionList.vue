<template>
  <div div class="card card-flush w-100">
    <div class="card-body">

      <!-- ================================================================== -->
      <!--                               헤더                                 -->
      <!-- ================================================================== -->
      <div class="sub-header">
        <h3>{{ $t("configuration.toolChain.list") }}</h3>
      </div>

      <!-- ================================================================== -->
      <!--                         목록 전체 갯수                              -->
      <!-- ================================================================== -->
      <div class="d-flex flex-stack flex-wrap mb-4 mt-5">
        <div class="fs-6 fw-bolder text-gray-700 ps-4">
          {{ $t('common.total') }}
          <span>
            ({{ ossList.length }})
          </span>
        </div>

        <!-- ================================================================== -->
        <!--                           목록 검색                                 -->
        <!-- ================================================================== -->
        <div class="ms-auto d-flex flex-shrink-0">
          <div class="d-flex ms-3 ">
            <span class="svg-icon svg-icon-2 svg-icon-gray-400 position-absolute ms-3 me-0 pe-0 mt-3 ">
              <inline-svg 
                src="images/icons/search/list-search-light.svg" 
                class="commit-detail-icon" />
            </span>
            <input 
              type="text" 
              class="form-control form-control-solid h-40px bg-body ps-13 fs-7" 
              name="search" 
              value=""
              :placeholder="$t('common.searchPlaceHolder')" 
              data-kt-search-element="input" 
              @input="onInputSearch" />
          </div>
        <!-- ================================================================== -->
        <!--                               등록                                 -->
        <!-- ================================================================== -->
          <div 
            class="btn btn-flex flex-center btn-primary btn-text-white w-md-auto h-40px px-0 px-md-6 ps-8 pe-8 w-120px"
            tooltip="New Stage" 
            data-bs-toggle="modal" 
            data-bs-target="#AddConnectionModal" 
            @click.stop="onClickNew">
            <span class="svg-icon svg-icon-3">
              <inline-svg src="media/icons/duotune/arrows/arr075.svg" />
            </span>
            <span class="d-none d-md-inline">
              {{ $t("configuration.toolChain.newToolChain") }}
            </span>
          </div>
        </div>

        <!-- ================================================================== -->
        <!--                               목록                                 -->
        <!-- ================================================================== -->
        <el-table 
          :data="state.displayItems" 
          class="list-table" 
          header-row-class-name="list-header"
          highlight-current-row>

          <!-- 툴체인 -->
          <el-table-column 
            :label="'TOOL NAME'" 
            align="left" 
            width="180" 
            prop="ossCd" 
            sortable>
            <template v-slot="scope">
              {{ scope.row.ossCd }}
            </template>
          </el-table-column>

          <!-- 툴체인 명 -->
          <el-table-column 
            :label="'NAME'" 
            align="left" 
            width="230" 
            prop="ossName" 
            sortable>
            <template v-slot="scope">
              <div 
                data-bs-toggle="tootip" 
                :title="`${scope.row.ossName}`">
                {{ shortenedOssName(scope.row.ossName) }}
              </div>
            </template>
          </el-table-column>

          <!-- 설명 -->
          <el-table-column 
            :label="'Description'" 
            align="left" 
            prop="ossDesc" 
            sortable>
            <template v-slot="scope">
              <div 
                data-bs-toggle="tootip" 
                :title="`${scope.row.ossDesc}`">
                {{ shortenedOssDesc(scope.row.ossDesc) }}
              </div>
            </template>
          </el-table-column>

          <!-- 툴체인 URL -->
          <el-table-column 
            :label="'URL'" 
            align="left" 
            width="230" 
            prop="ossUrl" 
            sortable>
            <template v-slot="scope">
              <div 
                data-bs-toggle="tootip" 
                :title="`${scope.row.ossUrl}`">
                {{ shortenedOssUrl(scope.row.ossUrl) }}
              </div>
            </template>
          </el-table-column>

          <!-- 생성일 -->
          <el-table-column 
            :label="'생성일'" 
            align="left" 
            width="200" 
            prop="regDate" 
            sortable>
            <template v-slot="scope">
              {{ scope.row.regDate }}
            </template>
          </el-table-column>

          <el-table-column 
            :label="'Action'" 
            align="center" 
            width="150" 
            prop="regDate">
            <template v-slot="scope">
              <div class="connection-action-btn-wrapper">
                <button 
                  class="svg-icon svg-icon-3 btn btn-primary btn-sm connection-action-btn" 
                  data-bs-toggle="modal"
                  data-bs-target="#editConnetionModal" 
                  @click="onClickRow(scope.row)">수정</button>
              </div>

              <div class="connection-action-btn-wrapper">
                <button 
                  class="svg-icon svg-icon-3 btn btn-primary btn-sm connection-action-btn" 
                  @click="onclickDelete(scope.row)">삭제</button>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <!-- <el-row type="flex" justify="center">
        <div class="mt-5 mb-5">
          <Paginator 
            ref="paginator" 
            :cntPerPage="CNT_PER_PAGE" 
            :itemCount="state.totalCount"
            @changedPage="onChangedPage" 
          />
        </div>
      </el-row> -->
    </div>
  </div>

  <AddConnetionModal ref="AddConnectionModal" @loadData="createNewOssCallback" />
  <EditConnetionModal ref="editConnetionModal" @loadData="createNewOssCallback" />
</template>

<script lang="ts">

import { useI18n } from "vue-i18n";
import { getCurrentInstance, nextTick, onMounted, ref, computed, onBeforeMount, reactive, watch } from "vue";
import { setCurrentPageBreadcrumbs, setCurrentPageTitle } from "@/core/helpers/breadcrumb";
import { useToast } from "vue-toastification";


// import serviceListDocMenuConfig from "@/views/services/submenu/ServiceListSubmenu";

import { AsideButtonProp } from "@/components/base/menu/AsideButtonProp";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import subMenuConfig, { setMenuPermission } from "@/views/projects/menus/SubMenu";
import { useRoute, useRouter } from "vue-router";
import { useStore } from "vuex";
// import Pagination from '@/components/paginationBkup/Pagination.vue';
import AddConnetionModal from "./components/AddConnetionModal.vue";
import EditConnetionModal from "./components/EditConnetionModal.vue";

// store
// import connection from '@/store/modules/connection';
import { connectionActions } from '@/store/modules/connection';
// import share from '@/store/modules/share';
import Swal from 'sweetalert2';
import { deleteOssConnection } from '@/api/preference';
import Paginator from "@/components/paginator/Paginator.vue";


export default {
  name: "ConfigurationConnection",
  components: {
    // Pagination,
    AddConnetionModal,
    EditConnetionModal,
    Paginator,
  },
  props: {},
  setup() {
    let { t, locale } = useI18n();

    const instance = getCurrentInstance();
    const toast = useToast();
    const route = useRoute();
    const store = useStore();

    const state = ref({
      // companyId: computed(()=> (share.state as any).companyInfo.companyId),
      search: '',
      totalCount: 0,
      displayItems: [] as any,
    });


    const CNT_PER_PAGE = 10;     // 목록의 페이지별 출력 개수
    let currentPageNo = 1;


    const confirmModal = ref(null);
    const contentMsg = ref(t("msg.enteredSaveConfirm"));
    // const companyInfo = computed(()=> store.state.share.companyInfo)

    onMounted(() => {
      nextTick(async () => {
        initUI();
        await loadConnectionListData();
      })
    });

    watch(() => store.state.connection.ossList, () => {
      onChangedPage(1);
    })
    watch(() => state.value.totalCount, () => {
      onChangedPage(1);
    })

    function initUI() {
      initTitle();
      initMenu();
    }

    function initTitle() {
      setCurrentPageBreadcrumbs(t("configuration.toolChain.title"), [
        // companyInfo.value.companyName
      ]);
    }

    function initMenu() {
      asidePrimaryController.setMenu([]);
      asideSecondaryController.setMenu("Toolchain", subMenuConfig, route.params, setMenuPermission, null);
    }

    async function loadConnectionListData() {
      store.dispatch(connectionActions.NAMESPACE + "/" + connectionActions.LOAD_CONNECTED_OSS_LIST, {});
    }

    const onClickNew = () => {
      (instance?.refs.AddConnectionModal as any).invoke();
    }
    const onClickRow = (row) => {
      (instance?.refs.editConnetionModal as any).show(row)
    }

    // 검색후 목록 보여주기
    const ossList = computed(() => {
      let ossListItem = [];
      // Todo : 요부분 수정
      if (state.value.search == '') {
        const ossList = store.state.connection.ossList;
        for (let item of ossList) {
          (ossListItem as any).push(item);
        }
      }

      else {
        const ossList = store.state.connection.ossList;
        for (let item of ossList) {
          if (item.ossName != null && item.ossName.toLowerCase().includes(state.value.search.toLowerCase())) {
            (ossListItem as any).push(item);
          }
          else if (item.ossCd != null && item.ossCd.toLowerCase().includes(state.value.search.toLowerCase())) {
            (ossListItem as any).push(item);
          }
          else if (item.ossDesc != null && item.ossDesc.toLowerCase().includes(state.value.search.toLowerCase())) {
            (ossListItem as any).push(item)
          }
          else if (item.ossUrl != null && item.ossUrl.toLowerCase().includes(state.value.search.toLowerCase())) {
            (ossListItem as any).push(item)
          }
          else if (item.regDate != null && item.regDate.toLowerCase().includes(state.value.search.toLowerCase())) {
            (ossListItem as any).push(item)
          }
        }
      }

      state.value.totalCount = ossListItem.length || 0
      return ossListItem ? ossListItem : []
    }) as any

    const onInputSearch = (e) => {
      state.value.search = e.target.value.trim();
    }

    function onclickDelete(row) {
      console.log(row)
      Swal.fire({
        text: t("configuration.toolChain.deleteConfirmMsg"),
        icon: "info",
        buttonsStyling: false,
        showCancelButton: true,
        cancelButtonText: t("common.cancel"),
        confirmButtonText: t("common.confirm"),
        customClass: {
          cancelButton: "btn btn-light",
          confirmButton: "btn fw-bold btn-light-danger",
        },
      }).then((result) => {
        if (result.isConfirmed) {
          try {
            procDeleteConnection(row);
          } catch (e) {
            toast.error(t("configuration.toolChain.deleteFailMsg"));
          }
        }
      });
    }

    function createNewOssCallback() {
      loadConnectionListData()
    }

    async function procDeleteConnection(row) {
      try {
        const response = await deleteOssConnection(row.ossId) as any;
        if (response.code == 200) {
          loadConnectionListData();
          toast.success(t("configuration.toolChain.successMsg"));
        } else if (response.code == 1501) {
          toast.error(t("configuration.toolChain.connectedFailedMsg"));
        } else {
          toast.error(t("configuration.toolChain.deleteFailMsg"));
        }
        console.log()
      } catch (error) {
        console.log(error)
        toast.error(t("configuration.toolChain.deleteFailMsg"));
      }
    }


    function shortenedOssName(ossName) {
      if (ossName == null || ossName == '' || Number(ossName.length) <= 15) {
        return ossName;
      } else {
        return ossName.substring(0, 15) + '...';
      }
    }

    function shortenedOssDesc(ossName) {
      if (ossName == null || ossName == '' || Number(ossName.length) <= 30) {
        return ossName;
      } else {
        return ossName.substring(0, 29) + '...';
      }
    }

    function shortenedOssUrl(ossUrl) {
      if (ossUrl == null || ossUrl == '' || Number(ossUrl.length) <= 34) {
        return ossUrl;
      } else {
        return ossUrl.substring(0, 29) + '...';
      }
    }

    const onChangedPage = (pageNo: number) => {
      currentPageNo = pageNo;
      state.value.displayItems.length = 0;
      console.log(ossList)
      for (let xx = (currentPageNo - 1) * CNT_PER_PAGE; xx < (currentPageNo * CNT_PER_PAGE) && xx < ossList.value.length; xx++) {
        state.value.displayItems.push(ossList.value[xx]);
      }

      console.log(state.value.displayItems)
    }

    return {
      state,
      CNT_PER_PAGE,

      confirmModal,
      contentMsg,
      ossList,
      onClickRow,
      onclickDelete,
      onInputSearch,
      loadConnectionListData,
      onClickNew,
      createNewOssCallback,
      procDeleteConnection,

      shortenedOssName,
      shortenedOssDesc,
      shortenedOssUrl,

      onChangedPage,
    };
  },
};
</script>
<style scoped>
.connection-action-btn-wrapper {
  display: inline-block;
  margin-right: 5px;
}
.connection-action-btn {
  border: 0px;
  height: 35px;
}
</style>