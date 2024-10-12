import { defineStore } from 'pinia'

// interface UserData {
//   accessToken: string
//   workspaceInfo: {
//     id: string
//     name: string
//     description: string
//     created_at: string
//     updated_at: string
//   }
//   projectInfo: {
//     id: string
//     ns_id: string
//     name: string
//     description: string
//     created_at: string
//     updated_at: string
//   }
//   operationId: string
// }

// TODO : 반드시 수정 필요
export const useUserStore = defineStore('user', {
  state: () => ({
      accessToken: "", // 있는지 확인
      workspaceInfo: {
          id: "",
          name: "",
          description: "",
          created_at: "",
          updated_at: ""
      },
      projectInfo: {
          id: "",
          ns_id: "",
          mci_id: "",
          cluster_id: "",
          name: "",
          description: "",
          created_at: "",
          updated_at: ""
      },
      operationId: ""
  }),
  actions: {
    setUser(userData:any) {
      this.accessToken =  userData.accessToken,
      this.workspaceInfo = userData.workspaceInfo,
      this.projectInfo = userData.projectInfo,
      this.operationId = userData.operationId
    },
    // clearUser() {
    //   this.id = null
    //   this.name = null
    //   this.isAuthenticated = false
    // }
  }
})