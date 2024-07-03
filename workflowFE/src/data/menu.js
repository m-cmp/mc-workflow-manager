const menuList = {
  list: {
    // configurations: [
    //   // {
    //   //   path: '/configurations/mypage/view',
    //   //   name: 'configuration_mypage_view',
    //   //   meta: {
    //   //     title: 'menu.config.myInfo',
    //   //     icon: 'fas fa-id-card',
    //   //     iconUrl: '/settings/myInfo.png'
    //   //   }
    //   // },
    //   {
    //     path: '/configurations/notifications/list',
    //     name: 'configuration_notifications_list',
    //     meta: {
    //       title: 'menu.config.notifications',
    //       icon: 'fas fa-bell',
    //       iconUrl: '/settings/alarm.png'
    //     }
    //   },
    //   {
    //     path: '/configurations/general',
    //     name: 'configuration_general',
    //     meta: {
    //       title: 'menu.config.general',
    //       icon: 'fas fa-cog',
    //       iconUrl: '/settings/general.png'
    //     }
    //   },
    //   {
    //     path: '/configurations/connection',
    //     name: 'connection',
    //     meta: {
    //       title: 'menu.config.connection.title',
    //       icon: 'fas fa-plug',
    //       iconUrl: '/settings/connection.png'
    //     },
    //     children: [
    //       {
    //         path: '/configurations/gitlab',
    //         name: 'configuration_gitlab',
    //         meta: {
    //           title:
		// 						'menu.config.connection.gitLab',
    //           icon: 'fab fa-git-square',
    //           iconUrl: '/settings/sub/gitlab.png'
    //         }
    //       },
    //       {
    //         path: '/configurations/jenkins',
    //         name: 'configuration_jenkins',
    //         meta: {
    //           title:
		// 						'menu.config.connection.jenkins',
    //           icon: 'fab fa-jenkins',
    //           iconUrl: '/settings/sub/jenkins.png'
    //         }
    //       }
    //     ]
    //   },
    //   {
    //     path: '/configurations/members/list',
    //     name: 'configuration_member_list',
    //     meta: {
    //       title: 'menu.member',
    //       icon: 'fas fa-users',
    //       iconUrl: '/settings/member.png'
    //     }
    //   },
    //   {
    //     path: '/configurations/authority',
    //     name: 'configuration_authority',
    //     meta: {
    //       title: 'menu.authority',
    //       icon: 'fas fa-layer-group',
    //       iconUrl: '/settings/authority.png'
    //     }
    //   },
    //   {
    //     path: '/configurations/message/list',
    //     name: 'configuration_message_list',
    //     meta: {
    //       title: 'menu.message',
    //       icon: 'fas fa-comment-dots',
    //       iconUrl: '/settings/msg.png'
    //     }
    //   },
    //   {
    //     path: '/configurations/statemachine',
    //     name: 'configuration_statemachine',
    //     meta: {
    //       title: 'menu.statemachine',
    //       icon: 'fas fa-bezier-curve',
    //       iconUrl: '/settings/approval.png'
    //     }
    //   }
    // ],
    // groups: [
    //   {
    //     path: '/groups/groupHome',
    //     name: 'group_list',
    //     meta: {
    //       title: 'menu.organization',
    //       icon: 'fab fa-goodreads',
    //       iconUrl: '/main/organization.png',
    //       noAuthority: true
    //     }
    //   }
    // ],
    // group: [
    //   {
    //     path: '/group/:groupId/projects/list',
    //     name: 'project_list',
    //     meta: {
    //       title: 'menu.project',
    //       icon: 'fas fa-box',
    //       noAuthority: true,
    //       iconUrl: '/organization/project.png'
    //     }
    //   },
    //   {
    //     path: '/group/:groupId/deploy_modeler/list',
    //     name: 'deploy_modeler_list',
    //     meta: {
    //       title: 'menu.deployModeler',
    //       icon: 'fas fa-tools',
    //       iconUrl: '/organization/deploy-modeler.png'
    //     }
    //   },
    //   /*
    //     {
    //     path: '/group/:groupId/task',
    //     name: 'tack',
    //     meta: {
    //       title: 'menu.task.title',
    //       icon: 'fas fa-tasks'
    //     },
    //     children: [
    //       {
    //         path: '/group/:groupId/task/overview',
    //         name: 'task_overview',
    //         meta: {
    //           title: 'menu.task.overview',
    //           icon: 'far fa-newspaper'
    //         },
    //         hidden: false
    //       },
    //       {
    //         path: '/group/:groupId/task/items',
    //         name: 'task_items',
    //         meta: {
    //           title: 'menu.task.items',
    //           icon: 'fab fa-creative-commons-nd'
    //         },
    //         hidden: false
    //       },
    //       {
    //         path: '/group/:groupId/task/sprints',
    //         name: 'task_sprints',
    //         meta: {
    //           title: 'menu.task.sprints',
    //           icon: 'fas fa-columns'
    //         },
    //         hidden: false
    //       }
    //     ]
    //   },
    //   */

    //   {
    //     path: '/group/:groupId/projects/setting',
    //     name: 'project_setting',
    //     meta: {
    //       title: 'menu.organizationSetting.title',
    //       icon: 'fas fa-cogs',
    //       iconUrl: '/organization/setting.png'
    //     },
    //     children: [
    //       {
    //         path: '/group/:groupId/view',
    //         name: 'group_view',
    //         meta: {
    //           title:
		// 						'menu.organizationSetting.general',
    //           icon: 'fab fa-goodreads',
    //           iconUrl: '/organization/sub/general.png'
    //         },
    //         hidden: false
    //       },
    //       {
    //         path: '/group/:groupId/member',
    //         name: 'group_member_list',
    //         meta: {
    //           title: 'menu.organizationSetting.member',
    //           icon: 'fas fa-users',
    //           iconUrl: '/organization/sub/member.png'
    //         },
    //         hidden: false
    //       },
    //       {
    //         path: '/group/:groupId/credential/list',
    //         name: 'group_credential_list',
    //         meta: {
    //           title: 'menu.organizationSetting.credential',
    //           icon: 'fas fa-id-card',
    //           iconUrl: '/organization/sub/credential.png'
    //         },
    //         hidden: false
    //       },
    //       /* {
		// 				path: "/group/:groupId/remotehost/list",
		// 				name: "group_remotehost_list",
		// 				meta: {
		// 					title:
		// 						"menu.organizationSetting.remoteHost",
		// 					icon: "fas fa-network-wired",
		// 				},
		// 				hidden: false,
		// 			},*/
    //       {
    //         path:
		// 					'/group/:groupId/deploy_location/list',
    //         name: 'group_deploy_location_list',
    //         meta: {
    //           title:
		// 						'menu.organizationSetting.deployLocation',
    //           icon: 'fas fa-project-diagram',
    //           iconUrl: '/organization/sub/deploy-location.png'
    //         },
    //         hidden: true
    //       },
    //       {
    //         path: '/group/:groupId/remotehost/list',
    //         name: 'group_remotehost_list',
    //         meta: {
    //           title: 'menu.organizationSetting.docker',
    //           icon: 'fas fa-server',
    //           iconUrl: '/organization/sub/docker.png'
    //         },
    //         hidden: false
    //       },
    //       {
    //         path: '/group/:groupId/k8sconfig/list',
    //         name: 'group_k8s_list',
    //         meta: {
    //           title:
		// 						'menu.organizationSetting.k8sConfig',
    //           icon: 'fas fa-server',
    //           iconUrl: '/organization/sub/kubernetes.png'
    //         },
    //         hidden: false
    //       },
    //       {
    //         path: '/group/:groupId/azurecredential/list',
    //         name: 'group_azurecredential_list',
    //         meta: {
    //           title:
		// 						'menu.organizationSetting.azuerConfig',
    //           icon: 'fas fa-server',
    //           iconUrl: '/organization/sub/azure.png'
    //         },
    //         hidden: false
    //       }, {
    //         path: '/group/:groupId/openshiftconfig/list',
    //         name: 'group_openshift_list',
    //         meta: {
    //           title:
		// 						'menu.organizationSetting.openShiftConfig',
    //           icon: 'fas fa-server',
    //           iconUrl: '/organization/sub/openshift.png'
    //         },
    //         hidden: false
    //       }
    //     ]
    //   }
    // ],
    // service: [],
    projects: [],
    project: [
      // {
      //   path: '/group/:groupId/project/:projectId/dashboard',
      //   name: 'project_dashboard',
      //   meta: {
      //     title: 'menu.dashboard',
      //     icon: 'fas fa-tachometer-alt',
      //     iconUrl: '/project/dashbord.png'
      //   },
      //   hidden: false
      // },

      // {
      //   path: '/group/:groupId/project/:projectId/repository',
      //   name: 'project_repository',
      //   meta: {
      //     title: 'menu.repository.title',
      //     icon: 'fas fa-database',
      //     iconUrl: '/project/repository.png'
      //   },
      //   hidden: false,
      //   children: [
      //     {
      //       path: '/group/:groupId/project/:projectId/repository/file',
      //       name: 'project_repository_file_list',
      //       meta: {
      //         title: 'menu.repository.file',
      //         icon: 'fas fa-file',
      //         iconUrl: '/project/sub/file.png'
      //       },
      //       hidden: false
      //     },
      //     {
      //       path:
			// 				'/group/:groupId/project/:projectId/repository/commit',
      //       name: 'project_repository_commit_list',
      //       meta: {
      //         title: 'menu.repository.commit',
      //         icon: 'fas fa-file-export',
      //         iconUrl: '/project/sub/commit.png'
      //       },
      //       hidden: false
      //     },
      //     {
      //       path:
			// 				'/group/:groupId/project/:projectId/repository/graph',
      //       name: 'project_repository_graph',
      //       meta: {
      //         title: 'menu.repository.graph',
      //         icon: 'fas fa-file-export',
      //         iconUrl: '/project/sub/graph.png'
      //       },
      //       hidden: false
      //     },
      //     {
      //       path:
			// 				'/group/:groupId/project/:projectId/repository/branch',
      //       name: 'project_repository_branches_list',
      //       meta: {
      //         title: 'menu.repository.branch',
      //         icon: 'fas fa-code-branch',
      //         iconUrl: '/project/sub/branch.png'
      //       },
      //       hidden: false
      //     }
      //   ]
      // },
      {
        path: '/group/:groupId/project/:projectId/apimapper',
        name: 'project_apimapper',
        meta: {
          title: 'menu.apiMappter.title',
          icon: 'fas fa-tools',
          iconUrl: '/project/api-mapper.png'
        },
        hidden: false,
        children: [
          {
            path:
							'/group/:groupId/project/:projectId/apimapper/connection/list',
            name: 'project_apimapper_connection_list',
            meta: {
              title: 'menu.apiMappter.connection',
              icon: 'fas fa-plug',
              iconUrl: '/project/sub/connection.png'
            },
            hidden: false
          },
          {
            path:
							'/group/:groupId/project/:projectId/apimapper/mapper/list',
            name: 'project_apimapper_mapper_list',
            meta: {
              title: 'menu.apiMappter.mapper',
              icon: 'fas fa-list-alt',
              iconUrl: '/project/sub/mepper.png'
            },
            hidden: false
          }
        ]
      },
      // {
      //   path: '/group/:groupId/project/:projectId/build/list',
      //   name: 'project_build_list',
      //   meta: {
      //     title: 'menu.build',
      //     icon: 'fab fa-bimobject',
      //     iconUrl: '/project/build.png'
      //   },
      //   hidden: false
      // },
      // {
      //   path: '/group/:groupId/project/:projectId/deploy/list',
      //   name: 'project_deploy_list',
      //   meta: {
      //     title: 'menu.deploy',
      //     icon: 'fab fa-buromobelexperte',
      //     iconUrl: '/project/deploy.png'
      //   },
      //   hidden: false
      // },
      // // {
      // // 	path: "/group/:groupId/project/:projectId/aksDeploy/list",
      // // 	name: "project_aks_deploy_list",
      // // 	meta: {
      // // 		title: "menu.aksDeploy",
      // // 		icon: "fab fa-buromobelexperte",
      // // 	},
      // // 	hidden: false
      // // },
      // {
      //   path: '/group/:groupId/project/setting',
      //   name: 'project_setting',
      //   meta: {
      //     title: 'menu.projectSettings.title',
      //     icon: 'fas fa-cogs',
      //     iconUrl: '/project/setting.png'
      //   },
      //   children: [
      //     {
      //       path:
			// 				'/group/:groupId/project/:projectId/general',
      //       name: 'project_view',
      //       meta: {
      //         title: 'menu.projectSettings.general',
      //         icon: 'fas fa-box-open',
      //         iconUrl: '/project/sub/general.png'

      //       },
      //       hidden: false
      //     },
      //     {
      //       path:
			// 				'/group/:groupId/project/:projectId/member',
      //       name: 'project_member_list',
      //       meta: {
      //         title: 'menu.projectSettings.member',
      //         icon: 'fas fa-users',
      //         iconUrl: '/project/sub/member.png'
      //       },
      //       hidden: false
      //     }
      //   ]
      // }
    ]
  }
}
export default menuList.list
