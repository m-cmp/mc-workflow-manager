export const GROUP_ID = "groupId";
export const SERVICE_ID = "serviceId";
export const PROJECT_ID = "projectId";
export const PAGE_LOADING_FLAG = "pageLoadingFlag";

export default {
    [GROUP_ID]: (state) => {
        if (state.groupInfo)
            return state.groupInfo.groupId;
        else
            return -1;
	},
	[SERVICE_ID]: (state) => {
		if (state.serviceInfo)
			return state.serviceInfo.serviceId;
		else
			return -1;
	},
	[PROJECT_ID]: (state) => {
		if (state.projectInfo)
			return state.projectInfo.projectId;
		else
			return -1;
	},
	[PAGE_LOADING_FLAG]: (state) => {
    	return state.pageLoadingFlag;
	}
}
