import { getOssConnectionList } from "@/api/preference";

import * as connectionActions from "./type";
import * as mutations from "./mutations";
import { async } from "validate.js";
import { getCommonOssList } from "@/api/preference";
import { useToast } from "vue-toastification";


const toast = useToast();

export default {
    [connectionActions.LOAD_OSSCD_LIST]: async ({ commit })=> {
        let response = null;
        let ossList = [];

        try {
            response = await getCommonOssList();
            
            ossList = response.data;
            commit(mutations.SET_OSSCD_LIST, ossList)
        } catch(error) {
            ossList = [];
            console.log(error);
        }
    },
    [connectionActions.LOAD_CONNECTED_OSS_LIST]: async ({ commit }, param)=> {
        let response = null;
        let ossList = [];

        try {
            response = await getOssConnectionList(param);

            ossList = response.data;
            commit(mutations.SET_OSS_LIST, ossList);
        } catch(error) {
            ossList = [];
            console.log(error)
        }
    },
    [connectionActions.CLEAR_EDIT_DATA]: ({commit})=> {
        const editData = {
            // companyId: 0,
            ossCd: '',
            ossName: '',
            ossDesc: '',
            ossUrl: '',
            ossUsername: '',
            ossPassword: '',
            ossToken: '',
        }
        commit(mutations.SET_EDIT_DATA, editData)
    },

    /**
     * 이하 미사용 (type.js의 내용과 함께 삭제 예정)
    */
    [connectionActions.LOAD_SERVICEGROUP_OSS_LIST]: async ({ commit, dispatch, state }, companyId)=> {
        const param ={
            companyId: companyId
        };

        param.oss = 'gitlab';
        await dispatch(connectionActions.LOAD_SERVICEGROUP_GITLAB_LIST, param)
        
        param.oss = 'jenkins';
        await dispatch(connectionActions.LOAD_SERVICEGROUP_JENKINS_LIST, param)

        param.oss = 'nexus'
        await dispatch(connectionActions.LOAD_SERVICEGROUP_NEXUS_LIST, param)

        param.oss = 'container_registry'
        await dispatch(connectionActions.LOAD_SERVICEGROUP_CONTAINERREGISTRY_LIST, param)

        param.oss = 'sonarqube'
        await dispatch(connectionActions.LOAD_SERVICEGROUP_SONARQUBE_LIST, param)
    },
    [connectionActions.LOAD_SERVICEGROUP_GITLAB_LIST]: async ({ commit }, param)=> {
        let response = null;
        let gitlabList = null;
        
        try {
            response = await getOssConnectionList(param);
            
            for(let item of response.data) {
                if(param.companyId.toString() == item.companyId.toString()){
                    if(gitlabList == null)  gitlabList = []
                    gitlabList.push(item)
                }
            }
            if(gitlabList !== null) {
                commit(mutations.SET_GITLAB_LIST, gitlabList)
            }
            else {
                toast.error('GitLab 정보가 없습니다.\n툴체인 > Gitlab 정보를 입력하세요')
            }
        } 
        catch(error) {
            gitlabList = [];
            console.log(error);
        }
    },
    [connectionActions.LOAD_SERVICEGROUP_JENKINS_LIST]: async ({ commit }, param)=> {
        let response = null;
        let jenkinsList = null;
        
        try {
            response = await getOssConnectionList(param);

            
            for(let item of response.data) {
                if(param.companyId.toString() == item.companyId.toString()) {
                    if(jenkinsList == null) jenkinsList = []
                    jenkinsList.push(item)
                }
            }    
            if(jenkinsList !== null) {
                commit(mutations.SET_JENKINS_LIST, jenkinsList)
            }
            else {
                toast.error('Jenkins 정보가 없습니다.\n툴체인 > Jenkins 정보를 입력하세요')
            }
        } 
        catch(error) {
            jenkinsList = [];
            console.log(error);
        }
    },
    [connectionActions.LOAD_SERVICEGROUP_NEXUS_LIST]: async ({ commit }, param)=> {
        let response = null;
        let nexusList = null;
        
        try {
            response = await getOssConnectionList(param);
            
            for(let item of response.data) {
                if(param.companyId.toString() == item.companyId.toString()) {
                    if(nexusList == null) nexusList = []
                    nexusList.push(item)
                }
            }    
            if(nexusList !== null) {
                commit(mutations.SET_NEXUS_LIST, nexusList)
            }
            else {
                toast.error('Nexus 정보가 없습니다.\n툴체인 > Nexus 정보를 입력하세요')                
            }
            
        } 
        catch(error) {
            nexusList = [];
            console.log(error);
        }
    },
    [connectionActions.LOAD_SERVICEGROUP_CONTAINERREGISTRY_LIST]: async ({ commit }, param)=> {
        let response = null;
        let containerRegistryList = [];
        
        try {
            response = await getOssConnectionList(param);
            containerRegistryList = response.data;
            commit(mutations.SET_CONTAINERREGISTRY_LIST, containerRegistryList)
        } 
        catch(error) {
            containerRegistryList = [];
            console.log(error);
        }
    },
    [connectionActions.LOAD_SERVICEGROUP_SONARQUBE_LIST]: async ({ commit }, param)=> {
        let response = null;
        let sonarqubeList = [];
        
        try {
            response = await getOssConnectionList(param);
            sonarqubeList = response.data;
            commit(mutations.SET_SONARQUBE_LIST, sonarqubeList)
        } 
        catch(error) {
            sonarqubeList = [];
            console.log(error);
        }
    },
    [connectionActions.SET_EDIT_DATA]: ({commit}, editData)=> {
        commit(mutations.SET_EDIT_DATA, editData)
    }
};
