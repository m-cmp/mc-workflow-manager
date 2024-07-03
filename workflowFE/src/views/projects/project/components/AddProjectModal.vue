<template>
  <div class="modal fade" id="modalProjectNew" aria-hidden="true" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered mw-650px">
      <div class="modal-content">

        <!-- 헤더 -->
        <div class="modal-header" id="new_organization_header">
          <!-- 타이틀 -->
          <h2 class="fw-bolder text-gray-700">
            프로젝트 생성
          </h2>
          <!-- X 표시 -->
          <div
            ref="btnClose"
            data-bs-dismiss="modal"
            class="btn btn-icon btn-sm btn-active-icon-primary">
            <span class="svg-icon svg-icon-1">
              <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
            </span>
          </div>
        </div>
  
        <el-form
          ref="newForm"
          class="content-wrapper"
          label-position="top"
          label-width="100px"
          :model="state.editData"
          :rules="state.inputRules"
          >
            <div class="modal-body">
              
              <div class="fs-6 text-gray-800 fw-bold me-5 projectTop">
                <label style="color: #F1416C;">
                  Gradle 프로젝트만 등록 가능합니다!
                </label>
                <el-form-item prop="projectName" class="d-flex projectTop_projectName">
                  <span class="field-label required">
                    프로젝트명
                  </span>
                  <el-input
                    v-model="state.editData.projectName"
                    :placeholder="'프로젝트명을 입력하세요'"
                    @input="onChangeInputDuplicateCheck"
                  />
                </el-form-item>
              </div>

              <div class="fs-6 text-gray-800 fw-bold me-5 projectTop">
                <el-form-item class="d-flex projectTop_projectName">
                  <span class="field-label required">
                    패키지명
                  </span>
                  <el-input
                    ref="projectPackage"
                    v-model.trim="state.editData.projectPackage"
                    :placeholder="'패키지명을 입력하세요'"
                    @input="onChangePackageName"
                  />
                </el-form-item>
              </div>
                    
              <el-form-item prop="gitlabUrl">
                <span class="field-label required">
                  GitLab 주소
                </span>
                <el-input
                  v-model.trim="state.editData.gitlabUrl"
                  :placeholder="'GitLab 주소를 입력하세요'"
                  @input="onChangeInputConnection"/>
              </el-form-item>

              <div class="d-flex">
                <div class="fs-6 fw-bold text-gray-800 fw-bold me-5">
                  <el-form-item inline-message="true" prop="gitlabUserName" class="gitlabUserName">
                    <span class="field-label required">
                      GitLab ID
                    </span>
                    <el-input
                      v-model="state.editData.gitlabUserName"
                      :placeholder="'GitLab ID 를 입력하세요'"
                      @input="onChangeInputConnection"/>
                  </el-form-item>
                </div>
                
                <div class="fs-0 fw-bold text-gray-800 fw-bold me-5">
                  <el-form-item inline-message="true" prop="gitlabPassWord" class="gitlabPassWord">
                    <span class="field-label required">
                      GitLab P/W
                    </span>
                    <el-input
                      v-model="state.editData.gitlabPassWord"
                      type="password"
                      :placeholder="'GitLab 비밀번호를 입력하세요'"
                      @input="onChangeInputConnection"/>
                  </el-form-item>
                </div>
              </div>

              <!-- OSS 토큰 -->
              <!-- <div class="ossToken">
                <el-form-item prop="ossToken">
                  <span 
                    class="field-label"
                    :class="{'required' : state.editData.ossCd === 'GITLAB' || state.editData.ossCd === 'SONARQUBE' }"
                  >
                    {{ $t("configuration.toolChain.ossToken") }}
                  </span>
                  <el-input
                    :disabled=!ossCdCheck
                    v-model.trim="state.editData.ossToken"
                    :placeholder="$t('configuration.toolChain.msgOssToken')"
                    @input="onChangeInputConnection"/>
                </el-form-item>
              </div> -->

              <div class="d-flex align-items-center me-5 checkBtn">
                <el-form-item inline-message="true" class="gitlabBranch">
                  <span class="field-label required">
                    GitLab Branch
                  </span>
                  <el-input
                    v-model="state.editData.gitlabBranch"
                    @input="onChangeInputConnection"
                    />
                </el-form-item>

                <el-button
                  v-if="state.isDuplicateChecked == false"
                  type="primary"
                  :loading="state.isChecking"
                  @click="onDuplicate">
                  중복체크
                </el-button>
                <el-button
                  v-if="state.isDuplicateChecked == true"
                  type="success"
                  icon="el-icon-success">
                  중복체크
                </el-button>

                <el-button
                  v-if="state.isConnectChecked == false"
                  type="primary"
                  :loading="state.isConnecting"
                  @click="onTestConnection">
                  연결체크
                </el-button>
                <el-button
                  v-if="state.isConnectChecked == true"
                  type="success"
                  icon="el-icon-success">
                  연결체크
                </el-button>
              </div>

              <!-- <div class="fs-6 fw-bold text-gray-800 fw-bold mb-7 me-5">
                <el-form-item prop="projectDesc">
                <span class="field-label">
                  프로젝트 설명
                </span>
                <el-input
                  type="textarea"
                  rows="4"
                  v-model="state.editData.projectDesc"
                  :placeholder="'프로젝트 설명을 입력하세요'"/>
                </el-form-item> 
              </div> -->
            </div>

            <div class="modal-footer flex-center">
              <el-form-item size="medium" class="submit-wrapper">
                <button
                  class="btn btn-light me-3"
                  style="width:10em;"
                  data-bs-dismiss="modal"
                  ref="modal"
                  @click="initEditData"> 
                  {{ $t("common.cancel") }} 
                </button>
                <button
                  class="btn btn-primary"
                  style="width:10em;"
                  @click.stop="submitForm()"> 
                  {{ $t("common.save") }} 
                </button>
              </el-form-item>
            </div>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import {computed, defineComponent, getCurrentInstance, ref} from "vue";
