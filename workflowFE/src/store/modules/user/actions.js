import store, { rootActions } from "@/store";
import * as userActions from "./type";
import * as mutations from "./mutations";

// import { getToken, setToken, removeToken } from "@/core/services/AuthToken";
// import { resetRouter } from "@/router";
import userHelper from "./userHelper";
import {Mutations} from "@/store/enums/StoreEnums";


export default {
    /*
        사용자와 관련 정보 모두 지우기
        call : 처음 app이 실행될때, logout 될때
    */
    [userActions.CLEAR]: ({ commit,dispatch }) => {
        /* 주의: 토큰 정보는 제외 */
        commit(mutations.SET_TOKEN, "");
        commit(mutations.SET_TEMP_USER_INFO, null);
        commit(mutations.SET_USER_ID, "");
        commit(mutations.SET_AUTH_ID, "");
        commit(mutations.SET_AUTH_NAME, "");
        commit(mutations.SET_USER_NAME, "");
        // 패스워드 초기화 유무
        commit(mutations.SET_PW_RESET, false);

        // 라우터 제거
        // BELSNAKE
        // resetRouter();
    },

    // 직접 removeToken()을 호춠하지 않고 action을 활용해 호출해야함.
    [userActions.CLEAR_TOKEN]: ({ commit, dispatch})=>{
        // removeToken();
    },

    [userActions.RESTORE_GENERAL_ROUTER_INFO]: async ({ commit, state, dispatch }) => {
        // console.log("RESTORE_GENERAL_ROUTER_INFO >> state @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ >>>>> ", state);

        // 사용자 auth 정보를 바탕으로 메뉴 재 생서하기
        await userHelper.createMenu(commit, state.authName);
    },


    /*
    clear 호출 후 logout 실행
    */
    [userActions.LOGOUT]: ({ commit, state, dispatch }) => {
        console.log("## logout in user");

        dispatch(userActions.CLEAR_TOKEN);
    },

    [userActions.UPDATE_USER_NAME]:({ commit }, newUserName)=>{
        commit(mutations.SET_USER_NAME, newUserName);
    },

    /*
        로그인이 성공한 경우(단, reset이 false인 경우에만)
        또는 패스워드까지 리셋을 성공한 경우 실행


        단계01: 쿠키에 토큰 저장
        단계02: 메뉴 및 라우터 생성
        단계03: 스토어에 사용자 핵심 정보 저장.

    */
    [userActions.UPDATE_USER_INFO]: async ({ commit, state, dispatch })=>{
        // tempUserInfo는 로그인 시 스토어에 저장됨.
        const userInfo = state.tempUserInfo;


        // 단계01: 쿠키에 토큰 저장
        /*
        토큰 설정(cookie)) 이 값은 rest api 호출 시 header 값으로 사용됨.
        주의:
            다른 api 호출 부터는 http header에 user_id가 설정되어ㅑ 하기 때문에
            setToken을 통해 값을 저장해야함.
        */
        // setToken(userInfo.token);


        // 단계02: 메뉴 및 라우터 생성
        /*
        1. 권한에 따른 메뉴 접근 정보 생성하기
        2. 권한에 따른 메뉴 항목 생성(data/menu.js를 기본으로)
        3. 권한에 따른 라우터 정보 생성하기
        4. 라우터  설정하기
        */
        // console.log("UPDATE_USER_INFO >> userInfo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ >>>>> ", userInfo);
        await userHelper.createMenu(commit, userInfo.authName);

        // 단계03: 스토어에 데이터 저장
        dispatch(userActions.SAVE_USER_POINT_INFO, userInfo);

    },


    // 사용자 정보중 어플에서 사용하는 정보를 저장
    [userActions.SAVE_USER_POINT_INFO]: ({ commit}, userInfo) => {

        console.log("userInfo ************************************************* >>>>> ", userInfo);
        // 단계03: 스토어에 토큰 저장
        commit(mutations.SET_TOKEN, userInfo.token);
        commit(mutations.SET_USER_ID, userInfo.userId);
        commit(mutations.SET_AUTH_ID, userInfo.authId);
        commit(mutations.SET_AUTH_NAME, userInfo.authName);
        commit(mutations.SET_USER_NAME, userInfo.name);
        // 패스워드 초기화 유무
        commit(mutations.SET_PW_RESET, userInfo.reset);
        return true;
    },

    /*
        사용자 패스워드가 초기화 되지 않은 경우
        패스워드 초기화 완료 후 사용자 정보를 저장하기 위해
        임시적으로 사용자 정보를 저장함.
    */
    [userActions.SET_TEMP_USER_INFO]: async ({ commit, state }, userInfo) => {
        commit(mutations.SET_TEMP_USER_INFO, userInfo);
    }
};
