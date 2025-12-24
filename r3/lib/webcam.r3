| webcam.r3 - Binding para webcam.dll
| Basado en webcam.h

| --- Constantes (Enums) ---

| WebcamPixelFormat
##WEBCAM_FMT_RGB24 0
##WEBCAM_FMT_RGB32 1
##WEBCAM_FMT_YUYV 2
##WEBCAM_FMT_YUV420 3
##WEBCAM_FMT_MJPEG 4

| WebcamParameter
##WEBCAM_PARAM_BRIGHTNESS 1
##WEBCAM_PARAM_CONTRAST 2
##WEBCAM_PARAM_SATURATION 3
##WEBCAM_PARAM_EXPOSURE 4
##WEBCAM_PARAM_FOCUS 5
##WEBCAM_PARAM_ZOOM 6
##WEBCAM_PARAM_GAIN 7
##WEBCAM_PARAM_SHARPNESS 8

| --- Definición de Punteros a Funciones ---

#webcam_list_devices_p
#webcam_free_list_p

#webcam_query_capabilities_p
#webcam_free_capabilities_p
#webcam_find_best_format_p

#webcam_open_p
#webcam_capture_p
#webcam_release_frame_p
#webcam_close_p
#webcam_get_actual_width_p
#webcam_get_actual_height_p
#webcam_get_parameter_p
#webcam_set_parameter_p
#webcam_set_auto_p
#webcam_get_format_p

| --- Wrappers (Llamadas al sistema) ---
| Nota: 'drop' se usa en funciones que retornan void en C

::webcam_list_devices webcam_list_devices_p sys1 ;
::webcam_free_list webcam_free_list_p sys1 drop ;

::webcam_query_capabilities webcam_query_capabilities_p sys1 ;
::webcam_free_capabilities webcam_free_capabilities_p sys1 drop ;
::webcam_find_best_format webcam_find_best_format_p sys4 ;

::webcam_open webcam_open_p sys4 ;
::webcam_capture webcam_capture_p sys2 ;
::webcam_release_frame webcam_release_frame_p sys1 drop ;
::webcam_close webcam_close_p sys1 drop ;

::webcam_get_actual_width webcam_get_actual_width_p sys1 ;
::webcam_get_actual_height webcam_get_actual_height_p sys1 ;
::webcam_get_format webcam_get_format_p sys1 ;

::webcam_get_parameter webcam_get_parameter_p sys2 ;
::webcam_set_parameter webcam_set_parameter_p sys3 ;
::webcam_set_auto webcam_set_auto_p sys3 ;

| --- Carga de la librería ---
|typedef struct {
|    unsigned char *data;
|    int width;
|    int height;
|    int size;
|    WebcamPixelFormat format;
|    unsigned long timestamp_ms; 
|} WebcamFrame;

|typedef struct {
|    int index;
|    char name[128];
|    char path[256]; // Util para identificacion unica
|} WebcamInfo;

|typedef struct {
|    WebcamPixelFormat format;
|    int width;
|    int height;
|    int fps;
|} WebcamFormatInfo;

|typedef struct {
|    WebcamFormatInfo *formats;
|    int format_count;
|    int max_width;
|    int max_height;
|    int min_width;
|    int min_height;
|} WebcamCapabilities;

:
|WIN| "dll/webcam.dll" loadlib 
|LIN| "/lib/libwebcam.so" loadlib
	dup "webcam_list_devices" getproc 'webcam_list_devices_p !
	dup "webcam_free_list" getproc 'webcam_free_list_p !
	dup "webcam_query_capabilities" getproc 'webcam_query_capabilities_p !
	dup "webcam_free_capabilities" getproc 'webcam_free_capabilities_p !
	dup "webcam_find_best_format" getproc 'webcam_find_best_format_p !
	
	dup "webcam_open" getproc 'webcam_open_p !
	dup "webcam_capture" getproc 'webcam_capture_p !
	dup "webcam_release_frame" getproc 'webcam_release_frame_p !
	dup "webcam_close" getproc 'webcam_close_p !
	dup "webcam_get_actual_width" getproc 'webcam_get_actual_width_p !
	dup "webcam_get_actual_height" getproc 'webcam_get_actual_height_p !
	dup "webcam_get_format" getproc 'webcam_get_format_p !
	dup "webcam_get_parameter" getproc 'webcam_get_parameter_p !
	dup "webcam_set_parameter" getproc 'webcam_set_parameter_p !
	dup "webcam_set_auto" getproc 'webcam_set_auto_p !

	drop 
	;