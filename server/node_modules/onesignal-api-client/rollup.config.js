import typescript from "rollup-plugin-typescript2";

const pkg = require("./package.json");
const external = Object.keys(pkg.dependencies);

export default {
  input: "lib/Client.ts",
  output: {
    file: "dist/index.js",
    format: "cjs"
  },
  external,
  sourcemap: true,

  plugins: [typescript()]
};
