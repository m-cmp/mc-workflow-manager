import KubernetesManager from "./KubernetesManager";

export default class DeployManagerFactory {
	static create(deployTypeId, deployState, rootState, rootGetters) {
		let deployManager = null;
		
		deployManager = new KubernetesManager(deployState, rootState, rootGetters);

		return deployManager;
	}
}
