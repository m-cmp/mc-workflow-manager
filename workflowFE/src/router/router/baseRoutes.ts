import { RouteRecordRaw } from "vue-router";

export const baseRoutes: RouteRecordRaw[] = [
  {
    path: "/",
    name: "ConfigurationConnectionList",
    redirect: '/projects/connection',
    // component: () => import("@/views/projects/connection/ConfigurationConnectionList.vue"),
    // children: [
    //   {
    //     path: "/projects/connection",
    //     name: "ConfigurationConnectionList",
    //     component: () => import("@/views/projects/connection/ConfigurationConnectionList.vue"),
    //   },
    // ]
  },
  {
    path: "/admin",
    component: () => import("@/views/admin/index.vue"),
  },
  {
    path: "/404",
    component: () => import("@/views/errors/404.vue"),
  },
  {
    path: "/401",
    component: () => import("@/views/errors/401.vue"),
  },
  {
    path: "/error",
    component: () => import("@/views/errors/Error.vue"),
  }
];
