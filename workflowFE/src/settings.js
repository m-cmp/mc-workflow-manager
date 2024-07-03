module.exports = {
    version:"1.5.0(2020.05.26, 17:04)",
    title: 'M-CMP Portal',
    
    // 로고 정보
    logo: {
        normal:"/images/brand/logo.png",
        small:"/images/brand/small_logo.png"
    },
    
  /**
   * @type {boolean} true | false
   * @description Whether fix the header
   */
  fixedHeader: false,

  /**
   * @type {boolean} true | false
   * @description Whether show the logo in sidebar
   */
  sidebarLogo: true,

  /**
   * @type {string | array} 'production' | ['production', 'development']
   * @description Need show err logs component.
   * The default is only used in the production env
   * If you want to also use it in dev, you can pass ['production', 'development']
   */
  errorLog: 'production'
}