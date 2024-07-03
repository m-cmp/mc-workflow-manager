const MODE_STATE = Object.freeze({
  LIST_MODE: 'LIST_MODE',
  NEW_MODE: 'NEW_MODE',
  EDIT_MODE: 'EDIT_MODE',
  VIEW_MODE: 'VIEW_MODE'
})

export {
  MODE_STATE
}


export const MAIN_MENU_KEY_LIST=Object.freeze({
    CONFIGURATION:"configurations",
    GROUP: "group",
    PROJECT: "project"
  })

export const BUILD_ICON_NAME = {
    SUCCESS_ICON: "/images/icons/icon_s.gif",
    FAILED_ICON: "/images/icons/icon_f.gif",
    BUILDING_ICON: "/images/icons/icon_loading.gif",
    APPROVE_ICON: "/images/icons/icon_approve.gif",
    ABORTED_ICON: "/images/icons/icon_aborted.gif",
    REJECT_ICON: "/images/icons/icon_reject.gif"
}


export const BUILD_STATE = {
    SUCCESS: "SUCCESS",
    FAILED: "FAILED",
    FAILURE:"FAILURE",
    BUILDING: "BUILDING",
    IN_PROGRESS:"IN_PROGRESS",
    APPROVE: "APPROVE",
    REJECT: "REJECT",
    ABORTED: "ABORTED"
}

export const DEPLOY_STATE = {
    SUCCESS: "SUCCESS",
    FAIL: "FAIL",
    FAILED: "FAILED",
    FAILURE:"FAILURE",
    BUILDING:"BUILDING",
    APPROVE: "APPROVE",
    REJECT: "REJECT",
    ABORTED: "ABORTED"
}

export const DEPLOY_RUNNING_ICON_NAME = {
    NORMAL_ICON:"/images/icons/build-normal-state.svg",
    SUCCESS_ICON: "/images/icons/icon_s.gif",
    FAILED_ICON: "/images/icons/icon_f.gif",
    BUILDING_ICON: "/images/icons/icon_loading.gif"
}


const API_MAPPER_PAGES=[
  'project_apimapper_connection_list',
  'project_apimapper_connection_create',
  'project_apimapper_connection_view',
  'project_apimapper_connection_update',

  'project_apimapper_mapper_list',
  'project_apimapper_mapper_create',
  'project_apimapper_mapper_view',
  'project_apimapper_mapper_update'
]

/*프로젝트 타입에 따라 사용하지 않는 페이지 정의*/
export const UNUSED_PAGES={
  TYPE1:new Array(),
  TYPE2:new Array().concat(API_MAPPER_PAGES),
  TYPE3:new Array().concat(API_MAPPER_PAGES)
}


const API_MAPPER_MENU=[
  'project_apimapper',
  'project_apimapper_connection_list',
  'project_apimapper_mapper_list'
]

const API_MAPPER_MENU2=[
    'project_apimapper_mapper_list'
  ]

/*프로젝트 타입에 따라 사용하지 않는 메뉴 정의*/
export const UNUSED_MENU={
  TYPE1:new Array(),
  TYPE2:new Array().concat(API_MAPPER_MENU),
  TYPE3:new Array().concat(API_MAPPER_MENU)
}

export const PROJECT_TEMPLATE_TYPES=[
    {label: 'Gradle', value: 1},
    {label: 'Maven', value: 2},
    {label: 'Node js', value: 3}
]
export const EDIT_MODE = {
	NEW: "new",
	EDIT:"edit"
}
