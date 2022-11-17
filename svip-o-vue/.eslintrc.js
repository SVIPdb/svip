module.exports = {
    root: true,

    env: {
        node: true,
    },

    extends: ['plugin:vue/essential', 'eslint:recommended'],

    rules: {
        'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
        'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
        'no-unused-vars': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
        'no-multiple-empty-lines': [2, {max: 2, maxEOF: 10000, maxBOF: 10000}],
        'no-constant-condition': 'off',
        'no-redeclare': 'off',
        'indent': ['error', 4],
        'no-tabs': 0,
        'vue/no-parsing-error': [
            2,
            {
                'invalid-first-character-of-tag-name': false,
            },
        ], // fixes erroneous detection of a start-of-tag sequence from < occurring inside of js expressions
        // The following rules are temporary switched off
        // TODO: reenable it and cleanup the code base
        'vue/multi-word-component-names': 'off',
        'vue/no-mutating-props': 'off',
        'vue/no-unused-vars': 'off',
        'no-prototype-builtins': 'off',
        'vue/no-arrow-functions-in-watch': 'off',
        'vue/valid-v-slot': 'off'
    },

    parserOptions: {
        parser: '@babel/eslint-parser',
        ecmaVersion: 8,
        requireConfigFile: false
    },

    globals: {
        _: true,
    },

    overrides: [
        {
            files: ['**/__tests__/*.{j,t}s?(x)', '**/tests/unit/**/*.spec.{j,t}s?(x)'],
            env: {
                jest: true,
            },
        },
    ],
};
