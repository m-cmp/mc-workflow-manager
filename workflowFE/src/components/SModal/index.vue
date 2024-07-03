<template>
  <div v-show="opening" class="modal-wrapper s-modal">
    <div class="modal-bg" @click="onClickModalBG" />
    <div class="modal-panel" :class="panelClass">
      <div class="header">
        <slot name="header">
          <div class="title">{{ title }}</div>
        </slot>
        <button class="btn-close" @click="onClosed">
          <i class="el-icon-close" />
        </button>
      </div>
      <main>
        <slot name="default" />
      </main>

      <div class="footer">
        <slot name="footer" />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    title: {
      type: String,
      default: ''
    },
    panelClass: {
      type: String,
      default: ''
    },
    visible: {
      type: Boolean,
      default: function() {
        return false
      }
    }
  },
  data() {
    return {
      opening: false,
      escHandler: null
    }
  },

  watch: {
    visible(value) {
      if (value) {
        this._attachElement()
        this.addEscEventListener()
      } else {
        this._dettachElement()
        this.removeEscEventListener()
      }
    }
  },

  beforeDestroy() {
    this.removeEscEventListener()
  },

  created() {},
  methods: {
    addEscEventListener() {
      this.escHandler = this.onEscKeyEvent.bind(this)
      document.addEventListener('keydown', this.escHandler)
    },

    removeEscEventListener() {
      if (this.escHandler) {
        document.removeEventListener('keydown', this.escHandler)
        this.escHandler = null
      }
    },

    onEscKeyEvent(evt) {
      evt = evt || window.event
      if (evt.keyCode === 27) {
        this.onClosed()
      }
    },

    onClickModalBG() {
      this._dettachElement()
    },

    _attachElement() {
      document.body.append(this.$el)
      this.oldOverflow = document.body.style.overflow
      document.body.style.overflow = 'hidden'

      this.opening = true
      this.$emit('open')
    },

    _dettachElement() {
      if (this.opening) {
        document.body.removeChild(this.$el)
        document.body.style.overflow = this.oldOverflow
        this.opening = false
        this.$emit('close')
      }
    },

    scrollEvent(e) {
      e.stopPropagation()
    },

    onClosed() {
      this._dettachElement()
    }
  }
}
</script>