export default {
  data() {
    return {
      isFirstDataLoadingCompleted: false,
      isFullScreen: false,
      showFullScreenUI: false
    }
  },

  beforeDestroy() {
    document.getElementsByTagName('body')[0].className = ''
  },

  computed: {

  },
  methods: {
    onEditorMouseLeave() {
      this.showFullScreenUI = false
    },

    onEditorMouseOver() {
      this.showFullScreenUI = true
    },

    onFullScreen(value) {
      this.isFullScreen = value
      if (this.isFullScreen) {
        document.getElementsByTagName('body')[0].className = 'scroll-hidden'
      } else {
        document.getElementsByTagName('body')[0].className = ''
      }
    }
  }
}
