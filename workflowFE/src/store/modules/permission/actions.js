import { asyncRoutes } from "@/router";
import { getAuth } from "@/api/util";
import authorityMappingInfo from "@/data/authority_mapping_data";
import mainMenuInfo from "@/data/menu";
import { AUTHORITY_NAMES } from "@/constant/authority";
// import { getGroupAuthority } from "@/api/group";
import router from "@/router";
import lodash from "lodash";

import * as permissionActions from "./type";
import * as mutations from "./mutations";

/**
 * Use meta.role to determine if the current user has permission
 * @param roles
 * @param route
 */
function hasPermission(roles, route) {
    if (route.meta && route.meta.roles) {
        return roles.some(role => route.meta.roles.includes(role));
    } else {
        return true;
    }
}

/**
 * Filter asynchronous routing tables by recursion
 * @param routes asyncRoutes
 * @param roles
 */
export function filterAsyncRoutes(routes, roles) {
    const res = [];

    routes.forEach(route => {
        const tmp = { ...route };
        if (hasPermission(roles, tmp)) {
            if (tmp.children) {
                tmp.children = filterAsyncRoutes(tmp.children, roles);
            }
            res.push(tmp);
        }
    });

    return res;
}

function removeRoute(router, enable, name) {
    if (enable == false) {
        return;
    }

    const index = router.children.findIndex(item => {
        return index.name == name;
    });
    if (index != -1) {
        router.children.splice(index, 1);
    }
}

function filterRoutes(routerModule, authMenuInfo) {
    routerModule.children = routerModule.children.filter(route => {
        // 존재하지 않는 경우, 포함 대상
        if (authMenuInfo.hasOwnProperty(route.name) == false) {
            return true;
        }
        return authMenuInfo[route.name];
    });
}
/*

*/
function filterMainMenuItems(menuList, authMenuInfo) {
    return menuList.filter(menuItem => {

        // 자식 항목 체크 하기
        let isChildren = false;
        if (menuItem.children) {
            isChildren = true;
            menuItem.children = filterMainMenuItems(
                menuItem.children,
                authMenuInfo
            );
        }
        // 자식 메뉴가 있는 메뉴 중 권한처리에 의해 자식 메뉴가 모두 사라지는 경우
        // 부모 메뉴도 제거해야함.
        if (isChildren && menuItem.children.length == 0) {
            return false;
        }

        // BELSNAKE
        // // 존재하지 않는 경우, 포함 대상
        // if (authMenuInfo.hasOwnProperty(menuItem.name) == false) {
        //     return true;
        // }
        //
        // // 권한 검사 없이 항상 출력 되는 메뉴인가?
        // if (menuItem.meta.noAuthority == true) {
        //     return true;
        // }
        return authMenuInfo[menuItem.name];
    });
}

