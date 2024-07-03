import {RouteParams} from "vue-router";

class AsideButtonProp {
    id: number;
    title: string;
    isActive: boolean;
    iconPath: string;
    routerName: string;
    secondaryMenus: Array<object> | null;
    params: RouteParams;

    constructor(id: number, title, isActive: boolean, iconPath: string, routerName: string, secondaryMenus: Array<object> | null, params: RouteParams | null) {
        this.id = id;
        this.title = title;
        this.isActive = isActive;
        this.iconPath = iconPath;
        this.routerName = routerName;
        this.params = (params == null ? {} : params);

        /* secondaryMenus를 복사해서 저장한다. */
        if(secondaryMenus != null) {
            const jsonStr = JSON.stringify(secondaryMenus);
            this.secondaryMenus = JSON.parse(jsonStr);
            if(this.secondaryMenus != null && params != null) this.rebuildSecondaryMenus(params);
        }
        else this.secondaryMenus = null;
    }

    rebuildSecondaryMenus(params) {
        const arrParam = Object.entries(params);
        this.secondaryMenus?.forEach((entry) => {
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

    clone() : AsideButtonProp {
        let myClone = new AsideButtonProp(this.id, this.title, this.isActive, this.iconPath, this.routerName, this.secondaryMenus, this.params);
        return myClone;
    }
}

export {
    AsideButtonProp
}
