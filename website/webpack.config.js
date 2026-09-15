const CopyWebpackPlugin = require("copy-webpack-plugin");
const path = require('path');

module.exports = {
  context: path.resolve(__dirname, "./"),
  entry: "./www/js/index.js",
	output: {
		path: path.resolve(__dirname, "dist"),
  	filename: "js/index.js",
	},
  mode: "development",
  devServer: {
    static: {
      directory: path.join(__dirname, './'),
      watch: true
		},
		port: 1236
  },
  plugins: [
    new CopyWebpackPlugin(
			[
				{ from: './www/index.html', to: './index.html' },
				{ from: './www/notes.html', to: './notes.html' },
				{ from: './www/shaders/standard.vert', to: './shaders/standard.vert' },
			  { from: './www/shaders/standard.frag', to: './shaders/standard.frag' },
				{ from: './www/models/teapot.obj', to: './models/teapot.obj' },
				{ from: './www/img', to: './img' }
			],
		)
  ]
};
