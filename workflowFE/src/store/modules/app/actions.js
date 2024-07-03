import * as appActions from "./type";
import * as mutations from "./mutations";


export default {
    // 로그아웃 또는 페이지 refresh하는 경우 호출
    [appActions.CLEAR]: ({ commit,dispatch }) => {
        
    },

    [appActions.TOGGLE_SIDE_BAR]:({ commit })=>{
        commit(mutations.TOGGLE_SIDEBAR);
    },
    [appActions.CLOSE_SIDE_BAR]:({ commit }, { withoutAnimation })=>{
        commit(mutations.CLOSE_SIDEBAR, withoutAnimation);
    },
    [appActions.TOGGLE_DEVICE]:({ commit }, device)=>{
        commit(mutations.TOGGLE_DEVICE, device);
    },
    [appActions.SET_SIZE]:({ commit }, size)=>{
        commit(mutations.SET_SIZE, size);
    }
};