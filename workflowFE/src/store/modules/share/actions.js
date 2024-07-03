import store from '@/store'
// import { getGroupInfo } from "@/api/group";
// import { getServiceInfo } from "@/api/service";
import { getProjectData } from "@/api/projects";

import * as groupActions from "./type";
import * as mutations from "./mutations";
import AUTHORITY_ID_LIST from "@/constant/authority";

export default {
    [groupActions.SET_PROJECT_INFO]: async ({ commit, state }, projectInfo) => {
        commit(mutations.SET_PROJECT_INFO, projectInfo);
        return true;
	},
    // [groupActions.INSERT_PROJECT_INFO]: async ({ commit, state }) => {
    //     const projectInfo = {
    //         "projectId": 10,
    //         "projectName": "test2",
    //         "gitlabCloneHttpUrl": "http://210.217.178.130:8101/devops-test/gradle-jar-app.git",
    //         "gitlab": {
    //             "url": "http://210.217.178.130:8101",
    //             "username": "root",
    //             "password": "IVEydzNlNHI1dA==",
    //             "groupName": "devops-test",
    //             "projectName": "gradle-jar-app",
    //             "branch": "master"
    //         },
    //         "regDate": "2023-07-21 14:13:53",
    //         "modDate": null
    //     }
    //     commit(mutations.SET_PROJECT_INFO, projectInfo);
    //     return true;
	// },

    













    [groupActions.CLEAR]: ({ commit })=>{
        commit(mutations.SET_GROUP_INFO, {
            name:""
        });
        commit(mutations.SET_SERVICE_INFO, {
            name:"",
            group: {
                name:""
            }
        });
        commit(mutations.SET_PROJECT_INFO, {
            name: "",
            group: {
                name:""
            },
            service: {
                name:""
            },
        });
    },
    [groupActions.CLEAR_GROUP_INFO]: async ({ commit }) => {
        commit(mutations.SET_GROUP_INFO, {
            name:""
        });
    },

    [groupActions.CLEAR_SERVICE_INFO]: async ({ commit }) => {
        commit(mutations.SET_SERVICE_INFO, {
            name: "",
            group: {
                name:""
            }
        });
    },

    [groupActions.CLEAR_PROJECT_INFO]: async ({ commit }) => {
        commit(mutations.SET_PROJECT_INFO, {
            name: "",
            group: {
                name:""
            },
            service: {
                name:""
            }
        });
    },


    [groupActions.LOAD_GROUP_INFO]: async ({ commit, state, dispatch, rootState }, payload) => {
        let { groupId, immediate } = payload;

        if (immediate != true) {
            if (state.groupInfo && state.groupInfo.groupId) {
                if (state.groupInfo.groupId == groupId) {
                    return true;
                }
            }
        }

        // try {

        //     console.log("21 신규 그룹 데이터로딩 시작 ")
        //     const response = await getGroupInfo(groupId);

        //     if (response.data == null)
        //         return false;

        //     commit(mutations.SET_GROUP_INFO, response.data);
        //     console.log("21 그룹 데이터로딩 완료 ")
        //     ////////////////////



        //     /////////////////////
        //     // SYSTEM_ADMIN은 그룹권한 체크 X
        //     console.log("22. 그룹권한 적용 테스트(AUTH_SYSTEM_ADMIN이 아닌경우 실행) ", rootState.user.authId);
        //     if (rootState.user.authId != AUTHORITY_ID_LIST.AUTH_SYSTEM_ADMIN) {
        //         console.log("23. 그룹권한 적용  데이터 읽기 시작 ");
        //         // 2020.03.20, ddan, 삭제하면 안됨.
        //         //그룹에 따른 권한정보 업데이트 처리
        //         let success = await store.dispatch("permission/updateGroupAuthority", {
        //             userId: rootState.user.userId,
        //             groupId: parseInt(groupId)
        //         })
        //         console.log("23. 그룹권한 적용  데이터 읽기 완료 ");
        //     }

        //     console.log("20 LOAD_GROUP_INFO end")
        //     return true;
        // } catch (error) {
        //     throw new Error(error);
        //     return false;
        // }
    },

    [groupActions.LOAD_SERVICE_INFO]: async ({ commit, state }, payload) => {
        let { serviceId, immediate } = payload;

        if (immediate != true) {
            if (state.serviceInfo && state.serviceInfo.serviceId) {
                if (state.serviceInfo.serviceId == serviceId) {
                    return true;
                }
            }
        }

        // try {
        //     const response = await getServiceInfo(serviceId);

        //     if (response.data == null)
        //         return false;

        //     commit(mutations.SET_SERVICE_INFO, response.data);

        //     return true;
        // } catch (error) {
        //     //throw new Error(error);
        //     return false;
        // }
    },


    [groupActions.LOAD_PROJECT_INFO]: async ({ commit, state }, payload) => {
        let { projectId } = payload;

        try {
           // console.log("temp10 신규 프로젝트 데이터로딩 시작 ")
            const response = await getProjectData(projectId);
            //console.log("temp10 프로젝트 데이터로딩 완료 ")

            if (response.data == null)
                return false;

            commit(mutations.SET_PROJECT_INFO, response.data);

            return true;
        } catch (error) {
            //throw new Error(error);
            return false;
        }
	},

	/*
		call : DeployNew.onSelectedSegmentItem()
	*/
	[groupActions.SET_DEPLOY_TYPE_INFO]: ({ commit }, params)=>{
		commit(mutations.SET_DEPLOY_TYPE_INFO, params);
	},


	[groupActions.SET_PAGE_LOADING_FLAG]: ({commit}, payload) => {
	    let { flag } = payload
	    commit(mutations.SET_PAGE_LOADING_FLAG, flag);
    }
};
