// Shim para web-term.r3 -- requiere xterm.js (https://xtermjs.org)
// <script src="https://cdn.jsdelivr.net/npm/xterm/lib/xterm.js"></script>
// <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/xterm/css/xterm.css">

const term = new Terminal({ cols: 80, rows: 24, cursorBlink: true });
term.open(document.getElementById('terminal'));

// cola de teclas -- term.onData llena, js_inkey vacia (no bloqueante)
const keyQueue = [];
let resizedFlag = 0;

term.onData(data => {
	// traduce lo que xterm.js entrega a los mismos codigos que
	// console.r3 espera (ver tabla [ESC]/[UP]/[F1].. en console.r3).
	// xterm.js ya decodifica secuencias VT en 'data' como texto, asi
	// que en el caso simple (ascii) el codigo es directo:
	if (data.length === 1) {
		keyQueue.push(data.charCodeAt(0));
		return;
	}
	// secuencias especiales (flechas, F-keys) -- mapear a los mismos
	// literales $415b1b etc que usa console.r3, byte a byte invertido
	// tal como arma esos numeros ($41 '5b' '1b' -> primer byte=$1b):
	let code = 0;
	for (let i = 0; i < data.length; i++) code |= data.charCodeAt(i) << (8 * i);
	keyQueue.push(code);
});

term.onResize(() => { resizedFlag = 1; });

function mem() { return instance.exports.memory; }

const env = {
	js_write: (ptr, len) => {
		const bytes = new Uint8Array(mem().buffer, ptr, len);
		term.write(bytes);
	},
	js_inkey: () => (keyQueue.length ? keyQueue.shift() : 0),
	js_getcols: () => term.cols,
	js_getrows: () => term.rows,
	js_resized: () => {
		if (resizedFlag) { resizedFlag = 0; return 1; }
		return 0;
	},
};

let instance;
async function main() {
	({ instance } = await WebAssembly.instantiateStreaming(fetch('r3.wasm'), { env }));
	instance.exports.main();
}
main();
