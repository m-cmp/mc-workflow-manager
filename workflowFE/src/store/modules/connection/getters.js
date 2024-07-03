export const OSS_LIST = "ossList";

export default {
	[OSS_LIST]: (state) => {
		if(state.ossLIst)
			return state.ossList
		else
			return -1;
	}
}
