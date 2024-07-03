import { createApp } from "vue";
import App from "./App.vue";

import "@/core/plugins/prismjs";
import "bootstrap";

const app = createApp(App);


/* ===================================================================================================================== */
// I18N
/* ===================================================================================================================== */
import i18n from "@/i18n/index.js";
app.use(i18n);


/* ===================================================================================================================== */
// VUE 3 UI
/* ===================================================================================================================== */
import ElementPlus from "element-plus";
app.use(ElementPlus);

import Toast from "vue-toastification";
import "vue-toastification/dist/index.css";
app.use(Toast, {});

// LADING-SPINNER
import VueLoading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';
app.use(VueLoading, {
  opacity: 1,
  width: 48,
  height: 48,
}, {});


// 이전버전 스타일
import '@/styles/index.scss'
import '@fortawesome/fontawesome-free/css/all.css'
import '@fortawesome/fontawesome-free/js/all.js'

// // CHART
// import ECharts from 'vue-echarts'
// import { use as useChart } from "echarts/core"
// import { CanvasRenderer } from 'echarts/renderers'
// import { BarChart, LineChart, PieChart } from 'echarts/charts'
// import { GridComponent, TooltipComponent, TitleComponent, LegendComponent, ToolboxComponent } from 'echarts/components'
// useChart([
//   CanvasRenderer,
//   BarChart,
//   LineChart,
//   GridComponent,
//   TooltipComponent,
//   TitleComponent,
//   LegendComponent,
//   PieChart,
//   ToolboxComponent
// ]);
// app.component('v-chart', ECharts);


/* ===================================================================================================================== */
// STORE & ROUTE
/* ===================================================================================================================== */
import router from "@/router";
import store from "@/store";
import './permission.js'
app.use(store);
app.use(router);


/* ===================================================================================================================== */
// ETC
/* ===================================================================================================================== */
import { initApexCharts } from "@/core/plugins/apexcharts";
import { initInlineSvg } from "@/core/plugins/inline-svg";
import { initVeeValidate } from "@/core/plugins/vee-validate";


initApexCharts(app);
initInlineSvg(app);
initVeeValidate();


/* ===================================================================================================================== */
// GLOBAL VAR
/* ===================================================================================================================== */

let asidePrimaryInstance: any;
function setAsidePrimary(inst) { asidePrimaryInstance = inst; }
function getAsidePrimary() { return asidePrimaryInstance; }

let asideSecondaryInstance: any;
function setAsideSecondary(inst) { asideSecondaryInstance = inst; }
function getAsideSecondary() { return asideSecondaryInstance; }

let asideSecondaryMenuInstance: any;
function setAsideSecondaryMenu(inst) { asideSecondaryMenuInstance = inst; }
function getAsideSecondaryMenu() { return asideSecondaryMenuInstance; }

/* ===================================================================================================================== */

app.mount("#app");

export default app;
export {
  setAsidePrimary,
  getAsidePrimary,
  setAsideSecondary,
  getAsideSecondary,
  setAsideSecondaryMenu,
  getAsideSecondaryMenu,
}
