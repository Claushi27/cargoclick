module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "linebreak-style": "off",  // Desactivar para Windows
    "max-len": ["error", {"code": 120}],  // Aumentar límite de caracteres
    "require-jsdoc": "off",  // Desactivar JSDoc requerido
    "comma-dangle": "off",  // Desactivar trailing comma
    "operator-linebreak": "off",  // Desactivar posición de operadores
    "no-trailing-spaces": "off",  // Desactivar espacios al final
    "indent": "off",  // Desactivar indentación estricta
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
