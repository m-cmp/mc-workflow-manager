import objectPath from "object-path";
import merge from "deepmerge";
import layoutConfig from "@/core/config/DefaultLayoutConfig";
import {Actions, Mutations} from "@/store/enums/StoreEnums";
import {Mutation, Module, VuexModule, Action} from "vuex-module-decorators";
import LayoutConfigTypes from "@/core/config/LayoutConfigTypes";

interface StoreInfo {
  config: LayoutConfigTypes;
  initial: LayoutConfigTypes;
}

@Module
export default class ConfigModule extends VuexModule implements StoreInfo {
  config = layoutConfig;
  initial = layoutConfig;

  /**
   * Get config from layout config
   * @returns {function(path, defaultValue): *}
   */
  get layoutConfig() {
    return (path, defaultValue) => {
      return objectPath.get(this.config, path, defaultValue);
    };
  }

  @Mutation
  [Mutations.SET_LAYOUT_CONFIG](payload): void {
    this.config = payload;
  }

  @Mutation
  [Mutations.RESET_LAYOUT_CONFIG]() {
    this.config = Object.assign({}, this.initial);
  }

  @Mutation
  [Mutations.OVERRIDE_LAYOUT_CONFIG](): void {
    this.config = this.initial = Object.assign(
      {},
      this.initial,
      JSON.parse(window.localStorage.getItem("config") || "{}")
    );
  }

  @Mutation
  [Mutations.OVERRIDE_PAGE_LAYOUT_CONFIG](payload): void {
    this.config = merge(this.config, payload);
  }

  @Mutation
  [Mutations.SET_ASIDE_CONFIG_MINIMIZE](flag): void {
    this.config.aside.minimize = flag;
  }

  @Mutation
  [Mutations.SET_ASIDE_CONFIG_MINIMIZED](flag): void {
    this.config.aside.minimized = flag;
  }

  @Mutation
  [Mutations.SET_ASIDE_CONFIG_SECONDARY_DISPLAY](flag): void {
    this.config.aside.secondaryDisplay = flag;
  }


  /* =================================================================================================================== */

  @Action
  [Actions.SET_ASIDE_CONFIG](payload) {
    const { config, value } = payload;

    if(config == Mutations.SET_ASIDE_CONFIG_MINIMIZE) this.context.commit(Mutations.SET_ASIDE_CONFIG_MINIMIZE, value);
    else if(config == Mutations.SET_ASIDE_CONFIG_MINIMIZED) this.context.commit(Mutations.SET_ASIDE_CONFIG_MINIMIZED, value);
    else if(config == Mutations.SET_ASIDE_CONFIG_SECONDARY_DISPLAY) this.context.commit(Mutations.SET_ASIDE_CONFIG_SECONDARY_DISPLAY, value);
  }
}
