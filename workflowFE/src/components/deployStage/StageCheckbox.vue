<template>
  <el-form
    v-if="state.isFirstDataLoadingCompleted"
    ref="stageForm"
    class="content-wrapper"
    label-position="top"
    label-width="100px"
    :model="state.formData"
    :rules="state.inputRules"
    autocomplete="on"
  >
    <el-form-item inline-message="true" prop="checkList" v-if="!props.readonly">
      <span class="field-label required">{{ $t("common.stage") }}</span>
      <el-checkbox-group v-model="state.formData.checkList">
        <el-checkbox
          v-for="item in state.stageList"
          :key="item.value"
          :label="item.label"
          name="checkList"
        ></el-checkbox>
      </el-checkbox-group>
    </el-form-item>

    <el-form-item v-if="props.readonly">
      <span class="field-label">{{ $t("common.stage") }}</span>
      <el-checkbox-group v-model="state.formData.checkList" disabled>
        <el-checkbox
          v-for="item in state.stageList"
          :key="item.value"
          :label="item.label"
          name="checkList"
        ></el-checkbox>
      </el-checkbox-group>
    </el-form-item>
  </el-form>
</template>
<script>
import { getCurrentInstance, nextTick, onMounted, ref, onUpdated } from "vue";
import { getStageList } from "@/api/commonDeploy";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter } from "vue-router";
import { useToast } from "vue-toastification";
export default {
  props: {
    readonly: Boolean,
    list: {
      type: Array,
      default: function () {
        return [];
      },
    },
  },

  setup(props) {
    /* ============================================================================================================= */
    // 다국어 설정
    /* ============================================================================================================= */

    let { t, locale } = useI18n();

    /* ============================================================================================================= */
    // 데이터
    /* ============================================================================================================= */

    const instance = getCurrentInstance();
    const router = useRouter();
    const route = useRoute();
    const toast = useToast();
    const state = ref({
      isFirstDataLoadingCompleted: false,
      stageList: [],
      formData: {
        checkList: props.list,
      },
      inputRules: {
        checkList: [
          {
            required: true,
            message: t("validation.msgSelect"),
            trigger: "change",
          },
        ],
      },
    });
    /* ============================================================================================================= */
    // 라이프사이클
    /* ============================================================================================================= */
    onMounted(() => {
      nextTick(() => {
        init();
      });
    });

    onUpdated(() => {
      requestStageList(); // 수정, 조회에서 정상작동 하기 위해
    });

    function init() {
      requestStageList(); // 등록에서 정상작동 하기 위해
    }

    /* ============================================================================================================= */
    // 데이터 관리
    /* ============================================================================================================= */
    async function requestStageList() {
      /***
			 *  0: {stageId: 1, stageName: "Stage", nickName: "STG", description: "Stage 배포"}
				1: {stageId: 2, stageName: "Production", nickName: "PRD", description: "개발 배포"}
				2: {stageId: 3, stageName: "Development", nickName: "DEV", description: "운영 배포"}
			*/
      const result = await getStageList();
      console.log(result);
      state.value.stageList = [];
      if (result.code == 2200) {
        result.data.forEach((x) => {
          state.value.stageList.push({
            label: x.nickName,
            value: x.stageId,
          });
        });
        onChangeListProp();
      }
    }

    /* ================================================================================================================= */
    // 이벤트 처리
    /* ================================================================================================================= */
    function onChangeListProp() {
      let checkList = [];
      props.list.forEach((id) => {
        let find = state.value.stageList.find((x) => {
          if (x.value == id) {
            return x;
          }
        });

        if (find) {
          checkList.push(find.label);
        }
      });
      state.value.formData.checkList = checkList;
      state.value.isFirstDataLoadingCompleted = true;
    }

    function validate() {
      let result = true;
      instance.refs["stageForm"].validate((valid) => {
        result = valid;
      });

      return result;
    }

    function getSelectedStage() {
      let ids = [];
      state.value.formData.checkList.forEach((check) => {
        ids.push(state.value.stageList.find((x) => x.label == check).value);
      });
      return ids;
    }

    function getSelectedStageStr() {
      return this.getSelectedStage().toString();
    }

    return {
      props,
      state,
      instance,
      onChangeListProp,
      validate,
      getSelectedStage,
      getSelectedStageStr,
    };
  },
};
</script>
