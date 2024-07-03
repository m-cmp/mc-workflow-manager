
<!-- ################################################################################################################### -->

<template>
  <div class="d-flex flex-stack flex-wrap pt-10">
    <div class="fs-6 fw-bolder text-gray-700">
      {{ $t("common.total") }} ({{ state.totalItem }})
    </div>
    <!-- begin::Pages-->
    <ul class="pagination pagination-circle">
      <li
        class="page-item previous"
        v-bind:class="{ disabled: state.isDisabledPrev }"
        ref="prev"
        v-on:click.prevent="onClickPrev"
      >
        <a href="#" class="page-link"> <i class="previous"></i> </a>
      </li>

      <div v-for="(prop, index) in state.pageProps" :key="index" ref="pages">
        <PaginationPage
          v-bind="prop"
          v-on:click.prevent="onClickPage(index + 1)"
        />
      </div>

      <li
        class="page-item next"
        v-bind:class="{ disabled: state.isDisabledNext }"
        ref="next"
        v-on:click.prevent="onClickNext"
      >
        <a href="#" class="page-link"> <i class="next"></i> </a>
      </li>
    </ul>
  </div>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import { defineComponent, getCurrentInstance, ref } from "vue";
import PaginationPage from "@/components/paginationBkup/PaginationPage.vue";
import { PaginationPageProp } from "@/components/paginationBkup/PaginationPageProp";
import { useI18n } from "vue-i18n";

export default defineComponent({
  name: "Pagination",
  components: { PaginationPage },
  props: {},
  setup() {
    /* ================================================================================================================= */
    // 데이터 설정
    /* ================================================================================================================= */

    const { t } = useI18n();
    const state = ref({
      beginItemIndex: 0,
      endItemIndex: 9,
      totalItem: 97,
      cntPerPage: 9,
      currentPage: 1,
      pageProps: new Array<PaginationPageProp>(),
      isDisabledPrev: false,
      isDisabledNext: false,
      callback: (pageNo: number) => {},
    });

    let totalPage = ref(5);
    const instance = getCurrentInstance();

    /* ================================================================================================================= */
    // 프로퍼티 설정
    /* ================================================================================================================= */

    function setProps(curPage, totalItem, cntPerPage, callback) {
      state.value.callback = callback;
      state.value.currentPage = curPage;

      state.value.totalItem = totalItem;
      state.value.cntPerPage = cntPerPage;

      totalPage.value = Math.floor(
        (state.value.totalItem - 1) / state.value.cntPerPage + 1
      );
      totalPage.value = Math.floor(totalPage.value < 0 ? 0 : totalPage.value);

      rebuild();
    }

    function rebuild() {
      state.value.beginItemIndex =
        (state.value.currentPage - 1) * state.value.cntPerPage;
      state.value.endItemIndex =
        state.value.beginItemIndex + state.value.cntPerPage - 1;
      if (state.value.endItemIndex >= state.value.totalItem)
        state.value.endItemIndex = state.value.totalItem - 1;

      /* PAGE 항목 설정 */
      state.value.pageProps.length = 0;
      for (var xx = 0; xx < totalPage.value; xx++) {
        state.value.pageProps.push(
          new PaginationPageProp(xx + 1, state.value.currentPage == xx + 1)
        );
      }

      /* PREV UI 설정 */
      state.value.isDisabledPrev = false;
      if (state.value.currentPage == 1) state.value.isDisabledPrev = true;

      /* NEXT UI 설정 */
      state.value.isDisabledNext = false;
      if (state.value.currentPage == totalPage.value)
        state.value.isDisabledNext = true;
    }

    /* ================================================================================================================= */
    // 이벤트
    /* ================================================================================================================= */

    const onClickPage = (pageNo) => {
      if (state.value.currentPage == pageNo) return;

      state.value.currentPage = pageNo;
      rebuild();

      state.value.callback(state.value.currentPage);
    };

    const onClickPrev = () => {
      if ((instance?.refs.prev as any).classList.contains("disabled")) return;

      state.value.currentPage--;
      rebuild();

      state.value.callback(state.value.currentPage);
    };

    const onClickNext = () => {
      if ((instance?.refs.next as any).classList.contains("disabled")) return;

      state.value.currentPage++;
      rebuild();

      state.value.callback(state.value.currentPage);
    };

    /* ================================================================================================================= */
    // 접근 정보 반환
    /* ================================================================================================================= */

    return {
      state,
      totalPage,
      setProps,
      onClickPage,
      onClickPrev,
      onClickNext,
      instance,
    };
  },
});
</script>

