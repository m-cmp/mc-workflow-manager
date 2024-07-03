
import validate from 'validate.js'
import deployValidationHelper from "../helper/deployValidationHelper";
import Vue from "vue";
const saveValidator = {
	emptySelect:{
		exclusion: {
			within: [""],
			"message":(value, attribute)=>{
				return "^"+Vue.app.$t("project.deploy.validateMsg.msgNotSelectError", {fieldName:attribute})
			}
		}
	},
	alphaNumbrHypen: {
		format: {
			pattern: "^[0-9a-zA-Z-]+$",
			message: (value, attribute) => {
				return "^"+Vue.app.$t("validation.alphanumericHyphen")
			}
		}
	},
	domain: {
		format: {
			pattern: "^[^((http(s?))\:\/\/)]([0-9a-zA-Z\-]+\.)+[a-zA-Z]{2,6}(\:[0-9]+)?(\/\S*)?$",
			message: (value, attribute) => {
				return "^"+Vue.app.$t("validation.domain")
			}
		}
	},
	twoLength: {
		length: {
			minimum: 2,
			message: (value, attribute) => {
				return "^" + Vue.app.$t("validation.msg2ltfield", { fieldName: attribute });
			}
		}
	},
	appName: {
		format: {
			pattern: "^[a-z]{1}[a-z0-9_-]{1,16}$",
			message: (value, attribute) => {
				return "^"+Vue.app.$t("validation.appNameMsg")
			}
		}
	},
	ports: {
		deployPorts:{}
	},
	pvcVolumes: {
		deployPVCVolumes: {}
	},
	hostPathVolumes: {
		deployHostPathVolumes: {}
	}
}

validate.validators.deployPorts = function (value, options, key, attributes) {
	// 0개면 패스
	if(value.length==0){
		return;
	}

	let fieldNames = ["name", "port", "containerPort"];

	// 빈 값 확인
	let message= deployValidationHelper.checkEmptyMultiInput(fieldNames, value);
	if(message!=false){
		return Vue.app.$t(message);
	}
	// 중복확인
	message=deployValidationHelper.duplicateMultiInput(fieldNames, value);
	if(message!=false){
		return Vue.app.$t(message);
	}

	return;

}

validate.validators.deployPVCVolumes = function (value, options, key, attributes) {
	// 0개면 패스
	if(value.length==0){
		return;
	}

	let fieldNames = ["name", "mountPath"];

	// 빈 값 확인
	let message= deployValidationHelper.checkEmptyMultiInput(fieldNames, value);
	if(message!=false){
		return Vue.app.$t(message);
	}

	// 중복확인
	message=deployValidationHelper.duplicateMultiInput(fieldNames, value);
	if(message!=false){
		return Vue.app.$t(message);
	}

	return;
}

validate.validators.deployHostPathVolumes= function(value, options, key, attributes){
	// 0개면 패스
	if(value.length==0){
		return;
	}

	let fieldNames = ["name"];

	for(var i=0;i<value.length;i++){
		let tartetValue = value[i];
		for(var m=0;m<fieldNames.length;m++){
			let targetFieldName = fieldNames[m];
			let fieldValue = tartetValue[targetFieldName].toString().trim();

			let result = portsValidationHelper.emptyValidation(i, fieldValue, targetFieldName);
			if(result!==true){
				return Vue.app.$t(result);
			}
		}
	}

	let duplicateValue = normalValidateHelper.isDuplicateCheck(value, fieldNames);
	if(duplicateValue!=false){
		return Vue.app.$t(duplicateValue);
	}

	return;
}

const portsValidationHelper = {
	emptyValidation(index, value, fieldName){
		if(value.length==0){			
			return Vue.app.$t("project.deploy.validateMsg.msgNotInputErrorAt", {index:index+1, fieldName:fieldName})
		}

		return true;
	}
}


const normalValidateHelper = {
	// 중복 유무 
	isDuplicateCheck(value, fieldNames){
		// 중복 유무
		for(var m=0;m<fieldNames.length;m++){
			let targetFieldName = fieldNames[m];
			let targetVaule="";
			let isDuplicate = value.find((item)=>{
				let fieldValue = item[targetFieldName];
				if(targetVaule==fieldValue){
					return true;
				}else {
					targetVaule=fieldValue;
					return false;
				}
			})
			
			if(isDuplicate!=null){
				return targetFieldName+" 값 중복";
			}
		}

		return false;
	}
}



export default saveValidator;