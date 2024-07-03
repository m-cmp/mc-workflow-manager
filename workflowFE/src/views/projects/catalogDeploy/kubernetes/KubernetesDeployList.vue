<template>
	<div v-if="state.isFirstDataLoadingCompleted" class="deploy-history-wrapper">
		<div class="flex-lg-row-fluid ms-0 ps-0" data-comp-id="project-deploy-history">
			<!-- 카탈로그 상세 컴포넌트 --> 
			<catalog-deploy-detail 
				ref="catalogDeployDetail" 
				:catalog-deploy-list="catalogDeployList"
				:deploy-info="currentDeployInfo"
				@onClickDelete="deleteDeployShowModal"

				:total-count="state.totalHistoryCount"
				:history-list="state.displayItems"
				:page-limit="CNT_PER_PAGE"
				:on-run-deploy="runDeploy"
				:enable-yaml="state.enableYaml"

		        @changeItem="onChangeDeployInfo"
				@paginator="onChangeHistoryPage"
			/>
		</div>
	</div>
	<!-- <ConfirmModal ref="confirmModal" :content="contentMsg" @fnParent="deleteDeployCall" /> -->
</template>


<script lang="ts">
import { getCatalogDeployhistoryInfo } from "@/api/kubernetesDeploy";
import { deleteKubernetesCatalogDeploy } from "@/api/kubernetesDeploy";
import KubernetesRunDeployModal from "./panels/KubernetesRunDeployModal.vue"

//add
import {useI18n} from "vue-i18n";
import {getCurrentInstance, nextTick, onMounted, ref} from "vue";
import axios from "axios";
import Pagination from "@/components/paginationBkup/Pagination.vue";

import { BUILD_ICON_NAME, BUILD_STATE } from "@/constant/common";
import { useRoute } from 'vue-router';
import { useToast } from "vue-toastification";
import ConfirmModal from "@/components/messagebox/ConfirmModal.vue";
import { Modal } from "bootstrap";
import store from "@/store";
import { catalogDeployKubernetesNow } from "@/api/kubernetesDeploy";
import CatalogDeployDetail from "../common/components/CatalogDeployDetailComponent.vue";
import Swal from 'sweetalert2';

