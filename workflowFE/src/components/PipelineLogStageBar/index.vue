<template>
    <div 
        data-comp-id="pipeline-log-stage-bar"
        class="pipeline-log-stage-bar">
        <div v-if="stages.length > 0" class="stages-list">
            <div class="stage">
                <div class="icon" />
                <div class="title">Start</div>
            </div>
            <div
                v-for="(stage, index) in stages"
                :key="index"
                class="stage link-action"
                @click="onClick(index)"
            > 
                <div
                    v-show="stage.status == BUILD_STATE.SUCCESS"
                    :class="{ selected: index == selectedIndex }"
                    class="icon success normal"
                >
                    <i class="fas fa-check-circle" />
                </div>
                <div
                    v-show="stage.status == BUILD_STATE.FAILED"
                    :class="{ selected: index == selectedIndex }"
                    class="icon failed normal"
                >
                    <i class="fas fa-times-circle" />
                </div>
                <div
                    v-show="stage.status == BUILD_STATE.IN_PROGRESS"
                    :class="{ selected: index == selectedIndex }"
                    class="icon building normal"
                >
                    <i class="fas fa-spinner loading-icon" />
                </div>

                <div class="title">{{ stage.name }}</div>
            </div>
            <div class="stage">
                <div class="icon" />
                <div class="title">End</div>
            </div>
        </div>
        <template v-else>
            No data
        </template>
    </div>
</template>
<script>
import { BUILD_STATE } from '@/constant/common'
import { DEPLOY_STATE } from '@/constant/common'
export default {
    props: {
        startIndex: {
            type: Number,
            default: 0
        },
        stages: {
            type: Array,
            default: function() {
                return [];
            }
        }
    },
    computed:{
        DEPLOY_STATE() {
            return DEPLOY_STATE;
        },

        BUILD_STATE(){
            return BUILD_STATE;
        }
    },
    data() {
        return {
            selectedIndex: 0
        };
    },
    watch: {
        startIndex(value) {
            this.selectedIndex = value;
        }
    },
    mounted() {
        this.selectedIndex = this.startIndex;
    },
    methods: {
        onClick(index) {
            console.log("dddddd")
            this.selectedIndex = index;
            this.$emit("change", index);
        }

        // #d54c53
    }
};
</script>
