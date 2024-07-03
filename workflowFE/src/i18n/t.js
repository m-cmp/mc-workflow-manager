import { computed } from 'vue'

import i18n from '@/i18n'

/**
 * Computed 적용된 다국어 함수
 * @function t
 * @param {string} argStr 다국어 경로
 * @returns {string} 다국어 처리된 텍스트
 */
const t = argStr => computed(() => i18n.global.t(argStr))

/**
 * Computed 적용 안된 다국어 함수(computed 적용된 함수를 사용할 경우 오류날 때 사용)
 * @function tt
 * @param {string} argStr 다국어 경로
 * @returns {string} 다국어 처리된 텍스트
 */
export const tt = argStr => i18n.global.t(argStr) // computed 적용 안 된 다국어 함수()
export const noDataTxt = tt('common.message.noData')

export default t
