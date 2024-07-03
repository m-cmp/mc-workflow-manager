<template>
    <props-modal
        ref="propModal"
        data-comp-id="project-build-props-panel"
        panel-class="build-properties-panel"
        @closed="onClose"
    >
    <header class="header">
        <div class="title"><i class="fas fa-th-list" /> Properties</div>
    </header>
    
    <el-form
        ref="newForm"
        class="contents-wrapper"
        label-position="top"
        label-width="100px"
        :model="state.editData"
        :rules="state.inputRules"
        autocomplete="on"
    >
        <el-form-item
            v-if="state.editMode === EDIT_MODE.NEW"
            inline-message="true"
            prop="deployName"
        >
            <span class="field-label required">{{
                $t("project.deploy.deployName")
            }}</span>
            <div class="duplicate-name-wrapper">
                <el-input
                    v-model.trim="state.editData.deployName"
                    :placeholder="
                        $t('project.deploy.msgInputDeployName')
                    "
                    @input.native="onChangeDuplicateCheck"
                />
                <el-button
                    v-if="state.editData.isDuplicateCheck === false"
                    type="primary"
                    @click="duplicateChecked"
                    >{{ $t("common.duplicateCheck") }}</el-button
                >
                <el-button
                    v-if="state.editData.isDuplicateCheck === true"
                    type="success"
                    icon="el-icon-success"
                    >{{ $t("common.duplicateCheck") }}</el-button
                >
            </div>
        </el-form-item>
        <el-form-item v-else inline-message="true" prop="deployName">
            <span class="field-label">{{
                $t("project.deploy.deployName")
            }}</span>
            <el-input
                v-model.trim="state.editData.deployName"
                readonly
                disabled
                :placeholder="$t('project.deploy.msgInputDeployName')"
            />
        </el-form-item>

        <!-- <el-form-item inline-message="true" prop="buildId">
            <span slot="label" class="field-label">{{
                $t("project.deploy.build")
            }}</span>
            <el-select
                v-model="editData.buildId"
                style="width:100%"
                @change="onSelectedBuildItem($event, 'buildId')"
                @blur="onValidateSelect('buildId')"
            >
                <el-option
                    key="empty"
                    value=""
                    :label="$t('project.deploy.msgSelectBuild')"
                >
                </el-option>
                <el-option
                    v-for="item in buildList"
                    :key="item.value"
                    :label="item.text"
                    :value="item.value"
                />
            </el-select>
        </el-form-item> -->
        <el-form-item
            v-if="deployApproveFlowList && deployApproveFlowList.length > 0"
            inline-message="true"
        >
            <span class="field-label">{{
                $t("project.deploy.defaultApproveFlow")
            }}</span>
            <el-select
                v-model="state.editData.deployApproveFlow"
                style="width:100%"
                @change="onSelectedBuildItem($event, 'deployApproveFlow')"
                @blur="onValidateSelect('deployApproveFlow')"
            >
                <el-option
                    key="empty"
                    value=""
                    :label="$t('project.deploy.selectApproveFlow')"
                />
                <el-option
                    v-for="item in deployApproveFlowList"
                    :key="item.value"
                    :label="item.text"
                    :value="item.value"
                />
            </el-select>
        </el-form-item>
    </el-form>

    </props-modal>
</template>

<script lang="ts">
import {useI18n} from "vue-i18n";
import { computed, watchEffect, getCurrentInstance, nextTick, onMounted, ref } from "vue";
import {useStore} from "vuex";
import { duplicateCheck, getProfiles } from "@/api/commonDeploy";
import topbarController from "@/layout/service/header/TopbarController";
import {EDIT_MODE} from "@/constant/common";
import { useToast } from "vue-toastification";

import {IS_BUILD_PANEL_OPEN, BUILD_EDIT_DATA,BUILD_LIST} from "@/store/modules/deploy/getters";
import { deployActionTypes, deployActions,deployGetters } from "@/store/modules/deploy";
import PropsModal from "@/components/PropsModal/index.vue";

import {
    _validateName,
    _validateLength,
    _validateSelect
} from "@/utils/input-validate";



