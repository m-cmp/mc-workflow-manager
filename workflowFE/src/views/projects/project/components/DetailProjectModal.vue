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
          class="content-wrapper"
          label-position="top"
          label-width="100px"
          :model="state.editData"
          :rules="state.inputRules"
          >
            <div class="modal-body">
              
              <!-- 구분/OSS명 -->
              <div class="fs-6 text-gray-800 fw-bold me-5 ossTop">
                <!-- <el-form-item prop="ossCd" class="d-flex flex-column mb-7 fv-row ossTop_ossCd">
                  <span class="field-label required align-items-center fs-6 mb-4 h-25px">
                    {{ $t('configuration.toolChain.ossCd') }}
                  </span>
                  <el-select
                    class=""
                    v-model="state.editData.ossCd"
                    :placeholder="$t('configuration.toolChain.msgOssSelect')"
                    style="width: 100%; margin: 0;"
                  >
                    <el-option
                      v-for="item in state.ossCdList"
                      :key="item.commonCd"
                      :label="item.commonCd"
                      :value="item.commonCd"
                    />
                  </el-select>
                </el-form-item> -->

                <!-- OSS 명 -->
                <el-form-item prop="ossName" class="d-flex ossTop_ossName">
                  <!-- OSS 명 타이틀-->
                  <span 
                    class="field-label"
                    :class="{'required' : state.editData.ossCd !== ''}"
                  >
                    <!-- {{ $t('configuration.toolChain.ossName') }} -->
                    프로젝트명
                  </span>
                  <!-- OSS 명 input -->
                  <el-input
                    v-model.trim="state.editData.ossName"
                    :placeholder="'프로젝트명을 입력하세요'"
                    @input="onChangeInputDuplicateCheck"
                  />
                </el-form-item>
              </div>
              <!-- 구분/OSS명 -->
                    
              <!-- URL -->
              <el-form-item prop="ossUrl">
                <!-- URL 타이틀 -->
                <span 
                  class="field-label"
                  :class="{'required' : state.editData.ossCd !== ''}"
                >
                GitLab 주소
              </span>
                <!-- URL input -->
                <el-input
                  v-model.trim="state.editData.ossUrl"
                  :placeholder="'GitLab 주소를 입력하세요'"
                  @input="onChangeInputConnection"/>
              </el-form-item>

              <!-- 사용자명 / 비밀번호 -->
              <div class="d-flex">
                <!-- 사용자명 -->
                <div class="fs-6 fw-bold text-gray-800 fw-bold me-5">
                  <el-form-item inline-message="true" prop="ossUsername" class="ossUserName">
                    <!-- 사용자명 타이틀 -->
                    <span 
                      class="field-label"
                      :class="{'required' : state.editData.ossCd !== ''}"
                    >
                      GitLab ID
                    </span>
                    <!-- 사용자명 input -->
                    <el-input
                      v-model="state.editData.ossUsername"
                      :placeholder="'GitLab ID 를 입력하세요'"
                      @input="onChangeInputConnection"/>
                  </el-form-item>
                </div>
                
                <!-- 패스워드 -->
                <div class="fs-0 fw-bold text-gray-800 fw-bold me-5">
                  <el-form-item inline-message="true" prop="ossPassword" class="ossPassWord">
                    <!-- 패스워드 타이틀 -->
                    <span 
                      class="field-label"
                      :class="{'required' : state.editData.ossCd !== ''}"
                    >
                      GitLab P/W
                    </span>
                    <!-- 패스워드 input -->
                    <el-input
                      v-model="state.editData.ossPassword"
                      type="password"
                      :placeholder="'GitLab 비밀번호를 입력하세요'"
                      @change="onChangeInputConnection"/>
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

              <!-- 중복체크 -->
              <div class="d-flex align-items-center me-5 checkBtn">
                <!-- 중복체크 버튼 - 비활성화-->
                <el-button
                  v-if="state.isDuplicateChecked == false"
                  type="primary"
                  :loading="state.isChecking"
                  @click="onDuplicate">
                  중복체크
                </el-button>
                <!-- 중복체크 버튼 - 활성화-->
                <el-button
                  v-if="state.isDuplicateChecked == true"
                  type="success"
                  icon="el-icon-success">
                  중복체크
                </el-button>

                <!-- 연결확인 버튼 - 비활성화 -->
                <el-button
                  v-if="state.isConnectChecked == false"
                  type="primary"
                  :loading="state.isConnecting"
                  @click="onTestConnection">
                  중복체크
                </el-button>
                <!-- 연결확인 버튼 - 활성화 -->
                <el-button
                  v-if="state.isConnectChecked == true"
                  type="success"
                  icon="el-icon-success">
                  중복체크
                </el-button>
              </div>

              <!-- OSS Desc -->
              <div class="fs-6 fw-bold text-gray-800 fw-bold mb-7 me-5">
                <el-form-item prop="ossDesc">
                <!-- OSS Desc 타이틀 -->
                <span class="field-label">
                  프로젝트 설명
                </span>
                <!-- OSS Desc input -->
                <el-input
                  type="textarea"
                  rows="4"
                  v-model="state.editData.ossDesc"
                  :placeholder="'프로젝트 설명을 입력하세요'"/>
                </el-form-item> 
              </div>
            </div>

            <!-- FOOTER (BUTTON) -->
            <div class="modal-footer flex-center">
              <el-form-item size="medium" class="submit-wrapper">
                <!-- 취소 버튼 -->
                <button
                  class="btn btn-light me-3"
                  style="width:10em;"
                  data-bs-dismiss="modal"
                  ref="modal"
                  @click="initEditData"> 
                  {{ $t("common.cancel") }} 
                </button>
                <!-- 저장 버튼 -->
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
// import { checkOssConnection, getOssDuplicate, setOssConnection } from "@/api/preference";
import {useStore} from 'vuex';
// import { connectionActions } from "@/store/modules/connection";

