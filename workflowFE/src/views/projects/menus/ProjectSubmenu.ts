const projectDocMenuConfig = [
    // {
    //     pages: [
    //         {
    //             heading: "menu.dashboard",
    //             route: "/organizations/:groupId/services/:serviceId/projects/:projectId/dashboard",
    //             svgIcon: "media/icons/duotune/art/art002.svg",
    //             fontIcon: "bi-app-indicator",
    //             isDisabled: false,
    //         },
    //     ],
    // },
    // {
    //     pages: [
    //         {
    //             heading: "",
    //             sectionTitle: "menu.repository.title",
    //             route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository",
    //             svgIcon: "media/icons/duotune/art/art002.svg",
    //             sub: [
    //                 {
    //                     heading: "menu.repository.file",
    //                     route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/file",
    //                     svgIcon: "media/icons/duotune/communication/com006.svg",
    //                     fontIcon: "bi-person",
    //                     isDisabled: false,

    //                 },
    //                 {
    //                     heading: "menu.repository.commit",
    //                     route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/commit",
    //                     svgIcon: "media/icons/duotune/communication/com006.svg",
    //                     fontIcon: "bi-person",
    //                     isDisabled: false,

    //                 },
    //                 {
    //                     heading: "menu.repository.graph",
    //                     route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/graph",
    //                     svgIcon: "media/icons/duotune/communication/com006.svg",
    //                     fontIcon: "bi-person",
    //                     isDisabled: false,

    //                 },
    //                 {
    //                     heading: "menu.repository.branch",
    //                     route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/branch",
    //                     svgIcon: "media/icons/duotune/communication/com006.svg",
    //                     fontIcon: "bi-person",
    //                     isDisabled: false,
    //                 },
    //                 {
    //                     heading: "menu.repository.harbor",
    //                     route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/harbor",
    //                     svgIcon: "media/icons/duotune/communication/com006.svg",
    //                     fontIcon: "bi-person",
    //                     isDisabled: false,
    //                 },
    //             ]
    //         },
    //     ],
    // },
    {
        pages: [
            {
                sectionTitle: "menu.apiMapper.title",
                route: "/projects/:projectId/apiMapper",
                svgIcon: "media/icons/duotune/art/art002.svg",
                sub: [
                    {
                        heading: "menu.apiMapper.connection",
                        route: "/projects/:projectId/apiMapper/connections",
                        svgIcon: "media/icons/duotune/communication/com006.svg",
                        fontIcon: "bi-person",
    
                    },
                    {
                        heading: "menu.apiMapper.mapper",
                        route: "/projects/:projectId/apiMapper/mapper",
                        svgIcon: "media/icons/duotune/communication/com006.svg",
                        fontIcon: "bi-person",
    
                    },
                ]
            }
        ],
    },
    // {
    //     pages: [
    //         {
    //             heading: "menu.build",
    //             route: "/organizations/:groupId/services/:serviceId/projects/:projectId/builds",
    //             svgIcon: "media/icons/duotune/art/art002.svg",
    //             fontIcon: "bi-app-indicator",
    //             isDisabled: false,
    //         },
    //     ],
    // },
    // {
    //     pages: [
    //         {
    //             heading: "menu.deploy",
    //             route: "/organizations/:groupId/services/:serviceId/projects/:projectId/deploy",
    //             svgIcon: "media/icons/duotune/art/art002.svg",
    //             fontIcon: "bi-app-indicator",
    //             isDisabled: false,
    //         },
    //     ],
    // },
    // {
    //     pages: [
    //         {
    //             heading: "",
    //             sectionTitle: "menu.projectSettings.title",
    //             route: "/organizations/:groupId/services/:serviceId/projects/:projectId/projectSettings",
    //             svgIcon: "media/icons/duotune/art/art002.svg",
    //             sub: [
    //                 {
    //                     heading: "menu.projectSettings.general",
    //                     route: "/organizations/:groupId/services/:serviceId/projects/:projectId/settings/general",
    //                     svgIcon: "media/icons/duotune/communication/com006.svg",
    //                     fontIcon: "bi-person",
    //                     isDisabled: false,

    //                 },
    //                 {
    //                     heading: "menu.projectSettings.member",
    //                     route: "/organizations/:groupId/services/:serviceId/projects/:projectId/settings/member",
    //                     svgIcon: "media/icons/duotune/communication/com006.svg",
    //                     fontIcon: "bi-person",
    //                     isDisabled: false,

    //                 },
    //             ]
    //         }
    //     ],
    // },
];

const APIMAPPER_INDEX = 0;
// const REPOSITORY_INDEX = 1;
// const APIMAPPER_INDEX = 2;
// const BUILD_INDEX = 3;
// const DEPLOY_INDEX = 4;
// const SETTING_INDEX = 5;

export const setMenuPermission = (menu) => {
    console.log("menu ========> ", menu);

    /* REPOSITORY */
    // menu[REPOSITORY_INDEX].pages[0].sub[0].isDisabled = !authMenu.project_repository_file_list;
    // menu[REPOSITORY_INDEX].pages[0].sub[1].isDisabled = !authMenu.project_repository_commit_list;
    // menu[REPOSITORY_INDEX].pages[0].sub[3].isDisabled = !authMenu.project_repository_branches_list;

    /* API MAPPER */
    // menu[APIMAPPER_INDEX].pages[0].sub[0].isDisabled = !authMenu.project_apimapper_connection_list;
    // menu[APIMAPPER_INDEX].pages[0].sub[1].isDisabled = !authMenu.project_apimapper_mapper_list;

    /* BUILD */
    // menu[BUILD_INDEX].pages[0].isDisabled = !authMenu.project_build_list;

    /* DEPLOY */
    // menu[DEPLOY_INDEX].pages[0].isDisabled = !authMenu.project_deploy_list;

    /* MEMBER */
    // menu[SETTING_INDEX].pages[0].sub[0].isDisabled = !authMenu.project_list;
    // menu[SETTING_INDEX].pages[0].sub[1].isDisabled = !authMenu.project_member_list;  // 권한 설정페이지에 프로젝트 회원관리 항목이 없음
};

