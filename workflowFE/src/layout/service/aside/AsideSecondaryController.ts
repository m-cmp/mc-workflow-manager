import App, {getAsideSecondary, getAsideSecondaryMenu} from "@/main"
import {AsideButtonProp} from "@/components/base/menu/AsideButtonProp";
import {Actions, Mutations} from "@/store/enums/StoreEnums";
import store from "@/store";

class AsideSecondaryController {

    setMenu(title, menuList, params, setPermission, authMenu) {

        const jsonStr = JSON.stringify(menuList);
        const cloneMenus = JSON.parse(jsonStr);
        if(params != null) this.rebuildSecondaryMenus(cloneMenus, params);

        if(setPermission != null) setPermission(cloneMenus, authMenu);
        getAsideSecondaryMenu().setupState.setMenu(title, cloneMenus);
    }

    rebuildSecondaryMenus(menus, params) {
        const arrParam = Object.entries(params);
        menus?.forEach((entry) => {
            entry["pages"].forEach((subentry) => {
                arrParam.forEach((convParam) => {
                    if(subentry.route.includes(":" + convParam[0])) {
                        subentry.route = subentry.route.replace(":" + convParam[0], convParam[1]);
                    }
                });

                if(typeof subentry['sub'] != 'undefined') {
                    subentry['sub'].forEach((subsubEntry) => {
                        arrParam.forEach((convParam) => {
                            if(subsubEntry.route.includes(":" + convParam[0])) {
                                subsubEntry.route = subsubEntry.route.replace(":" + convParam[0], convParam[1]);
                            }
                        });
                    });
                }
            });
        });
    }
}

const asideSecondaryController = new AsideSecondaryController();
export default asideSecondaryController;




