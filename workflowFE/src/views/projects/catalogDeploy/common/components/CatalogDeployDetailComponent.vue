<template>
  <div class="card card-flush w-100">
    <div class="card-body">

      <!-- ==== 헤더 ==== -->
      <div class="sub-header">
        <h3>{{ $t('project.catalog.catalogDeployList') }}</h3>
      </div>

      <div class="d-flex flex-stack flex-wrap mb-4 mt-5">
        <!-- ==== 전체 개수 ==== -->
        <div class="fs-6 fw-bolder text-gray-700 ps-4">
          {{ $t('common.total') }} ({{ catalogDeployList.length }})
        </div>

        <div class="ms-auto d-flex flex-shrink-0">

          <!-- ---- 검색 ---- -->
          <div class="d-flex ms-3 ">

            <span class="svg-icon svg-icon-2 svg-icon-gray-400 position-absolute ms-3 me-0 pe-0 mt-3 ">
              <inline-svg 
                src="images/icons/search/list-search-light.svg"
                class="commit-detail-icon"  
              />
            </span>

            <input type="text" class="form-control form-control-solid h-40px bg-body ps-13 fs-7" name="search" value=""
              :placeholder="$t('project.catalog.searchCatalogDeploy')" data-kt-search-element="input" @input="onInputSearch" />
          </div>

          <!-- <div
            class="btn btn-flex flex-center btn-primary btn-text-white w-md-auto h-40px px-0 px-md-6 ps-8 pe-8"
            tooltip="New Cluster" 
            style="width:120px; margin-left: 10px;"
            @click="onGotoNewPage"
          >
            <span class="svg-icon svg-icon-3">
              <inline-svg src="media/icons/duotune/arrows/arr075.svg" />
            </span>
            <span class="d-none d-md-inline"> 
              {{ $t("project.catalog.newCatalogDeploy") }} 
            </span>
          </div> -->
        </div>
      </div>

      <!-- 목록 -->
      <el-table 
        :data="catalogDeployListData" 
        width="100%" 
        class="list-table" 
        header-row-class-name="list-header"
        highlight-current-row 
        row-class-name="link-deploy-row">
        <!-- 카탈로그명 -->
        <el-table-column :label="$t('project.catalog.catalogName')" width="170px" align="center">
          <template v-slot="scope">
            <div
              data-bs-toggle="modal"
              data-bs-target="#catalogDeployHistory"
              @click.prevent="onClickHistory(scope.row)">
              {{ scope.row.deployName }}
            </div>
          </template>
        </el-table-column>

        <!-- 프로젝트명 -->
        <!-- <el-table-column :label="$t('project.catalog.projectName')" width="170px" align="center">
          <template v-slot="scope">
            <div
              data-bs-toggle="modal"
              data-bs-target="#catalogDeployHistory"
              @click.prevent="onClickHistory(scope.row)">
              {{ scope.row.projectName }}
            </div>
          </template>
        </el-table-column> -->

        <!-- 스테이지 -->
        <!-- <el-table-column :label="$t('project.catalog.stageName')" width="110px" align="center">
          <template v-slot="scope">
            {{ scope.row.stageCd }}
          </template>
        </el-table-column> -->

        <!-- 프로바이더 -->
        <el-table-column :label="$t('project.catalog.providerName')" width="110px" align="center">
          <template v-slot="scope">
            <div
              data-bs-toggle="modal"
              data-bs-target="#catalogDeployHistory"
              @click.prevent="onClickHistory(scope.row)">
              {{ scope.row.providerCd }}
            </div>
          </template>
        </el-table-column>

        <!-- 클러스터 -->
        <el-table-column :label="$t('project.catalog.clusterName')" width="210px" align="center">
          <template v-slot="scope">
            <div
              data-bs-toggle="modal"
              data-bs-target="#catalogDeployHistory"
              @click.prevent="onClickHistory(scope.row)">
              {{ scope.row.k8sName }}
            </div>
          </template>
        </el-table-column>

        <!-- 카탈로그 -->
        <el-table-column :label="$t('project.catalog.catalog')" width="160px" align="center">
          <template v-slot="scope">
            <div 
              data-bs-toggle="modal"
              data-bs-target="#catalogDeployHistory"
              @click.prevent="onClickHistory(scope.row)">
              {{ scope.row.catalogName + ' / v' + scope.row.catalogVersion }}
            </div>
          </template>
        </el-table-column>

        <!-- 배포 타입 -->
        <el-table-column :label="$t('project.catalog.deployType')" width="150px" align="center">
          <template v-slot="scope">
            <div 
              data-bs-toggle="modal"
              data-bs-target="#catalogDeployHistory"
              @click.prevent="onClickHistory(scope.row)">
                {{ scope.row.catalogTypeCd }}
            </div>
          </template>
        </el-table-column>

        <!-- 액션 -->
        <!-- <el-table-column :label="$t('project.catalog.order')" align="center">
          <template v-slot="scope">

            < !-- 이력 -- >
            < !-- <div class="mr-10 inlineBlock" 
              data-bs-toggle="modal"
              data-bs-target="#catalogDeployHistory"
              @click.prevent="onClickHistory(scope.row)">
              <span class="svg-icon svg-icon-3">
                <button class="btn btn-primary btn-sm">
                  {{ $t('project.catalog.history') }}
                </button>
              </span>
            </div> -- >

            < !-- 수정 -- >
            <div 
              class="mr-10 inlineBlock" 
              @click.prevent="onGotoEditPage(scope.row)"
            >
              <span class="svg-icon svg-icon-5">
                <button class="btn btn-primary btn-sm">
                  {{ $t('project.catalog.edit') }}
                </button>
              </span>
            </div>

            < !-- 삭제 -- >
            <div 
              class="inlineBlock" 
              @click.prevent="onClickDelete(scope.row)"
            >
              <span class="svg-icon svg-icon-3">
                <button class="btn btn-primary btn-sm">
                  {{ $t('project.catalog.delete') }}
                </button>
              </span>
            </div>
          </template>
        </el-table-column> -->
      </el-table>
    </div>
  </div>
