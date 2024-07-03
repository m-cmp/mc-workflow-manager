enum Actions {
  // action types
  ADD_BODY_CLASSNAME = "addBodyClassName",
  REMOVE_BODY_CLASSNAME = "removeBodyClassName",
  ADD_BODY_ATTRIBUTE = "addBodyAttribute",
  REMOVE_BODY_ATTRIBUTE = "removeBodyAttribute",
  ADD_CLASSNAME = "addClassName",
  VERIFY_AUTH = "verifyAuth",
  LOGIN = "login",
  LOGOUT = "logout",
  REGISTER = "register",
  UPDATE_USER = "updateUser",
  FORGOT_PASSWORD = "forgotPassword",
  SET_BREADCRUMB_ACTION = "setBreadcrumbAction",
  NEW_USERS = "newUsers",
  SET_ASIDE_CONFIG = "setAsideConfig",

  // action types
  ADD_BODY_CLASSNAME_ORIG = "addBodyClassNameOrig",
  REMOVE_BODY_CLASSNAME_ORIG = "removeBodyClassNameOrig",
  ADD_BODY_ATTRIBUTE_ORIG = "addBodyAttributeOrig",
  REMOVE_BODY_ATTRIBUTE_ORIG = "removeBodyAttributeOrig",
  ADD_CLASSNAME_ORIG = "addClassNameOrig",
  VERIFY_AUTH_ORIG = "verifyAuthOrig",
  LOGIN_ORIG = "loginOrig",
  LOGOUT_ORIG = "logoutOrig",
  REGISTER_ORIG = "registerOrig",
  UPDATE_USER_ORIG = "updateUserOrig",
  FORGOT_PASSWORD_ORIG = "forgotPasswordOrig",
  SET_BREADCRUMB_ACTION_ORIG = "setBreadcrumbActionOrig",
  NEW_USERS_ORIG = "newUsersOrig",
}

enum Mutations {
  // mutation types
  SET_CLASSNAME_BY_POSITION = "appendBreadcrumb",
  PURGE_AUTH = "logOut",
  SET_AUTH = "setAuth",
  SET_USER = "setUser",
  SET_PASSWORD = "setPassword",
  SET_ERROR = "setError",
  SET_BREADCRUMB_MUTATION = "setBreadcrumbMutation",
  SET_LAYOUT_CONFIG = "setLayoutConfig",
  SET_TEMP_USER_INFO = "setTempUserInfo",
  RESET_LAYOUT_CONFIG = "resetLayoutConfig",
  OVERRIDE_LAYOUT_CONFIG = "overrideLayoutConfig",
  OVERRIDE_PAGE_LAYOUT_CONFIG = "overridePageLayoutConfig",
  SET_NEW_USER = "setNewUser",

  SET_ASIDE_CONFIG_MINIMIZE = "setAsideConfigMinimize",
  SET_ASIDE_CONFIG_MINIMIZED = "setAsideConfigMinimized",
  SET_ASIDE_CONFIG_SECONDARY_DISPLAY = "setAsideConfigSecondaryDisplay",


  // mutation types
  SET_CLASSNAME_BY_POSITION_ORIG = "appendBreadcrumbOrig",
  PURGE_AUTH_ORIG = "logOutOrig",
  SET_AUTH_ORIG = "setAuthOrig",
  SET_USER_ORIG = "setUserOrig",
  SET_PASSWORD_ORIG = "setPasswordOrig",
  SET_ERROR_ORIG = "setErrorOrig",
  SET_BREADCRUMB_MUTATION_ORIG = "setBreadcrumbMutationOrig",
  SET_LAYOUT_CONFIG_ORIG = "setLayoutConfigOrig",
  RESET_LAYOUT_CONFIG_ORIG = "resetLayoutConfigOrig",
  OVERRIDE_LAYOUT_CONFIG_ORIG = "overrideLayoutConfigOrig",
  OVERRIDE_PAGE_LAYOUT_CONFIG_ORIG = "overridePageLayoutConfigOrig",
  SET_NEW_USER_ORIG = "setNewUserOrig",
}

export { Actions, Mutations };
