import Vue from "vue";
import { getNextBuildId } from "@/api/build";
import { getBuildForBuilding } from "@/api/build";
import { deployNow } from "@/api/deployModeler";
import axios from 'axios';
import {CancelToken} from "@/common/request.js";
import { BUILD_ICON_NAME, BUILD_STATE } from "@/constant/common";
import { List } from "echarts/core";


/*	
	- 초기 화면 실행시 실행중인 deploy 관리 
	- 중간 실행중인 deploy 관리지
*/
class DeployRunningmanager2 {

	//변수 정의
	_historyList: Array<Object> | any
	_currentDeployInfo: Object | any
	_userId: string | any
	_runDeployEditData: Object | any
	_init: boolean | any
	_cancelTokenSourceMap: Map<Object, Object> | any
	
	//정의된 변수 생성자에 등록
    constructor() {
        // run 응답용 promise 취소 맵
		this.clear();
	}

	_setInfo(info) {
		this.clear();
		this._historyList = info.historyList;
		this._currentDeployInfo = info.currentDeployInfo;
		this._userId = info.userId;
		this._runDeployEditData = info._runDeployEditData;
		this._init = true;
	}


	public clear() {
		this._cancelHistoryRunBuildWatching();
		this._cancelTokenSourceMap = new Map();
		this._historyList = [];
		this._currentDeployInfo = {};
		this._userId = "";
		this._runDeployEditData = {};
		this._init = false;
	}
	
	/*
		실행중인 watcher 취소 처리하기.
	*/
	_cancelHistoryRunBuildWatching() {
		if (this._cancelTokenSourceMap) {
			console.log("\t deploy 100 _cancelHistoryRunBuildWatching() 취소 개수 =  ", this._cancelTokenSourceMap.size)
			this._cancelTokenSourceMap.forEach((tokenSource) => {
				tokenSource.cancel("cancel build run watching");
			});
			this._cancelTokenSourceMap.clear();
		}

		
	}
	public loguse(){
		console.log("로그사용!!!!!!")
	}
	/*
		실행중인 빌드가 존재중인지 찾기 
		
			@historyList
			@currentDeployInfo
			@userId
			@runDeployEditData
			@jenkinsJobName
		call:  deploy 리스트 페이지에서 실행.
	*/
	public startHistoryBuildWatching(info) {
		console.log("\t deploy 099 startHistoryBuildWatching() 실행 시작")
		// 초기화 처리
		this._setInfo(info);
		
		// 히스토리 목록에서 실행중인 목록만 걸러낸다.
		const runningHistoryItemList = this._historyList.filter((item) => item.isBuilding) || [];
		this._cancelTokenSourceMap = new Map();

		// getBuildForBuilding 실행하기
		/*
			단계01: 취소 토콘 생성하기
			단계02: 벌드 체크 실행
		*/
		runningHistoryItemList.forEach((item) => {
			console.log("Temp 00 ", item)
			// 단계01: 취소 토콘 추가하기
			const cancelTokenSource = this.addCancelTokenSource(item.jenkinsDeployId)
			
			// 단계02: 벌드 체크 실행
			const params = {
				jenkinsJobName:info.currentDeployInfo.jenkinsJobName,
				buildId: item.deployId,
				queueId: item.queueId,
			};
			
			console.log("\t\t deploy 099-01 getBuildForBuilding 실행 시작(늦게 결과 발생) jenkinsDeployId =", item.jenkinsDeployId)
			// 단계03: 응답이 오래 걸릴 수 있음
			getBuildForBuilding(params,cancelTokenSource.token)
				.then((response) => {
					const historyBuildInfo = response.data;
					// 토콘에서 삭제하기
					this.removeCancelTokenSource(historyBuildInfo.id);
					// 빌드 정보 업데이트
					this._updateHistoryBuildItem(historyBuildInfo);
					console.log("\t\t deploy 099-01 getBuildForBuilding 실행 완료 jenkinsDeployId =", historyBuildInfo.id)
				})
				.catch((error) => {
					if (axios.isCancel(error)) {
						console.log("cancle Run build watching  ");
					} else {
						console.log(
							"executeHistoryBuildWatching  error ",
							error
						);
					}
				});
		});

		console.log("\t deploy 099 startHistoryBuildWatching() 실행 완료 ", runningHistoryItemList.length)
		return runningHistoryItemList.length;

	}

	// 취소 토큰 추가
	public addCancelTokenSource(jenkinsDeployId) {
		
		// 단계01: 취소 토콘 생성하기
		const cancelTokenSource = CancelToken.source(); // axios.CancelToken.source();//
		// console.log("cancelTokenSource===========")
		// console.log(cancelTokenSource.token);
		this._cancelTokenSourceMap.set(
			jenkinsDeployId,
			cancelTokenSource
		);

		return cancelTokenSource;
	}
	
	// 취소 토큰 제거 
	public removeCancelTokenSource(jenkinsDeployId) {
		if(this._cancelTokenSourceMap)
			this._cancelTokenSourceMap.delete(parseInt(jenkinsDeployId));
	}
	
	/*
		빌드 중 완료되는 경우 빌드 상태를 업데이트 처리하기
		실행 :
			- 초기 히스토리 목록에서 빌드가 완료된 경우
			- 빌드 버튼을 눌러 빌드를 실행 시킨 경우

		주의 : 2020.03.20
			-  업데이트시  total 정보도 같이 업데이트 되어야 하기 때문에
				페이지를 다시 읽는 것으로 변경함.
				추후 이 메서드는 삭제 예정

	*/
	_updateHistoryBuildItem(historyBuildInfo) {
		// 단계03: 빌드 정보 업데이트
		/* 주의 :
	빌드 후 생성되어 넘어오는 jenkinsId(id)는 문자로 되어 있음
	시작시 받아오는 히스토리 목록의 jenkinsId는 숫자로 되어 있기 때문에
	형변환 해줌.
	*/
		historyBuildInfo.id = parseInt(historyBuildInfo.id);
		// 히스토리 정보에서 업데이트된 빌드 아이템 찾기
		const historyBuildItem = this._historyList.find(
			(item) => {
				return (
					item.jenkinsDeployId ==historyBuildInfo.id
				);
			}
		);

		// 빌드 아이템 정보 업데이트
		if (historyBuildItem) {
			// 날짜 정보 업데이트
			historyBuildItem.deployDate =historyBuildInfo.timestamp;
			// 빌딩 상태를 false로 변경
			historyBuildItem.isBuilding = false;
			// 아이콘 정보 업데이트
			if (historyBuildInfo.result ==BUILD_STATE.SUCCESS) {
				historyBuildItem.icon =BUILD_ICON_NAME.SUCCESS_ICON;
			} else if (historyBuildInfo.result ==BUILD_STATE.FAILURE) {
				historyBuildItem.icon = BUILD_ICON_NAME.FAILED_ICON;
			}
		}
	}
	//////////////////////////////////////////////////////////////////

}

export default DeployRunningmanager2;