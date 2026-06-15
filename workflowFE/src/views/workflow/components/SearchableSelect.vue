<template>
  <div class="searchable-select">
    <input
      ref="inputRef"
      class="form-control p-2 searchable-select-input"
      :placeholder="placeholder"
      :title="title || selectedLabel"
      :value="inputText"
      autocomplete="off"
      @blur="onBlur"
      @focus="openOptions"
      @input="onInput"
      @keydown.down.prevent="moveActive(1)"
      @keydown.enter.prevent="selectActiveOption"
      @keydown.esc="closeOptions"
      @keydown.up.prevent="moveActive(-1)"
    />
    <div v-if="isOpen" class="searchable-select-menu">
      <button
        v-for="(option, index) in filteredOptions"
        :key="`${option.value}-${index}`"
        type="button"
        class="searchable-select-option"
        :class="{ active: index === activeIndex }"
        :title="option.label"
        @mousedown.prevent="selectOption(option)"
      >
        {{ option.label }}
      </button>
      <div v-if="filteredOptions.length === 0" class="searchable-select-empty">
        No matches
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'

interface SelectOption {
  label: string
  value: string
  searchText?: string
}

interface Props {
  modelValue?: string
  options: Array<SelectOption>
  placeholder?: string
  title?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  options: () => [],
  placeholder: '',
  title: '',
})

const emit = defineEmits(['update:modelValue', 'change'])

const inputRef = ref<HTMLInputElement>()
const inputText = ref('')
const isOpen = ref(false)
const activeIndex = ref(0)

const selectedOption = computed(() => {
  return props.options.find((option) => option.value === props.modelValue)
})

const selectedLabel = computed(() => {
  return selectedOption.value?.label || props.modelValue || ''
})

const filteredOptions = computed(() => {
  const query = normalize(inputText.value)
  const source = props.options || []
  const result = query
    ? source.filter((option) => {
      return matchesOption(option, query)
    })
    : source

  return result.slice(0, 80)
})

watch(
  () => [props.modelValue, props.options],
  () => {
    syncInputText()
  },
  { immediate: true }
)

const syncInputText = () => {
  inputText.value = selectedLabel.value
}

const onInput = (event: Event) => {
  inputText.value = (event.target as HTMLInputElement).value
  activeIndex.value = 0
  openOptions()
}

const openOptions = () => {
  isOpen.value = true
}

const closeOptions = () => {
  isOpen.value = false
  syncInputText()
}

const onBlur = () => {
  window.setTimeout(() => {
    commitTypedValue()
    isOpen.value = false
  }, 120)
}

const moveActive = (direction: number) => {
  if (!isOpen.value) {
    openOptions()
    return
  }

  const total = filteredOptions.value.length
  if (total === 0) return
  activeIndex.value = (activeIndex.value + direction + total) % total
}

const selectActiveOption = () => {
  const option = filteredOptions.value[activeIndex.value]
  if (option) {
    selectOption(option)
  }
}

const selectOption = (option: SelectOption) => {
  emit('update:modelValue', option.value)
  inputText.value = option.label
  isOpen.value = false
  activeIndex.value = 0
  inputRef.value?.blur()
  emit('change')
}

const commitTypedValue = () => {
  const text = inputText.value.trim()
  if (!text) {
    if (props.modelValue) {
      emit('update:modelValue', '')
      emit('change')
    }
    return
  }

  const exactOption = props.options.find((option) => {
    return matchesOptionExactly(option, text)
  })

  if (exactOption) {
    if (exactOption.value !== props.modelValue) {
      emit('update:modelValue', exactOption.value)
      emit('change')
    }
    inputText.value = exactOption.label
    return
  }

  syncInputText()
}

const normalize = (value?: string) => {
  return (value || '').trim().toLowerCase()
}

const compact = (value?: string) => {
  return normalize(value).replace(/[^a-z0-9\uac00-\ud7a3]/g, '')
}

const getOptionSearchValues = (option: SelectOption) => {
  return [
    option.label,
    option.value,
    option.searchText || '',
  ]
}

const matchesOption = (option: SelectOption, normalizedQuery: string) => {
  const compactQuery = compact(normalizedQuery)
  return getOptionSearchValues(option).some((value) => {
    const normalizedValue = normalize(value)
    if (normalizedValue.includes(normalizedQuery)) return true
    return Boolean(compactQuery) && compact(normalizedValue).includes(compactQuery)
  })
}

const matchesOptionExactly = (option: SelectOption, text: string) => {
  const normalizedText = normalize(text)
  const compactText = compact(text)
  return getOptionSearchValues(option).some((value) => {
    const normalizedValues = normalize(value)
      .split(/\n/)
      .map((item) => item.trim())
      .filter(Boolean)

    return normalizedValues.some((normalizedValue) => {
      return normalizedValue === normalizedText || compact(normalizedValue) === compactText
    })
  })
}
</script>

<style scoped>
.searchable-select {
  position: relative;
}

.searchable-select-input {
  min-width: 0;
}

.searchable-select-menu {
  background: #ffffff;
  border: 1px solid #dce3ec;
  border-radius: 4px;
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.16);
  left: 0;
  max-height: 18rem;
  overflow-y: auto;
  position: absolute;
  right: 0;
  top: calc(100% + 0.25rem);
  z-index: 1080;
}

.searchable-select-option {
  background: transparent;
  border: 0;
  color: #1f2a3d;
  display: block;
  font-size: 0.875rem;
  line-height: 1.35;
  overflow: hidden;
  padding: 0.55rem 0.75rem;
  text-align: left;
  text-overflow: ellipsis;
  white-space: nowrap;
  width: 100%;
}

.searchable-select-option:hover,
.searchable-select-option.active {
  background: #eef5ff;
  color: #0f5db8;
}

.searchable-select-empty {
  color: #6b7890;
  font-size: 0.875rem;
  padding: 0.65rem 0.75rem;
}
</style>
