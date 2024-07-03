export  const BUILD_NETWORK_TYPE = Object.freeze({
    HOST: 0,
    PORT: 1
    
})


export const DEPLOY_INFO = {
	"DOCKER": {
		INFO_COMPONENT: "DockerInfoComponent",
		INFO_PROPERTIES_PANEL: "DeployServerPropertiesPanel",
		RUN_DEPLOY_MODAL:"DockerRunDeployModal"
	},
	"AKS": {
		INFO_COMPONENT: "AKSItemInfoComponent",
		INFO_PROPERTIES_PANEL:"AKSDeployServerPropertiesPanel",
		RUN_DEPLOY_MODAL:"AKSRunDeployModal"
	},
	"OPEN_SHIFT": {
		INFO_COMPONENT: "OpenShiftInfoComponent",
		INFO_PROPERTIES_PANEL:"OpenShiftDeployServerPropertiesPanel",
		RUN_DEPLOY_MODAL:"OpenShiftRunDeployModal"
	},

	"KUBERNETES": {
		INFO_COMPONENT: "KubernetesInfoComponent",
		INFO_PROPERTIES_PANEL:"KubernetesDeployServerPropertiesPanel",
		RUN_DEPLOY_MODAL:"KubernetesRunDeployModal"
	},
	"BM": {
		INFO_COMPONENT: "BMInfoComponent",
		INFO_PROPERTIES_PANEL: "BMDeployServerPropertiesPanel",
		RUN_DEPLOY_MODAL:"BMRunDeployModal"
	},
}

export const DeployStageTypeInfo = Object.freeze({
	dev: {
		label: "DEV",
		stageId:3
	},
	stg: {
		label: "STG",
		stageId:1
	},
	prod: {
		label: "PRD",
		stageId:2
	}
})

/*
	deploy 코드 이름.
*/
export  const DEPLOY_TYPE_ID = Object.freeze({
	DOCKER: 1,
	KUBERNETES:2,
	AKS: 3, 
	OPEN_SHIFT: 4,
	BM: 5
})

export  const DEPLOY_TYPE_NAME = Object.freeze({
	DOCKER: "docker",
	KUBERNETES:"kubernetes",
	AKS: "aks",
	OPEN_SHIFT: "openshift",
	BM : "bm"
})

export const DeployTypeInfo = Object.freeze({
	docker: {
		label: "Docker",
		typeName:DEPLOY_TYPE_NAME.DOCKER,
		typeId:DEPLOY_TYPE_ID.DOCKER
	},kubernetes: {
		label: "Kubernetes",
		typeName:DEPLOY_TYPE_NAME.KUBERNETES,
		typeId:DEPLOY_TYPE_ID.KUBERNETES
	},aks: {
		label: "AKS",
		typeName:DEPLOY_TYPE_NAME.AKS,
		typeId:DEPLOY_TYPE_ID.AKS
	},openShfit: {
		label: "OpenShift",
		typeName:DEPLOY_TYPE_NAME.OPEN_SHIFT,
		typeId:DEPLOY_TYPE_ID.OPEN_SHIFT
	},bm: {
		label: "BM",
		typeName:DEPLOY_TYPE_NAME.BM,
		typeId:DEPLOY_TYPE_ID.BM
	}
})

export const DEPLOY_CONTROLLER_TYPE = Object.freeze({
	DEPLOYMENT: "Deployment",
	DAEMON_SET: "DaemonSet",
	STATEFUL_SET: "StatefulSet",
	CRONJOB: "CronJob",
	
})

export const DEFAULT_SERVICE_TYPE = "ClusterIP";
export const DEFAULT_STRATEGY_TYPE = "RollingUpdate";


export const DeployEvent = {
	DATA_LOAD_COMPLETED:"dataLoadCompleted"
}

export const ACR_DEFAULT_DOMAIN = "azurecr.io"





export const DEPLOY_APPROVE_INFO = {
  AKS: 'aksDeploy',
  Kubernetes: 'k8sDeploy',
  OpenShift: 'okdDeploy',
  Docker: 'deploy',
  BM: 'bmDeploy'
}

