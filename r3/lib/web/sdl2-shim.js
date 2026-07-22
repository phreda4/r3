// Shim para sdl2-web.r3 -- backend Canvas2D (WebGL2 queda para otro dia,
// solo cubre SDL_GL_* que no esta portado en esta version).

const canvas = document.getElementById('sdl-canvas');
const ctx = canvas.getContext('2d');
const textures = [null];          // indice 0 reservado, ids empiezan en 1
let drawColor = 'rgb(0,0,0)';

function mem()  { return new DataView(instance.exports.memory.buffer); }
function bytes(){ return new Uint8Array(instance.exports.memory.buffer); }
function cstr(ptr) {
	let s = '', b = bytes();
	while (b[ptr]) s += String.fromCharCode(b[ptr++]);
	return s;
}

// ---- cola de eventos, llenada por los listeners del DOM ---------------
const evQueue = [];
function pushEvent(type, fields) { evQueue.push({ type, ...fields }); }

canvas.addEventListener('mousemove', e => {
	const r = canvas.getBoundingClientRect();
	pushEvent(0x400, { x: (e.clientX - r.left) | 0, y: (e.clientY - r.top) | 0 });
});
canvas.addEventListener('mousedown', e => pushEvent(0x401, { button: e.button + 1 }));
canvas.addEventListener('mouseup',   e => pushEvent(0x402, { button: e.button + 1 }));
canvas.addEventListener('wheel',     e => pushEvent(0x403, { wheel: Math.sign(e.deltaY) }));
window.addEventListener('keydown',   e => pushEvent(0x300, { key: e.keyCode }));
window.addEventListener('keyup',     e => pushEvent(0x301, { key: e.keyCode }));
new ResizeObserver(() => {
	pushEvent(0x200, { w: canvas.width, h: canvas.height }); // SDL_WINDOWEVENT
}).observe(canvas);

// ---- escribe UN evento en memoria con el layout real de SDL_Event -----
// offsets tal como los lee SDLupdate/changews en sdl2.r3 -- NO cambiar
// sin actualizar el .r3 en espejo.
function writeEvent(addr, ev) {
	const v = mem();
	v.setUint32(addr + 0, ev.type, true);
	if (ev.type === 0x200) {                       // WINDOWEVENT
		v.setUint8(addr + 12, 5);                    // SDL_WINDOWEVENT_RESIZED
		v.setUint32(addr + 16, ev.w, true);
		v.setUint32(addr + 20, ev.h, true);
	} else if (ev.type === 0x300 || ev.type === 0x301) {   // KEYDOWN/UP
		v.setUint32(addr + 20, ev.key, true);
	} else if (ev.type === 0x400) {                 // MOUSEMOTION
		v.setUint32(addr + 20, ev.x & 0xffff, true);
		v.setUint16(addr + 24, ev.y, true);
	} else if (ev.type === 0x401 || ev.type === 0x402) {   // MOUSEBUTTON
		v.setUint8(addr + 16, ev.button);
	} else if (ev.type === 0x403) {                  // MOUSEWHEEL
		v.setUint32(addr + 20, ev.wheel, true);
	}
}

// ---- estado minimo de "ventana"/"renderer" (un solo canvas, IDs dummy) -
let sdlEventAddr = 0;

