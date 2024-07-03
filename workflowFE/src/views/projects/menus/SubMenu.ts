const subMenuConfig = [
  {
    pages: [
      {
        heading: "menu.service.setting.toolChain",
        route: "/projects/connection",
        svgIcon: "images/icons/menu/settings/connection.svg",
        fontIcon: "bi-app-indicator",
        isDisabled: false,
      },
      // {
      //   heading: "menu.service.setting.clusterConfig",
      //   route: "/projects/kubernetes/list",
      //   svgIcon: "images/icons/menu/settings/general.svg",
      //   fontIcon: "bi-app-indicator",
      //   isDisabled: false,
      // },
      // {
      //   heading: "menu.service.setting.infra",
      //   route: "/projects/infra/list",
      //   svgIcon: "images/icons/menu/settings/infra.svg",
      //   fontIcon: "bi-app-indicator",
      //   isDisabled: false,
      // },
      {
        heading: "menu.service.setting.pipeLineConfig",
        route: "/projects/pipeline",
        svgIcon: "images/icons/menu/settings/authority.svg",
        fontIcon: "bi-app-indicator",
        isDisabled: false,
      },
      // {
      //   heading: "menu.project.catalogDeploy",
      //   route: "/projects/catalogDeploy/list",
      //   svgIcon: "images/icons/menu/projects/projectList.svg",
      //   fontIcon: "bi-app-indicator",
      //   isDisabled: false,
      // },
      // {
      //   heading: "menu.project.workflowDeploy",
      //   route: "/projects/workflowDeploy/list",
      //   svgIcon: "images/icons/menu/projects/projectList.svg",
      //   fontIcon: "bi-app-indicator",
      //   isDisabled: false,
      // },
      {
        heading: "menu.project.workflowDeploy",
        route: "/projects/workflow/list",
        svgIcon: "images/icons/menu/projects/projectList.svg",
        fontIcon: "bi-app-indicator",
        isDisabled: false,
      },
    ],
  },
];

export const setMenuPermission = (menu, authMenu) => { };

export default subMenuConfig;
