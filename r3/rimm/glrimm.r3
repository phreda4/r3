| RIMM: immediate mode gui for R3Forth (OpenGL backend, glgfx)
|   ^r3/rimm/glrimm.r3
| Same words as rimm.r3. Call fini before the gui and fend after it
| (glgfx), and uiStart / uiEnd as always.
| Open the window with rimmGLini (GLini + glgfx): without glgfx nothing is drawn.
|
^r3/rimm/rimmgl.r3
^r3/rimm/rimmwid.r3
