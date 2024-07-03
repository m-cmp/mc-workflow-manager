<template>
  <el-dialog
    v-model="state.isVisible"
    title="Console"
    data-comp-id="console-log-dialog"
    custom-class="console-log-dialog"
    
    width="850px"
    :destroy-on-close="true"
    @closed="hide"
  >
    <template v-if="state.stages.length>0">
      <div>
        <pipeline-log-stage-bar
          :stages="state.stages"
          :start-index="state.activePipelineIndex"
          @change="onChangePipelineIndex"
        />
      </div>

      <div class="total mt-10 mb-3">
        {{ $t("common.total") }}(<span
          class="total-count"
        >{{ state.detailList.length }}</span>)
      </div>
    </template>
    <div class="console-log-list-wrapper">
      <div v-if="state.isDetailDataLoadingCompleted">
        <div
            class="accordion overflow-auto"
            id="kt_accordion_1 pe-0"
            style=""
            v-for="(info, index) in state.detailList"
            :key="index"
        >
          <div
            class="accordion-item border-gray-300"
            @click.native="onClickDetailIndex(index)"
          >
            <h2
              class="accordion-header"
              :id="'kt_accordion_1_header_' + index"
            >
              <button
                class="accordion-button fs-6 fw-bold collapsed h-45px ps-0"
                type="button"
                data-bs-toggle="collapse"
                :data-bs-target="'#kt_accordion_1_body_' + index"
                aria-expanded="false"
                :aria-controls="'kt_accordion_1_body_' + index"
              >
                <span
                  v-if="info.status === buildState.SUCCESS"
                  class="h-45px w-35px pt-4 ps-3 bg-success me-4"
                  ><i class="fas fa-check text-white"
                /></span>
                <span
                  v-if="info.status === buildState.FAILED"
                  class="bg-danger h-45px w-35px pt-4 ps-4 me-4"
                  ><i class="fas fa-times text-white"
                /></span>
                <span
                  v-if="info.status === buildState.IN_PROGRESS"
                  class="bg-warning h-45px w-35px pt-4 ps-3 me-4"
                  ><i class="fas fa-spinner loading-icon" />
                </span>

                {{ info.name }}
              </button>
            </h2>
            <div
              :id="'kt_accordion_1_body_' + index"
              class="accordion-collapse collapse"
              :aria-labelledby="'kt_accordion_1_header_' + index"
              style="background-color: #3f4254"
            >
              <div class="accordion-body p-0 text-white">
                <pre
                  class="console-log-body fs-6 p-4 m-0 text-gray-300"
                  style="color: white; min-height: 50px"
                  v-html="info.consoleLog"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <el-row slot-name="footer" type="flex" justify="end" class="footer mt-5">
      <el-button v-show="false" id="reportBtn" class="btn btn-primary" ref="report" type="primary" @click="goReport()">Report</el-button>
      <el-button type="primary" class="btn btn-primary" @click="onCancel()">{{ $t("common.close") }}</el-button>
    </el-row>
  </el-dialog>
</template>

<script lang="ts">
import {useI18n} from "vue-i18n";
import {getCurrentInstance, nextTick, computed, defineComponent, onMounted, ref} from "vue";
import { useToast } from "vue-toastification";
import loaderMixin from '@/mixins/loaderMixin'
import {
  getPipelineLog,
  getPipelineLogDetail,
  getSonarAnalytics
} from '@/api/build'
import PipelineLogStageBar from '@/components/PipelineLogStageBar/index.vue'
import { BUILD_STATE } from '@/constant/common'


