import { DEPLOY_TYPE_ID, DEPLOY_TYPE_NAME } from "@/constant/deploy";

export default {
	getDeployTypeIdToTypeName(typeId) {
		switch (typeId) {
			case DEPLOY_TYPE_ID.DOCKER:
				return DEPLOY_TYPE_NAME.DOCKER;
			case DEPLOY_TYPE_ID.KUBERNETES:
				return DEPLOY_TYPE_NAME.KUBERNETES;
			case DEPLOY_TYPE_ID.AKS:
				return DEPLOY_TYPE_NAME.AKS;
			case DEPLOY_TYPE_ID.OPEN_SHIFT:
				return DEPLOY_TYPE_NAME.OPEN_SHIFT;
			case DEPLOY_TYPE_ID.BM:
				return DEPLOY_TYPE_NAME.BM;
		}
	},
	getDeployTypeNameToTypeId(typeName) {
		switch (typeName) {
			case DEPLOY_TYPE_NAME.DOCKER:
				return DEPLOY_TYPE_ID.DOCKER;
			case DEPLOY_TYPE_NAME.KUBERNETES:
				return DEPLOY_TYPE_ID.KUBERNETES;
			case DEPLOY_TYPE_NAME.AKS:
				return DEPLOY_TYPE_ID.AKS;
			case DEPLOY_TYPE_NAME.OPEN_SHIFT:
				return DEPLOY_TYPE_ID.OPEN_SHIFT;
			case DEPLOY_TYPE_NAME.BM:
				return DEPLOY_TYPE_ID.BM;
		}
	},
	getDeployListComponentName(deployTypeName) {
		switch (deployTypeName) {
			case DEPLOY_TYPE_ID.DOCKER: return "DockerDeployList";
			case DEPLOY_TYPE_ID.AKS: return "AKSDeployList";
			case DEPLOY_TYPE_ID.OPEN_SHIFT: return "OpenShiftDeployList";
			case DEPLOY_TYPE_ID.KUBERNETES : return "KubernetesDeployList";
			case DEPLOY_TYPE_ID.BM: return "BMDeployList";
		}
	},
	getDeployNewComponentName(deployTypeId){
		switch(deployTypeId){
			case DEPLOY_TYPE_ID.DOCKER : return "DockerDeployEdit";
			case DEPLOY_TYPE_ID.AKS : return "AKSDeployEdit";
			case DEPLOY_TYPE_ID.OPEN_SHIFT : return "OpenShiftDeployEdit";
			case DEPLOY_TYPE_ID.KUBERNETES : return "KubernetesDeployEdit";
			case DEPLOY_TYPE_ID.BM: return "BMDeployEdit";
		}
	},


	getDeployEditComponentNameWithTypeName(deployTypeName){
		switch(deployTypeName){
			case DEPLOY_TYPE_NAME.DOCKER : return "DockerDeployEdit";
			case DEPLOY_TYPE_NAME.AKS : return "AKSDeployEdit";
			case DEPLOY_TYPE_NAME.OPEN_SHIFT : return "OpenShiftDeployEdit";
			case DEPLOY_TYPE_NAME.KUBERNETES : return "KubernetesDeployEdit";
			case DEPLOY_TYPE_NAME.BM: return "BMDeployEdit";
		}
	},
	
}