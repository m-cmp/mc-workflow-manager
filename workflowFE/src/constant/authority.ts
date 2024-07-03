
const AUTHORITY_ID_LIST=Object.freeze({
  AUTH_SYSTEM_ADMIN: 1,
  AUTH_GROUP_OWNER: 2,
  AUTH_PROJECT_MANAGER: 3,
  AUTH_DEVELOPER: 4,
  AUTH_SERVICE_OWNER: 5 // yyr : - add SERVICE_OWNER 권한 추가
})

export default AUTHORITY_ID_LIST;


/*그룹 또는 프로젝트 생성시 OWNER로 지정할 수 있는 auth ids */
export const OWNER_AUTH = Object.freeze({
  GROUP: [2],
  SERVICE: [2, 5], // yyr : - add SERVICE_OWNER 권한 추가
  PROJECT: [2, 3, 5]
})


export const AUTHORITY_NAMES = Object.freeze({
  AUTH_SYSTEM_ADMIN: 'SYSTEM_ADMIN',
  AUTH_GROUP_OWNER: 'ORGANIZATION_OWNER',
  AUTH_PROJECT_MANAGER: 'PROJECT_MANAGER',
  AUTH_DEVELOPER: 'DEVELOPER',
  AUTH_SERVICE_OWNER: 'SERVICE_OWNER' // yyr : - add SERVICE_OWNER 권한 추가
})

