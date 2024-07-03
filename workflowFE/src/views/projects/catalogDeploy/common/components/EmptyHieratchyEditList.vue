<template>
    <main class="contents-wrapper min-height">
		<div>
			<div class="build-card-wrapper">
				<edit-build-info-component-list
					:editMode="editMode"
					:class="{'build-card': true}"
					v-on:click="onClickCatalogItem"
				/>
			</div>
		</div>
	</main>
</template>

<script lang="ts">
	import { computed, ref } from "vue";
	import {useStore} from "vuex";
	// import { deployActionTypes, deployGetters, deployActions } from "@/store/modules/deploy";
	import EditBuildInfoComponentList from "./EditBuildInfoComponentList.vue";

	export default {
		props: {
			editMode: {
				type: String,
				default: ""
			},
		},
		components: {
			 EditBuildInfoComponentList
		},
		setup() {
			
			const store = useStore();
			const state = ref({
				catalogEditData : computed(() => store.state.catalogEditData),
				isBuildPanelOpen : computed(() => store.state.deploy.isBuildPanelOpen)
			});
			function onClickCatalogItem(event) {
				// store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.SHOW_BUILD_PANEL);
				event.stopPropagation();
			}

			return {
				state,
				onClickCatalogItem
			}
		}

	};
</script>

<style lang="scss" scoped>
	.min-height {
		margin-top:30px;
	}
</style>