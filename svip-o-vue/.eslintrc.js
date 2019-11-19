module.exports = {
    root: true,
    env: {
        node: true
    },
    'extends': [
        'plugin:vue/essential',
        'eslint:recommended'
    ],
    rules: {
        'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
        'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
        'no-unused-vars': process.env.NODE_ENV === 'production' ? 'error' : 'off',
        'no-multiple-empty-lines': [2,{"max": 2, "maxEOF": 10000, "maxBOF": 10000}],
        "indent": ["error", 4],
        "no-tabs": 0,
        'vue/no-parsing-error': [2, {
            "invalid-first-character-of-tag-name": false
        }] // fixes erroneous detection of a start-of-tag sequence from < occurring inside of js expressions
    },
    parserOptions: {
        parser: 'babel-eslint'
    },
    globals: {
        "_": true
    }
};
