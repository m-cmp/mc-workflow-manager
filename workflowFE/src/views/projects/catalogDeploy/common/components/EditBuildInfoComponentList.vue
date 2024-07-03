<template>
  <div>
    <div style="margin-bottom: 10px;">
      <!-- <i class="fas fa-cogs" />  -->
      <span class="field-label required">
        {{ $t("project.catalog.catalog") }}
      </span>
    </div>
    <!-- 수정 -->
    <div>
      <el-select 
        v-if="editMode == EDIT_MODE.EDIT"
        disabled
        v-model="state.editData.catalogName" 
        style="width: 100%"
        @click="onClickCheckNexus"
      >
      </el-select>
    </div>
    
    <!-- 생성 -->
    <div>
      <el-select 
        v-if="editMode == EDIT_MODE.NEW"
        v-model="state.editData.catalogId" 
        style="width: 100%"
        @click="onClickCheckNexus"
      >
        <el-option
          key="empty"
          value=""
          :label="$t('project.catalog.msgSelectCatalog')"
        >
        </el-option>
        <el-option
          v-for="item in state.catalogList"
          @click="selectedItem(item)"
          :key="item.value"
          :label="item.text"
          :value="item.value"
        />
      </el-select>
    </div>
  </div>
</template>
<script lang="ts">
import { computed, ref } from "vue";
import { useStore } from "vuex";
import { EDIT_MODE } from "@/constant/common";
import share from '@/store/modules/share';
import { useToast } from 'vue-toastification';

export default {
  components: {},
  props: {
    editMode: {
			type: String,
			default: ""
		},
    itemInfo: {
      type: Object,
      default: null,
    },
  },
  setup() {
    const store = useStore();
    const toast = useToast();
    
    const state = ref({
      catalogList: computed(() => store.state.deploy.catalogList),
      editData: computed(() => store.state.deploy.catalogEditData),
    });

    const serviceGroupInfo:any = computed(()=> share.state.serviceGroupInfo);

    function selectedItem(item) {
      state.value.editData.catalogName = item.data.catalogName
      state.value.editData.catalogVersion = item.data.catalogVersion
    }

    function onClickCheckNexus() {
      if(!serviceGroupInfo.value.nexusId) {
        toast.error('서비스 그룹에 매핑된 Nexus 정보가 없습니다. \n 서비스 그룹 > 상세에서 선택해주세요.');
      }
    }

    return {
      state,
      selectedItem,
      EDIT_MODE,
      onClickCheckNexus
    };
  },
};
</script>