export default {
    components: {
        PropsModal
    },
    props: {
       
        editMode: {
            type: String,
            default: "new"
		},
    	deployApproveFlowList: {
      		type: Array,
      		default: null
		}
		
    },

    setup(props,{emit}) {

        /* ============================================================================================================= */
        // 다국어 설정
        /* ============================================================================================================= */

        let { t, locale } = useI18n();

    
    
        /* ============================================================================================================= */
        // 변수 및 데이터
        /* ============================================================================================================= */
        const instance = getCurrentInstance();
        const toast = useToast();
        const store = useStore();

        const state = ref({
            editData : computed(() => store.state.deploy.buildEditData),
            editMode: props.editMode,
            deployApproveFlowList:props.deployApproveFlowList,
            inputRules: {
                deployName: [
                    {
                        required: true,
                        trigger: "blur",
                        validator: _validateName,
                        labelName: "Deploy name"
                    },
                    {
                        required: true,
                        trigger: "blur",
                        validator: _validateLength,
                        length: 2
                    }
                ],
                // buildId: [
                //     {
                //         required: true,
                //         trigger: "select",
                //         validator: _validateSelect
                //     }
                // ]
            }
        });

        watchEffect(async () => {
            await store.dispatch(deployActionTypes.NAMESPACE + "/" + IS_BUILD_PANEL_OPEN,store.state);

            if (store.state.deploy.buildPanel.opened) {
                (instance?.refs.propModal as any).show();
            } else {
                (instance?.refs.propModal as any).hide();
            }
        });

        // ...deployActions([
		// 	deployActionTypes.CLOSE_BUILD_PANEL,
		// ]),

        function deployNewShow(){
            (instance?.refs.propModal as any).show();
        }

		function onClose() {
			const propModalObj =  (instance?.refs.propModal as any);

            propModalObj.hide();
            
            store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.CLOSE_BUILD_PANEL);
		}
		
		function onChangeDuplicateCheck() {
            store.state.deploy.buildEditData.isDuplicateCheck = false;
        }

        async function duplicateChecked() {
            const length = state.value.editData.deployName.trim().length;
            if (length < 2) {
                const msg =
                    length == 0
                        ? t("project.deploy.msgInputDeployName")
                        : t("msg.least2Charac");

                toast.error(msg);
            } else {
                const params = {
                    projectId: state.value.editData.projectId,
                    name: state.value.editData.deployName,
                    deployFrom: 1 // delpoy와 modeler 구분용으로 사용
                };

                const response = await duplicateCheck(params);

                if (response.data === false) {
                    store.state.deploy.buildEditData.isDuplicateCheck = true;
                    
                    toast.success(t("msg.availableName"));
                } else {
                    toast.error(t("msg.alreadyName"));

                    store.state.deploy.buildEditData.isDuplicateCheck = false;
                }
            }
        }

        function onSelectedBuildItem($event, id) {
            selectedBuildItem();
            validateSelect($event, id);
        }

        function selectedBuildItem() {
            let find = store.state.deploy.buildList.find(
                x => x.value == state.value.editData.buildId
            );

            state.value.editData.buildName = find ? find.text : "";
        }

        /*
				select 태그에서는 blur 이벤트 발생을 하지 않기 때문에
				수동으로 blur시 유효성 체크 실행
			*/
        function validateSelect(e, prop) {
            (instance?.refs.newForm as any).validateField(prop);
        }

        /*
            DeployNew에서 validate 실행
        */
        function executeValidation() {
            return new Promise((resolve, reject) => {
                // edit 모드가 new(생성)일때만 실행
                if (props.editMode === EDIT_MODE.NEW) {
                    const length = state.value.editData.deployName.trim().length;
                    if (length < 2) {
                        const msg =
                            length == 0
                                ? t("project.deploy.msgInputDeployName")
                                : t("msg.least2Charac");

                        toast.error(msg);

                        resolve(false);
                        return;
                    }

                    if (state.value.editData.isDuplicateCheck === false) {
                        toast.error(t("msg.msgDuplicate"));

                        resolve(false);
                        return;
                    }
                }

                (instance?.refs.newForm as any).validate(valid => {
                    resolve(valid);
                });
            });
        }

        /*
        select 태그에서는 blur 이벤트 발생을 하지 않기 때문에
        수동으로 blur시 유효성 체크 실행
    */
        function onValidateSelect(prop) {
            (instance?.refs.newForm as any).validateField(prop);
		}
		
		function hide(){
			(instance?.refs.propModal as any).hide();
		}

        return {
            state,
            EDIT_MODE,
            onClose,
            onChangeDuplicateCheck,
            onSelectedBuildItem,
            onValidateSelect,
            duplicateChecked,
            deployNewShow
        }
    }

    // computed: {
	// 	...deployGetters([BUILD_LIST, IS_BUILD_PANEL_OPEN, BUILD_EDIT_DATA]),
	// 	editData(){
	// 		return this[BUILD_EDIT_DATA]
	// 	},
	
	// 	EDIT_MODE(){
	// 		return EDIT_MODE
	// 	},
	
	// 	EDIT_MODE(){
	// 		return EDIT_MODE
	// 	},
    // }
};
</script>
