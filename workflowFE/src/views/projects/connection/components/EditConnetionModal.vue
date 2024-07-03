<template>
  <div class="modal fade" id="editConnetionModal" aria-hidden="true" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered mw-650px">
      <div class="modal-content">
        <div class="modal-header" id="new_organization_header">

          <!-- 
            OSS 수정 타이틀
          -->
          <h2 class="fw-bolder text-gray-700">
            {{ $t("configuration.toolChain.editOSS") }}
          </h2>
          <div ref="btnClose" data-bs-dismiss="modal" class="btn btn-icon btn-sm btn-active-icon-primary">
            <span class="svg-icon svg-icon-1">
              <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
            </span>
          </div>
        </div>

        <el-form 
          v-if="state.editData != null" 
          class="content-wrapper" 
          label-position="top" 
          label-width="100px"
          :model="state.editData" 
          :rules="state.inputRules"
        >

          <div class="modal-body">
            <div class="fs-6 text-gray-800 fw-bold me-5">
              <!-- 
                구분 / OSS Name 
              -->
              <el-row>

                <!-- OSS Cd -->
                <el-form-item prop="ossCd" class="d-flex flex-column mb-7 fv-row">
                  <span 
                    class="field-label align-items-center fs-6 mb-4 h-25px required"> 
                    {{ $t('configuration.toolChain.ossCd') }} 
                  </span>
                  <el-select 
                    v-model="state.editData.ossCd" 
                    disabled 
                    style="width: 100%; margin: 0;"
                    :placeholder="$t('configuration.toolChain.msgOssSelect')" 
                  />
                </el-form-item>

                <!-- NAME -->
                <el-form-item prop="ossName" class="d-flex">
                  <span 
                    class="field-label"
                    :class="{'required' : state.editData.ossCd !== ''}"
                  >
                    {{ $t('configuration.toolChain.ossName') }}
                  </span>
                  <el-input 
                    v-model.trim="state.editData.ossName"
                    disabled 
                    :placeholder="$t('configuration.toolChain.msgOssName')" 
                    @input="onChangeInputDuplicateCheck()" 
                  />
                </el-form-item>

              </el-row>

              <!-- URL -->
              <el-form-item prop="ossUrl">
                <span 
                  class="field-label"
                  :class="{'required' : state.editData.ossCd !== ''}"
                >
                  {{ $t("configuration.toolChain.ossUrl") }}
                </span>
                <el-input 
                  v-model.trim="state.editData.ossUrl" 
                  :placeholder="$t('configuration.toolChain.msgURLInput')"
                  @input="onChangeInputConnection(), onChangeInputDuplicateCheck()" />
              </el-form-item>

              <!-- 사용자명 / 패스워드 -->
              <el-row>
                <!-- 사용자명 -->
                <el-form-item inline-message="true" prop="ossUsername">
                  <span 
                    class="field-label"
                    :class="{'required' : state.editData.ossCd !== ''}"
                  >
                    {{ $t("common.userName") }}
                  </span>
                  <el-input v-model="state.editData.ossUsername"
                    :placeholder="$t('configuration.toolChain.msgOssUserName')"
                    @input="onChangeInputConnection(), onChangeInputDuplicateCheck()" />
                </el-form-item>

                <!-- 패스워드-->
                <el-form-item inline-message="true" prop="ossPassword">
                  <span 
                    class="field-label"
                    :class="{'required' : state.editData.ossCd !== ''}"
                  >
                    {{ $t("common.pw") }}
                  </span>
                  <el-input 
                    v-model="state.editData.ossPassword" 
                    type="password" 
                    :placeholder="$t('common.pw')"
                    @input="onChangeInputConnection()" 
                    @focus="onClickedPasswordInput()"
                  />
                </el-form-item>

              </el-row>

              <!-- 툴체인 / 중복확인/연결확인 -->
              <el-row>
                <!-- ToolChain 토큰 -->
                <el-form-item prop="ossToken">
                  <span 
                    class="field-label"
                    :class="{'required' : state.editData.ossCd === 'SONARQUBE' }"
                  >
                    {{ $t("configuration.toolChain.ossToken") }}
                  </span>
                  <el-input 
                    v-model.trim="state.editData.ossToken"
                    type="password"
                    :disabled=!ossCdCheck 
                    :placeholder="$t('configuration.toolChain.msgOssToken')" 
                    @input="onChangeInputConnection()" 
                    @focus="onClickedTokenInput()"  
                  />
                </el-form-item>

                <el-form-item style="margin-top: 40px; margin-bottom: 0px;">

                  <!-- 중복체크 -->
                  <el-button v-if="state.isDuplicateChecked == false" type="primary" :loading="state.isChecking" @click="onDuplicate">
                    {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                  </el-button>
                  <el-button v-if="state.isDuplicateChecked == true" type="success" icon="el-icon-success">
                    {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                  </el-button>

                  <!-- 연결확인 -->
                  <el-button v-if="state.isConnectChecked == false" type="primary" :loading="state.isConnecting" @click="onTestConnection">
                    {{ $t("configuration.toolChain.btnCheckConnection") }}
                  </el-button>
                  <el-button v-if="state.isConnectChecked == true" type="success" icon="el-icon-success">
                    {{ $t("configuration.toolChain.btnCheckConnection") }}
                  </el-button>
                </el-form-item>
              </el-row>


              <!-- OSS Desc -->
              <div class="fs-6 fw-bold text-gray-800 fw-bold mb-7 me-5">
                <el-form-item prop="ossDesc">
                  <span class="field-label">
                    {{ $t("configuration.toolChain.ossDesc") }}
                  </span>
                  <el-input type="textarea" rows="4" v-model="state.editData.ossDesc"
                    :placeholder="$t('configuration.toolChain.msgOssDesc')" />
                </el-form-item>
              </div>
            </div>

            <!-- FOOTER (BUTTONs) -->
            <div class="modal-footer flex-center">

              <el-form-item size="medium" class="submit-wrapper">
                <button class="btn btn-light me-3" style="width:10em;" data-bs-dismiss="modal" ref="modal"
                  @click="initEditData">
                  {{ $t("common.cancel") }}
                </button>
                <button 
                  v-if="state.isConnectChecked && state.isDuplicateChecked"
                  class="btn btn-primary" 
                  style="width:10em;" 
                  @click="onClickSubmit">
                  {{ $t("common.edit") }}
                </button>
                
                <button 
                  v-else
                  class="btn btn-primary" 
                  style="width:10em;" 
                >
                  {{ $t("common.edit") }}
                </button>
              </el-form-item>
            </div>

          </div>
        </el-form>
      </div>
    </div>
  </div>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import {computed, defineComponent, getCurrentInstance, nextTick, onMounted, ref, watch} from "vue";
import {useI18n} from "vue-i18n";
import {useToast} from "vue-toastification";

import { _validateName, _validateLength, _validateSelect, _valdateLimitLength, _validateURL} from '@/utils/input-validate.js'
import { checkOssConnection, getOssDuplicate, updateOssConnection } from "@/api/preference";

import {useStore} from 'vuex';
import { connectionActions } from "@/store/modules/connection";
/* ===================================================================================================================== */

export default defineComponent({
  name: "AddConnectionModal",
  components: {},

  props: {
    loadData: {
      type: Function,
    },
  },
  setup(props, { emit }) {
      
      let { t, locale } = useI18n();
      const instance = getCurrentInstance();
      
      const toast = useToast();
      const store = useStore();
      const state = ref({
        // companyId: computed(()=> store.state.share.companyInfo.companyId),
        ossCdList: computed(()=> store.state.connection.ossCdList),
        
        editData: {
          ossId: 0,
          ossCd: '',
          ossName: '',
          ossUrl: '',
          ossUsername: '',
          ossPassword: '',
          ossToken: '',
          ossDesc: '',
        } as any,

        isConnecting: true,
        isConnectChecked: true,
        isChecking: true,
        isDuplicateChecked: true,
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

      // 부모 컴포넌트로부터 데이터 받기
      const show = (row) => {
        // 변수명을 똑같이 가져갈경우 수정시 목록에서도 값이 변경되는 이슈가 있어서 변수를 새로 만들어서 데이터 세팅을 해준다
        state.value.editData.ossId = row.ossId
        state.value.editData.ossCd = row.ossCd
        state.value.editData.ossName = row.ossName
        state.value.editData.ossUrl = row.ossUrl
        state.value.editData.ossUsername = row.ossUsername
        state.value.editData.ossPassword = row.ossPassword
        state.value.editData.ossToken = row.ossToken;
        state.value.editData.ossDesc = row.ossDesc
        // store.dispatch(connectionActions.NAMESPACE + "/" + connectionActions.SET_EDIT_DATA, row)
        initData();
      }

      function initData() {
        state.value.isConnectChecked = true
        state.value.isDuplicateChecked = true
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
          // let encodingPwd = editData.ossPassword

          let encodingToken = editData.ossToken
          const encodingPwd = btoa(editData.ossPassword)

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
        if(state.value.editData.ossCd.toLowerCase() =='sonarqube')
          return true;
        else
          return false;
      })

      function onChangeInputConnection() {
        state.value.isConnectChecked = false;
        state.value.isConnecting = false;
      }

      function onChangeInputDuplicateCheck() {
        state.value.isDuplicateChecked = false;
        state.value.isChecking = false;
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
            ossId: editData.ossId,
            ossCd: editData.ossCd,
            ossName: editData.ossName,
            ossDesc: editData.ossDesc,
            ossUrl: editData.ossUrl,
            ossUsername: editData.ossUsername,
            ossPassword: encodingPwd,
            ossToken: encodingToken,
          }

          const response:any = await updateOssConnection(params);

          if (response.code === 200) {
            toast.success(t("msg.saved"));  
            initEditData();
            (instance?.refs.btnClose as any).click();
            // props.loadData() 
            emit("loadData", {})
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
      /* ============================================================================================================= */
      
      return {
          instance,
          state,
          ossCdCheck,
          show,

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
.el-row > .el-form-item {
  width: 45%;
}
.el-row > .el-form-item:nth-child(2) {
  margin-left: 50px;
}
</style>