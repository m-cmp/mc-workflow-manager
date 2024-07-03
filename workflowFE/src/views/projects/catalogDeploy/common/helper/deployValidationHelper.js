import Vue from "vue";
export default {

	/*
		다중 입력 유효성 체크
		@fieldNames : 검증할 필드 목록
		@value : 입력 정보
		@callback : 콜백 처리
	*/
	checkEmptyMultiInput(fieldNames, valueList) {
	
		/* 값에서 필드명에 해당하는 입력 값 찾기*/
		for (var i = 0; i < valueList.length; i++) {
			// n번째 값 구하기(다중)
			let tartetValue = valueList[i];
			for (var m = 0; m < fieldNames.length; m++) {
				// fieldnames에서 m번째 필드 명 구하기
				let targetFieldName = fieldNames[m];
				// value에서 필드명에 해당하는 값 구하기
				let fieldValue = tartetValue[targetFieldName].toString().trim();
				
				// 빈 값인지 체크 
				if (fieldValue.length == 0) {
					//let message = `${i + 1} 번째의 ${targetFieldName}이 입력되지 않았습니다.`;
					let message= Vue.app.$t("validation.msgNotInputValue", {index:i+1, fieldName:targetFieldName})
					//callback(new Error(Vue.app.$t(message)));
					return message;
				}
			}
		}

		return false;
	},

	/*
		field별 중복 값 체크하기
		예) 아래와 같을때 field1이 중복되어 있음.
			field1, field2, field3
		1	  a       b       c
		2     a       bb      cc
		
	*/
	duplicateMultiInput(fieldNames, valueList) {
		let tempSet = new Set();
		for (var m = 0; m < fieldNames.length; m++) {
			let targetFieldName = fieldNames[m];
			tempSet.clear();
			let isDuplicate = false;
			for (let item of valueList) {
				// 숫자인 경우 문자열로 변환해야함.
				let fieldValue = item[targetFieldName].toString();
				if (tempSet.has(fieldValue) == true) {
					isDuplicate = true;
					break;
				} else {
					tempSet.add(fieldValue, true);
				}
			}
			
			if (isDuplicate ==true) {
				return Vue.app.$t("validation.msgDuplicateInputValue", { fieldName: targetFieldName })
			}
		}

		return false;
	}
}