export default {
  components: {
    PipelineLogStageBar,
  },
 //mixins: [loaderMixin],
  props: {},
  setup() {
    const buildState =  computed( ()=> { return BUILD_STATE });
    const instance = getCurrentInstance();
    const toast = useToast();
    const state = ref({
      isFirstDataLoadingCompleted: false,
      isVisible: false,
      stages: [],
      detailList: [],
      isDetailDataLoadingCompleted: false,
      activePipelineIndex: 0,
      currentHistoryBuildInfo: {
        buildId: 0,
        jenkinsJobName: ''
      },
      timerId: -1,
      _currentMainStatus: '',
      isLogingPipelineLogDetailInfo: false,
      buildInfo: {} // show()호출시 넘어오는 build 정보 값.
    });



    async function show(info) {
      // console.log("##############!!!!!!!")
      // console.log(info);
      // console.log("##############!!!!!")
      state.value.isVisible = true
      state.value.isFirstDataLoadingCompleted = false
      //loaderMixin.activeLoadingbar({ target: '.console-log-list-wrapper' })
      state.value.buildInfo = info

      state.value.activePipelineIndex = 0
      state.value.currentHistoryBuildInfo = info

      state.value.stages = []
      state.value.detailList = []
      state.value._currentMainStatus = ''
      state.value.isLogingPipelineLogDetailInfo = false
      _clearLoop()
      _executeGetPipelineLog()
    }

    function hide() {
      console.log('hide2')
      state.value.isVisible = false

      _clearLoop()
      //loaderMixin.deactiveLoadingbar()
    }

    function _clearLoop() {
      clearInterval(state.value.timerId)
      state.value.timerId = -1
    }

   function _nextLoop() {
      // 처음 로딩바 처리, stages 정보가 1개 이상 받을 때 까지 한번만 실행됨.
      if (state.value.isFirstDataLoadingCompleted == false) {
        state.value.isFirstDataLoadingCompleted = state.value.stages.length > 0
        if (state.value.isFirstDataLoadingCompleted) {
          console.log('loop deactiveLoadingbar 실행 ')
          loaderMixin.deactiveLoadingbar()
        }
      }

      // 성공 또는 실패할때 까지 루프 반복.
      if (state.value._currentMainStatus == BUILD_STATE.SUCCESS || state.value._currentMainStatus == BUILD_STATE.FAILED) {
        _clearLoop()
        return
      }

      // 루프 반복 처리
      state.value.timerId = setTimeout(() => {
        _executeGetPipelineLog()
      }, 2000)
    }

    /*
            파이프 라인 로그 정보 구하기

            실행 환경에 따라
            response.data
            response.data.status
            response.data.stages가
            존재 하기 때문에 존재유무를 확읺인하고 사용해야 함.
        */
    async function _executeGetPipelineLog() {
      try {
        console.log("================excute==============")
        console.log(state.value.buildInfo)
        const response:any = await getPipelineLog(state.value.buildInfo)
        
        console.log(response);
        if (response.code == 2200) {
          if (response.hasOwnProperty('data') == false) {
            _nextLoop()
            return
          }

          // 파이프라인 로그 정보에서 stages만 구하기
          if (response.data.hasOwnProperty('status')) { state.value._currentMainStatus = response.data.status }

          if (response.data.hasOwnProperty('stages')) {
            state.value.stages = response.data.stages

            // stages가 1개 이상 있는 상태일때 디테일 정보를 읽지 않은 경우 딱 한번 자동으로 읽기
            if (state.value.stages.length > 0 && state.value.isLogingPipelineLogDetailInfo == false) {
              state.value.isLogingPipelineLogDetailInfo = true
              state.value.activePipelineIndex = 0
              console.log("getPipelineLogDetailCall==========================")
              console.log((state.value.stages[state.value.activePipelineIndex] as any)._links.self.href);
              await getPipelineLogDetailCall(
                (state.value.stages[state.value.activePipelineIndex] as any)._links.self.href
              )

              for (let i = 0; i < state.value.stages.length; i++) {
                const stageObj = (state.value.stages[i] as any);
                const stageName = stageObj.name;
                const status = stageObj.status;
                if (stageName == 'analytics' && status == 'SUCCESS') {
                  (instance?.refs.report as any).el.setAttribute('style', 'display: block;')
                }
              }
            }
          }
         // loaderMixin.this_nextLoop();
        }
      } catch (error) {
        console.log('error ', error)
        toast.error('데이터를 읽는 도중 에러가 발생했습니다.')
        hide()
      }
    }

    /*
            현재 선택된 히스토리의 파이프 라인 상태 목록 구하기
        */
    // async function getPipelineLog(params) {

    // }

    /*
            상세정보 구하기
        */
    async function getPipelineLogDetailCall(link) {
      state.value.isDetailDataLoadingCompleted = false

      state.value.detailList = []
      // const created = loaderMixin.activeLoadingbar({
      //   target: '.console-log-list-wrapper'
      // })
      try {
        const response:any = await getPipelineLogDetail(link)
        console.log("getPipelineLogDetail====================")
        console.log(response.data);
        const list = response.data.stageFlowNodes || []
         console.log(list);
        let key = new Date().getTime()
        state.value.detailList = list.map(info => {
          info.loaded = false
          info.consoleLog = ''
          info.key = key++
          return info
        })

        // if (created) {
        //   loaderMixin.deactiveLoadingbar()
        // }
      } catch (error) {
        // if (created) {
        //   loaderMixin.deactiveLoadingbar()
        // }

        console.error(error)
      }

      state.value.isDetailDataLoadingCompleted = true
    }

    /*
            status가 변경되는 경우 디테일 정보 다시 구하기
        */
    async function onChangePipelineIndex(index) {
      state.value.activePipelineIndex = index
      const stageObj = (state.value.stages[state.value.activePipelineIndex] as any)
      await getPipelineLogDetailCall(
        stageObj._links.self.href
      )

      const stageName = stageObj.name
      const status = stageObj.status
      if (stageName == 'analytics') {
        if (status == 'SUCCESS') {
          (instance?.refs.report as any).el.setAttribute('style', 'display: block;')
        }
      }
    }

    async function goReport() {
      const projectName = "project name";//this.projectInfo.name <- shareMapState check point 2022.03.30

      const response:any = await getSonarAnalytics(projectName)

      if (response.code == 2200) {
        const url = response.data.url
        const str = 'width=1200,height=800,top=10,left=10,status=0, scrollbars=0, resizable=0 '
        window.open(url, '_blank', str)
      }
    }

    function onCancel() {
      hide()
    }

    async function onClickDetailIndex(index) {
      const detailListObj = (state.value.detailList[index] as any)
      if (detailListObj.loaded === false) {
        detailListObj.loaded = true

        // const created = loaderMixin.activeLoadingbar({
        //   target: '.console-log-list-wrapper'
        // })
        try {
          const response:any = await getPipelineLogDetail(
            detailListObj._links.log.href
          )

          const text = response.data.text || ''
          detailListObj.consoleLog = text

          // if (created) {
          //   loaderMixin.deactiveLoadingbar()
          // }
        } catch (error) {
          console.error(error)
          // if (created) {
          //   loaderMixin.deactiveLoadingbar()
          // }
          detailListObj.consoleLog = '에러'
        }
      }
    }

    return {
      state,
      buildState,
      show,
      hide,
      _clearLoop,
      _nextLoop,
      _executeGetPipelineLog,
      onChangePipelineIndex,
      goReport,
      onCancel,
      onClickDetailIndex
    }
  }
}
</script>
