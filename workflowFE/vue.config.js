module.exports = {
  publicPath: "/",
  transpileDependencies: ['@vue/reactivity'],
  
   devServer: {
     proxy: {
       '/*': {
         target: process.env.VUE_APP_API_URL,
         changeOrigin: true,
       },
     },
   }
};
