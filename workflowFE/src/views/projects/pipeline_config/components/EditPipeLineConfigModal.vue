<template>
  <!-- ================================================================================ -->
  <!-- MODAL -->
  <!-- ================================================================================ -->
  <div 
    class="modal fade" 
    id="modalEditPipeLine" 
    aria-hidden="true" 
    tabindex="-1"
    ref="editPipeLineConfigModal">

  <!-- ================================================================================ -->
  <!-- Header -->
  <!-- ================================================================================ -->

    <div class="modal-dialog modal-dialog-centered mw-1000px">
      <div class="modal-content">

        <div class="modal-header">

          <h2 class="fw-bolder">{{ $t("project.pipeLine.editPipeLine") }}</h2>
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
          <el-form :model="state.form" label-position="top">
            <!-- 파이프라인 구분 -->
            <el-form-item>
              <label class="field-label required block">
                {{ $t('project.pipeLine.pipeLineName') }}
              </label>
              <el-radio 
                v-model="state.form.pipelineCd" 
                v-for="pipelineCd in stageCdList"
                  :key="pipelineCd.commonCd"
                  :label="pipelineCd.commonCd"
                  :value="pipelineCd.commonCd"
                  disabled
                >
                <label>{{ pipelineCd.commonCd }}</label>
				      </el-radio>
            </el-form-item>

            <!-- 파이프라인 명 -->
            <el-form-item>
              <label class="field-label required">
                {{ $t('project.pipeLine.pipeLineName') }}
              </label>
              <el-input 
                v-model="state.form.pipelineName" 
                :placeholder="$t('project.pipeLine.pipeLineNamePlaceHolder')" 
                disabled
              />
            </el-form-item>

            <!-- 파이프라인 내용 -->
            <el-form-item >
              <label class="field-label required">
                {{ $t('project.pipeLine.pipeLineContents') }}
              </label>
              <VAceEditor
                v-model:value="state.form.pipelineScript"
                :readonly="state.protectedYn == 'Y' ? true : false"
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
            @click.prevent="onSave()"
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
import { computed, getCurrentInstance, onMounted, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { VAceEditor } from 'vue3-ace-editor';
import { updateJenkinsPipeLine, getPipelineDetail } from '@/api/jenkinsPipeline'
import { useToast } from 'vue-toastification';
import share from '@/store/modules/share';

export default {
  components: {
    VAceEditor,
  },
  props: {
    reloadList: Function,
    stageCdList: Array,
    // buildCdList: Array,
  } as any,
  setup(props) {
    let { t, locale } = useI18n();

    const instance:any = getCurrentInstance();
    const toast:any = useToast();

    const state = ref({
      isSaving: false,

      form: {
        pipelineId: '',
        pipelineCd: '',
        // buildCd: '',
        pipelineName: '',
        pipelineScript: ''
      } as any,

      protectedYn: 'Y',
    })

    // const serviceGroupInfo = computed(() => share.state.serviceGroupInfo) as any;

    async function invoke(data) {

      state.value.protectedYn = data.protectedYn
      const response = await getPipelineDetail(data.pipelineId)
      state.value.form = response.data
      state.value.form.pipelineScript = state.value.form.pipelineScript.replace('\\\\', '\\')
    }

    async function onSave() {
      state.value.isSaving = true;
      // state.value.form.serviceGroupId = serviceGroupInfo.value.serviceGroupId

      let requestForm = {
        pipelineId : state.value.form.pipelineId,
        pipelineScript : state.value.form.pipelineScript
      }

      const response:any = await updateJenkinsPipeLine(requestForm);
      
      if(response.code == 200) {
        toast.success('파이프라인 수정 성공')
        state.value.isSaving = false;
        props.reloadList();
        instance?.refs['Btn_Close'].click();
      }
      else {
        toast.error('파이프라인 수정 실패')
      }
    }

    return {
      state,
      invoke,

      onSave,
    }
  }
}
</script>
<style scoped>
.block {
  display: block;
}
</style>