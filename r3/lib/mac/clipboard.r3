| clipboard in linux - need xclip instaled
| sudo apt install xclip
| PHREDA 2026

^r3/lib/mac/posix.r3

::copyclipboard \| 'mem cnt --
  "pbcopy" "w" libc-popen
  dup >r libc-fwrite
  r> libc-pclose ;

::pasteclipboard \| 'mem --
  "pbpaste" "r" libc-popen
  0? ( 2drop ; )
  >r 1 8192 r@ libc-fread
  r> libc-pclose ;
