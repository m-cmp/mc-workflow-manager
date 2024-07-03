const state = {
    title: "",
    messageNo:-1,
    message: "",
    isError:false
};

const mutations = {
    SET_ERROR_MESSAGE: (state, messageInfo) => {
        state.title = messageInfo.title;
        state.messageId = messageInfo.messageId;
        state.message = messageInfo.message;
        state.isError = true;
    },

    CLEAR_ERROR_MESSAGE: state => {
        state.title = "";
        state.messageId = -1;
        state.message = "";

        state.isError=false
    }
};

const actions = {
    setErrorMessage({ commit }, messageInfo) {
        commit("SET_ERROR_MESSAGE", messageInfo);
    },
    clearErrorLog({ commit }) {
        commit("CLEAR_ERROR_MESSAGE");
    }
};

export default {
    namespaced: true,
    state,
    mutations,
    actions
};
