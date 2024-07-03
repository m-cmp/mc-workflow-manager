<template>
	<div>
		<!-- 스테이지 -->
		<div style="display: flex; justify-content: space-between;">
			<!-- <div style="width: 100%; margin-top: 50px;">
				<span class="field-label required">
					{{ $t("project.catalog.stage") }}
				</span> 
				<div style="margin-top: 10px;">
					<el-radio 
						:disabled="editMode == 'edit'"
						v-model="state.editData.stageCd" 
						@change="onChangedStage"
						v-for="stage in state.stageList"
							:key="stage.label"
							:label="stage.label"
							:value="stage.label"
							>
						<label>{{ stage.label }}</label>
					</el-radio>
				</div>
			</div> -->
			
			<!-- 프로바이더 -->
			<div class="mt-5" inline-message="true" style="width: 48%;">
				<span class="field-label required">
					{{ $t('project.catalog.provider') }}
				</span>
				<el-select 
					:disabled="editMode == 'edit'"
					v-model="state.editData.providerCd"
					:placeholder="$t('project.catalog.selectProvider')"
					@change="onChangeProvider"
					style="width: 100%; margin-top: 10px;"
					>
					<el-option
						key="empty"
						value=""
						:label="$t('project.catalog.selectProvider')"
					>
					</el-option>
					<el-option 
						v-for="provider in selectedProvider"
						:key="provider"
						:label="provider.providerCd"
						:value="provider.providerCd"
						>
						{{ provider.providerCd }}
					</el-option>
				</el-select>
			</div>
			<!-- 클러스터 목록 -->
			<div class="mt-5" inline-message="true" style="width: 50%;">
				<span class="field-label required">
					{{ $t('project.catalog.cluster') }}
				</span>

				<el-select  
					v-if="editMode == 'edit'"
					disabled
					v-model="state.editData.k8sName"
					:placeholder="$t('project.catalog.selectCluster')"
					style="width: 100%; margin-top: 10px;"
					>
				</el-select>

				<el-select  
					v-else
					v-model="state.editData.k8sId"
					:placeholder="$t('project.catalog.selectCluster')"
					style="width: 100%; margin-top: 10px;"
					>
					<el-option
						key="empty"
						value=""
						:label="$t('project.catalog.selectCluster')"
					>
					</el-option>
					<el-option 
						v-for="cluster in state.clusterConfigList"
						:key="cluster.k8sId"
						:label="cluster.k8sName"
						:value="cluster.k8sId"
						>
						{{ cluster.k8sName }}
					</el-option>
				</el-select>
			</div>
		</div>
	</div>
</template>
<script lang="ts">
import { useI18n } from "vue-i18n";
import {useStore} from "vuex";

import { nextTick, computed, onMounted, ref, getCurrentInstance } from "vue";
import { EDIT_MODE } from "@/constant/common";

// import share from '@/store/modules/share'
import { deployActionTypes } from "@/store/modules/deploy";
import { getKubernetesCatalogDeployNameList, getYaml } from '@/api/kubernetesDeploy';
import { useToast } from 'vue-toastification';

export default {


	props: {
		editMode: {
			type: String,
			default: ""
		},

		deployConfigCounts: {
			type: Array,
			default:null
		},

		// stageInfo: {
		// 	type: Array,
		// 	default:null
		// },

		// stageId: {
		// 	type: String,
		// 	default: ""
		// },

		// deployTypeId: {
		// 	type: String,
		// 	default: ""
		// },

		providerCd: {
			type: String,
			default: ""
		},
		stageCd: {
			type: String,
			default: ""
		},
	},

	setup(props, { emit }) {
    const { t } = useI18n();
		const store = useStore();
		const instance = getCurrentInstance();
		const toast = useToast();

		const state = ref({
			activeTargetCount: 0,
			// selectStageId: props.stageId,
			// stageList: [] as any,
			providerList: computed(() => store.state.deploy.providerInfo),
			editData: computed(() => store.state.deploy.catalogEditData),

			clusterConfigList: computed(() => store.state.deploy.clusterConfigInfo),
		});
		
		// const serviceGroupInfo = computed(()=> share.state.serviceGroupInfo) as any;

		onMounted(() => {
			nextTick(async() => {
				await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.LOAD_PROVIDER_INFO);
				// setStageList();
			});
		});
		
		// function setStageList() {
		// 	state.value.stageList = [];
		// 	props.stageInfo.forEach((item) => {
		// 		state.value.stageList.push({
		// 			stageId: (item as any).codeOrder,
		// 			label: (item as any).codeName.toUpperCase(),
		// 			deployList: state.value.providerList
		// 		});
		// 	});
		// }
		
		const selectedProvider = computed(() => {
			let viewItem = [] as any;
			let result = [] as any;

			for(let item in props.deployConfigCounts) {
				if((props.deployConfigCounts[item] as any).cnt > 0) {
					viewItem.push(props.deployConfigCounts[item])
				}
			}
			for(let item in viewItem) {
				if(viewItem[item].stageCd == state.value.editData.stageCd) {
					result.push(viewItem[item])
				}
			}
			return result;
		}) as any


		async function onChangeProvider() {
			clearClusterConfigInfo();

			if(state.value.editData.providerCd) {
				const params = {
					providerCd: state.value.editData.providerCd,
					stageCd: state.value.editData.stageCd,
					// serviceGroupId:serviceGroupInfo.value.serviceGroupId
				}

				await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.LOAD_CLUSTER_CONFIG_INFO, params);
			}
		}

		// cluster 정보 초기화
		function clearClusterConfigInfo(){
			state.value.editData.k8sId="";
			store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.CLEAR_CLUSTER_CONFIG_INFO);
		}

		function onChangedStage() {
			state.value.editData.providerCd = '';
			state.value.editData.k8sId = '';
			// state.value.selectedCopyDeployItem = '';
			state.value.editData.catalogDeployYaml = '';

			if(selectedProvider.value.length === 0) {
				toast.error('등록된 클러스터 정보가 없습니다.');
			}
		}
		
		return {
			state,
			EDIT_MODE,
			selectedProvider,
			onChangeProvider,
			onChangedStage
		}
	}
};
</script>