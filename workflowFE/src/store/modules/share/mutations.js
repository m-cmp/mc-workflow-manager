export const SET_GROUP_INFO = 'setGroupInfo'
export const SET_SERVICE_INFO = 'setServiceInfo'
export const SET_PROJECT_INFO = 'setProjectInfo'
export const SET_DEPLOY_TYPE_INFO = 'setDeployTypeInfo'
export const SET_PAGE_LOADING_FLAG = 'setPageLoadingFlag'

export default {
    [SET_GROUP_INFO]: (state, groupInfo) => {
        state.groupInfo = groupInfo
    },
    [SET_SERVICE_INFO]: (state, serviceInfo) => {
        state.serviceInfo = serviceInfo
    },
    [SET_PROJECT_INFO]: (state, projectInfo) => {
        state.projectInfo = projectInfo
    },
    [SET_PAGE_LOADING_FLAG]: (state, flag) => {
        state.pageLoadingFlag = flag
    }
}
