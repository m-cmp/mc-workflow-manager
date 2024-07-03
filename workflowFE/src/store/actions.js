import * as actions from "./type";
import * as mutations from "./mutations";
import { appActions } from "@/store/modules/app";
import { permissionActions } from "@/store/modules/permission";
import { shareActions } from "@/store/modules/share";

export default {
    // 모든 스토어 데이터 초기화, 데이터 + 토큰까지 초기화
    [actions.CLEAR_ALL_APPLICATION]: ({ commit, dispatch }) => {
        console.log("CLEAR_ALL_APPLICATION ")
        dispatch(actions.CLEAR_APPLICATION);
        // dispatch(userActions.G_LOGOUT);
    },
    [actions.CLEAR_APPLICATION]: ({ commit, dispatch }) => {
        console.log("CLEAR_APPLICATION ")
        // 어플리케이션 초기화
        commit(mutations.APP_INIT_COMPLETED, false);
        // app 초기화
        dispatch(appActions.G_CLEAR);
        // 사용자 정보 초기화
        // dispatch(userActions.G_CLEAR);
        // 인증관뤈 정보 초기화
        dispatch(permissionActions.G_CLEAR);
        // 인증관뤈 정보 초기화
        dispatch(shareActions.G_CLEAR);
    },


    /*
        어플 초기화 완료 유무
        true여야만 기능을 사용할 수 있음.
    */
    [actions.SET_APP_INIT_COMPLETED]: ({ commit }, completed = true) => {
        commit(mutations.APP_INIT_COMPLETED, completed);
    },

    [actions.LOGOUT]: ({ commit, dispatch }) => {
        dispatch(actions.CLEAR_APPLICATION);
    },
};

