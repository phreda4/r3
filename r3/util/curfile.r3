| name of the current file (shared buffer)
| The editor (tuiedit) and the IDE tools (r3map, r3token, ...) work on the same file,
| so they must share one buffer: defined here once and included by both.
|-------------------------
##filename * 1024
