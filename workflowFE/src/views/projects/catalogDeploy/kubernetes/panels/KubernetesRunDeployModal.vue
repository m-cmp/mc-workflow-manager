<template>
    <s-modal :visible="isVisible" title="" @close="onClose">
        <template v-slot:header>
            <div class="title">
                <i class="fas fa-cloud-upload-alt" /> Kubernetes-{{ approveFlg?$t("project.deploy.deployRequest"):$t("project.deploy.runDeploy") }}
            </div>
        </template>
        <el-form
            v-if="enableBuild"
            ref="newForm"
            class="contents-wrapper"
            label-position="top" 
            label-width="100px"
            autocomplete="on"
            :model="runDeployEditData"
            :rules="inputRules"
        >
            <el-form-item required>
                <template v-slot:label>
                <span class="field-label">{{
                    $t("project.deploy.buildId")
                }}</span>
                </template>
                <el-select
                    v-model="buildId"
                    style="width:100%"
                    @change="onChangeArtifact"
                >
                    <el-option
                        v-for="item in buildHistoryList"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value"
                    />
                </el-select>
            </el-form-item>

           
           <el-form-item prop="description" class="desc-field-form">
                <template v-slot:label>
                    <span class="field-label"
                    >{{ $t("common.description") }}</span>
                    <span class="txt-info">{{runDeployEditData.description.length}}/250{{$t("common.limitCharacterGuide")}}</span>
                </template>     
                <el-input
                    v-model="runDeployEditData.description"
                    type="textarea"
                    rows="3"
                />
            </el-form-item>
			<el-form-item
				inline-message="true"
				prop="deleteYn">
				<el-checkbox v-model="runDeployEditData.deleteYn"> {{$t('Delete the existing controller')}}</el-checkbox>
			</el-form-item>
        </el-form>
        <div v-else>
            {{ $t("project.deploy.msgEmptyBuildError") }}
        </div>

        <template v-slot:footer>
            <el-button type="info" class="btn btn-secondary" @click="onCancel">{{
                $t("common.cancel")
            }}</el-button>
            <el-button v-if="enableBuild" type="primary" class="btn btn-primary" @click="onFinish">{{
        		approveFlg?$t("project.deploy.deployRequest"):$t("project.deploy.runDeploy")
            }}</el-button>
        </template>
    </s-modal>
</template>

<script>
import SModal from "@/components/SModal";
import { _validateName, _validateLength, _valdateLimitLength } from "@/utils/input-validate";
import { mapState as shareMapState } from "@/store/modules/share";
import { getProfiles } from "@/api/commonDeploy";
export default {
	name:"KubernetesRunDeployModal",
    components: {
        SModal
    },
    props: {
        buildHistoryList: {
            type: Array,
            default: () => {
                return [];
            }
        },
        runDeployEditData: {
            type: Object,
            default: () => {
                return {};
            }
        },
    	approveFlg: {
      		type: Boolean
    	}
    },
    data() {
        return {
            
            buildId: 0,
            isVisible: false,
            inputRules: {
                description:[{
                    required: false,
                    trigger: 'blur',
                    validator: _valdateLimitLength,
                    length: 250
                }]
            }
        };
    },

    computed: {
        ...shareMapState(["projectInfo"]),

        enableBuild() {
			if(this.buildHistoryList==null)
				return false;

			if(this.runDeployEditData==null)
				return false;

            return this.buildHistoryList.length > 0;
        },

    },

    methods: {
        onClose() {
            this.isVisible = false;
            this.$emit("closed", false);
        },

        onCancel() {
            this.isVisible = false;
            this.$emit("closed", false);
        },

        onFinish() {
            this.$refs["newForm"].validate(valid => {
                if (valid) {
                    this.isVisible = false;
                    this.$emit("closed", true);
                } else {
                    //this.$refs.activeProfile.focus();
                }
            });
        },

        show() {
            this.isVisible = true;
            this.buildId = 0;
            this._updateBuildInfo();
        },

        onChangeArtifact(value) {
            this._updateBuildInfo();
        },

        _updateBuildInfo() {
            this.runDeployEditData.buildHistory = this.buildHistoryList[this.buildId].item;
			this.runDeployEditData.jenkinsBuildId = this.runDeployEditData.buildHistory.jenkinsBuildId;
			
		},
		
		hide(){
			this.isVisible=false;
		}

       

    }
};
</script>
