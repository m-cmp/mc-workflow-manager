import { createStore } from "vuex";
import { config } from "vuex-module-decorators";

import BodyModule from "@/store/modules/BodyModule";
import BreadcrumbsModule from "@/store/modules/BreadcrumbsModule";
import ConfigModule from "@/store/modules/ConfigModule";

// import UserModule from "@/store/modules/UserModule";

import errorLog from "./modules/etc/errorLog";
import app from "./modules/app";
import permission from "./modules/permission";
import settings from "./modules/etc/settings";
import share from "./modules/share";
import user from "./modules/user";

import connection from "./modules/connection";
import clusterConfig from "./modules/clusterConfig";
import deploy from "./modules/deploy";

import * as actionTypes from "./type.js";
import actions from "./actions";
import mutations from "./mutations";
import getters from './getters';


config.rawError = true;
const state = {
    init: false,
    adminInitialize:false
};

const store = createStore({
    modules: {
        // UserModule,
        BodyModule,
        BreadcrumbsModule,
        ConfigModule,

        share,
        app,
        errorLog,
        permission,
        settings,
        user,

        connection,
        clusterConfig,
        deploy
    },

    state,
    mutations,
    getters,
    actions
});

export {actionTypes as rootActions};

export default store;
