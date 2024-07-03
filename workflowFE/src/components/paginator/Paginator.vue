<template>
    
    <div class="dataTables_paginate paging_simple_numbers">
        <ul class="pagination pagination-circle">
    
            <!-- ==== PREV BUTTON ==== -->
            <li
                class="page-item previous"
                v-bind:class="{ disabled: state.currentPageNo == 1 }"
                ref="prev"
                v-on:click.prevent="onChangedPage(state.currentPageNo-1, true)">
                <a href="#" class="page-link"> <i class="previous"></i> </a>
            </li>
    
            <!-- ==== PAGE BUTTONs ==== -->
            <div
                v-if="state.pageCount > 0"
                v-for="index in state.pageCount" :key="index">
                <PaginatorPage
                    ref="pageIndicator"
                    :currentPageNo="state.currentPageNo"
                    :pageNo="index"
                    v-on:click.prevent="onChangedPage(index, true)"
                />
            </div>
    
            <!-- ==== SAMPLE PAGE BUTTONs ==== -->
            <PaginatorPage
                v-if="state.pageCount == 0"
                :currentPageNo="state.currentPageNo"
                :pageNo="1"
                v-on:click.prevent="onChangedPage(1)"
            />
            <PaginatorPage
                v-if="state.pageCount == 0"
                :currentPageNo="state.currentPageNo"
                :pageNo="2"
                v-on:click.prevent="onChangedPage(2)"
            />
            <PaginatorPage
                v-if="state.pageCount == 0"
                :currentPageNo="state.currentPageNo"
                :pageNo="3"
                v-on:click.prevent="onChangedPage(3)"
            />
            <PaginatorPage
                v-if="state.pageCount == 0"
                :currentPageNo="state.currentPageNo"
                :pageNo="4"
                v-on:click.prevent="onChangedPage(4)"
            />
            
            <!-- ==== NEXT BUTTON ==== -->
            <li
                class="page-item next"
                v-bind:class="{ disabled: state.currentPageNo >= state.pageCount }"
                ref="next"
                v-on:click.prevent="onChangedPage(state.currentPageNo+1, true)">
                <a href="#" class="page-link"> <i class="next"></i> </a>
            </li>
        </ul>
    </div>

</template>

<!-- ################################################################################################################### -->

<script>
import {nextTick, ref} from "vue";
import PaginatorPage from "@/components/paginator/PaginatorPage";
import {computed, getCurrentInstance} from "vue";

export default {
    name: "Paginator",
    components: {
        PaginatorPage,
    },
    props: {
        cntPerPage: {
            type: Number,
            default: 1
        },
        itemCount: {
            type: Number,
            default: 0
        }
    },
    emits: [ 'changedPage' ],
    setup(props, { emit }) {
    
        /* ============================================================================================================= */
        // 데이터 정의
        
        const instance = getCurrentInstance();
        
        const state = ref({
            currentPageNo: 1,
            itemCount: 0,
            pageCount: computed(() => {
                let cnt = parseInt('' + ((props.itemCount - 1) / props.cntPerPage)) + 1;
    
                if(state.value.currentPageNo > cnt) state.value.currentPageNo = cnt;
                onChangedPage(state.value.currentPageNo, false);
                return cnt;
            }),
        });
    
    
        /* ============================================================================================================= */
        // EXTERN FUNCTION
        
        // function setItemCount(pageNo, itemCount) {
        //     state.value.currentPageNo = pageNo;
        //     state.value.itemCount = itemCount;
        //     state.value.pageCount = parseInt('' + (state.value.itemCount == 0 ? 0 : (state.value.itemCount - 1)/props.cntPerPage + 1));
        //     onChangedPage(pageNo);
        // }
        
        function getCurrentPageNo() {
            return state.value.currentPageNo;
        }
    
        function setCurrentPageNo(pageNo) {
            state.value.currentPageNo = pageNo;
        }
        
        /* ============================================================================================================= */
        // 이벤트, 콜백
        
        function onChangedPage(pageNo, eventFlag) {
            if(pageNo <= 0) return;
            if(pageNo > state.value.pageCount) return;
    
            state.value.currentPageNo = pageNo;
            if(eventFlag) {
                emit('changedPage', pageNo);
            }
            nextTick(()=>{
                for (let xx = 0; xx < instance.refs.pageIndicator.length; xx++) {
                    (instance.refs.pageIndicator[xx]).changedPage(pageNo);
                }
            });
   
        }
        
        
        /* ============================================================================================================= */
        return {
            state,
            instance,
            onChangedPage,
    
            getCurrentPageNo,
            setCurrentPageNo
        }
    }
}
</script>
