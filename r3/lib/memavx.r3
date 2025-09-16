| memavx.dll
| mem copy with AVX converting from/to float or Fixedpoint
| f32:float p16:fixedpoint rgb:int32
| PHREDA 2025
^r3/lib/win/kernel32.r3

#memcpy_rgb3f_p ::memcpy_rgb3f memcpy_rgb3f_p sys3 drop ;
#memcpy_bgr3f_p ::memcpy_bgr3f memcpy_bgr3f_p sys3 drop ;
#memcpy_rgbf_p ::memcpy_rgbf memcpy_rgbf_p sys3 drop ;
#memcpy_f32p16_p ::memcpy_f32p16 memcpy_f32p16_p sys3 drop ;
#memcpy_p16f32_p ::memcpy_p16f32 memcpy_p16f32_p sys3 drop ;
#memcpy_avx_p ::memcpy_avx memcpy_avx_p sys3 drop ;

: 
	"dll/memavx.dll" loadlib 
	dup "memcpy_rgb3f" getproc 'memcpy_rgb3f_p !
	dup "memcpy_bgr3f" getproc 'memcpy_bgr3f_p !
	dup "memcpy_rgbf" getproc 'memcpy_rgbf_p !
	dup "memcpy_f32p16" getproc 'memcpy_f32p16_p !
	dup "memcpy_p16f32" getproc 'memcpy_p16f32_p !
	dup "memcpy_avx" getproc 'memcpy_avx_p !
	drop
	;