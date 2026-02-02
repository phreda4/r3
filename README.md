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


2. **Build and Run:**
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

1. Download the [latest release](https://www.google.com/search?q=https://github.com/phreda4/r3/releases).
2. Extract and run `r3.exe`. No installation required.

---

## Showcase & Demos

r3 is not just a language; it's a creative suite. Here is what you can find:

| Category | Highlights | Image/GIF |
| :--- | :--- | :--- |
| **Graphics** | Real-time Fractals (Mandelbrot), 3D Wireframe Engine, Particle Systems. | ![Mandelbrot](link_a_tu_gif) |
| **Games** | Classic Snake, Tetris, and Collision Physics demos. | ![Games](link_a_tu_gif) |
| **Tooling** | **Self-hosted IDE**: code, debug, and run without leaving r3. | ![Editor](link_a_tu_gif) |
| **Advanced** | Immediate Mode GUI (immgui), Tilemap editors, and Sound synthesis. | ![GUI](link_a_tu_gif) |

**** building ****
<img width="400" alt="image" src="https://github.com/user-attachments/assets/5ddc3924-0463-4a59-b8d6-fa3b48c271a6" />

The main.r3 execute by r3.exe is a browser for files in /r3 folder

with the keys you can navigate while see the code in the left side of the screen.

<img width="360" alt="image" src="https://github.com/user-attachments/assets/bd0785a6-ddd1-4afc-8d35-8af8d5a5331f" /><img width="360" alt="image" src="https://github.com/user-attachments/assets/1b8edc5b-c4ed-42b6-b263-76d491cf5375" />


Edit with ESP or execute with ENTER the code in this folder. 

## Manual

[r3forth Manual](https://github.com/phreda4/r3/wiki/r3forth-Manual).

## Youtube Channel

[Videos](https://www.youtube.com/@pablohreda)

***



https://github.com/phreda4/r3evm

