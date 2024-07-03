<template>
    <!-- ================================================================================ -->
    <!-- MODAL -->
    <!-- ================================================================================ -->
    <div 
      class="modal fade" 
      id="modalNewPipeLine" 
      aria-hidden="true" 
      tabindex="-1"
      ref="newPipeLineConfigModal">
  
    <!-- ================================================================================ -->
    <!-- Header -->
    <!-- ================================================================================ -->
  
      <div class="modal-dialog modal-dialog-centered mw-1000px">
        <div class="modal-content">
  
          <div class="modal-header">
  
            <h2 class="fw-bolder">{{ $t("project.pipeLine.newPipeLine") }}</h2>
            <div 
              ref="Btn_Close" 
              data-bs-dismiss="modal"
              class="btn btn-icon btn-sm btn-active-icon-primary"
            >
              <span class="svg-icon svg-icon-1">
                <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
              </span>
            </div>
          </div>
  
          <!-- ================================================================================ -->
          <!-- Contents -->
          <!-- ================================================================================ -->
          <div class="modal-body py-10 px-lg-17">
            <el-form 
              ref="newPipelineForm"
              :model="state.form" 
              label-position="top"
              :rules="state.inputRules"
            >
              <!-- 파이프라인 구분 -->
              <el-form-item>
                <label class="field-label required block">
                  {{ $t('project.pipeLine.pipeLineDivision') }}
                </label>
                <el-radio 
                  v-model="state.form.pipelineCd" 
                  v-for="pipelineCd in state.stageCdList"
                  :key="pipelineCd.commonCd"
                  :label="pipelineCd.commonCd"
                  :value="pipelineCd.commonCd"
                  @change="onChangeValidate"
                >
                  <label>{{ pipelineCd.commonCd }}</label>
                  <!-- <span 
                    v-if="pipelineCd.protectedYn == 'N'" 
                    class="svg-icon svg-icon-1" 
                    @click="deleteStatgeCdList(pipelineCd.commonCd)" 
                    style="cursor: pointer;"
                  >
                    <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
                  </span> -->
                        </el-radio>
                
                <el-input 
                  v-model="state.newStageCd" 
                  placeholder="추가할 스테이지 구분 입력"
                  style="width: 200px;" 
                />
                <span 
                  class="svg-icon svg-icon-1" 
                  @click="onClickAddStageCd" 
                  style="cursor: pointer; margin-left: 5px;"
                >
                  <inline-svg src="media/icons/duotune/general/gen035.svg" />
                </span>
              </el-form-item>
              
              <!-- 빌드 구분 -->
              <el-form-item prop="buildCd">
                <label 
                  class="field-label block"
                  :class="state.form.pipelineCd === 'JUNIT' || state.form.pipelineCd === 'SONARQUBE' ? 'required' : ''">
                  {{ $t('project.pipeLine.buildCd') }}
                </label>
  
                <el-radio 
                  v-model="state.form.buildCd" 
                  v-for="buildCd in buildCdList"
                  :key="buildCd.commonCd"
                  :label="buildCd.commonCd"
                  :value="buildCd.commonCd"
                  @change="onChangeValidate"
                  :disabled="state.form.pipelineCd === 'JUNIT' && buildCd.commonCd === 'NPM'"
                >
                  <label>
                    {{ buildCd.commonCd }}
                  </label>
                        </el-radio>
                <el-radio 
                  v-model="state.form.buildCd"
                  :value="''"
                  @change="onChangeValidate"
                >
                  <label>{{ '선택안함' }}</label>
                        </el-radio>
              </el-form-item>
  
              <!-- 파이프라인 명 -->
              <el-form-item prop="pipelineName">
                <label class="field-label required">
                  {{ $t('project.pipeLine.pipeLineName') }}
                </label>
  
                  <div>
                    <el-input 
                      class="pipelineName-input"
                      v-model="state.form.pipelineName" 
                      :placeholder="$t('project.pipeLine.pipeLineNamePlaceHolder')"
                      @input="onChangeValidate"
                    />
                    <el-button v-if="state.isDuplicateChecked == false" 
                      class="ml-10" 
                      type="primary" 
                      :loading="state.isChecking" 
                      @click="_onDuplicate"
                    >
                      {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                    </el-button>
                    <el-button v-if="state.isDuplicateChecked == true" 
                      class="ml-10"
                      type="success" 
                      icon="el-icon-success"
                      >
                      {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                    </el-button>
                  </div>
              </el-form-item>
  
              <!-- 파이프라인 내용 -->
              <el-form-item>
                <label class="field-label required">
                  {{ $t('project.pipeLine.pipeLineContents') }}
                </label>
                <VAceEditor
                  v-model:value="state.form.pipelineScript"
                  :placeholder="$t('project.pipeLine.pipeLineContentsPlaceHolder')" 
                  style="height: 300px;"
                />
              </el-form-item>
            </el-form>
          </div>
  
  
          <!-- ================================================================================ -->
          <!-- Footer -->
          <!-- ================================================================================ -->
  
          <div class="modal-footer flex-center">
  
            <button 
              class="btn btn-light me-3" 
              style="width:10em;" 
              data-bs-dismiss="modal"
            > 
              {{ $t("common.cancel") }}
            </button>
  
            <button 
              v-if="!state.isSaving" 
              class="btn btn-primary" 
              style="width:12em;"
              @click.prevent="_onSave()"
            >
              <span class="indicator-label"> 
                {{ $t("common.confirm") }}
              </span>
            </button>
  
            <button v-if="state.isSaving" class="btn btn-primary" style="width:12em;" @click.prevent="">
              <span>
                Please wait...
                <span class="spinner-border spinner-border-sm align-middle ms-2"></span>
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script lang="ts">
  import { computed, getCurrentInstance, ref, watch } from 'vue';
  import { useI18n } from 'vue-i18n';
  import { VAceEditor } from 'vue3-ace-editor';
  import { createJenkinsPipeLine, deleteStageCdList, duplicateJenkinsPipelineName, getDefaultScript, getStageCdList, updateStageCdList } from '@/api/jenkinsPipeline'
  import { useToast } from 'vue-toastification';
  import share from '@/store/modules/share';
  import { _validateLength, _validateName, _validateSelect } from '@/utils/input-validate';
  import Swal from 'sweetalert2';
  
  export default {
    components: {
      VAceEditor,
    },
    props: {
      reloadList: Function,
      stageCdList: Function,
      buildCdList: Function,
      calback: Function,
    } as any,
    setup(props, { emit }) {
      let { t, locale } = useI18n();
  
      const instance:any = getCurrentInstance();
      const toast:any = useToast();
  
      const state = ref({
        isSaving: false,
        isDuplicateChecked: false,
        isChecking: false,
  
        form: {
          pipelineCd: '',
          buildCd: null,
          pipelineName: '',
          pipelineScript: '',
        } as any,
        
        stageCdList: [] as any,
        newStageCd: '',
  
        // validation rule 처리
        inputRules: {
          // pipelineCd: [
          //   {
          //     required: true,
          //     trigger: "blur",
          //     validator: _validateSelect,
          //     labelName: "pipelineCd",
          //   },
          // ],
          // buildCd: [
          //   {
          //     required: true,
          //     trigger: "blur",
          //     validator: _validateSelect,
          //     labelName: "buildCd",
          //   },
          // ],
          pipelineName: [
            {
              required: true,
              trigger: "blur",
              validator: _validateName,
              labelName: "User name",
            },
            {
              required: true,
              trigger: "blur",
              validator: _validateLength,
              length: 2,
            },
          ],
        }
      })
  
      const serviceGroupInfo = computed(() => share.state.serviceGroupInfo) as any;
      
      watch(()=> state.value.form.buildCd, ()=> {
        if(state.value.form.buildCd !== null) {
          if(state.value.form.pipelineCd !== '') {
            onChangeStageCdValidate()
          }  
        }
      })
  
      watch(()=> state.value.form.pipelineCd, ()=> {
        if(state.value.form.pipelineCd !== '') {
          if(state.value.form.buildCd !== null) {
            onChangeStageCdValidate()
          }  
        }
      })
  
      function invoke() {
        init();
        resetStateInputRules();
        state.value.stageCdList = props.stageCdList
      }
  
      function init() {
        state.value.form = {
          pipelineCd: '',
          buildCd: null,
          pipelineName: '',
          pipelineScript: ''
        }
        state.value.newStageCd = '';
        state.value.isSaving = false;
        state.value.isDuplicateChecked = false;
      }
  
      function resetStateInputRules() {
        let validKey = [] as any
        Object.keys(state.value.form).forEach((item:any)=> {
          validKey.push(item)
        })
        instance?.refs.newPipelineForm.clearValidate(validKey)
      }
  
      function onChangeValidate() {
        console.log(state.value.inputRules['pipelineName'])
  
        state.value.isDuplicateChecked = false
      }
      // =================================================================================
      // API
      // =================================================================================
  
      /**
       * Trigger: @click
       * 입력된 파이프라인 명 중복검사 메서드
       */
      async function _onDuplicate() {
        if(state.value.form.pipelineCd == '') {
          toast.error('파이프라인 구분을 선택해주세요')
          return;
        } else if(state.value.form.buildCd === null) {
          toast.error('빌드 구분을 선택해주세요')
          return;
        }
        state.value.isChecking = true
        let param:any
  
        if(state.value.form.buildCd == '') 
          param = {
            serviceGroupId: serviceGroupInfo.value.serviceGroupId,
            pipelineCd: state.value.form.pipelineCd,
            pipelineName: state.value.form.pipelineName
          }
        else
          param = {
            serviceGroupId: serviceGroupInfo.value.serviceGroupId,
            pipelineCd: state.value.form.pipelineCd,
            buildCd: state.value.form.buildCd,
            pipelineName: state.value.form.pipelineName
          } 
          console.log(param)
        try {
          const response:any = await duplicateJenkinsPipelineName(param)
  
          if(response.data == false) {
            toast.success('사용 가능한 이름입니다.')
            state.value.isDuplicateChecked = true
          } 
          else {
            toast.error('이미 존재하는 이름입니다.')
            state.value.isDuplicateChecked = false
            
          }
        } 
        catch(error) {
          console.log(error)
          toast.error('중복검사를 할 수 없습니다.')
          state.value.isDuplicateChecked = false
        }
        state.value.isChecking = false
      }
  
  
  
      async function _onSave() {
  
        if (state.value.isDuplicateChecked == false) {
          toast.error(t("msg.duplicateMessage"));
          return false;
        }
  
        instance?.refs['newPipelineForm'].validate(async valid => {
          if(valid) {
  
            state.value.isSaving = true;
            state.value.form.serviceGroupId = serviceGroupInfo.value.serviceGroupId
            const response:any = await createJenkinsPipeLine(state.value.form);
  
            init();
  
            if(response.code == 200) {
              toast.success('파이프라인 생성 성공')
              instance?.refs['Btn_Close'].click();
              props.reloadList();
            }
            else {
              toast.error('파이프라인 생성 실패')
            }
          }
          else {
            toast.error('파이프라인 생성 실패')
          }
        })
      }
  
      async function onClickAddStageCd() {
        
        if(state.value.newStageCd.trim() == '') return;
  
        let response:any
        
        try {
          const param = {
            commonGroupCd: 'Pipeline',
            commonCd: state.value.newStageCd.toUpperCase().trim(),
            codeName: state.value.newStageCd.toUpperCase().trim(),
            codeDesc: "Add StageCd",
            codeOrder: state.value.stageCdList.length + 1,
          }
  
          response = await updateStageCdList(param)
  
          if(response.code == 200){
            toast.success('추가되었습니다')
            state.value.newStageCd = '';
                
            props.calback()
          }
        } catch (error) {
          console.log(error)
          toast.error('영문 및 숫자만 입력해 주시기 바랍니다.')
        }
  
        response = await getStageCdList()
        state.value.stageCdList = response.data
      }
  
      // async function deleteStatgeCdList(commonCd) {
        
      //   Swal.fire({
      //     text: '해당 스테이지 구분을 삭제할 경우 관련된 스테이지 등록 내용이 모두 사라집니다. 그래도 삭제하시겠습니까?',
      //     icon: "info",
      //     buttonsStyling: false,
      //     showCancelButton: true,
      //     cancelButtonText: t("common.cancel"),
      //     confirmButtonText: t("common.confirm"),
      //     customClass: {
      //       cancelButton: "btn btn-light",
      //       confirmButton: "btn fw-bold btn-light-danger",
      //     },
      //   }).then(async(result) => {
      //     if (result.isConfirmed) {
      //       try {
      //         const response:any = await deleteStageCdList({
      //           commonCd: commonCd
      //         });
      //         if(response.code == 200) {
      //           const { data } = await getStageCdList();
      //           state.value.stageCdList = data;
  
      //           state.value.form.stageCd = '';
  
      //           state.value.newStageCd = '';
  
      //           toast.success('스테이지 구분을 삭제했습니다')
  
      //           props.calback()
      //         }
      //       } catch (e) {
      //         toast.error(t("project.delete.failMsg"));
      //       }
      //     }
      //   });
      // }
  
      async function onChangeStageCdValidate() {
        const param = {
          pipelineCd: state.value.form.pipelineCd, 
          buildCd: state.value.form.buildCd
        }
  
        const { data } = await getDefaultScript(param)
  
        state.value.form.pipelineScript = data[0].pipelineScript
      }
  
      return {
        state,
        invoke,
        _onDuplicate,
        onChangeValidate,
        _onSave,
  
        onClickAddStageCd,
        // deleteStatgeCdList,
      }
    }
  }
  </script>
  <style scoped>
  .block {
    display: block;
  }
  .pipelineName-input {
    width: 85% !important
  }
  .ml-10 {
    margin-left: 10px;
  }
  .pipelineCd {
    display: flex;
    justify-content: space-between;
  }
  </style>