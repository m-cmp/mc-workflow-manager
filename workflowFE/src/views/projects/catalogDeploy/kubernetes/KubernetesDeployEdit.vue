
<script>
// import DeployEditCore from "../common/core/DeployEditCore.vue";
import { getYaml } from "@/api/kubernetesDeploy";

// import ItemInfoPropertiesPanel from "./panels/KubernetesItemInfoPropertiesPanel.vue";

import { DEPLOY_INFO } from "@/constant/deploy";
import { EDIT_MODE } from "@/constant/common";
import {
  deployActionTypes,
  deployActions,
  deployGetters,
  deployState,
} from "@/store/modules/deploy";
import { mapGetters } from "vuex";

/*
	1. 계층도 (내부)
	2. 빌드 프로퍼티 패널(내부)
	3. deploy info 프로퍼티 패널(내부)
*/
export default {
  // extends: DeployEditCore,
  // components: {
  //   ItemInfoPropertiesPanel,
  // },
  props: {
    // stageId: {
    //   type: Number,
    // },
    editMode: {
      type: String,
      required: true,
    },
    // editData: {
    //   type: Object,
    //   required: true,
    // }
  },

  data() {
    return {
      singleMode: true,
    };
  },
  computed: {
    ...deployState({
      currentDeployManager: (state) => state.deployManager,
    }),
    ...mapGetters(["serviceGroupId"]),
    ...deployGetters(["catalogEditData"])
  },

  created() {
    console.log("#######KubernetesDeployEdit.vue", this.editData);
  },

  methods: {
    $$create_initProperties() {
      // 계층도에서 그려질 info  컴포넌트 이름 설정
      this.deployInfoComponentName = DEPLOY_INFO.KUBERNETES.INFO_COMPONENT;
    },

    async showYamlModal() {
      console.log("#####showYamlModal");
      //if (this.$parent.executeValidation() == false) return;

      // 굳이 deploy Manager를 통해서 가져올 이유를 못찾겠어서 여기서 작업
      let param = {
        // serviceGroupId: this.serviceGroupId,
        k8sId: this.catalogEditData.k8sId,
        deployName: this.catalogEditData.deployName,
        catalogName: this.catalogEditData.catalogName,
        catalogVersion: this.catalogEditData.catalogVersion,
      }
      
      // let params = this.currentDeployManager.createSaveCatalogParams(param);
      let response = await getYaml(param);
      console.log(response);
      this.$refs.yamlModal.show(response.data);
    },
  },
};
</script>