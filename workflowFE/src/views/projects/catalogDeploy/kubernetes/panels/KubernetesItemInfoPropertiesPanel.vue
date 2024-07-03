<template>
  <props-modal
    data-comp-id="kubernetes-deploy-props-panel"
    ref="propModal"
    panel-class="build-properties-panel"
    @closed="onClose"
  >
  
    <template v-if="true">
      <!-- 타이틀 -->
      <template v-if="true">
        <div class="title">
          <i class="fas fa-th-list" />
          {{ $t("project.deploy.kubernetesDeploy.catalogProperties") }}
        </div>
      </template>
      <!-- 타이틀 -->
      

      <!-- Content  -->
      <template v-if="true">

        <!-- 시작 -->
        <el-form
          ref="newForm"
          class="contents-wrapper"
          label-width="100px"
          :model="state.editData"
          label-position="top"
          autocomplete="on"
        >
          <el-collapse
            v-model="state.showAccordionList"
            v-if="state.editData"
          >

            <!-- 배포 복사 -->
            <el-form-item
              v-if="deployNameList.length > 0"
              inline-message="true"
            >

              <!--  -->
              <span class="field-label">
                {{ $t("project.deploy.kubernetesDeploy.deployCopyFrom") }}
              </span>
                <div class="deploy-copy-wrapper">
                  <el-select
                    v-model="state.selectedCopyDeployItem"
                    class="deploy-list"
                  >
                    <el-option
                      key="empty"
                      :label="$t('project.deploy.kubernetesDeploy.msgSelectCopyDeploy')"
                      value=""
                    />
                    <el-option
                      v-for="(item, index) in deployNameList"
                      :key="index + '_' + item.deployName"
                      :label="item.deployName"
                      :value="item.deployName"
                    />
                  </el-select>
                  
                  <!-- 복사 버튼 -->
                  <el-button
                    class="copy-button"
                    :disabled="state.selectedCopyDeployItem == ''"
                    type="primary"
                    @click="onSelectedCopyDeployItem"
                    >
                    {{ $t("project.deploy.kubernetesDeploy.copy") }}
                  </el-button>
                </div>
              </el-form-item>
              <!-- 배포 복사 -->
              

              <!-- Yaml -->
              <!-- <el-form-item inline-message="true" prop="info.replicas"> -->
              <el-form-item>
              
              <span class="field-label required">
                {{$t("project.deploy.kubernetesDeploy.Yaml")}}
              </span>

              <!-- Yaml 버튼 -->
              <el-row type="flex"  justify="end">
                <el-button type="primary" size="mini" @click="onClickPreviewYaml">
                  Values.Yaml
                </el-button>
              </el-row>

              <el-input
                type="textarea"
                v-model="state.editData.catalogDeployYaml"
                rows="30"
                :placeholder="$t('project.deploy.kubernetesDeploy.msgInputYaml')"
              />
            </el-form-item>
          </el-collapse>
        </el-form>
      </template>
      <!-- Content  -->

    </template>
  </props-modal>
</template>

<script lang="ts">
//add
import { useI18n } from "vue-i18n";
import {
  getCurrentInstance,
  nextTick,
  computed,
  // defineComponent,
  onMounted,
  ref,
  watch,
} from "vue";
import { useRoute } from "vue-router";
import { useToast } from "vue-toastification";
import { useStore } from "vuex";

import loaderMixin from "@/mixins/loaderMixin";
import PropsModal from "@/components/PropsModal/index.vue";
import GroupInputList from "@/views/projects/deploy/common/inputs/GroupInputList.vue";
import PortInputList from "@/views/projects/deploy/common/inputs/PortsInputList.vue";
import ImagePullSecretInputList from "@/views/projects/deploy/common/inputs/ImagePullSecretInputList.vue";
import PVCVolumeInputList from "@/views/projects/deploy/common/inputs/PVCVolumeInputList.vue";
import HostPathInputList from "@/views/projects/deploy/common/inputs/HostPathInputList.vue";

// import { getNamespaceList } from "@/api/kubernetesDeploy";
// import { getNodeSelectorList } from "@/api/kubernetesDeploy";
// import { getPVCVolumeList } from "@/api/kubernetesDeploy";

import { DEPLOY_CONTROLLER_TYPE } from "@/constant/deploy";
import { EDIT_MODE } from "@/constant/common";
import {
  _validateName,
  _validateLength,
  _validateIp,
  _validateURL,
  _validateAppName,
  _validateSelect,
} from "@/utils/input-validate";