export default {
	components: {
		CatalogDeployDetail,
		Pagination,
		KubernetesRunDeployModal,
		ConfirmModal
	},
	props: {
		sidebarState: null,
		onToggleSidebar: {
			type: Function,
			default() {
				return () => {
					console.log("override 필요");
				};
			},
		},
		onRefreshDeployList: {
			// deploy 삭제시 호출, deploy 리스트 다시 부르기
			type: Function,
			default: null
		} as any,
		currentDeployInfo:{
			type: Object,
			default: null
		} as any,
		catalogDeployList:{
			type: Object,
			default: null
		} as any,
		callbackCatalogList: {
			type: Function,
			default: null
		} as any,
	},
	

	setup(props,{emit}) {
			/* ============================================================================================================= */
		// 다국어 설정
		/* ============================================================================================================= */
		
		let { t, locale } = useI18n();

		const instance = getCurrentInstance();
		const toast = useToast();

		const state = ref({
			enableYaml:true,
			isFirstDataLoadingCompleted: false,
			
			historyList: [],

			totalHistoryCount: 0,

			displayItems: new Array(),              // 현재 화면 춮력 목록
		})

		const CNT_PER_PAGE = 5;                     // 목록의 페이지별 출력 개수
		let currentPageNo = 1;                      // 페이지 넘버

		const confirmModal = ref(null);
		// const contentMsg = ref(t("msg.deleteConfirm"));

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// 라이프 사이클
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		onMounted( () => {
			nextTick(() => {
				init();
				buildHistoryList();
			});
		});

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// 라이프 사이클
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		function onChangeDeployInfo(catalogDeployInfo) {
			emit("changeItem", catalogDeployInfo, 0);
		}

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// 데이터 초기화
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		async function init(){
			state.value.isFirstDataLoadingCompleted = true;
		}

		function buildHistoryList() {
			/* 필터된 데이터에서 현재 출력 데이터 구성 */
			state.value.displayItems = [];
			for(let xx = (currentPageNo-1)*CNT_PER_PAGE; xx < (currentPageNo*CNT_PER_PAGE) && xx < state.value.totalHistoryCount; xx++) {
				state.value.displayItems.push(state.value.historyList[xx]);
			}
		}

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// 데이터 초기화
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		async function runDeploy() {
			const params = {
				"catalogDeployId": props.currentDeployInfo.catalogDeployId,
				"catalogDeployYaml": props.currentDeployInfo.catalogDeployYaml
			}
			catalogDeployKubernetesNow(params).then(async () => {
				// 페이지 업데이트
				const success = await _refreshHistoryList(0);
				// if (success) {
				// 	// 실행중인 히스토리 완료 체크처리하기
				// 	_executeHistoryBuildWatching();
				// }
			})
			.catch((error) => {
				if (axios.isCancel(error)) {
					console.log("Canceled normally.");
				} else {
					console.log("error ", error);
				}
			});
		}

		//add confirm modal
		function deleteDeployShowModal(catalogId) {
      Swal.fire({
        text: '해당 카탈로그 배포를 삭제 하시겠습니까?',
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
					console.log(catalogId)
          deleteDeployCall(catalogId).then(()=> {
						props.callbackCatalogList();
						toast.success('삭제되었습니다')
					});
        }
      });
		}
	
		async function deleteDeployCall(catalogId){
			try {
				await deleteKubernetesCatalogDeploy(catalogId);
				
				(instance?.refs.confirmModal as any).closePop();
				
				toast.success(t("msg.delCompleted"))

				//  DeployList에 있는 메서드 호출하기
				// deploy 리스트 다시 호출하기
				props.onRefreshDeployList();

			} catch (error) {
				console.log("delete deploy warning", error);
			}
		}

		function $$createHistoryList(historyList){
			historyList.map((item)=>{
				item.deployUserId = item.userId,
				item.deployDesc = item.description;
			
				return item;
			})
			return historyList;
		}

		async function _refreshHistoryList(offset = 0) {
			console.log("\t deploy 004 _refreshHistoryList() 히스토리 목록 구하기 시작");
			let success = false;
		
			// try {
			// 	// 히스토리 목록 구하기
			// 	const response:any = await getCatalogDeployhistoryInfo(props.currentDeployInfo.catalogDeployId);
				
			// 	state.value.totalHistoryCount = response.data.length;
				
			// 	state.value.historyList = [];
			// 	/*
			// 		원본 데이터에
			// 			-아이콘 정보
			// 			-빌드진행유무 정보
			// 			-lastArtifact 상태 정보
			// 			-날짜 정보
			// 		추가.
			// 	*/
			// 	if (response.data) {
			// 		let tempHistoryList = response.data.map((item) => {
			// 			item.userId = item.deployUserId

			// 			item.isApprove = false;
			// 			item.isBuilding = false;
						
			// 			// 아이콘
			// 			switch (item.deployResult) {
			// 				case BUILD_STATE.SUCCESS:
			// 					item.icon = BUILD_ICON_NAME.SUCCESS_ICON;
			// 					break;
			// 				case BUILD_STATE.FAILED:
			// 					default:
			// 						item.icon = BUILD_ICON_NAME.FAILED_ICON;
			// 				}
			// 					return item;
			// 				}
			// 			)
			// 			state.value.historyList = $$createHistoryList(tempHistoryList);
			// 	} else {
			// 		state.value.totalHistoryCount = 0;
			// 		state.value.historyList = [];
			// 	}
			// 	//paging
			// 	buildHistoryList();
			// 	success = true;
			// } catch (error) {
			// 	console.log("ERROR ", error);
			// 	return false;
			// }
			// console.log("\t deploy 004 _refreshHistoryList() 히스토리 목록 구하기 완료", success);

			return success;
		}


		async function updateHistoryList(currentDeployInfo) {
			props.currentDeployInfo.infoItems = [{
				// 임시 하드코딩
				// controller:currentDeployInfo.controller
				controller:'Deployment'
			}];

			/*
				- deploy 리스트 구하기
				- 0 = 히스토리 offset
			*/
			let success = await _loadHistoryList(0);

			if (success) {
				state.value.isFirstDataLoadingCompleted = true;
			} else {
				// 메시지 출력 후
				toast.error("No data");
			}
		}

		// 실행중인 빌드 목록 감사하기
		// const _executeHistoryBuildWatching = () => {
		// 	console.log("\t deploy 005 _executeHistoryBuildWatching() 실행 시작");
		// 	const length = dpRunMangerObject.startHistoryBuildWatching(
		// 		{
		// 			historyList: state.value.historyList,
		// 			currentDeployInfo: props.currentDeployInfo,
		// 			// userId: state.value.userId,
		// 			// runDeployEditData: (instance?.refs.runDeployModal as any)
		// 		}
		// 	);

		// 	console.log("\t deploy 005 _executeHistoryBuildWatching() 실행 완료, deploy lengt= ",	length);
		// }


		/*
			1. deployInfo 설정
			2. artifactId 목록 구하기
			3. 히스토리 params 설정
			4. offset(pgae)에 해당하는 히스토리 목록 요청
			5. 감시 실행
		*/
		async function _loadHistoryList(offset = 0) {
			// 4. offset(pgae)에 해당하는 히스토리 목록 요청
			const success = await _refreshHistoryList(offset);

			// if (success) 
			// 	// 5. 감시 실행
			// 	_executeHistoryBuildWatching();

			return success;
		}

		async function onChangeHistoryPage(info) {
			currentPageNo = info.page;
			let offset =  Math.max(0,(info.pageNo - 1) * CNT_PER_PAGE);//Math.max(0, (info.page - 1) * info.limit);
			const success = await _refreshHistoryList(offset);
			// if (success) {
			// 	// 실행중인 히스토리 완료 체크처리하기
			// 	_executeHistoryBuildWatching();
			// }
		}

		return {
			state,
			
			confirmModal,
			// contentMsg,
			CNT_PER_PAGE,

			$$createHistoryList,
			updateHistoryList,

			deleteDeployShowModal,
			deleteDeployCall,
			onChangeHistoryPage,

			runDeploy,
			onChangeDeployInfo
		}
	},
}
</script>