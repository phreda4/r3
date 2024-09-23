| main filesystem
| PHREDA 2019
|------------------------
^r3/posix/console.r3
^r3/lib/mconsole.r3

:main
    .cls
    "test1" .println
    ( inkey $1b <>?
        1? ( dup "%h " .print )
        drop ) drop

    |.input | no corta con enter!!!
    ;

: main ;
