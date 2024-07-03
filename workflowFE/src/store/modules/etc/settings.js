import Vue from "vue";
import defaultSettings from "@/settings";

const { fixedHeader, sidebarLogo, version, logo, title } = defaultSettings;

const state = {
    titie:title,
    version:version,
    fixedHeader: fixedHeader,
    sidebarLogo: sidebarLogo,
    initConfig:false,
    adminInitialize: false,
    logo: {
        normal: logo.normal,
        small:logo.small
    },
    config: {}
};

const mutations = {
    CHANGE_SETTING: (state, { key, value }) => {
        if (state.hasOwnProperty(key)) {
            state[key] = value;
        }
    },
    SET_INIT: (state, value) => {
        state.init = value;
    },
    SET_CONFIG: (state, value) => {
        state.config = value;
    },
    SET_INIT_CONFIG: (state, value) => {
        state.initConfig = value;
    },

};

const actions = {
    changeSetting({ commit }, data) {
        commit("CHANGE_SETTING", data);
    }

};

export default {
    namespaced: true,
    state,
    mutations,
    actions
};