</template>

<script lang="ts">
//add
import { useI18n } from "vue-i18n";
import { computed, getCurrentInstance, ref } from "vue";
import { useStore } from "vuex";
import { useRouter } from 'vue-router';

export default {
  props: {
    // 카탈로그 배포 목록
    deployInfo: {
      type: Object,
    } as any,
    catalogDeployList: {
      type: Array,
    } as any,

    // 카탈로그 배포 이력
    totalCount: {
      type: Number,
      default: null,
    } as any,
    historyList: {
      type: Array,
      default: null,
    } as any,
    pageLimit: {
      type: Number,
      default: null,
    } as any,
    onRunDeploy: {
      type: Function,
      default: null,
    } as any,
    enableYaml: {
      type: Boolean,
      default: null,
    } as any,
  },

  setup(props, { emit }) {

    let { t, locale } = useI18n();

    const instance = getCurrentInstance();
    const router = useRouter();
    const store = useStore();

    const state = ref({
      search: '',
      catalogDeployList: props.catalogDeployList
    });

    // 새 카탈로그 배포로 이동
    function onGotoNewPage() {
      router.push({ path: "new" });
    }

    // 검색된 내용 저장
    const onInputSearch = (e) => {
      state.value.search = e.target.value.trim();
    }

    /*
    * 검색된 카탈로그 배포 목록 세팅
    * 검색창에 데이터가 없을경우 모든 목록 보여줌
    */
    const catalogDeployListData = computed(() => {
      let catalogDeployItem = [];

      if (state.value.search == '') {
        catalogDeployItem = props.catalogDeployList;
      } else {
        const catalogDeployList = props.catalogDeployList;

        for (let item of catalogDeployList) {
          if (item.deployName != null && item.deployName.toLowerCase().includes(state.value.search.toLowerCase())) {
            (catalogDeployItem as any).push(item);
          }
          // else if (item.projectName != null && item.projectName.toLowerCase().includes(state.value.search.toLowerCase())) {
          //   (catalogDeployItem as any).push(item);
          // }
          // else if (item.stageCd != null && item.stageCd.toLowerCase().includes(state.value.search.toLowerCase())) {
          //   (catalogDeployItem as any).push(item);
          // }
          else if (item.providerCd != null && item.providerCd.toLowerCase().includes(state.value.search.toLowerCase())) {
            (catalogDeployItem as any).push(item);
          }
          else if (item.k8sName != null && item.k8sName.toLowerCase().includes(state.value.search.toLowerCase())) {
            (catalogDeployItem as any).push(item);
          }
          else if (item.catalogName != null && item.catalogName.toLowerCase().includes(state.value.search.toLowerCase())) {
            (catalogDeployItem as any).push(item);
          }
          else if (item.catalogVersion != null && item.catalogVersion.toLowerCase().includes(state.value.search.toLowerCase())) {
            (catalogDeployItem as any).push(item);
          }
          else if (item.catalogTypeCd != null && item.catalogTypeCd.toLowerCase().includes(state.value.search.toLowerCase())) {
            (catalogDeployItem as any).push(item);
          }
        }
      }
      console.log(catalogDeployItem)
      return catalogDeployItem ? catalogDeployItem : []
    })

    // function onClickHistory(catalogDeployInfo) {
    //   emit("changeItem", catalogDeployInfo);
    //   (instance?.refs.catalogDeployHistory as any)
    // }

    // 수정 페이지로 이동
    function onGotoEditPage(rows) {
      router.push({ path: 'edit/' + rows.catalogDeployId })
    }

    // 삭제 버튼 클릭
    function onClickDelete(rows) {
      emit('onClickDelete', rows.catalogDeployId);
    }

    // 페이징
    function onChangeHistoryPage(info) {
      emit('paginator', info)
    }

    return {
      state,
      onGotoNewPage,
      onInputSearch,
      // onClickHistory,
      onGotoEditPage,
      onClickDelete,

      catalogDeployListData,
      onChangeHistoryPage,
    };
  },
};
</script>

<style scoped>
.mr-10 {
  margin-right: 10px;
}
.inlineBlock {
  display: inline-block;
}
</style>
