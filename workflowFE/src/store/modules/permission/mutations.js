import {baseRoutes} from "@/router/router/baseRoutes";
export const CLEAR = 'clear'
export const SET_AUTH_MENU = 'setAuthMenu'
export const SET_GENERAL_AUTH_MENU = 'setGeneralAuthMenu'
export const SET_GROUP_AUTH_MENU = 'setGroupAuthMenu'
export const SET_ROUTES = 'setRoutes'
export const SET_MAIN_MENU = 'setMainMenu'
export const SET_CURRENT_MAIN_MENU_NAME = 'setCurrentMainMenuName'

export default {
  [CLEAR]: (state) => {
    state.authMenu = []
    state.generalAuthMenu = []
    state.routes = []
    state.addRoutes = []
    state.mainMenu = {}
    state.currentMainMenuName = ''
    state.groupAuthMenu = []
  },
  // 실제 페이지에서 사용하는 권한 정보
  [SET_AUTH_MENU]: (state, authMenu) => {
    state.authMenu = authMenu
  },

  // autority 페이지의 authority등급에(projectmanger, developer 등등)에 적용된
  // 권한 정보
  [SET_GENERAL_AUTH_MENU]: (state, authMenu) => {
    state.generalAuthMenu = authMenu
  },

  // 그룹의 사용자 권한으로 적용된 권한 정보
  [SET_GROUP_AUTH_MENU]: (state, authMenu) => {
    state.groupAuthMenu = authMenu
  },

  [SET_ROUTES]: (state, routes) => {
    state.addRoutes = routes
    state.routes = baseRoutes.concat(routes)
  },

  [SET_MAIN_MENU]: (state, mainMenu) => {
    state.mainMenu = mainMenu
  },

  [SET_CURRENT_MAIN_MENU_NAME]: (state, mainMenuName) => {
    state.currentMainMenuName = mainMenuName
  }

}
