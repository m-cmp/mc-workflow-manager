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
          :model="newData"
          :rules="inputRules"
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
                    v-model="newData.ossCd"
                    :placeholder="$t('configuration.toolChain.msgOssSelect')"
                    style="width: 100%; margin: 0;"
                  >
                    <el-option
                      v-for="item in ossCdList"
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
                    v-model.trim="newData.ossName"
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
                  :class="{'required' : newData.ossCd !== ''}"
                >
                  {{ $t("configuration.toolChain.ossUrl") }}
                </span>
                <!-- URL input -->
                <el-input
                  v-model.trim="newData.ossUrl"
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
                      v-model="newData.ossUsername"
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
                      v-model="newData.ossPassword"
                      type="password"
                      :placeholder="$t('common.pw')"
                      @change="onChangeInputConnection()"
                      @focus="onClickedPasswordInput()"
                    />
                  </el-form-item>
                </div>
              </div>

              <div class="ossToken">
                <el-form-item prop="ossToken">
                  <span class="field-label">
                    {{ $t("configuration.toolChain.ossToken") }}
                  </span>
                  <el-input
                    :disabled=!ossCdCheck
                    type="password"
                    v-model.trim="newData.ossToken"
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
                  v-if="isDuplicateChecked == false"
                  type="primary"
                  :loading="isChecking"
                  @click="onDuplicate">
                  {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                </el-button>
                <!-- 중복체크 버튼 - 활성화-->
                <el-button
                  v-if="isDuplicateChecked == true"
                  type="success"
                  icon="el-icon-success">
                  {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                </el-button>

                <!-- 연결확인 버튼 - 비활성화 -->
                <el-button
                  v-if="isConnectChecked == false"
                  type="primary"
                  :loading="isConnecting"
                  @click="onTestConnection">
                  {{ $t("configuration.toolChain.btnCheckConnection") }}
                </el-button>
                <!-- 연결확인 버튼 - 활성화 -->
                <el-button
                  v-if="isConnectChecked == true"
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
                  v-model="newData.ossDesc"
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
                  @click="init()"> 
                  {{ $t("common.cancel") }} 
                </button>
                <!-- 저장 버튼 -->
                <button
                  v-if="isConnectChecked && isDuplicateChecked"
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

<script setup lang="ts">
import {computed, defineComponent, getCurrentInstance, ref, watch} from "vue";
import {useI18n} from "vue-i18n";
import {useToast} from "vue-toastification";
import { _validateName, _validateLength, _validateSelect, _valdateLimitLength, _validateURL} from '@/utils/input-validate.js'
import { checkOssConnection, getOssDuplicate, setOssConnection } from "@/api/preference";
import {useStore} from 'vuex';
import _ from "lodash";

import { NewData, OssCd } from "@/views/projects/connection/type/type"
import { getCommonOssList } from "@/api/preference";


const emit = defineEmits(['load-data'])

const { t } = useI18n();
const instance = getCurrentInstance();
const toast = useToast();
const store = useStore();

const newData = ref({} as NewData)
const isConnecting = ref(false as boolean)
const isConnectChecked = ref(false as boolean)
const isChecking = ref(false as boolean)
const isDuplicateChecked = ref(false as boolean)
const isChangedPassword = ref(false as boolean)
const isChangedToken = ref(false as boolean)

const invoke = async() => {
  init();
  await getCdOssList();
  (instance?.refs.addToolChainForm as any).clearValidate(newData.value);
}

const init = () => {
  newData.value = {
    ossCd: '',
    ossName: '',
    ossDesc: '',
    ossUrl: '',
    ossUsername: '',
    ossPassword: '',
    ossToken: '',
  };

  isConnecting.value = false;
  isConnectChecked.value = false;
  isChecking.value = false;
  isDuplicateChecked.value = false;
}

const ossCdList = ref([] as Array<OssCd>)
const getCdOssList = async () => {
  try {
    const { data } = await getCommonOssList()
    ossCdList.value = data

    // ossCdList 받아올때 목록에 있는 OssCd 미노출
    const ossList = store.state.connection.ossList
    ossCdList.value.filter((ossCdInfo, idx) => {
      ossList.filter((registeredOssInfo) => {
        if (ossCdInfo.commonCd === registeredOssInfo.ossCd) {
          ossCdList.value.splice(idx, 1)
        }
      })
    })

  } catch (error) {
    toast.error('oss 목록을 가져올 수 없습니다.')
  }
}

const onDuplicate = () => {
  if (!isChecking.value) {
    executeDuplicatCheck();
  } else {
    toast.info(t("msg.duplicatChecking"));
  }
}

const executeDuplicatCheck = async() => {
  try {
    isChecking.value = true;

    let params = {
      ossName: newData.value.ossName,
      ossUrl: newData.value.ossUrl,
      ossUsername: newData.value.ossUsername,
    }

    // 중복체크
    const response = await getOssDuplicate(params);

    isChecking.value = false;

    if (response) {
      toast.success(t("msg.duplicateSuccess"));
      isDuplicateChecked.value = true;
    } else {
      toast.error(t("msg.duplicateFailed"));
      isDuplicateChecked.value = false;
    }
  } catch (error) {
    toast.error(t("msg.duplicateFailed"));
    isDuplicateChecked.value = false;
    isChecking.value = false;
  }
}

const onTestConnection = () => {
  if (isConnecting.value == false) {
    executeTestConnection();
  } else {
    toast.info(t("msg.connecting"));
  }
}

const executeTestConnection = async() => {
  try {
    isConnecting.value = true;

    let newDataReq = newData.value

    const encodingPwd = btoa(newDataReq.ossPassword)
    const encodingToken = btoa(newDataReq.ossToken)

    let params = {
      ossCd: newDataReq.ossCd,
      ossName: newDataReq.ossName,
      ossDesc: newDataReq.ossDesc,
      ossUrl: newDataReq.ossUrl,
      ossUsername: newDataReq.ossUsername,
      ossPassword: encodingPwd,
      ossToken: encodingToken,
    }

    // 연결 테스트
    const response = await checkOssConnection(params);
    isConnecting.value = false;

    if (response.data) {
      toast.success(t("msg.connectSuccess"));
      isConnectChecked.value = true;
    } else {
      toast.error(t("msg.connectFailed"));
      isConnectChecked.value = false;
    }
  } catch (error) {
    toast.error(t("msg.connectFailed"));
    console.error(error);

    isConnectChecked.value = false;
    isConnecting.value = false;
  }
}

const ossCdCheck = computed(() => {
  return false;
})

const onChangeInputConnection = () => {
  isConnectChecked.value = false;
}

const onChangeInputDuplicateCheck = () => {
  isDuplicateChecked.value = false;
}

const onClickSubmit = async() => {
  if (!isConnectChecked.value) {
    toast.error(t("msg.connectMessage"));
    return false;
  } else if (!isDuplicateChecked.value) {
    toast.error(t("msg.duplicateMessage"));
    return false;
  }

  try {

    let newDataReq = newData.value

    let encodingPwd = btoa(newDataReq.ossPassword)
    let encodingToken = btoa(newDataReq.ossToken)

    let params = {
      ossCd: newDataReq.ossCd,
      ossName: newDataReq.ossName,
      ossDesc: newDataReq.ossDesc,
      ossUrl: newDataReq.ossUrl,
      ossUsername: newDataReq.ossUsername,
      ossPassword: encodingPwd,
      ossToken: encodingToken,
    }

    const response = await setOssConnection(params);

    if (response.code === 200) {
      toast.success(t("msg.saved")) as any
      (instance?.refs.btnClose as any).click();
      emit('load-data')
    } else {
      toast.error(t("msg.runFail"));
    }
  } catch (e) {
    console.log(e)
    toast.error(t("msg.runFail"));
  }
};

const onClickedPasswordInput= () => {
  newData.value.ossPassword = '';
  isChangedPassword.value = true;
  onChangeInputConnection();
}

const onClickedTokenInput = () => {
  newData.value.ossToken = '';
  isChangedToken.value = true;
  onChangeInputConnection();
}

const inputRules = {
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
  ossDesc: [
    {
      required: true,
      trigger: 'blur',
      validator: _valdateLimitLength,
      length: 250
    }
  ]
}

defineExpose({
  invoke,
})
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