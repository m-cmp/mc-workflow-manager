
/*
    권한 처리 필드 셋
    @name: 코드 번호 대신 실제 소스코드에서 사용되는 이름.
*/
export default {
  list: {
    '1': { 'name': 'group_list', 'value': false, 'global':true,  },
    '2': { 'name': 'group_create', 'value': false, 'global':false },
    '3': { 'name': 'group_update', 'value': false, 'global':false },
    '4': { 'name': 'group_delete', 'value': false, 'global':false },

    '5': { 'name': 'project_list', 'value': false, 'global':false },
    '6': { 'name': 'project_create', 'value': false, 'global':false },
    '7': { 'name': 'project_update', 'value': false, 'global':false },
    '8': { 'name': 'project_delete', 'value': false, 'global':false },

    '9': { 'name': 'project_repository_file_list', 'value': false, 'global':false },
    '10': { 'name': 'project_repository_file_create', 'value': false, 'global':false },
    '11': { 'name': 'project_repository_commit_list', 'value': false, 'global':false },
    '12': { 'name': 'project_repository_branches_list', 'value': false, 'global':false },
    '13': { 'name': 'project_repository_branches_create', 'value': false, 'global':false },
    '14': { 'name': 'project_repository_branches_delete', 'value': false, 'global':false },

    '15': { 'name': 'project_setting_list', 'value': false, 'global':false },
    '16': { 'name': 'project_setting_update', 'value': false, 'global':false },

    '17': { 'name': 'project_apimapper_list', 'value': false, 'global':false },
    '18': { 'name': 'project_apimapper_create', 'value': false, 'global':false },
    '19': { 'name': 'project_apimapper_update', 'value': false, 'global':false },
    '20': { 'name': 'project_apimapper_delete', 'value': false, 'global':false },

    '21': { 'name': 'project_build_list', 'value': false, 'global':false },
    '22': { 'name': 'project_build_create', 'value': false, 'global':false },
    '23': { 'name': 'project_build_update', 'value': false, 'global':false },
    '24': { 'name': 'project_build_delete', 'value': false, 'global':false },
    '27': { 'name': 'project_build_history', 'value': false, 'global':false },
    '28': { 'name': 'project_build_run', 'value': false, 'global':false },

    '53': { 'name': 'project_deploy_list', 'value': false, 'global':false },
    '54': { 'name': 'project_deploy_create', 'value': false, 'global':false },
    '55': { 'name': 'project_deploy_update', 'value': false, 'global':false },
    '56': { 'name': 'project_deploy_delete', 'value': false, 'global':false },
    '57': { 'name': 'project_deploy_history', 'value': false, 'global':false },
    '58': { 'name': 'project_deploy_run', 'value': false, 'global':false },

    '29': { 'name': 'group_docker_build_server_list', 'value': false, 'global':false },
    '30': { 'name': 'group_docker_build_server_create', 'value': false, 'global':false },
    '31': { 'name': 'group_docker_build_server_update', 'value': false, 'global':false },
    '32': { 'name': 'group_docker_build_server_delete', 'value': false, 'global':false },

    '33': { 'name': 'group_deploy_location_list', 'value': false, 'global':false },
    '34': { 'name': 'group_deploy_location_create', 'value': false, 'global':false },
    '35': { 'name': 'group_deploy_location_update', 'value': false, 'global':false },
    '36': { 'name': 'group_deploy_location_delete', 'value': false, 'global':false },

    '37': { 'name': 'configuration_member_list', 'value': false, 'global':true },
    '38': { 'name': 'configuration_member_create', 'value': false, 'global':true },
    '39': { 'name': 'configuration_member_update', 'value': false, 'global':true },
    '40': { 'name': 'configuration_member_delete', 'value': false, 'global':true },

    '41': { 'name': 'group_credential_list', 'value': false, 'global':false },
    '42': { 'name': 'group_credential_create', 'value': false, 'global':false },
    '43': { 'name': 'group_credential_update', 'value': false, 'global':false },
    '44': { 'name': 'group_credential_delete', 'value': false, 'global':false },

    '45': { 'name': 'group_remotehost_list', 'value': false, 'global':false },
    '46': { 'name': 'group_remotehost_create', 'value': false, 'global':false },
    '47': { 'name': 'group_remotehost_update', 'value': false, 'global':false },
    '48': { 'name': 'group_remotehost_delete', 'value': false, 'global':false },

    '49': { 'name': 'configuration_gitlab', 'value': false, 'global':true },
    '50': { 'name': 'configuration_jenkins', 'value': false, 'global':true },
    '51': { 'name': 'configuration_general', 'value': false, 'global':true },
    '52': { 'name': 'configuration_authority', 'value': false, 'global':true },

    '59': { 'name': 'deploy_modeler_list', 'value': false, 'global':false },
    '60': { 'name': 'deploy_modeler_create', 'value': false, 'global':false },
    '61': { 'name': 'deploy_modeler_update', 'value': false, 'global':false },
    '62': { 'name': 'deploy_modeler_delete', 'value': false, 'global':false },
    '63': { 'name': 'deploy_modeler_run_deploy', 'value': false, 'global':false },
    
    '67': { 'name': 'configuration_statemachine', 'value': false, 'global': true },
    '69': { 'name': 'configuration_message_list', 'value': false, 'global': true },
    '71': { 'name': 'configuration_message_update', 'value': false, 'global': false },
    '73': { 'name': 'configuration_notifications_list', 'value': false, 'global': false },

    '161': { 'name': 'project_apimapper_connection_list', 'value': false, 'global':false },
    '162': { 'name': 'project_apimapper_connection_create', 'value': false, 'global':false },
    '163': { 'name': 'project_apimapper_connection_update', 'value': false, 'global':false },
    '164': { 'name': 'project_apimapper_connection_delete', 'value': false, 'global':false },

    '165': { 'name': 'project_apimapper_mapper_list', 'value': false, 'global':false },
    '166': { 'name': 'project_apimapper_mapper_create', 'value': false, 'global':false },
    '167': { 'name': 'project_apimapper_mapper_update', 'value': false, 'global':false },
    '168': { 'name': 'project_apimapper_mapper_delete', 'value': false, 'global':false },


    '191': { 'name': 'group_member_list', 'value': false, 'global':false },
    '192': { 'name': 'group_member_create', 'value': false, 'global':false },
    '195': { 'name': 'project_member_list', 'value': false, 'global':false },
    '196': { 'name': 'project_member_create', 'value': false, 'global':false }

  },
  temp_mapping_list: [
    {
      'target': 'project_apimapper_list',
      'source': ['project_apimapper_connection_list', 'project_apimapper_mapper_list']
    }, {
      'target': 'project_apimapper_create',
      'source': ['project_apimapper_connection_create', 'project_apimapper_mapper_create']
    }, {
      'target': 'project_apimapper_update',
      'source': ['project_apimapper_connection_update', 'project_apimapper_mapper_update']
    }, {
      'target': 'project_apimapper_delete',
      'source': ['project_apimapper_connection_delete', 'project_apimapper_mapper_delete']
    }

  ]

}
