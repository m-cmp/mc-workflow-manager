import lodash from 'lodash'
import validate from 'validate.js'
export default class DeployManagerCore {

	constructor(deployState, rootState, rootGetters) {
		this.deployState = deployState;
		this.rootState = rootState;
		this.rootGetters = rootGetters;
	}


	get buildEditData() {
		return this.deployState.buildEditData;
	}

	get extendBuildEditData() {
		return this.deployState.extendBuildEditData;
	}
	get deployEditData() {
		return this.deployState.deployEditData;
	}

	get compProperties() {
		return this.deployState.compProperties;
	}

	// get groupId() {
	// 	return this.rootGetters.groupId;
	// }

	// get serviceId() {
	// 	return this.rootGetters.serviceId;
	// }

	// get projectId() {
	// 	return this.rootGetters.projectId;
	// }
	// get userId() {
	// 	return this.rootGetters.userId;
	// }

	get stageCd() {
		return this.deployState.stageCd;
	}


	createNewDeployEditData() {
		throw new Error("override");
	}

	createNewExtendBuildEditData() {
		throw new Error("override");
	}

	createOriginalEditData() {
		let editData= {
			buildEditData:this.buildEditData,
			deployEditData:this.deployEditData,
			extendBuildEditData:this.extendBuildEditData
		}
		return  lodash.cloneDeep(editData);
	}


	/*
		편집 변경 유무 체크
		new 상태  또는 update 상태 이후 편집 유무 확인

		call : deploy 가 변경되는 경우 호출
	*/
	checkChangingEditData() {
		let currentEditData = this.createOriginalEditData();
		let currentEditDataString = JSON.stringify(currentEditData);
		let originalEditDataString = JSON.stringify(this.deployState.originalEditData);
		return originalEditDataString != currentEditDataString;
	}
	//////////////////////////////////////////////////////////////




	//////////////////////////////////////////////////////////////
	/*
		편집 정보 유효성 체크
	*/
	// 기본 빌드 정보 유효성 체크
	validateBuildEditData() {
		let constraints = {
			"buildId": {
				exclusion: {
                    within: [-1, ""],
                    "message": " 를 선택해주세요. "
                }
			}
		}

		let result = validate(this.buildEditData, constraints);
		if (result != null) {

			const firstMessage = messageResult[firstFieldName][0]
			Vue.$message({
			  type: 'error',
			  message: firstMessage
			})

			return false;
		}

		return true;

	}

	// 아이템 정보 유효성 체크
	validateDeployEditData() {
		throw new Error("override validateDeployEditData")
	}


	validateExtendBuildEditData() {
		return true;
	}

}