export default projectDocMenuConfig;





// const projectDocMenuConfig = [
//     {
//         pages: [
//             {
//                 heading: "menu.dashboard",
//                 route: "/organizations/:groupId/services/:serviceId/projects/:projectId/dashboard",
//                 svgIcon: "media/icons/duotune/art/art002.svg",
//                 fontIcon: "bi-app-indicator",
//                 isDisabled: false,
//             },
//         ],
//     },
//     {
//         pages: [
//             {
//                 heading: "",
//                 sectionTitle: "menu.repository.title",
//                 route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository",
//                 svgIcon: "media/icons/duotune/art/art002.svg",
//                 sub: [
//                     {
//                         heading: "menu.repository.file",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/file",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false,

//                     },
//                     {
//                         heading: "menu.repository.commit",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/commit",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false,

//                     },
//                     {
//                         heading: "menu.repository.graph",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/graph",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false,

//                     },
//                     {
//                         heading: "menu.repository.branch",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/branch",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false,
//                     },
//                     {
//                         heading: "menu.repository.harbor",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/repository/harbor",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false,
//                     },
//                 ]
//             },
//         ],
//     },
//     {
//         pages: [
//             {
//                 sectionTitle: "menu.apiMapper.title",
//                 route: "/organizations/:groupId/services/:serviceId/projects/:projectId/apiMapper",
//                 svgIcon: "media/icons/duotune/art/art002.svg",
//                 sub: [
//                     {
//                         heading: "menu.apiMapper.connection",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/apiMapper/connections",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
    
//                     },
//                     {
//                         heading: "menu.apiMapper.mapper",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/apiMapper/mapper",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
    
//                     },
//                 ]
//             }
//         ],
//     },
//     {
//         pages: [
//             {
//                 heading: "menu.build",
//                 route: "/organizations/:groupId/services/:serviceId/projects/:projectId/builds",
//                 svgIcon: "media/icons/duotune/art/art002.svg",
//                 fontIcon: "bi-app-indicator",
//                 isDisabled: false,
//             },
//         ],
//     },
//     {
//         pages: [
//             {
//                 heading: "menu.deploy",
//                 route: "/organizations/:groupId/services/:serviceId/projects/:projectId/deploy",
//                 svgIcon: "media/icons/duotune/art/art002.svg",
//                 fontIcon: "bi-app-indicator",
//                 isDisabled: false,
//             },
//         ],
//     },
//     {
//         pages: [
//             {
//                 heading: "",
//                 sectionTitle: "menu.projectSettings.title",
//                 route: "/organizations/:groupId/services/:serviceId/projects/:projectId/projectSettings",
//                 svgIcon: "media/icons/duotune/art/art002.svg",
//                 sub: [
//                     {
//                         heading: "menu.projectSettings.general",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/settings/general",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false,

//                     },
//                     {
//                         heading: "menu.projectSettings.member",
//                         route: "/organizations/:groupId/services/:serviceId/projects/:projectId/settings/member",
//                         svgIcon: "media/icons/duotune/communication/com006.svg",
//                         fontIcon: "bi-person",
//                         isDisabled: false,

//                     },
//                 ]
//             }
//         ],
//     },
// ];

// const REPOSITORY_INDEX = 1;
// const APIMAPPER_INDEX = 2;
// const BUILD_INDEX = 3;
// const DEPLOY_INDEX = 4;
// const SETTING_INDEX = 5;

// export const setMenuPermission = (menu, authMenu) => {
//     console.log("menu ========> ", menu);
//     console.log("menu ========> ", authMenu);

//     /* REPOSITORY */
//     menu[REPOSITORY_INDEX].pages[0].sub[0].isDisabled = !authMenu.project_repository_file_list;
//     menu[REPOSITORY_INDEX].pages[0].sub[1].isDisabled = !authMenu.project_repository_commit_list;
//     menu[REPOSITORY_INDEX].pages[0].sub[3].isDisabled = !authMenu.project_repository_branches_list;

//     /* API MAPPER */
//     menu[APIMAPPER_INDEX].pages[0].sub[0].isDisabled = !authMenu.project_apimapper_connection_list;
//     menu[APIMAPPER_INDEX].pages[0].sub[1].isDisabled = !authMenu.project_apimapper_mapper_list;

//     /* BUILD */
//     menu[BUILD_INDEX].pages[0].isDisabled = !authMenu.project_build_list;

//     /* DEPLOY */
//     menu[DEPLOY_INDEX].pages[0].isDisabled = !authMenu.project_deploy_list;

//     /* MEMBER */
//     menu[SETTING_INDEX].pages[0].sub[0].isDisabled = !authMenu.project_list;
//     // menu[SETTING_INDEX].pages[0].sub[1].isDisabled = !authMenu.project_member_list;  // 권한 설정페이지에 프로젝트 회원관리 항목이 없음
// };

// export default projectDocMenuConfig;
