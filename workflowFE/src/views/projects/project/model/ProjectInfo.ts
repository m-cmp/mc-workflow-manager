class ProjectInfo {
  projectId: number;
  projectName: string;
  packageName: string;
  gitlabCloneHttpUrl: string;
  gitlab: {
      url: string,
      username: string,
      password: string,
      groupName: string,
      projectName: string,
      branch: string
  };
  regDate: string;
  modDate: string;

  constructor(projectId, projectName, packageName, gitlabCloneHttpUrl, gitlab, regDate, modDate) {
    this.projectId = projectId;
    this.projectName = projectName;
    this.packageName = packageName;
    this.gitlabCloneHttpUrl = gitlabCloneHttpUrl;
    this.gitlab = gitlab;
    this.regDate = regDate;
    this.modDate = modDate;
  }
};


export {
  ProjectInfo
}
