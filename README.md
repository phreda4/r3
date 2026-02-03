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
      <p align="center"><b>IDE</b></p>
    <img src="https://github.com/user-attachments/assets/e13d9b6e-a0d9-4130-8f7a-95a31ecd3ee2">
    </td>
    <td>
      <p align="center"><b>CLI</b></p>
      <img src="https://github.com/user-attachments/assets/0ad1456f-fa25-4378-af93-5e44795eacdf">
    </td>
  </tr>
</table>

### 3. Folder Structure

* `main.r3`: The core startup script.
* `/r3`: Contains all the code, the system libraries, the IDE code, and core tools, etc.. all in .r3 code
* `/asm`: Compiler folder, not used if you not invoke it.
* `/dll`: In WIN you not install anything, the dll is here.
* `/doc`: Documentation, in progress as allways, r3datasheet.pdf is the usefull one.
* `/media`: graphics, sounds, models, font..etc
* `/mem`: use like static memory (for keep info when exit r3)
*  `main.xml`: syntax coloring for notepad++

---

## Showcase & Demos

r3 is not just a language; it's a creative suite. Here is what you can find:

| Category | Highlights | Image/GIF |
| :--- | :--- | :--- |
| **Graphics** | Real-time Fractals (Mandelbrot), 3D Wireframe Engine, Particle Systems. | ![Mandelbrot](link_a_tu_gif) |
| **Games** | Classic Snake, Tetris, and Collision Physics demos. | ![Games](link_a_tu_gif) |
| **Tooling** | **Self-hosted IDE**: code, debug, and run without leaving r3. | ![Editor](link_a_tu_gif) |
| **Advanced** | Immediate Mode GUI (immgui), Tilemap editors, and Sound synthesis. | ![GUI](link_a_tu_gif) |

---

## More documentation

In the doc folder. Always in progress.

[Manual](https://github.com/phreda4/r3/blob/main/doc/r3forth_manual.md)
[Quick reference](https://github.com/phreda4/r3/blob/main/doc/r3forth_quick_ref.md)
[Words from basic libs](https://github.com/phreda4/r3/blob/main/doc/r3forth_word_ref.md)
[Cheatsheet only BASE words](https://github.com/phreda4/r3/blob/main/doc/r3cheatsheet.pdf)

---

## Youtube Channel

[Videos](https://www.youtube.com/@pablohreda)