const env = {
	js_SDL_Init: () => 0,
	js_SDL_Quit: () => {},
	js_SDL_CreateWindow: (titlePtr, x, y, w, h, flags) => {
		canvas.width = w; canvas.height = h;
		return 1;
	},
	js_SDL_DestroyWindow: () => {},
	js_SDL_RaiseWindow: () => {},       // no aplica -- no hay foco de OS que robar
	js_SDL_SetWindowFullscreen: (win, flag) => {
		if (flag) canvas.requestFullscreen?.(); else document.exitFullscreen?.();
		return 0;
	},
	js_SDL_GetWindowSize: () => 0,       // TODO: escribir w/h en los punteros recibidos
	js_SDL_SetWindowSize: (win, w, h) => { canvas.width = w; canvas.height = h; },
	js_SDL_ShowCursor: (show) => { canvas.style.cursor = show ? 'default' : 'none'; return 0; },

	js_SDL_CreateRenderer: () => 1,      // el canvas 2D "es" el renderer, id dummy
	js_SDL_DestroyRenderer: () => {},
	js_SDL_SetRenderDrawColor: (rend, r, g, b, a) => { drawColor = `rgba(${r},${g},${b},${a / 255})`; },
	js_SDL_RenderClear: () => { ctx.fillStyle = drawColor; ctx.fillRect(0, 0, canvas.width, canvas.height); },
	js_SDL_RenderPresent: () => {},      // canvas2D ya pinta inmediato, no hay flip real
	js_SDL_RenderDrawPoint: (rend, x, y) => { ctx.fillStyle = drawColor; ctx.fillRect(x, y, 1, 1); },
	js_SDL_RenderDrawLine: (rend, x1, y1, x2, y2) => {
		ctx.strokeStyle = drawColor; ctx.beginPath();
		ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke();
	},
	js_SDL_RenderDrawRect: (rend, rectPtr) => {
		const v = mem();
		const x = v.getInt32(rectPtr, true), y = v.getInt32(rectPtr + 4, true);
		const w = v.getInt32(rectPtr + 8, true), h = v.getInt32(rectPtr + 12, true);
		ctx.strokeStyle = drawColor; ctx.strokeRect(x, y, w, h);
	},
	js_SDL_RenderFillRect: (rend, rectPtr) => {
		const v = mem();
		const x = v.getInt32(rectPtr, true), y = v.getInt32(rectPtr + 4, true);
		const w = v.getInt32(rectPtr + 8, true), h = v.getInt32(rectPtr + 12, true);
		ctx.fillStyle = drawColor; ctx.fillRect(x, y, w, h);
	},
	js_SDL_RenderCopy: (rend, texId, srcPtr, dstPtr) => {
		const v = mem(), img = textures[texId];
		const dx = v.getInt32(dstPtr, true), dy = v.getInt32(dstPtr + 4, true);
		const dw = v.getInt32(dstPtr + 8, true), dh = v.getInt32(dstPtr + 12, true);
		ctx.drawImage(img, dx, dy, dw, dh);
	},
	js_SDL_RenderCopyEx: (rend, texId, srcPtr, dstPtr, angle, centerPtr, flip) => {
		const v = mem(), img = textures[texId];
		const dx = v.getInt32(dstPtr, true), dy = v.getInt32(dstPtr + 4, true);
		const dw = v.getInt32(dstPtr + 8, true), dh = v.getInt32(dstPtr + 12, true);
		ctx.save();
		ctx.translate(dx + dw / 2, dy + dh / 2);
		ctx.rotate(angle * Math.PI / 180);
		ctx.drawImage(img, -dw / 2, -dh / 2, dw, dh);
		ctx.restore();
	},

	js_SDL_CreateTexture: (rend, format, access, w, h) => {
		const off = new OffscreenCanvas(w, h);
		textures.push(off);
		return textures.length - 1;
	},
	js_SDL_UpdateTexture: (texId, rectPtr, pixelsPtr, pitch) => {
		const off = textures[texId];
		const octx = off.getContext('2d');
		const imgData = octx.createImageData(off.width, off.height);
		imgData.data.set(bytes().subarray(pixelsPtr, pixelsPtr + imgData.data.length));
		octx.putImageData(imgData, 0, 0);
	},
	js_SDL_DestroyTexture: (texId) => { textures[texId] = null; },
	js_SDL_QueryTexture: (texId, fmtPtr, accessPtr, wPtr, hPtr) => {
		const v = mem(), t = textures[texId];
		v.setInt32(wPtr, t.width, true);
		v.setInt32(hPtr, t.height, true);
	},

	js_SDL_PollEvent: (evAddr) => {
		if (evQueue.length === 0) return 0;
		writeEvent(evAddr, evQueue.shift());
		return 1;
	},
	js_SDL_Delay: () => {},              // ver nota de bloqueo, mas abajo
	js_SDL_GetTicks: () => performance.now() | 0,
	js_SDL_GetError: () => 0,            // TODO: puntero a mensaje real si hace falta
};

let instance;
async function main() {
	({ instance } = await WebAssembly.instantiateStreaming(fetch('r3.wasm'), { env }));
	sdlEventAddr = instance.exports.get_sdlevent_addr();
	// SDLtick reemplaza el WHILE bloqueante que tenia SDLshow -- una
	// iteracion por vuelta de rAF, la palabra a renderizar ya quedo
	// guardada en 'SDLrenderword por el SDLshow inicial (una sola vez,
	// en el arranque del programa r3, antes de que empiece este loop).
	function frame() {
		instance.exports.SDLtick();
		requestAnimationFrame(frame);
	}
	requestAnimationFrame(frame);
}
main();
