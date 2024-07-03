import ko from '@/i18n/locales/ko.json';
import en from '@/i18n/locales/en.json';
import {createI18n} from "vue-i18n";

const defaultLocale = 'ko'

const languages = {
  ko: ko,
  en: en,
}


const messages = Object.assign(languages)

const i18n = createI18n({
  legacy: false,
  locale: defaultLocale,
  globalInjection: true,
  messages
})

export default i18n;
