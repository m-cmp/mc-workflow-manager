import App, {getAsidePrimary} from "@/main"
import {AsideButtonProp} from "@/components/base/menu/AsideButtonProp";

class AsidePrimaryController {

    /* 메뉴 목록 추가 */
    setMenu(menus: Array<AsideButtonProp>) {

        console.log("####### AsidePrimaryController... ", getAsidePrimary());
        getAsidePrimary().setupState.clear();
        menus.forEach((el) => {
            getAsidePrimary().setupState.push(el.clone());
        })
    }
}

const asidePrimaryController = new AsidePrimaryController();
export default asidePrimaryController;




