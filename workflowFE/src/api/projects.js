import request from "@/common/request";


export function getProjectList(data) {
  return request({
    url: '/project/list',
    method: 'post',
    data
  })
}

export function getProjectDuplicate(data) {
  return request({
    url: `/project/duplicate?branch=${data.branch}&gitlabCloneHttpUrl=${data.gitlabUrl}`,
    method: 'get',
    data
  })
}

export function checkProjectConnection(data) {
  return request({
    url: `/project/connection/check`,
    method: 'post',
    data
  })
}

export function setProject(data) {
  return request({
    url: `/project`,
    method: 'post',
    data
  })
}

export function updateProject(data) {
  return request({
    url: `/project/${data.projectId}`,
    method: 'put',
    data
  })
}

export function deleteProject(projectId) {
  return request({
    url: `/project/${projectId}`,
    method: 'delete',
  })
}

export function getProjectData(projectId) {
  return request({
    url: '/project/' + projectId,
    method: 'get'
  })
}

















// export function getProjectList(data) {
//   return request({
//     url: '/projects',
//     method: 'post',
//     data
//   })
// }

// export function getProjectListSummary(data) {
//   return request({
//     url: '/projects/summary',
//     method: 'post',
//     data
//   })
// }

// export function getProjectData(projectId) {
//   return request({
//     url: '/projects/' + projectId,
//     method: 'get'
//   })
// }

// export function deleteProject(projectId) {
//   return request({
//     url: '/projects/' + projectId,
//     method: 'delete'
//   })
// }

// export function getRepositorySize(data) {
//   return request({
//     url: '/repository/getRepositorySize',
//     method: 'post',
//     data
//   })
// }

// export function getBranchs(data) {
//   return request({
//     url: '/repository/getBranchs',
//     method: 'post',
//     data
//   })
// }

// export function getFileList(data) {
//   return request({
//     url: '/repository/getRepositoryFiles',
//     method: 'post',
//     data
//   })
// }

// export function getCommitList(data) {
//   return request({
//     url: '/repository/getCommits',
//     method: 'post',
//     data
//   })
// }

// export function getRepositoryGraph(data){
//     return request({
//       url: '/repository/graph',
//       method: 'post',
//       data
//     })

// }

// export function createBranch(data) {
//   return request({
//     url: '/repository/createBranch',
//     method: 'post',
//     data
//   })
// }

// export function deleteBranch(data) {
//   return request({
//     url: '/repository/deleteBranch',
//     method: 'post',
//     data
//   })
// }

// export const duplicateCheck = (data) => {
//   return request({
//     url: `/projects/duplicateCheck?projectName=${data.projectName}&groupId=${data.subgroupId}`,
//     method: 'get'
//   })
// }

// export function createProject(data) {
//   return request({
//     url: '/createProject',
//     method: 'post',
//     data
//   })
// }

// export function updateProject(data) {
//   return request({
//     url: '/projects',
//     method: 'put',
//     data
//   })
// }

// export function addUserToProject(data) {
//   return request({
//     url: '/projects/users/add',
//     method: 'post',
//     data
//   })
// }

// export function getUsersNotInProject(params) {
//   return request.post('/projects/usersNotInProject', params)
// }

// export function removeUserFromProject(data) {
//   return request({
//     url: '/projects/users/remove',
//     method: 'delete',
//     data
//   })
// }

// export function getRepositoryUrl(data) {
//   return request({
//     url: '/repository/getRepositoryUrl',
//     method: 'post',
//     data
//   })
// }

// export function getRepositoryFileContent(data) {
//   return request({
//     url: '/repository/getRepositoryFileContent',
//     method: 'post',
//     data
//   })
// }

// export function importProject(params) {
//   return request({
//     url: '/importProject',
//     method: 'post',
//     headers: {
//       'Content-Type': 'multipart/form-data'
//     },
//     data: params
//   })
// }

// export function downloadProject(data) {
//   return request({
//     url: '/repository/downloadProject',
//     method: 'post',
//     responseType: 'blob',
//     data
//   })
// }


// export function getProjectMembers(data){
//   return request({
//     url: '/projects/users',
//     method: 'post',
//     data
//   })
// }


// export function getProjectTemplateList() {
//     return request.get('/projects/template');
// }