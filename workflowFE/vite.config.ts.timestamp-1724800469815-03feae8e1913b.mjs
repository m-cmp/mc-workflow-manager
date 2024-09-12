// vite.config.ts
import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "file:///C:/Users/Sung-Hun%20Yang/Desktop/%EC%83%88%20%ED%8F%B4%EB%8D%94/project/16.mcmp(%EA%B5%AD%EC%B1%85%EA%B3%BC%EC%A0%9C)/%EB%A9%94%EA%B0%80%EC%A1%B4/workflow_v3/workflow-manager-ui/node_modules/vite/dist/node/index.js";
import vue from "file:///C:/Users/Sung-Hun%20Yang/Desktop/%EC%83%88%20%ED%8F%B4%EB%8D%94/project/16.mcmp(%EA%B5%AD%EC%B1%85%EA%B3%BC%EC%A0%9C)/%EB%A9%94%EA%B0%80%EC%A1%B4/workflow_v3/workflow-manager-ui/node_modules/@vitejs/plugin-vue/dist/index.mjs";
import vueDevTools from "file:///C:/Users/Sung-Hun%20Yang/Desktop/%EC%83%88%20%ED%8F%B4%EB%8D%94/project/16.mcmp(%EA%B5%AD%EC%B1%85%EA%B3%BC%EC%A0%9C)/%EB%A9%94%EA%B0%80%EC%A1%B4/workflow_v3/workflow-manager-ui/node_modules/vite-plugin-vue-devtools/dist/vite.mjs";
var __vite_injected_original_import_meta_url = "file:///C:/Users/Sung-Hun%20Yang/Desktop/%EC%83%88%20%ED%8F%B4%EB%8D%94/project/16.mcmp(%EA%B5%AD%EC%B1%85%EA%B3%BC%EC%A0%9C)/%EB%A9%94%EA%B0%80%EC%A1%B4/workflow_v3/workflow-manager-ui/vite.config.ts";
var vite_config_default = defineConfig({
  plugins: [
    vue(),
    vueDevTools()
  ],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", __vite_injected_original_import_meta_url))
    }
  }
  // server: {
  //   proxy: {
  //     '/*': {
  //       target: import.meta.env.VITE_API_URL,
  //       changeOrigin: true,
  //     },
  //   },
  // }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFxTdW5nLUh1biBZYW5nXFxcXERlc2t0b3BcXFxcXHVDMEM4IFx1RDNGNFx1QjM1NFxcXFxwcm9qZWN0XFxcXDE2Lm1jbXAoXHVBRDZEXHVDQzQ1XHVBQ0ZDXHVDODFDKVxcXFxcdUJBNTRcdUFDMDBcdUM4NzRcXFxcd29ya2Zsb3dfdjNcXFxcd29ya2Zsb3ctbWFuYWdlci11aVwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiQzpcXFxcVXNlcnNcXFxcU3VuZy1IdW4gWWFuZ1xcXFxEZXNrdG9wXFxcXFx1QzBDOCBcdUQzRjRcdUIzNTRcXFxccHJvamVjdFxcXFwxNi5tY21wKFx1QUQ2RFx1Q0M0NVx1QUNGQ1x1QzgxQylcXFxcXHVCQTU0XHVBQzAwXHVDODc0XFxcXHdvcmtmbG93X3YzXFxcXHdvcmtmbG93LW1hbmFnZXItdWlcXFxcdml0ZS5jb25maWcudHNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL0M6L1VzZXJzL1N1bmctSHVuJTIwWWFuZy9EZXNrdG9wLyVFQyU4MyU4OCUyMCVFRCU4RiVCNCVFQiU4RCU5NC9wcm9qZWN0LzE2Lm1jbXAoJUVBJUI1JUFEJUVDJUIxJTg1JUVBJUIzJUJDJUVDJUEwJTlDKS8lRUIlQTklOTQlRUElQjAlODAlRUMlQTElQjQvd29ya2Zsb3dfdjMvd29ya2Zsb3ctbWFuYWdlci11aS92aXRlLmNvbmZpZy50c1wiO2ltcG9ydCB7IGZpbGVVUkxUb1BhdGgsIFVSTCB9IGZyb20gJ25vZGU6dXJsJ1xuXG5pbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tICd2aXRlJ1xuaW1wb3J0IHZ1ZSBmcm9tICdAdml0ZWpzL3BsdWdpbi12dWUnXG5pbXBvcnQgdnVlRGV2VG9vbHMgZnJvbSAndml0ZS1wbHVnaW4tdnVlLWRldnRvb2xzJ1xuXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xuICBcbiAgcGx1Z2luczogW1xuICAgIHZ1ZSgpLFxuICAgIHZ1ZURldlRvb2xzKCksXG4gIF0sXG4gIHJlc29sdmU6IHtcbiAgICBhbGlhczoge1xuICAgICAgJ0AnOiBmaWxlVVJMVG9QYXRoKG5ldyBVUkwoJy4vc3JjJywgaW1wb3J0Lm1ldGEudXJsKSlcbiAgICB9XG4gIH0sXG4gIC8vIHNlcnZlcjoge1xuICAvLyAgIHByb3h5OiB7XG4gIC8vICAgICAnLyonOiB7XG4gIC8vICAgICAgIHRhcmdldDogaW1wb3J0Lm1ldGEuZW52LlZJVEVfQVBJX1VSTCxcbiAgLy8gICAgICAgY2hhbmdlT3JpZ2luOiB0cnVlLFxuICAvLyAgICAgfSxcbiAgLy8gICB9LFxuICAvLyB9XG59KVxuIl0sCiAgIm1hcHBpbmdzIjogIjtBQUFpakIsU0FBUyxlQUFlLFdBQVc7QUFFcGxCLFNBQVMsb0JBQW9CO0FBQzdCLE9BQU8sU0FBUztBQUNoQixPQUFPLGlCQUFpQjtBQUo2UixJQUFNLDJDQUEyQztBQU10VyxJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUUxQixTQUFTO0FBQUEsSUFDUCxJQUFJO0FBQUEsSUFDSixZQUFZO0FBQUEsRUFDZDtBQUFBLEVBQ0EsU0FBUztBQUFBLElBQ1AsT0FBTztBQUFBLE1BQ0wsS0FBSyxjQUFjLElBQUksSUFBSSxTQUFTLHdDQUFlLENBQUM7QUFBQSxJQUN0RDtBQUFBLEVBQ0Y7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBU0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
