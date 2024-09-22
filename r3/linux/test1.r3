| main filesystem
| PHREDA 2019
|------------------------
^r3/posix/console.r3
^r3/posix/mconsole.r3

:main
    .cls
    "test1" .println

    getch
    .input | no corta con enter!!!

    ;

: main ;
