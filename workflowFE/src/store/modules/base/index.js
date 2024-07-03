import getters from '../../getters';
import actions from "../../actions";
import mutations from "../../mutations";
import {config} from "vuex-module-decorators";

config.rawError = true;
const state = {
    init: false,
    adminInitialize:false
};

export default {
    state,
    mutations,
    getters,
    actions
};
