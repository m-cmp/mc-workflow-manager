<template>
  <div class="modal fade" id="AddConnectionModal" aria-hidden="true" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered mw-650px">
      <div class="modal-content">

        <!-- 헤더 -->
        <div class="modal-header" id="new_organization_header">
          <!-- 타이틀 -->
          <h2 class="fw-bolder text-gray-700">
            {{ $t("configuration.toolChain.addOSS") }}
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
          ref="addToolChainForm"
          >
            <div class="modal-body">
              
              <!-- 구분/OSS명 -->
              <div class="fs-6 text-gray-800 fw-bold me-5 ossTop">
                <!-- 구분 -->
                <el-form-item prop="ossCd" class="d-flex flex-column mb-7 fv-row ossTop_ossCd">
                  <!-- 구분 타이틀 -->
                  <span class="field-label required align-items-center fs-6 mb-4 h-25px">
                    {{ $t('configuration.toolChain.ossCd') }}
                  </span>
                  <!-- 구분 Select -->
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
                </el-form-item>

                <!-- OSS 명 -->
                <el-form-item prop="ossName" class="d-flex ossTop_ossName">
                  <!-- OSS 명 타이틀-->
                  <span class="field-label required">
                    {{ $t('configuration.toolChain.ossName') }}
                  </span>
                  <!-- OSS 명 input -->
                  <el-input
                    v-model.trim="state.editData.ossName"
                    :placeholder="$t('configuration.toolChain.msgOssName')"
                    @input="onChangeInputDuplicateCheck()"
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
                  {{ $t("configuration.toolChain.ossUrl") }}
                </span>
                <!-- URL input -->
                <el-input
                  v-model.trim="state.editData.ossUrl"
                  :placeholder="$t('configuration.toolChain.msgURLInput')"
                  @input="onChangeInputDuplicateCheck(), onChangeInputConnection()"/>
              </el-form-item>

              <!-- 사용자명 / 비밀번호 -->
              <div class="d-flex">
                <!-- 사용자명 -->
                <div class="fs-6 fw-bold text-gray-800 fw-bold me-5">
                  <el-form-item inline-message="true" prop="ossUsername" class="ossUserName">
                    <!-- 사용자명 타이틀 -->
                    <span class="field-label required">
                      {{ $t("common.userName") }}
                    </span>
                    <!-- 사용자명 input -->
                    <el-input
                      v-model="state.editData.ossUsername"
                      :placeholder="$t('configuration.toolChain.msgOssUserName')"
                      @input="onChangeInputDuplicateCheck(), onChangeInputConnection()"/>
                  </el-form-item>
                </div>
                
                <!-- 패스워드 -->
                <div class="fs-0 fw-bold text-gray-800 fw-bold me-5">
                  <el-form-item inline-message="true" prop="ossPassword" class="ossPassWord">
                    <!-- 패스워드 타이틀 -->
                    <span class="field-label required">
                      {{ $t("common.pw") }}
                    </span>
                    <!-- 패스워드 input -->
                    <el-input
                      v-model="state.editData.ossPassword"
                      type="password"
                      :placeholder="$t('common.pw')"
                      @change="onChangeInputConnection()"
                      @focus="onClickedPasswordInput()"
                    />
                  </el-form-item>
                </div>
              </div>

              <!-- OSS 토큰 -->
              <div class="ossToken">
                <el-form-item prop="ossToken">
                  <!-- OSS 토큰 타이틀 -->
                  <span class="field-label">
                    {{ $t("configuration.toolChain.ossToken") }}
                  </span>
                  <!-- OSS 토큰 input -->
                  <el-input
                    :disabled=!ossCdCheck
                    type="password"
                    v-model.trim="state.editData.ossToken"
                    :placeholder="$t('configuration.toolChain.msgOssToken')"
                    @input="onChangeInputConnection()"
                    @focus="onClickedTokenInput()"
                  />
                </el-form-item>
              </div>

              <!-- 중복체크 -->
              <div class="d-flex align-items-center me-5 checkBtn">
                <!-- 중복체크 버튼 - 비활성화-->
                <el-button
                  v-if="state.isDuplicateChecked == false"
                  type="primary"
                  :loading="state.isChecking"
                  @click="onDuplicate">
                  {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                </el-button>
                <!-- 중복체크 버튼 - 활성화-->
                <el-button
                  v-if="state.isDuplicateChecked == true"
                  type="success"
                  icon="el-icon-success">
                  {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                </el-button>

                <!-- 연결확인 버튼 - 비활성화 -->
                <el-button
                  v-if="state.isConnectChecked == false"
                  type="primary"
                  :loading="state.isConnecting"
                  @click="onTestConnection">
                  {{ $t("configuration.toolChain.btnCheckConnection") }}
                </el-button>
                <!-- 연결확인 버튼 - 활성화 -->
                <el-button
                  v-if="state.isConnectChecked == true"
                  type="success"
                  icon="el-icon-success">
                  {{ $t("configuration.toolChain.btnCheckConnection") }}
                </el-button>
              </div>

              <!-- OSS Desc -->
              <div class="fs-6 fw-bold text-gray-800 fw-bold mb-7 me-5">
                <el-form-item prop="ossDesc">
                <!-- OSS Desc 타이틀 -->
                <span class="field-label">
                  {{ $t("configuration.toolChain.ossDesc") }}
                </span>
                <!-- OSS Desc input -->
                <el-input
                  type="textarea"
                  rows="4"
                  v-model="state.editData.ossDesc"
                  :placeholder="$t('configuration.toolChain.msgOssDesc')"/>
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
                  v-if="state.isConnectChecked && state.isDuplicateChecked"
                  class="btn btn-primary"
                  style="width:10em;"
                  @click="onClickSubmit">
                  등록
                </button>
                <button
                  v-else
                  class="btn btn-primary"
                  style="width:10em;"
                  disabled
                >
                  등록
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
import { checkOssConnection, getOssDuplicate, setOssConnection } from "@/api/preference";
import {useStore} from 'vuex';
import { connectionActions } from "@/store/modules/connection";
import _ from "lodash";

export default defineComponent({
  name: "AddConnectionModal",
  components: {},

  props: {
    loadData: {
      type: Function,
    },
  },
  setup(props, { emit }) {
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
        ossCdList: computed(()=> store.state.connection.ossCdList),
        editData: computed(()=> store.state.connection.editData),

        isConnecting: false,
        isConnectChecked: false,
        isChecking: false,
        isDuplicateChecked: false,
        isChangedPassword: false,
        isChangedToken: false,

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
        init();
        (instance?.refs.addToolChainForm as any).clearValidate(state.value.editData);
      }

      function init() {
        state.value.editData = {
          // companyId: 0,
          ossCd: '',
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
        try {
          state.value.isChecking = true;

          const editData = state.value.editData;

          let params = {
            // companyId: state.value.companyId,
            ossName: editData.ossName,
            ossUrl: editData.ossUrl,
            ossUsername: editData.ossUsername,
          }
          
          // 중복체크
          const response = await getOssDuplicate(params);

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

          // if(state.value.isChangedPassword === true) {
          //   state.value.editData.ossPassword = btoa(state.value.editData.ossPassword)
          // }
          // if(state.value.isChangedToken === true) {
          //   state.value.editData.ossToken = btoa(state.value.editData.ossToken)
          // }

          const editData = state.value.editData;

          let encodingPwd = editData.ossPassword
          let encodingToken = editData.ossToken

          if(editData.ossCd.toUpperCase() !== "TUMBLEBUG") {
            encodingPwd = btoa(editData.ossPassword)
            encodingToken = btoa(editData.ossToken)
          }
          
          let params = {
            // companyId: state.value.companyId,
            ossCd: editData.ossCd,
            ossName: editData.ossName,
            ossDesc: editData.ossDesc,
            ossUrl: editData.ossUrl,
            ossUsername: editData.ossUsername,
            ossPassword:  encodingPwd,
            ossToken: encodingToken,
          }

          // 연결 테스트
          const response = await checkOssConnection(params);

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
        // if(state.value.editData.ossCd.toLowerCase() =='sonarqube')
        //   return true;
        // else
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
        store.dispatch(connectionActions.NAMESPACE + "/" + connectionActions.CLEAR_EDIT_DATA)
        state.value.isConnecting = false,
        state.value.isConnectChecked = false,
        state.value.isChecking = false,
        state.value.isDuplicateChecked = false
      }
 
      async function onClickSubmit() {
        if (state.value.isConnectChecked == false) {
          toast.error(t("msg.connectMessage"));
          return false;
        } else if (state.value.isDuplicateChecked == false) {
          toast.error(t("msg.duplicateMessage"));
          return false;
        }

        try {          
          const editData = state.value.editData;

          let encodingPwd = btoa(editData.ossPassword)
          let encodingToken = btoa(editData.ossToken)

          let params = {
            // companyId: state.value.companyId,
            ossCd: editData.ossCd,
            ossName: editData.ossName,
            ossDesc: editData.ossDesc,
            ossUrl: editData.ossUrl,
            ossUsername: editData.ossUsername,
            ossPassword: encodingPwd,
            ossToken: encodingToken,
          }

          const response:any = await setOssConnection(params);

          if (response.code === 200) {
            toast.success(t("msg.saved"))
            // initEditData;
            // (instance?.refs.btnClose as any).click();
            // emit("loadData", {})
          } else {
            toast.error(t("msg.runFail"));
          }
        } catch (e) {
          console.log(e)
          toast.error(t("msg.runFail"));
        }
      };

      function onClickedPasswordInput() {
        state.value.editData.ossPassword = '';
        state.value.isChangedPassword = true;
        onChangeInputConnection();
      }

      function onClickedTokenInput() {
        state.value.editData.ossToken = '';
        state.value.isChangedToken = true;
        onChangeInputConnection();
      }
      
      return {
          instance,
          state,
          ossCdCheck,
          invoke,

          onChangeInputDuplicateCheck,
          onChangeInputConnection,
          onClickedPasswordInput,
          onClickedTokenInput,

          initEditData,
          onClickSubmit,
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