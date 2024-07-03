import {createRouter, createWebHashHistory} from "vue-router";
// import {organizationRoutes} from './router/organizationRoutes'
// import {serviceRoutes} from './router/serviceRoutes'
import {projectRoutes} from './router/projectRoutes'
// import {configurationRoutes} from './router/configurationRoutes'
import {baseRoutes} from "@/router/router/baseRoutes";


/**
 * 동적 라우터
 * 사용자 rolues에 따라 동적 추가 삭제 처리
 *
 * !!! 미적용중 (store 관련 기능 수정 필요)
 */
export const asyncRoutes = {
    // groupRouter: organizationRoutes,
    // serviceRouter: serviceRoutes,
    projectRouter: projectRoutes,
    // configurationRouter: configurationRoutes,
    default: { path: "*", redirect: "/404", hidden: true }
}

/** 라우팅 정보 등록 */
const constantRoutes = baseRoutes;
// constantRoutes.push(organizationRoutes);        // asyncRoutes 적용 시, 삭제
// constantRoutes.push(serviceRoutes);             // asyncRoutes 적용 시, 삭제
constantRoutes.push(projectRoutes);             // asyncRoutes 적용 시, 삭제
// constantRoutes.push(configurationRoutes);       // asyncRoutes 적용 시, 삭제
const router = createRouter({
    history: createWebHashHistory(),
    routes: constantRoutes,
});

export default router;
