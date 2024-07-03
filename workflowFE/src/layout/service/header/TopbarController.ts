import App from "@/main"
import {AsideButtonProp} from "@/components/base/menu/AsideButtonProp";

export class TopbarController {
    header: any;

    init() {
        this.header = ((App._instance?.subTree?.component?.subTree.component?.refs.header as any));
    };

    /* 메뉴 항목 삭제 */
    setTopbar(compName, compProps) {
        this.init();
        return (this.header as any).setTopbar(compName, compProps);
    }
}

export function setTopbar(compName, compProps) {
    const header = ((App._instance?.subTree?.component?.subTree.component?.refs.header as any));
    if(typeof header == 'undefined') return;
    if(typeof header.setTopbar == 'undefined') return;

    return header.setTopbar(compName, compProps);
}


const topbarController = new TopbarController();
export default topbarController;




