import store from "@/store";
import router from "@/router";
import * as mutations from "./mutations";

const userHelper = {
  /*

  2019.11.08, ddan
  1. 권한에 따른 메뉴 접근 정보 생성하기
  2. 권한에 따른 메뉴 항목 생성(data/menu.js를 기본으로)
  3. 권한에 따른 라우터 정보 생성하기
  4. 라우터  설정하기
  */
    async createMenu(commit, authName) {
        // ////////////////
        console.log("createMenu userInfo.authName ", authName)
        /*
        1. 권한에 따른 메뉴 접근 정보 생성하기
            - 권한에 따른 메뉴가 달라짐.
        */
        // 메뉴 권한 code를 field로 생성
        console.log("\t step01 permission/generateGeneralAuthMenu 실행 시작");
        const authMenu = await store.dispatch("permission/generateGeneralAuthMenu", authName);
        console.log("\t step01 permission/generateGeneralAuthMenu 실행 완료", authMenu);

        // 접근 권한 라우터 생성
        console.log("\t step02 permission/generateRoutes 실행 시작");
        const accessRoutes = await store.dispatch("permission/generateRoutes");

        console.log("\t step02 permission/generateRoutes 실행 완료",accessRoutes);
        // 접근 권한 메뉴 생성

        console.log("\t step03 permission/generateMainMenu 실행 시작");
        const mainMenu = await store.dispatch("permission/generateMainMenu");
        console.log("\t step03 permission/generateMainMenu 실행 완료", mainMenu);

        // 라우터 초기화
        // BELSNAKE
        // resetRouter();
        console.log("\t step04 라우터 초기화 완료");

        // 라우터 path 설정
        // BELSNAKE
        // router.addRoutes(accessRoutes);

        console.log("\t step05 라우터에 라우트 설정 완료 ");
    }

};

export default userHelper;
