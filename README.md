# r3forth 

A Minimalist, Self-Hosted Stack Machine Environment

r3forth is a programming language and environment inspired by ColorForth and the Forth philosophy. It’s designed to be a complete, self-contained system that balances extreme minimalism with practical creative power.

R3 can load and call procedures from any dynamic library (.DLL in windows) or (.SO in linux) the distro use SDL2 library for make games.

### Technical Overview

* **Ultra-Minimalist VM:** A highly portable, lightweight core (~40kb) written in C. It’s designed for simplicity and speed, currently supporting Windows and Linux: [r3evm](https://github.com/phreda4/r3evm).
* **Zero Bloat Philosophy:** No massive standard libraries or complex toolchains. It’s just the core VM, the stack, and your code.
* **High Performance & Native Ambitions:** Despite running on a VM, r3 is architected for speed. It features a self-hosted compiler (currently for Windows) written entirely in **r3forth**, laying the groundwork for future direct-to-metal implementations.
* **Rich Ecosystem:** On top of this minimal core, r3 provides a powerful suite of libraries for:
* **Graphics & 2D:** Sprites, tilemaps, fonts, animations, and stack-based sprites.
* **Advanced Logic:** 3D engine, collision hash, and TUI/Immediate Mode GUI (immgui).
* **Tooling:** Integrated editors and a growing collection of games and demos.

---

# Quick Start

### **LINUX**

r3 requires **SDL2** development libraries.

1. **Install dependencies:**
```bash
sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev

```

2a. **Run the precompiled binary:**

Donwload the [latest release(.zip)](https://github.com/phreda4/r3/archive/refs/heads/main.zip)
```bash
chmod +x r3lin
./r3lin
```

or

2b. **Build and Run:**
If you want to build the VM from source (recommended for compatibility):
```bash
# Clone the VM core
git clone https://github.com/phreda4/r3evm
cd r3evm && make
# Move the binary back to the main folder
mv r3lin ../ && cd ..
./r3lin

```

### **WINDOWS**

1. Donwload the [latest release(.zip)](https://github.com/phreda4/r3/archive/refs/heads/main.zip)
2. Extract and run `r3.exe`. No installation required.

---

## Workflow: How to use r3

r3 is flexible. You can use the built-in environment or stay in your favorite terminal/editor.

### 1. The Integrated Development Environment (IDE)

By default, running the binary without arguments loads the internal system.

* **Execution:** Run `./r3lin` (Linux) or `r3.exe` (Windows).
* **Bootstrap:** The system automatically loads `main.r3`. This script acts as the entry point, scanning the `/r3` folder to build the internal menu and tools.
* **The Environment:** Inside, you have access to the built-in code editor, dictionary browser, and live-coding tools.

### 2. Standard Text Editor Workflow (CLI)

If you prefer using Emacs, Vim or Notepad++, you can use r3 as a traditional compiler/interpreter.

* **Create your script:** Save your code with the `.r3` extension (e.g., `hello.r3`).
* **Run it directly:** Pass the filename as an argument:
```bash
| linux
./r3lin hello.r3

| windows
r3 hello.r3

```

* **Development Loop:** r3 is designed for instant feedback. The VM starts, compiles, and executes your script in milliseconds.

<table border="0">
  <tr>
    <td>
<video src="https://github.com/user-attachments/assets/163984bb-798e-472b-992c-779241fe481e" width="50%" controls></video>
    </td>
    <td>
<video src="https://github.com/user-attachments/assets/7d836a55-aa24-4ed0-938d-1d2deb8490b3" width="50%" controls></video>
    </td>
  </tr>
</table>

### 3. First program

Red box in the corner program

```
^r3/lib/sdl2gfx.r3

:main
	0 sdlcls
	$ff0000 sdlcolor
	10 10 100 100 sdlfrect
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	drop ;
	
:
	"red box in the corner" 800 600 SDLinit
	'main SDLShow
	SDLquit 
	;
```

### 4. Folder Structure

* `main.r3`: The core startup script.
* `/r3`: Contains all the code, the system libraries, the IDE code, and core tools, etc.. all in .r3 code
* `/asm`: Compiler folder, not used if you not invoke it.
* `/dll`: In WIN you not install anything, the dll is here.
* `/doc`: Documentation.
* `/media`: graphics, sounds, models, font..etc
* `/mem`: use like static memory (for keep info when exit r3)
*  `main.xml`: syntax coloring for notepad++

---

## Showcase & Demos

r3 is not just a language; it's a creative suite. Here is what you can find:

<table border="0">
  <tr>
    <td>
<video src="https://github.com/user-attachments/assets/1733a220-af3c-4621-a1bd-7330dee1b1d3" width="50%" controls></video>
    </td>
    <td>
<video src="https://github.com/user-attachments/assets/8b1be4ba-7a59-4b79-a756-6679d80ab342" width="50%" controls></video>
    </td>
  </tr>
  <tr>
    <td>
<video src="https://github.com/user-attachments/assets/aec7db6c-161a-4adf-b5d0-9a317ae7fe6f" width="50%" controls></video>
    </td>
    <td>
<video src="https://github.com/user-attachments/assets/2b8a343e-6df0-4c43-913c-1097ca2f2b65" width="50%" controls></video>
    </td>
  </tr>
</table>

### Games in itch.io
* https://phreda4.itch.io/

---

## More documentation

In the /doc folder.

* [Cheatsheet only BASE words](https://github.com/phreda4/r3/blob/main/doc/r3cheatsheet.pdf)
* [Tutorial](https://github.com/phreda4/r3/blob/main/doc/r3forth_tutorial.md)
* [Reference](https://github.com/phreda4/r3/blob/main/doc/r3forth_reference.md)
* [SDL graphics programing](https://github.com/phreda4/r3/blob/main/doc/r3forth-SDL-graphics.md)
* [Code libraries (Feb-2026)](https://github.com/phreda4/r3/blob/main/doc/r3forth-libs.md)

---

## Youtube Channel

* [Videos](https://www.youtube.com/@pablohreda)

