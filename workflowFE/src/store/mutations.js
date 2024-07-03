export const APP_INIT_COMPLETED = "appInitCompleted";
export const SET_ADMIN_INITIALIZE = "setAdminInitialize";

export default {
    [APP_INIT_COMPLETED]: (state,completed) => {
        state.init = completed;
    },

    [SET_ADMIN_INITIALIZE]: (state, value) => {

        state.adminInitialize = value;
    }
};