export default {
    [permissionActions.CLEAR]: ({ commit, dispatch }) => {
        commit(mutations.CLEAR);
    },
    /*
        사용자 권한에 따른 메뉴 목록 생성하기

        @userAuthName : 사용자 authority

    */
    [permissionActions.GENERATE_GENERAL_AUTH_MENU]: async (
        { commit },
        userAuthName
    ) => {
        try {
            console.log(
                "\t\t############### PERMISSION 01 generateGeneralAuthMenu 시작, 사용자 auth = ",
                userAuthName
            );
            let authItem = null;
            console.log("\t\t PERMISSION 01-01 그룹 권한정보 구하기 시작 ");
            const authResponse = await getAuth();
            // console.log("@@@@@@@@@@@@@@@@@@@@@ authResponse = ", authResponse);

            /*
            @authorityMappingInfoList =
                '1': { 'name': 'group_list', 'value': false },
                '2': { 'name': 'group_create', 'value': false },
                '3': { 'name': 'group_update', 'value': false },
            */
            const authorityMappingInfoList = lodash.cloneDeep(
                authorityMappingInfo.list
            );
            console.log("\t\t PERMISSION 01-01 그룹 권한정보 구하기 완료");

            // 1. 사용자 권한에 맞는 권한 그룹 선택
            authItem = authResponse.data.find(item => {
                return item.name == userAuthName;
            });
            console.log("authItem ==========> ", authItem);

            // 2. 코드에 해당하는 메뉴에 접근 권한 주기
            authItem.authCodes.forEach(code => {
                try {
                    authorityMappingInfoList[code.toString()].value = true;
                } catch (error) {
                    console.log("\t\t 제공하지 않는 auth code", code);
                }
            });
            console.log("authorityMappingInfoList ==========> ", authorityMappingInfoList);

            // 3. 코드를 속성으로 변경
            const authMenu = {};
            for (const [key, item] of Object.entries(
                authorityMappingInfoList
            )) {
                const name = item.name;
                authMenu[name] = item.value;
            }
            console.log("authMenu ==========> ", authMenu);


            /*
                코드가 현재 존재하지 않아 대신 기존 코드를 대신해서 사용하는 경우
            */
            const tempMappingInfoList = lodash.cloneDeep(
                authorityMappingInfo.temp_mapping_list
            );
            tempMappingInfoList.forEach(info => {
                info.source.forEach(name => {
                    authMenu[name] = authMenu[info.target];
                });
            });

            ///////////////////////////////
            /*
                기본 권한 설정 (아직 권한 설정 항목이 존재하지 않음)
                그룹 권한과 시스템 어드민 만 가능
            */
            if (
                userAuthName == AUTHORITY_NAMES.AUTH_GROUP_OWNER ||
                userAuthName == AUTHORITY_NAMES.AUTH_SYSTEM_ADMIN
            ) {
                authMenu.group_member_list = true;
                authMenu.group_member_create = true;
            }

            // 개발자가 아닌 경우 프로젝트 멤버 관리 기능 가능.
            if (userAuthName != AUTHORITY_NAMES.AUTH_DEVELOPER) {
                authMenu.project_member_list = true;
                authMenu.project_member_create = true;
            } else {
                authMenu.project_member_list = false;
                authMenu.project_member_create = false;
            }
            ///////////////////////////////



            // 일반 권한 정보와 페이지에서 사용하는 권한 정보로 저장
            commit(mutations.SET_GENERAL_AUTH_MENU, authMenu);
            // authMenu 정보는 추후 그룹권한 정보와 조합되어  변경됨.
            commit(mutations.SET_AUTH_MENU, authMenu);

            console.log("\t\t############### PERMISSION 01 generateGeneralAuthMenu 완료 ", authMenu);
            return authMenu;
        } catch (error) {
            console.log("error ", error);
        }
    },
    /*
        권한에 따른 라우터 정보 생성하기
    */
    [permissionActions.GENERATE_ROUTES]: ({ commit, state }) => {
        console.log("PERMISSION 02 generateRoutes 시작 ");
        const authMenuInfo = state.authMenu;

        /* 주의 사항
            asyncRotues 내용은 기본(원본) 내용이기 때문에
            복사해서 사용해야함.
        */

        const filterAsyncRoutes = lodash.cloneDeep(asyncRoutes);
        return new Promise(resolve => {
            // // config 설정
            filterRoutes(filterAsyncRoutes.configurationRouter, authMenuInfo);
            filterRoutes(filterAsyncRoutes.groupRouter, authMenuInfo);
            filterRoutes(filterAsyncRoutes.serviceRouter, authMenuInfo);
            filterRoutes(filterAsyncRoutes.projectRouter, authMenuInfo);

            // 배열로 변경
            const accessedRoutes = [
                filterAsyncRoutes.configurationRouter,
                filterAsyncRoutes.groupRouter,
                filterAsyncRoutes.serviceRouter,
                filterAsyncRoutes.projectRouter,
                filterAsyncRoutes.default
            ];

            commit(mutations.SET_ROUTES, accessedRoutes);

            console.log("PERMISSION 02 generateRoutes 완료 ");
            resolve(accessedRoutes);
        });
    },

    [permissionActions.GENERATE_MAIN_MENU]: ({ commit, state }) => {
        console.log("PERMISSION 03 generateMainMenu 시작 ");
        const authMenuInfo = state.authMenu;
        const tempMainMenuInfo = lodash.cloneDeep(mainMenuInfo);

        const tempMainMenu = {
            configurations: [],
            group: [],
            service: [],
            project: []
        };

        tempMainMenu.configurations = filterMainMenuItems(
            tempMainMenuInfo.configurations,
            authMenuInfo
        );
        tempMainMenu.group = filterMainMenuItems(
            tempMainMenuInfo.group,
            authMenuInfo
        );
        tempMainMenu.service = filterMainMenuItems(
            tempMainMenuInfo.service,
            authMenuInfo
        );
        tempMainMenu.project = filterMainMenuItems(
            tempMainMenuInfo.project,
            authMenuInfo
        );

        console.log("PERMISSION 03 generateMainMenu 준비 ");
        commit(mutations.SET_MAIN_MENU, tempMainMenu);
        console.log("PERMISSION 03 generateMainMenu 완료 ");
        return true;
    },

    [permissionActions.SET_CURRENT_MAIN_MENU_NAME]: (
        { commit },
        mainMenuName
    ) => {
        commit(mutations.SET_CURRENT_MAIN_MENU_NAME, mainMenuName);
    },
    // ////////////////////////////////////////////////////////

    // ////////////////////////////////////////////////////////

    /*
        그룹권한 적용하기
            1. 서버에서 그룹 권한 구하기
            2. 기본 그룹 정보(전역을 제외한 정보 global:false인 경우) + 서버에서 구한 정보를 통합해
               그룹 권한 정보 만들기

            3. 기본 권한 정보에 그룹 권한 정보를 반영하기

        payload = {
            groupId:00,
            userId:""
        }
    */

    [permissionActions.UPDATE_GROUP_AUTHORITY]: async (
        { commit, state, dispatch, rootState },
        payload
    ) => {
        console.log("\t step41 그룹 권한 정보 읽기 시작 ", payload);
        // 1. 서버에서 그룹 권한 구하기
        const groupMenuAuthority = await dispatch(
            "generateGroupAuthMenu",
            payload
        );
        if (groupMenuAuthority == null) {
            console.log("updateGroupAuthority 업데이트 정보가 존재하지 않음.");
            return false;
        }
        console.log("\t step41 그룹 권한 정보 읽기 완료 ", groupMenuAuthority);

        console.log("\t step42 그룹 권한 정보 업데이트 시작 ");
        // 2. authMenu 업데이트 처리
        const success = await dispatch("updateAuthMenu", groupMenuAuthority);

        console.log("\t step42 그룹 권한 정보 업데이트 완료 ", success);
        if (success == false) {
            return false;
        }

        // 3. 변경된 접근 권한에 따른 라우터 생성
        console.log("\t step51 permission/generateRoutes 실행 시작");
        const accessRoutes = await dispatch("generateRoutes");
        console.log("\t step51 permission/generateRoutes 실행 완료");

        // 4. 메뉴 생성
        console.log("\t step52 permission/generateMainMenu 실행 시작");
        const mainMenu = await dispatch("generateMainMenu");
        console.log("\t step52 permission/generateMainMenu 실행 완료");

        // 5. 라우터 리셋 (constantRoutes만이 담겨 있는 라우터 생성)
        // BELSNAKE
        // resetRouter();

        console.log("\t step53 라우터 초기화 완료. : ", accessRoutes);
        // 6. 신규 라우터 적용.
        // BELSNAKE
        // router.addRoutes(accessRoutes);
        console.log("\t step54 라우터 신규 적용  완료.");

        // 3. 접근 권한 라우터 생성
        // ///////////////////////////////////////////////////////

        // 3. 기본 권한 정보에 그룹 권한 정보를 반영하기
        return true;
    },

    /*
        그룹에 속한 사용자 권한 구하기
        payload = {
            groupId:00,
            userId:""
        }
    */
    [permissionActions.GENERATE_GROUP_AUTH_MENU]: async (
        { commit, state, dispatch, rootState },
        payload
    ) => {
        // try {
        //     const authItem = null;
        //     console.log("PERMISSION 11-01 generateGroupAuthMenu 실행 시작", payload);

        //     // const response = await getGroupAuthority(payload);

        //     if (!response.data) {
        //         return null;
        //     }

        //     if (!response.data.authCodes) {
        //         return null;
        //     }

        //     const authCodes = response.data.authCodes;

        //     /*
        //      @authorityMappingInfoList =
        //         '1': { 'name': 'group_list', 'value': false },
        //         '2': { 'name': 'group_create', 'value': false },
        //         '3': { 'name': 'group_update', 'value': false },
        //     */

        //     const authorityMappingInfoList = lodash.cloneDeep(
        //         authorityMappingInfo.list
        //     );
        //     console.log(
        //         "PERMISSION 11-01 getGroupAuthority 실행 완료",
        //         authCodes
        //     );

        //     // 2. 코드에 해당하는 메뉴에 접근 권한 주기
        //     authCodes.forEach(code => {
        //         try {
        //             authorityMappingInfoList[code.toString()].value = true;
        //         } catch (error) {
        //             console.log("권한 코드 없음(error 아님) ", code);
        //         }
        //     });




        //     // 3. 코드를 속성으로 변경
        //     const authMenu = {};
        //     for (const [key, item] of Object.entries(
        //         authorityMappingInfoList
        //     )) {
        //         // 전역 정보는 제외 시키기
        //         if (item.global == false) {
        //             const name = item.name;
        //             authMenu[name] = item.value;
        //         }
        //     }



        //     ///////////////////////////////
        //     /*
        //         그룹 권한에 따른 메뉴 권한 만들기.
        //     */
        //     let groupUserAuthName = response.data.name;

        //     if (
        //         groupUserAuthName == AUTHORITY_NAMES.AUTH_GROUP_OWNER ||
        //         groupUserAuthName == AUTHORITY_NAMES.AUTH_SYSTEM_ADMIN
        //     ) {
        //         authMenu.group_member_list = true;
        //         authMenu.group_member_create = true;
        //     }

        //     // 개발자가 아닌 경우 프로젝트 멤버 관리 기능 가능.
        //     if (groupUserAuthName != AUTHORITY_NAMES.AUTH_DEVELOPER) {
        //         authMenu.project_member_list = true;
        //         authMenu.project_member_create = true;
        //     } else {
        //         authMenu.project_member_list = false;
        //         authMenu.project_member_create = false;

        //     }
        // ///////////////////////////////





        //     // 스토어에 정보 저장하기
        //     commit(mutations.SET_GROUP_AUTH_MENU, authMenu);

        //     console.log("PERMISSION 11 generateGroupAuthMenu 완료 ");
        //     return authMenu;
        // } catch (error) {
        //     console.log("ERROR-0--- ", error);
        //     return null;
        // }
    },

    [permissionActions.UPDATE_AUTH_MENU]: (
        { commit, state, dispatch, rootState },
        groupMenuAuthority
    ) => {
        console.log("PERMISSION updateAuthMenu 시작 ");

        if (groupMenuAuthority == null) {
            return false;
        }

        if (state.generalAuthMenu == null) {
            return false;
        }

        // 1. 시작시 사용자 auth에 부여된 권한 정보 복사
        const newAuthMenu = lodash.cloneDeep(state.generalAuthMenu);
        if (newAuthMenu == null) {
            return false;
        }

        // 2. general auth 정보에 그룹권한 정보(groupMenuAuthority) 적용
        for (const [key, value] of Object.entries(groupMenuAuthority)) {
            try {
                newAuthMenu[key] = value;
            } catch (error) {
                console.log("권한 없는 메뉴 ", key);
            }
        }

        // 3. 메뉴에 적용
        commit(mutations.SET_AUTH_MENU, newAuthMenu);
        console.log("PERMISSION updateAuthMenu 완료 ", newAuthMenu);
        return true;
    }
};
