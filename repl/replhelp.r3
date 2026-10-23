| replhelp2 - command table of r3repl2 (autocomplete and /help): the table of replhelp plus the commands of the zones
| each record: "name" "library" "args" "description"; the list ends with a 0 byte
| words (base + mlibs) come from replib.r3

##ctab
| inspect
"/stack" "cmd" "" "show the stack"
"/fmt" "cmd" "[dec|hex|fix]" "stack format, no arg: cycle (also ctrl+f)"
"/term" "cmd" "" "output terminal of the last run (also ctrl+t)"
"/src" "cmd" "[word]" "definitions of the project, or only that word"
| zones (r3repl2): a zone is a definition, a data, a block of comments or a text that is edited as a whole
"/list" "cmd" "[text]" "zones of the project, numbered (the text filters by name)"
"/redef" "cmd" "[word|n]" "load a zone in the box to redefine it in its place (no arg: the last one)"
"/del" "cmd" "word|n" "delete a zone of the project"
"/format" "cmd" "" "format all the code and leave a blank line between the zones"
"/trace" "cmd" "[on|off]" "stack at the exit of each project word (program instrumented from the tokens)"
| clean
"/clear" "cmd" "" "clear the screen only (also ctrl+l)"
"/reset" "cmd" "" "empty stack, data and project code (keeps .bak)"
| project
"/save" "cmd" "" "save the project (also saved when code is added)"
"/new" "cmd" "name" "new (empty) project"
"/load" "cmd" "name" "open a project (no name: list)"
"/proj" "cmd" "" "list projects"
"/open" "cmd" "file" "new project from a code in r3/"
"/find" "cmd" "text" "search codes in r3/"
"/edit" "cmd" "" "edit the project (r3ide, F5 debugs)"
"/run" "cmd" "" "launch the project"
| hooks
"/init" "cmd" "[code|off]" "hook run before each line (repl-init)"
"/done" "cmd" "[code|off]" "hook run after each line (repl-done)"
| help
"/help" "cmd" "" "command help"
"/words" "cmd" "[txt]" "search words in base + libraries"
"/lib" "cmd" "word" "library to include"
"/exit" "cmd" "" "quit"
".rs" "repl" "--" "inside any code: print the stack and keep it"
( 0 )

::e.lib >>0 ;                  | record -- library
::e.arg >>0 >>0 ;              | record -- args
::e.desc >>0 >>0 >>0 ;         | record -- description
::e.next >>0 >>0 >>0 >>0 ;     | record -- next record
