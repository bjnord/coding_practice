module.exports = {
    "env": {
        "browser": true,
        "es6": true,
        "node": true,
        "mocha": true,
    },
    "parserOptions": {
        "ecmaVersion": 8,
    },
    "extends": "eslint:recommended",
    "globals": {
        "Atomics": "readonly",
        "SharedArrayBuffer": "readonly",
    },
    "rules": {
        "keyword-spacing": [
            "error",
            {
                "before": true,
                "after": true,
            },
        ],
        "space-before-function-paren": [
            "error",
            {
                "anonymous": "always",
                "named": "never",
            },
        ],
        "eqeqeq": "error",
        "strict": [
            "error",
            "global",
        ],
        "no-var": "error",
        "prefer-const": "error",
        "no-console": "off",
        "indent": [
            "error",
            2,
        ],
        "linebreak-style": [
            "error",
            "unix",
        ],
        "quotes": [
            "error",
            "single",
            "avoid-escape",
        ],
        "semi": [
            "error",
            "always",
        ],
        "no-extra-semi": "off",
    },
};
