const projectListDocMenuConfig = [
    {
        pages: [
            {
                heading: "menu.project.list",
                route: "/projects",
                svgIcon: "images/icons/menu/projects/projectList.svg",
                fontIcon: "bi-app-indicator",
                isDisabled: false
            },
            // {
            //     heading: "menu.project.deployModeler",
            //     route: "/organizations/:groupId/services/:serviceId/deployModeler/list",
            //     svgIcon: "media/icons/duotune/general/gen019.svg",
            //     fontIcon: "bi-layers",
            //     isDisabled: false
            // },
            // {
            //     sectionTitle: "menu.project.setting.title",
            //     route: "/organizations/:groupId/services/:serviceId/settings",
            //     svgIcon: "images/icons/menu/projects/setting.svg",
            //     sub: [
            //         // {
            //         //     heading: "menu.project.setting.general",
            //         //     route: "/organizations/:groupId/view",
            //         //     svgIcon: "media/icons/duotune/communication/com006.svg",
            //         //     fontIcon: "bi-person",
            //         //
            //         // },
            //         {
            //             heading: "menu.project.setting.member",
            //             route: "/organizations/:groupId/services/:serviceId/members",
            //             svgIcon: "media/icons/duotune/communication/com006.svg",
            //             fontIcon: "bi-person",
            //             isDisabled: false
            //         },
            //         {
            //             heading: "menu.project.setting.credential",
            //             route: "/organizations/:groupId/services/:serviceId/credential/list",
            //             svgIcon: "media/icons/duotune/communication/com006.svg",
            //             fontIcon: "bi-person",
            //             isDisabled: false
            //         },
            //         {
            //             heading: "menu.project.setting.dockerBuildServer",
            //             route: "/organizations/:groupId/services/:serviceId/remotehost/list",
            //             svgIcon: "media/icons/duotune/communication/com006.svg",
            //             fontIcon: "bi-person",
            //             isDisabled: false
            //         },
            //         {
            //             heading: "menu.project.setting.k8sConfig",
            //             route: "/organizations/:groupId/services/:serviceId/k8sconfig/list",
            //             svgIcon: "media/icons/duotune/communication/com006.svg",
            //             fontIcon: "bi-person",
            //             isDisabled: false
            //         },
            //         {
            //             heading: "menu.project.setting.azuer",
            //             route: "/organizations/:groupId/services/:serviceId/azure-config/list",
            //             svgIcon: "media/icons/duotune/communication/com006.svg",
            //             fontIcon: "bi-person",
            //             isDisabled: false
            //         },
            //         {
            //             heading: "menu.project.setting.openShiftConfig",
            //             route: "/organizations/:groupId/services/:serviceId/openshift-config/list",
            //             svgIcon: "media/icons/duotune/communication/com006.svg",
            //             fontIcon: "bi-person",
            //             isDisabled: false
            //         },
            //         {
            //             heading: "menu.project.setting.harbor",
            //             route: "/organizations/:groupId/services/:serviceId/harbor-config",
            //             svgIcon: "media/icons/duotune/communication/com006.svg",
            //             fontIcon: "bi-person",
            //             isDisabled: false
            //         },
            //     ]
            // }
        ],
    },
];

// const DEPLOY_MODELER_INDEX = 1;
// const SETTING_INDEX = 2;

export const setMenuPermission = (menu, authMenu) => {

    // /* 배포 모델러 */
    // menu[0].pages[DEPLOY_MODELER_INDEX].isDisabled = !authMenu.deploy_modeler_list;

    // /* 설정 */
    // menu[0].pages[SETTING_INDEX].sub[0].isDisabled = !true;
    // menu[0].pages[SETTING_INDEX].sub[1].isDisabled = !authMenu.group_credential_list;
    // menu[0].pages[SETTING_INDEX].sub[2].isDisabled = !authMenu.group_docker_build_server_list && !authMenu.group_remotehost_list ;
    // menu[0].pages[SETTING_INDEX].sub[3].isDisabled = !true;
    // menu[0].pages[SETTING_INDEX].sub[4].isDisabled = !true;
    // menu[0].pages[SETTING_INDEX].sub[5].isDisabled = !true;
    // menu[0].pages[SETTING_INDEX].sub[6].isDisabled = !true;
};

