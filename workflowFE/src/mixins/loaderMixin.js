/*
공통으로 사용하는 로딩 처리 기능
*/
export default {
  data() {
    return {
      _loadingbar: null,
      _loadingTimerID: 0,
      _isDataLoading: false
    }
  },
  beforeDestroy() {
    this.deactiveLoadingbar()
  },
  computed: {
    isDataLoading() {
      return this._isDataLoading
    }
  },
  methods: {
    /**
     * @param {*} options
     * @param {number} delay
     */
    activeLoadingbar(options = {}, delay = 300) {
      if (this._loadingbar) {
        return false
      }
      if (this._loadingTimerID) {
        clearInterval(this._loadingTimerID)
        this._loadingTimerID = 0
      }

      this._isDataLoading = true
      this._loadingTimerID = setTimeout(() => {
        if (this._loadingbar == null) {
          this.createLoadingbar(options)
        }
      }, delay)

      return true
    },
    createLoadingbar(options) {
      const tempOptions = Object.assign({
        lock: true,
        text: 'Loading',
        target: '.app-main',
        background: 'rgba(255, 255, 255, 0.7)'
      }, options)
      console.log(this.$loading);
      this._loadingbar = this.$loading(tempOptions)
    },
    deactiveLoadingbar() {
      // 타이머 제거
      clearInterval(this._loadingTimerID)
      this._loadingTimerID = 0
      this._isDataLoading = false

      if (this._loadingbar != null) {
        this._loadingbar.close()
        this._loadingbar = null
      }

      this._isLoading = false
    }
  }
}
