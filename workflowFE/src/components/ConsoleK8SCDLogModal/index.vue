<template>
<!-- :visible.sync="isVisible" -->
  <el-dialog
    v-model="state.isVisible"
    title="Console"
    data-comp-id="console-log-dialog"
    custom-class="console-log-dialog"
    
    width="700px"
    :destroy-on-close="true"
    @closed="hide"
  >
    <div class="console-log-list-wrapper">
      <el-collapse v-if="state.isDetailDataLoadingCompleted">
        <el-collapse-item
          v-for="(info, index) in state.detailList"
          :key="info.key"
          :name="index"
          
        >
          <template v-slot:title>
            <el-row
              type="flex"
              class="title-wrapper"
              justify="center"
              align="middle"
            >
              <div class="title mt-10"> <p class="ellips">{{ info.kind }} 배포상태</p></div>
            </el-row>
          </template>
          <pre
            class="console-log-body"
            v-html="info.status"
          />
        </el-collapse-item>
      </el-collapse>
      <el-collapse v-else>
        <div class="title mt-10"> <p class="ellips">현재 배포된 Pod가 없습니다.</p></div>
      </el-collapse>
    </div>

    <el-row slot-name="footer" type="flex" justify="end" class="footer mt-5">
      <el-button type="primary" class="btn btn-primary" @click="onCancel()">{{ $t("common.close") }}</el-button>
    </el-row>
  </el-dialog>
</template>

<script lang="ts">
import {useI18n} from "vue-i18n";
import {getCurrentInstance, nextTick, computed, defineComponent, onMounted, ref} from "vue";
import { useToast } from "vue-toastification";
import loaderMixin from '@/mixins/loaderMixin'
import {  getK8SCDStatusLog } from '@/api/build'


import { BUILD_STATE } from '@/constant/common'
import { mapState as shareMapState } from '@/store/modules/share'

// ...shareMapState(['projectInfo']), <-   처리 고려 : 2020.03.30

export default {
  components: {
    // PipelineLogStageBar
  },
  mixins: [loaderMixin],
  props: {},
  setup() {
    const projectInfo = computed(()=>{return shareMapState([projectInfo])});
    const buildState =  computed( ()=> { return BUILD_STATE });
    const instance = getCurrentInstance();
    const toast = useToast();
    const state = ref({
      isFirstDataLoadingCompleted: false,
      isVisible: false,
      stages: [],
      detailList: [],
      isDetailDataLoadingCompleted: true,
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
      state.value.isVisible = true
      state.value.isFirstDataLoadingCompleted = false
      //this.activeLoadingbar({ target: '.console-log-list-wrapper' })
      state.value.buildInfo = info

      state.value.activePipelineIndex = 0
      state.value.currentHistoryBuildInfo = info

      state.value.stages = []
      state.value.detailList = []
      state.value._currentMainStatus = ''
      state.value.isLogingPipelineLogDetailInfo = false
      //_clearLoop()
      _executeGetPipelineLog()
    }

    function hide() {
      console.log('hide1')
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
         // loaderMixin.deactiveLoadingbar()
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
        const response:any = await getK8SCDStatusLog(state.value.buildInfo)
        console.log("_executeGetPipelineLog=====================")
        console.log(response);
        if (response.code == 2200) {
          console.log(response.hasOwnProperty('data'));
          if (response.hasOwnProperty('data') == true && response.data.length > 0 ) {
                 // this.detailList = response.data.list;
              const list = response.data || []
              let key = new Date().getTime()
              let arrint = 0;
              state.value.detailList = list.map(info => {
                info.loaded = false
                info.kind = list[arrint].kind
                info.status = list[arrint].status
                info.key = key++
                arrint++
                return info
              })
                  
          }else{
              state.value.isDetailDataLoadingCompleted = false
          }
        }
      } catch (error) {
        console.log('error ', error)
        toast.error('데이터를 읽는 도중 에러가 발생했습니다.')
        hide();
      }
    }

    /*
            현재 선택된 히스토리의 파이프 라인 상태 목록 구하기
        */
    // async getPipelineLog(params) {

    // },

    /*
            상세정보 구하기
        */
    // async getPipelineLogDetail(link) {
    //   this.isDetailDataLoadingCompleted = false

    //   this.detailList = []
    //   const created = this.activeLoadingbar({
    //     target: '.console-log-list-wrapper'
    //   })
    //   try {
    //     const response = await getPipelineLogDetail(link)
    //     const list = response.data.stageFlowNodes || []
    //     let key = new Date().getTime()
    //     this.detailList = list.map(info => {
    //       info.loaded = false
    //       info.consoleLog = ''
    //       info.key = key++
    //       return info
    //     })

    //     if (created) {
    //       this.deactiveLoadingbar()
    //     }
    //   } catch (error) {
    //     if (created) {
    //       this.deactiveLoadingbar()
    //     }

    //     console.error(error)
    //   }

    //   this.isDetailDataLoadingCompleted = true
    // },

    // /*
    //         status가 변경되는 경우 디테일 정보 다시 구하기
    //     */
    // async onChangePipelineIndex(index) {
    //   this.activePipelineIndex = index
    //   await this.getPipelineLogDetail(
    //     this.stages[this.activePipelineIndex]._links.self.href
    //   )

    //   const stageName = this.stages[this.activePipelineIndex].name
    //   const status = this.stages[this.activePipelineIndex].status
    //   if (stageName == 'analytics') {
    //     if (status == 'SUCCESS') {
    //       this.$refs.report.$el.setAttribute('style', 'display: block;')
    //     }
    //   }
    // },

    // async goReport() {
    //   const projectName = this.projectInfo.name

    //   const response = await getSonarAnalytics(projectName)

    //   if (response.code == 2200) {
    //     const url = response.data.url
    //     const str = 'width=1200,height=800,top=10,left=10,status=0, scrollbars=0, resizable=0 '
    //     window.open(url, '_blank', str)
    //   }
    // },

    function onCancel() {
      hide()
    }//,

    // async onClickDetailIndex(index) {
    //   if (this.detailList[index].loaded === false) {
    //     this.detailList[index].loaded = true

    //     const created = this.activeLoadingbar({
    //       target: '.console-log-list-wrapper'
    //     })
    //     try {
    //       const response = await getPipelineLogDetail(
    //         this.detailList[index]._links.log.href
    //       )

    //       const text = response.data.text || ''
    //       this.detailList[index].consoleLog = text

    //       if (created) {
    //         this.deactiveLoadingbar()
    //       }
    //     } catch (error) {
    //       console.error(error)
    //       if (created) {
    //         this.deactiveLoadingbar()
    //       }

    //       this.detailList[index].consoleLog = '에러'
    //     }
    //   }
    // }

    return {
      state,
      buildState,
      show,
      hide,
      _clearLoop,
      _nextLoop,
      _executeGetPipelineLog,
      onCancel
    }
  }
 

 
}
</script>
