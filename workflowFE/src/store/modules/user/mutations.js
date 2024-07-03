export const SET_TOKEN = "setToken";
export const SET_NAME = "setName";
export const SET_USER_ID = "setUserId";
export const SET_AUTH_ID = "setAuthId";
export const SET_AUTH_NAME = "setAuthName";
export const SET_USER_NAME = "setUserName";
export const SET_PW_RESET = "setPwReset";
export const SET_TEMP_USER_INFO = "setTempUserInfo";


export default {
    [SET_TOKEN]: (state, token) => {
        state.token = token;
    },
    [SET_NAME]: (state, name) => {
        state.name = name;
    },
    [SET_USER_ID]: (state, userId) => {
        state.userId = userId;
    },
    [SET_AUTH_ID]: (state, authId) => {
        state.authId = authId;
    },
    [SET_AUTH_NAME]: (state, authName) => {
        state.authName = authName;
    },
    [SET_USER_NAME]: (state, userName) => {
        state.userName = userName;
    },
    
    [SET_PW_RESET]: (state, reset) => {
        state.pwReset = reset;
    },
    [SET_TEMP_USER_INFO]: (state, userInfo) => {
        state.tempUserInfo = userInfo;
    }
};