export default defineComponent({
  name: "DetailProjectModal",
  components: {},

  props: {
    callBack: {
      type: Function,
    },
  },
  setup(props) {
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
        // companyId: computed(()=> store.state.share.companyInfo.companyId),
        // ossCdList: computed(()=> store.state.connection.ossCdList),
        // editData: computed(()=> store.state.connection.editData),
        editData: {
          companyId: 0,
          ossCd: 'gitlab',
          ossName: '',
          ossDesc: '',
          ossUrl: '',
          ossUsername: '',
          ossPassword: '',
          ossToken: '',
        } as any,

        
        isConnecting: false,
        isConnectChecked: false,
        isChecking: false,
        isDuplicateChecked: false,

        // validation rule 처리
        inputRules: {
          ossName: [
            {
              required: true,
              trigger: "blur",
              validator: _validateName,
              labelName: "Name",
            },
          ],
          ossUrl: [
            {
              required: true,
              trigger: "blur",
              validator: _validateURL,
              labelName: "URL",
            },
          ],
          ossToken: [
            {
              required: true,
              trigger: "blur",
              validator: _validateName,
              labelName: "API Token",
            },
            {
              required: true,
              trigger: "blur",
              validator: _validateLength,
              length: 4,
            },
          ],
          ossUsername: [
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
          ossPassword: [
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
          ossDesc:[
            {
              required: true,
              trigger: 'blur',
              validator: _valdateLimitLength,
              length: 250
            }
          ]
        },
      });
      
      function invoke() {
        init()
      }

      function init() {
        state.value.editData = {
          companyId: 0,
          ossCd: 'gitlab',
          ossName: '',
          ossDesc: '',
          ossUrl: '',
          ossUsername: '',
          ossPassword: '',
          ossToken: '',
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
            companyId: state.value.companyId,
            ossName: editData.ossName,
            ossUrl: editData.ossUrl,
            ossUsername: editData.ossUsername,
          }
          
          // 중복체크
          // const response = await getOssDuplicate(params);
          const response = {} as any;

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
            companyId: state.value.companyId,
            ossCd: editData.ossCd,
            ossName: editData.ossName,
            ossDesc: editData.ossDesc,
            ossUrl: editData.ossUrl,
            ossUsername: editData.ossUsername,
            ossPassword: editData.ossPassword,
            ossToken: editData.ossToken,
          }

          // 연결 테스트
          // const response = await checkOssConnection(params);
          const response = {} as any
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

      const ossCdCheck = computed(()=> {
        if(state.value.editData.ossCd.toLowerCase() =='gitlab' || state.value.editData.ossCd.toLowerCase() =='sonarqube')
          return true;
        else
          return false;
      })

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
            companyId: state.value.companyId,
            ossCd: editData.ossCd,
            ossName: editData.ossName,
            ossDesc: editData.ossDesc,
            ossUrl: editData.ossUrl,
            ossUsername: editData.ossUsername,
            ossPassword: editData.ossPassword,
            ossToken: editData.ossToken,
          }

          // const response = await setOssConnection(params);
          const response = {} as any;

          if ((response as any).code === 200) {
            toast.success(t("msg.saved"));  
            initEditData;
            (instance?.refs.btnClose as any).click();
            (props as any).callBack() 
          } else {
            toast.error(t("msg.runFail"));
          }
        } catch (e) {
          toast.error(t("msg.runFail"));
        }
      };
      
      return {
          instance,
          state, t,
          ossCdCheck,
          invoke,

          onChangeInputDuplicateCheck,
          onChangeInputConnection,
          initEditData,
          submitForm,
          onDuplicate,
          executeDuplicatCheck,
          onTestConnection,
          executeTestConnection,
      };
  },
});
</script>


<style scoped>
.ossTop {
  width: 100%;
}
.ossTop_ossCd {
  width: 46%;
  display: inline-block !important;  
  margin-right: 3em; 
}
.ossTop_ossName {
  width: 46%;
  display: inline-block !important;   
}
.ossToken {
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
.ossUserName {
  width: 89%;
  margin-right: 4em;
}
.ossPassWord {
  width: 100%;
}
</style>