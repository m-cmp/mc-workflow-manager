export const SET_OSS_LIST = 'setOssList'
export const SET_GITLAB_LIST = 'setGitlabList'
export const SET_JENKINS_LIST = 'setJenkinsList'
export const SET_NEXUS_LIST = 'setNexusList'
export const SET_CONTAINERREGISTRY_LIST = 'setContainerRegistryList'
export const SET_SONARQUBE_LIST = 'setSonarqubeList'
export const SET_OSSCD_LIST = 'setOsscdList'
export const SET_EDIT_DATA = 'setEditData'

export default {
    [SET_OSS_LIST]: (state, ossList) => {
        state.ossList = ossList;
    },

    
    [SET_GITLAB_LIST]: (state, gitlabList) => {
        state.gitlabList = gitlabList;
    },
    [SET_JENKINS_LIST]: (state, jenkinsList) => {
        state.jenkinsList = jenkinsList;
    },
    [SET_NEXUS_LIST]: (state, nexusList) => {
        state.nexusList = nexusList;
    },
    [SET_CONTAINERREGISTRY_LIST]: (state, containerRegistryList) => {
        state.containerRegistryList = containerRegistryList;
    },
    [SET_SONARQUBE_LIST]: (state, sonarqubeList) => {
        state.sonarqubeList = sonarqubeList;
    },


    // 커넥션 화면
    [SET_OSSCD_LIST]: (state, ossCdList) => {
        state.ossCdList = ossCdList
    },

    // OSS 등록 / 수정
    [SET_EDIT_DATA]: (state, editData) => {
        state.editData = editData
    }
}
