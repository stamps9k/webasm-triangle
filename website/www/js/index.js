import $ from "jquery";
// wasm-pack builds with `--target web`: the default export fetches and
// instantiates the .wasm (Vite resolves its URL at build time), and must
// be awaited before any exported function is called.
import init, { initialize_web_gl } from "../../../webasm/pkg/webasm_triangle.js";

await init();
$(fetch_vert_shader);

function fetch_vert_shader() {
	$.ajax({
		url: "shaders/standard.vert",
		success: function (result) {
			const resources = new Map();
			resources.set("vert_shader", result);
			console.log("Vert shader loaded...");
			fetch_frag_shader(resources);
		},
	});
}

function fetch_frag_shader(resources) {
	$.ajax({
		url: "shaders/standard.frag",
		success: function (result) {
			resources.set("frag_shader", result);
			console.log("Frag shader loaded...");
			fetch_model(resources);
		},
	});
}

function fetch_model(resources) {
	$.ajax({
		url: "models/teapot.obj",
		success: function (result) {
			resources.set("teapot", result);
			console.log("teapot loaded...");
			initialize_web_gl(resources);
		},
		error: function () {
			console.log("Model fetched failed.");
		},
	});
}
