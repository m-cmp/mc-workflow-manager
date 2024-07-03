<template>
  <div class="modal fade" id="catalogDeployHistory" aria-hidden="true" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered mw-800px">
      <div class="modal-content">

        <div v-if="authMenu.catalog_deploy_history" class="history-list-wrapper">
          <div class="card card-flush mt-8 pt-4 pb-8">
            <div class="card-body pt-4">

              <el-row type="flex" justify="space-between" align="middle">
                <!-- "배포 이력" Title -->
                <div class="sub-header pt-4 pb-8">
                  <h3>
                    {{ $t("project.deploy.deployHistory") }}(<span class="total-count">{{ totalCount }}</span>)
                  </h3>
                </div>
                <div>
                  <el-button v-if="authMenu.catalog_deploy_run" class="btn btn-primary" @click="onRunDeploy">
                    {{ $t("project.deploy.runDeploy") }}
                  </el-button>
                </div>
              </el-row>
              
              <!-- 배포 이력 테이블  -->
              <el-table :data="historyList" width="100%" class="list-table" header-row-class-name="list-header"
                highlight-current-row row-class-name="link-deploy-row" @row-click="onClickHistory">

                <!-- 상태 -->
                <el-table-column :label="$t('project.deploy.status')" width="80px" align="center">
                  <template v-slot="scope">
                    <img :src="scope.row.icon" />
                  </template>
                </el-table-column>

                <!-- 배포 아이디 -->
                <el-table-column :label="$t('project.deploy.deployId')" width="95px" align="center">
                  <template v-slot="scope">
                    {{ "#" + scope.row.rownum }}
                  </template>
                </el-table-column>

                <!-- Yaml -->
                <el-table-column :label="$t('Yaml')" width="100px" align="center" v-if="enableYaml">
                  <template v-slot="scope">
                    <el-button @click.prevent.stop="onShowYaml(scope.row.catalogDeployYaml)" type="text" size="small"><i
                        class="far fa-file-alt fa-lg"></i></el-button>
                  </template>
                </el-table-column>

                <!-- 설명 -->
                <el-table-column :label="$t('common.description')">
                  <template v-slot="scope">
                    {{ scope.row.deployDesc }}
                  </template>
                </el-table-column>

                <!-- 배포 사용자 -->
                <el-table-column :label="$t('project.deploy.deployFor')" width="130px" align="left">
                  <template v-slot="scope">
                    <div data-bs-toggle="tootip" :title="`${scope.row.deployUserName} (@ ${scope.row.deployUserId})`">
                      {{ deployUserName(scope.row.deployUserName, scope.row.deployUserId) }}
                    </div>
                  </template>
                </el-table-column>

                <!-- 배포일 -->
                <el-table-column :label="$t('project.deploy.deployDate')" width="170px" align="center">
                  <template v-slot="scope">
                    <!-- {{ moment(scope.row.deployDate).format("YYYY-MM-DD HH:mm:ss") }} -->
                  </template>
                </el-table-column>
              </el-table>
              
              <div class="pt-8">
                <!-- <Paginator 
                  ref="paginator" 
                  :cntPerPage="pageLimit" 
                  :itemCount="totalCount" 
                  @changedPage="onChangedPage"
                /> -->
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DeployK8sCdConsoleLogModal ref="DeployK8sCdConsoleLogModal" />
  <yaml-modal ref="yamlModal" />

  <!-- 롤백 히스토리 모달 -->
</template>

<script lang="ts">
import { computed, getCurrentInstance, ref } from 'vue'
import { useStore } from 'vuex';
// import moment from "moment";
import DeployK8sCdConsoleLogModal from "@/components/ConsoleK8SCDLogModal/k8sCatalogConsoleModal.vue";
import YamlModal from "../panels/YamlModal.vue";
import Paginator from "@/components/paginator/Paginator.vue";

export default {
  components: {
    DeployK8sCdConsoleLogModal,
    YamlModal,
    Paginator,
  },
  props: {
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

    const instance = getCurrentInstance();
    const store = useStore();

    const state = ref({
      deployFlowInfo: {},
    });

    const authMenu = computed(() => store.getters.newAuthMenu)


    function onClickHistory(row) {
      const info =
      {
        'catalogDeployId': row.catalogDeployId
      };
      (instance?.refs.DeployK8sCdConsoleLogModal as any).show(info);
    }

    function onShowYaml(deployYaml) {
      (instance?.refs.yamlModal as any).show(deployYaml);
    }

    function deployUserName(userName, userId) {
      const result = userName + ' (@' + userId + ')'

      if (Number(result.length) > 10) {
        const toolTipResult = result.substring(0, 9) + '...';
        return toolTipResult;
      }
      else
        return result;
    }

    const onChangedPage = (pageNo: number) => {
      emit('paginator', {
        page: pageNo,
        limit: props.pageLimit
      })
    }


    return {
      state,
      authMenu,
      // moment,

      onClickHistory,
      onShowYaml,
      deployUserName,
      onChangedPage,
    }
  }
}

</script>