import {useI18n} from "vue-i18n";
import {useToast} from "vue-toastification";
import { _validateName, _validateLength, _validateSelect, _valdateLimitLength, _validateURL} from '@/utils/input-validate.js'
import {useStore} from 'vuex';
import { checkProjectConnection, getProjectDuplicate, setProject } from "@/api/projects";

export default defineComponent({
  name: "AddProjectModal",
  setup(props, {emit}) {
      /* ============================================================================================================= */
      // 다국어 설정
      /* ============================================================================================================= */
      
      let { t, locale } = useI18n();

      /* ============================================================================================================= */
      // 데이터 정의
      /* ============================================================================================================= */
      
      const instance = getCurrentInstance();
      
      const toast = useToast();
      const store = useStore();
      const state = ref({
        editData: {
          companyId: 0,
          // ossCd: 'gitlab',
          projectName: '',
          projectPackage: '',
          // projectDesc: '',
          gitlabUrl: '',
          gitlabUserName: '',
          gitlabPassWord: '',
          // ossToken: '',
          gitlabBranch: 'master',
        } as any,

        
        isConnecting: false,
        isConnectChecked: false,
        isChecking: false,
        isDuplicateChecked: false,

        // validation rule 처리
        inputRules: {
          projectName: [
            {
              required: true,
              trigger: "blur",
              validator: _validateName,
              labelName: "Name",
            },
          ],
          gitlabUrl: [
            {
              required: true,
              trigger: "blur",
              validator: _validateURL,
              labelName: "URL",
            },
          ],
          // ossToken: [
          //   {
          //     required: true,
          //     trigger: "blur",
          //     validator: _validateName,
          //     labelName: "API Token",
          //   },
          //   {
          //     required: true,
          //     trigger: "blur",
          //     validator: _validateLength,
          //     length: 4,
          //   },
          // ],
          gitlabUserName: [
            {
              required: true,
              trigger: "blur",
              validator: _validateName,
              labelName: "Username",
            },
            {
              required: true,
              trigger: "blur",
              validator: _validateLength,
              length: 4,
            },
          ],
          gitlabPassWord: [
            {
              required: true,
              trigger: "blur",
              validator: _validateName,
              labelName: "Password",
            },
            {
              required: true,
              trigger: "blur",
              validator: _validateLength,
              length: 4,
            },
          ],
          // projectDesc:[
          //   {
          //     required: true,
          //     trigger: 'blur',
          //     validator: _valdateLimitLength,
          //     length: 250
          //   }
          // ]
        },
      });
      
      function invoke() {
        init();
        (instance?.refs.newForm as any).clearValidate();
      }

      function init() {
        state.value.editData = {
          companyId: 0,
          // ossCd: 'gitlab',
          projectName: '',
          // projectDesc: '',
          gitlabUrl: '',
          gitlabUserName: '',
          gitlabPassWord: '',
          // ossToken: '',
          gitlabBranch: 'master',
        };

        state.value.isConnecting = false;
        state.value.isConnectChecked = false;
        state.value.isChecking = false;
        state.value.isDuplicateChecked = false;
      }

      function onDuplicate() {
        if (state.value.isChecking == false) {
          executeDuplicatCheck();
        } else {
          toast.info(t("msg.duplicatChecking"));
        }
      }

      async function executeDuplicatCheck() {
        console.log(instance?.refs)
        try {
          state.value.isChecking = true;

          const editData = state.value.editData;

          let params = {
            projectName: editData.projectName,
            gitlabUrl: editData.gitlabUrl,
            branch: editData.gitlabBranch,
          }
          
          // 중복체크
          const response = await getProjectDuplicate(params);

          state.value.isChecking = false;

          if (response) {
            toast.success(t("msg.duplicateSuccess"));
            state.value.isDuplicateChecked = true;
          } else {
            toast.error(t("msg.duplicateFailed"));
            state.value.isDuplicateChecked = false;
          }
        } catch (error) {
          toast.error(t("msg.duplicateFailed"));
          console.error(error);

          state.value.isDuplicateChecked = false;
          state.value.isChecking = false;
        }
      }


      function onTestConnection() {
        if (state.value.isConnecting == false) {
          executeTestConnection();
        } else {
          toast.info(t("msg.connecting"));
        }
      }

      async function executeTestConnection() {
        try {
          state.value.isConnecting = true;

          const editData = state.value.editData;

          let params = {
            projectName:editData.projectName,
            gitlabCloneHttpUrl:editData.gitlabUrl,
            gitlab : {
              branch: editData.gitlabBranch,
              username: editData.gitlabUserName,
              password: btoa(editData.gitlabPassWord)
            }
          }
          console.log(params)
          // 연결 테스트
          const response = await checkProjectConnection(params);
          state.value.isConnecting = false;

          if (response.data) {
            toast.success(t("msg.connectSuccess"));
            state.value.isConnectChecked = true;
          } else {
            toast.error(t("msg.connectFailed"));
            state.value.isConnectChecked = false;
          }
        } catch (error) {
          toast.error(t("msg.connectFailed"));
          console.error(error);

          state.value.isConnectChecked = false;
          state.value.isConnecting = false;
        }
      }

      // const ossCdCheck = computed(()=> {
      //   if(state.value.editData.ossCd.toLowerCase() =='gitlab' || state.value.editData.ossCd.toLowerCase() =='sonarqube')
      //     return true;
      //   else
      //     return false;
      // })

      function onChangeInputConnection() {
        console.log('onChangeInputConnection')
        state.value.isConnectChecked = false;
      }

      function onChangeInputDuplicateCheck() {
        console.log('onChangeInputDuplicateCheck')
        state.value.isDuplicateChecked = false;
      }

      function initEditData() {
        // store.dispatch(connectionActions.NAMESPACE + "/" + connectionActions.CLEAR_EDIT_DATA)
        state.value.isConnecting = false,
        state.value.isConnectChecked = false,
        state.value.isChecking = false,
        state.value.isDuplicateChecked = false
      }
 
      async function submitForm() {
        if (state.value.isConnectChecked == false) {
          toast.error(t("msg.connectMessage"));
          return;
        } else if (state.value.isDuplicateChecked == false) {
          toast.error(t("msg.duplicateMessage"));
          return;
        }

        try {          
          const editData = state.value.editData;

          let params = {
            projectName:editData.projectName,
            packageName:editData.projectPackage,
            gitlabCloneHttpUrl:editData.gitlabUrl,
            gitlab : {
              branch: editData.gitlabBranch,
              username: editData.gitlabUserName,
              password: btoa(editData.gitlabPassWord)
            }
          }

          const response:any = await setProject(params);
          
          if(response.code === 1107) {
            toast.error("Gradle 프로젝트가 아닙니다.");
          }
          else if (response.code === 200) {
            toast.success(t("msg.saved"));  
            initEditData;
            (instance?.refs.btnClose as any).click();
            emit('callback', {})

          } 
          else {
            console.log(response.code)
            toast.error(t("msg.runFail"));
          }
        } catch (e) {
          console.log(e)
          toast.error(t("msg.runFail"));
        }
      };
     
      function onChangePackageName() {
        let input = state.value.editData.projectPackage;

        const regex = /^[a-zA-Z][a-zA-Z0-9._-]*$/;

        if (!regex.test(input)) {
          if(input.length == 1) {
            input = input.replace(/[^a-zA-Z0-9._-]/g, '');
          }
          else {
            input = input.replace(/[^a-zA-Z0-9._-]/g, '');
          }
          state.value.editData.projectPackage = input;
        }

        (instance?.refs.projectPackage as any).handleBlur();
      }
      
      return {
          instance,
          state, t,
          invoke,

          onChangeInputDuplicateCheck,
          onChangeInputConnection,
          initEditData,
          submitForm,
          onDuplicate,
          executeDuplicatCheck,
          onTestConnection,
          executeTestConnection,
          onChangePackageName,
      };
  },
});
</script>


<style scoped>
.projectTop {
  width: 100%;
}
/* .gitlabToken {
  width: 46%;
  display: inline-block !important;
  margin-right: 4em;
} */

.gitlabBranch {
  width: 46%;
  display: inline-block !important;
  margin-right: 4em;
}

.checkBtn {
  display: inline-block !important;
}
.checkBtn > button {
  margin-right: 0.5em;
}
.gitlabUserName {
  width: 89%;
  margin-right: 4em;
}
.gitlabPassWord {
  width: 100%;
}
</style>