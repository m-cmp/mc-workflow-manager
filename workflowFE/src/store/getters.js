const getters = {

    initConfig: state => state.settings.initConfig,
    adminInitialize:state=>state.adminInitialize,
    appInitCompleted: state => state.init,
    sidebar: state => state.app.sidebar,
    size: state => state.app.size,
    device: state => state.app.device,
    userId: state => state.user.userId,
    userPwReset:state=>state.user.pwReset,
    token: state => state.user.token,
    userName: state => state.user.userName,
    permission_routes: state => state.permission.routes,
    mainMenuList:state=>state.permission.mainMenu,
    errorLog: state => state.errorLog,
	theme: state => state.settings.theme,
	version:state=>state.settings.version,
    homeTitle: state => state.settings.title,
    mainThemeColor: state => state.settings.theme,
    logo:state=>state.settings.logo,
    currentMainMenuName: state => state.permission.currentMainMenuName,
	// authMenu: state => state.permission.authMenu,
	projectId: state => state.share.projectInfo.projectId,
	// groupId:state=>state.share.groupInfo.groupId,
    // serviceId:state=>state.share.serviceInfo.subgroupId, //DB에서 가져오는 값(subgroupId)과 화면에서 사용하는 값(serviceId)이 다름
    isPageLoading:state=>state.share.pageLoadingFlag,
};
export default getters;