export default {
  components: {
    PropsModal,
    GroupInputList,
    PortInputList,
    ImagePullSecretInputList,
    PVCVolumeInputList,
    HostPathInputList,
  },
  mixins: [loaderMixin],
  props: {
    visible: {
      type: Boolean,
      default: false,
    },
    editData: {
      type: Object,
      default: null,
    },
    editMode: {
      type: String,
      default: "",
    },
  },

  setup(props, { emit }) {
    console.log("######KubernetesItemInfoPropertiesPanel.vue");
    /* ============================================================================================================= */
    // 1. 다국어 설정
    /* ============================================================================================================= */

    let { t, locale } = useI18n();

    const instance = getCurrentInstance();
    const toast = useToast();
    const store = useStore();
    const state = ref({
      editData: computed(()=> store.state.deploy.catalogEditData),

      isFirstDataLoadingCompleted: false,
      selectedCopyDeployItem: "",
      namespaceList: [],
      nodeSelectorList: [],
      pvcVolumeList: [],
      showAccordionList: ["1"],
    });
    
    const COMP_PROPERTIES = store.state.deploy.compProperties;
    
    const isEditMode = computed(() => {
      return props.editMode === EDIT_MODE.EDIT;
    });
    
    const deployNameList = computed(() => {
      return COMP_PROPERTIES.deployNameList;
    });
    const kubernetesConfigList = computed(() => {
      return COMP_PROPERTIES.kubernetesConfigList;
    });
    const controllerList = computed(() => {
      return COMP_PROPERTIES.controllerList;
    });
    const strategyTypeList = computed(() => {
      return COMP_PROPERTIES.strategyTypeList;
    });
    const serviceTypeList = computed(() => {
      return COMP_PROPERTIES.serviceTypeList;
    });


    
    console.log("######const deployNameList");
    console.log(deployNameList);
    /* ============================================================================================================= */
    // 라이프사이클
    /* ============================================================================================================= */

    onMounted(() => {
      nextTick(() => {});
    });
    const data = computed(() => ref(props.visible));
    watch(data, (value) => {
      const propModalObj = instance?.refs.propModal as any;
      
      if (value.value) {
        propModalObj.show();
        // if (props.editMode == EDIT_MODE.EDIT) {
        //   _loadDataList(props.editData.info.configId);
        // }
      } else {
        propModalObj.hide();
      }
    }); // ?

    async function onSelectedCopyDeployItem() {
      let deployNameInfo = (deployNameList.value as any).find((deployInfo) => {
        return deployInfo.deployName == state.value.selectedCopyDeployItem;
      });
      if (deployNameInfo == null) {
        alert(t("project.deploy.kubernetesDeploy.msgNotDeployInfo"));
        return;
      } else {
        state.value.editData.catalogDeployYaml = deployNameInfo.catalogDeployYaml
      }
      
    }

    function onClose() {
      emit("closed", false);
    }

    function onFinish() {}

    function onClickPreviewYaml($event) {
      // onShowYamlModal <-- 외부 메서드
      console.log("####onClickPreviewYaml");
      emit("showYamlModal");
    }
    // async function _loadDataList(configId) {
    //   let success = false;
    //   state.value.namespaceList = [];
    //   state.value.nodeSelectorList = [];
    //   state.value.pvcVolumeList = [];
    //   if (configId != "") {
    //     success = await _loadNamespaceList(configId);
    //     if (success === true) success = await _loadNodeSelectorList(configId);
    //     if (success === true) success = await _loadPVCVolumeList(configId);
    //   }

    //   return success;
    // }

    // async function _loadNamespaceList(configId) {
    //   let response: any = null;
    //   try {
    //     response = await getNamespaceList(configId);
    //     console.log("#####getNamespaceList");
    //     console.log(response);
    //     state.value.namespaceList = response.data || [];
    //   } catch (error) {
    //     state.value.namespaceList = [];
    //     return false;
    //   }

    //   return true;
    // }
    

    // async function _loadNodeSelectorList(configId) {
    //   let response: any = null;
    //   try {
    //     response = await getNodeSelectorList(configId);
    //     state.value.nodeSelectorList = response.data || [];
    //   } catch (error) {
    //     state.value.nodeSelectorList = [];
    //     return false;
    //   }
    //   return true;
    // }

    
    // async function _loadPVCVolumeList(configId) {
    //   let response: any = null;
    //   try {
    //     response = await getPVCVolumeList(configId);
    //     state.value.pvcVolumeList = response.data || [];
    //   } catch (error) {
    //     state.value.pvcVolumeList = [];
    //     return false;
    //   }
    //   return true;
    // }


    // 유효성 체크, 저장시 외부에서 호출
    function executeValidation() {
      return new Promise((resolve, reject) => {
        if (props.editMode == EDIT_MODE.NEW) {
          if (props.editData.info.isDuplicateCheckName === false) {
            toast.error(t("msg.msgDuplicate"));
            resolve(false);
          }
        }
        (instance?.refs.newForm as any).validate((valid) => {
          resolve(valid);
        });
      });
    }


    
    function hide() {
      (instance?.refs.propModal as any).hide();
    }

    return {
      props,
      state,
      onSelectedCopyDeployItem,
      onClose,
      onClickPreviewYaml,
      executeValidation,
      hide,
      
      DEPLOY_CONTROLLER_TYPE,
      EDIT_MODE,
      isEditMode,
      deployNameList,
      kubernetesConfigList,
      controllerList,
      strategyTypeList,
      serviceTypeList,
    };
  },
};

/*
	ports 유효성 체크
*/


const portsValidationHelper = {
  emptyValidation(index, value, fieldName) {
    if (value.length == 0) {
      return `${index + 1} 번째의 ${fieldName}이 입력되지 않았습니다.`;
    }

    return true;
  },
};

const normalValidateHelper = {
  // 중복 유무
  isDuplicateCheck(value, fieldNames) {
    // 중복 유무
    for (var m = 0; m < fieldNames.length; m++) {
      let targetFieldName = fieldNames[m];
      let targetVaule = "";
      let isDuplicate = value.find((item) => {
        let fieldValue = item[targetFieldName];
        if (targetVaule == fieldValue) {
          return true;
        } else {
          targetVaule = fieldValue;
          return false;
        }
      });

      if (isDuplicate != null) {
        return targetFieldName + " 값 중복";
      }
    }

    return false;
  },
};
</script>


<style lang="scss" scoped>
.el-collapse-item__header {
  font-size: 16px;
  font-weight: 700;
}

.deploy-copy-wrapper {
  display: flex;
  .deploy-list {
    flex: 1;
    margin-right: 5px;
  }
  .copy-button {
    width: 80px;
  }
}

.input-name-column {
  width: 70px !important;
  text-align: center;
  -webkit-box-flex: 0 !important;
  -ms-flex: none !important;
  flex: none !important;
}
</style>
