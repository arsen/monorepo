const typescriptEslint = require("@typescript-eslint/eslint-plugin");
const typescriptParser = require("@typescript-eslint/parser");
const importPlugin = require("eslint-plugin-import");
const googleConfig = require("eslint-config-google");

module.exports = [
  {
    ignores: ["lib/**/*", ".deploy/**/*", "node_modules/**/*", "eslint.config.js"],
  },
  {
    files: ["**/*.js", "**/*.ts"],
    languageOptions: {
      parser: typescriptParser,
      parserOptions: {
        project: ["./tsconfig.json", "./tsconfig.dev.json"],
        tsconfigRootDir: __dirname,
        sourceType: "module",
        ecmaVersion: 2018,
      },
      globals: {
        console: "readonly",
        process: "readonly",
        __dirname: "readonly",
        module: "readonly",
        require: "readonly",
        exports: "readonly",
        Buffer: "readonly",
      },
    },
    plugins: {
      "@typescript-eslint": typescriptEslint,
      "import": importPlugin,
    },
    rules: {
      // Google style guide base rules
      ...googleConfig.rules,
      
      // TypeScript recommended rules
      ...typescriptEslint.configs.recommended.rules,
      
      // Import plugin rules
      "import/no-unresolved": 0,
      
      // Custom rules
      "quotes": ["warn", "double"],
      "indent": ["error", 2],
      "object-curly-spacing": ["off"],
      "require-jsdoc": "off",
      "valid-jsdoc": "off",
      "@typescript-eslint/no-unused-vars": "warn",
    },
  },
];

