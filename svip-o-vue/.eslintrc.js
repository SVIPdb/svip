// https://eslint.org/docs/user-guide/configuring

module.exports = {
  root: true,
  parserOptions: {
    parser: 'babel-eslint'
  },
  env: {
    browser: true,
  },
  extends: [
    // https://github.com/vuejs/eslint-plugin-vue#priority-a-essential-error-prevention
    // consider switching to `plugin:vue/strongly-recommended` or `plugin:vue/recommended` for stricter rules.
    'plugin:vue/essential', 
    // https://github.com/standard/standard/blob/master/docs/RULES-en.md
    'standard'
  ],
  // required to lint *.vue files
  plugins: [
    'vue'
  ],
  // add your custom rules here
  rules: {
    // allow async-await
    'generator-star-spacing': 'off',
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',

    'quotes': 'off',
    'semi': 'off',
    'indent': 'off',
    'space-before-function-paren': 'off',
    'curly': 'off',
    'camelcase': 'off',
    'eqeqeq': 'off',
    'no-mixed-spaces-and-tabs': 'off',
    'no-new': 'off',
    'no-tabs': 'off',
    'no-undef': 'off',
    'no-unused-vars': 'off',
    'no-useless-escape': 'off',
    'one-var': 'off',
    'prefer-promise-reject-errors': 'off',
    'standard/object-curly-even-spacing': 'off',

    'func-call-spacing': 'off',
    'no-unexpected-multiline': 'off',
    'no-return-assign': 'off',
    'no-unused-expressions': 'off',
    'vue/no-parsing-error': 'off',
    'vue/no-unused-components': 'off',
    'vue/no-unused-vars': 'off',
    'vue/require-v-for-key': 'off',
  }
}
