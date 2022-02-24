import Vue from 'vue'
import VueI18n from 'vue-i18n'

import validationMessagesEn from 'vee-validate/dist/locale/en'
import validationMessagesEs from 'vee-validate/dist/locale/es'

Vue.use(VueI18n)

const validationMessages = {
  en: validationMessagesEn,
  es: validationMessagesEs
}

function loadLocaleMessages () {
  const locales = require.context('./locales', true, /[A-Za-z0-9-_,\s]+\.json$/i)
  const messages = {}
  locales.keys().forEach(key => {
    const matched = key.match(/([A-Za-z0-9-_]+)\./i)
    if (matched && matched.length > 1) {
      const locale = matched[1]
      messages[locale] = locales(key)
      messages[locale].validations = validationMessages[locale]
    }
  })
  return messages
}

export default new VueI18n({
  locale: process.env.VUE_APP_I18N_LOCALE || 'en',
  fallbackLocale: process.env.VUE_APP_I18N_FALLBACK_LOCALE || 'en',
  messages: loadLocaleMessages()
})