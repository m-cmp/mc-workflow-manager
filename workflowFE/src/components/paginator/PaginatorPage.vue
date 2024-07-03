
<template>
    <li
        class="page-item"
        :class="{ active: state.isActive }"
        ref="node">
    
        <a href="#" class="page-link">{{ pageNo }}</a>
    </li>
</template>

<!-- ################################################################################################################### -->

<script lang="ts">

import {computed, getCurrentInstance, ref} from "vue";

export default {
    name: "PaginatorPage",
    props: {
        currentPageNo: Number,
        pageNo: Number,
        isActive: Boolean
    },
    setup(props) {
        const instance = getCurrentInstance();
        const state = ref({
            currentPageNo: props.currentPageNo,
            pageNo: props.pageNo,
            isActive: false,
        });
    
        /* ============================================================================================================= */
        // 이벤트 및 콜백
        
        function changedPage(pageNo) {
            state.value.currentPageNo = pageNo;
            state.value.isActive = state.value.currentPageNo == state.value.pageNo;
            
            console.log("chagePage: ", state.value.pageNo, ':', pageNo);
        }
        
        /* ============================================================================================================= */
        return {
            instance,
            state,
    
            changedPage,
        }
    }
}
</script>