export default projectListDocMenuConfig;


// const projectListDocMenuConfig = [
//     {
//         pages: [
//             {
//                 heading: "menu.project.list",
//                 route: "/organizations/:groupId/services/:serviceId/projects",
//                 svgIcon: "images/icons/menu/projects/projectList.svg",
//                 fontIcon: "bi-app-indicator",
//                 isDisabled: false
//             },
//             {
//                 heading: "menu.project.deployModeler",
//                 route: "/organizations/:groupId/services/:serviceId/deployModeler/list",
//                 svgIcon: "media/icons/duotune/general/gen019.svg",
//                 fontIcon: "bi-layers",
//                 isDisabled: false
//             },
//             {
//                 sectionTitle: "menu.project.setting.title",
//                 route: "/organizations/:groupId/services/:serviceId/settings",
//                 svgIcon: "images/icons/menu/projects/setting.svg",
//                 sub: [
//                     // {
//                     //     heading: "menu.project.setting.general",
//                     //     route: "/organizations/:groupId/view",
//                     //     svgIcon: "media/icons/duotune/communication/com006.svg",
//                     //     fontIcon: "bi-person",
//                     //
//                     // },
//                     {
//                         heading: "menu.project.setting.member",
//                         route: "/organizations/:groupId/services/:serviceId/members",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false
//                     },
//                     {
//                         heading: "menu.project.setting.credential",
//                         route: "/organizations/:groupId/services/:serviceId/credential/list",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false
//                     },
//                     {
//                         heading: "menu.project.setting.dockerBuildServer",
//                         route: "/organizations/:groupId/services/:serviceId/remotehost/list",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false
//                     },
//                     {
//                         heading: "menu.project.setting.k8sConfig",
//                         route: "/organizations/:groupId/services/:serviceId/k8sconfig/list",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false
//                     },
//                     {
//                         heading: "menu.project.setting.azuer",
//                         route: "/organizations/:groupId/services/:serviceId/azure-config/list",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false
//                     },
//                     {
//                         heading: "menu.project.setting.openShiftConfig",
//                         route: "/organizations/:groupId/services/:serviceId/openshift-config/list",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false
//                     },
//                     {
//                         heading: "menu.project.setting.harbor",
//                         route: "/organizations/:groupId/services/:serviceId/harbor-config",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false
//                     },
//                 ]
//             }
//         ],
//     },
// ];

// const DEPLOY_MODELER_INDEX = 1;
// const SETTING_INDEX = 2;

// export const setMenuPermission = (menu, authMenu) => {

//     /* 배포 모델러 */
//     menu[0].pages[DEPLOY_MODELER_INDEX].isDisabled = !authMenu.deploy_modeler_list;

//     /* 설정 */
//     menu[0].pages[SETTING_INDEX].sub[0].isDisabled = !true;
//     menu[0].pages[SETTING_INDEX].sub[1].isDisabled = !authMenu.group_credential_list;
//     menu[0].pages[SETTING_INDEX].sub[2].isDisabled = !authMenu.group_docker_build_server_list && !authMenu.group_remotehost_list ;
//     menu[0].pages[SETTING_INDEX].sub[3].isDisabled = !true;
//     menu[0].pages[SETTING_INDEX].sub[4].isDisabled = !true;
//     menu[0].pages[SETTING_INDEX].sub[5].isDisabled = !true;
//     menu[0].pages[SETTING_INDEX].sub[6].isDisabled = !true;
// };

// export default projectListDocMenuConfig;
