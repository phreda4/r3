| webcam.r3 - Binding para webcam.dll
| Basado en webcam.h

| --- Constantes (Enums) ---

| WebcamPixelFormat
##WEBCAM_FMT_RGB24 0
##WEBCAM_FMT_YUYV 1

| WebcamParameter
##WEBCAM_PARAM_BRIGHTNESS 1
##WEBCAM_PARAM_CONTRAST 2
##WEBCAM_PARAM_SATURATION 3
##WEBCAM_PARAM_EXPOSURE 4
##WEBCAM_PARAM_FOCUS 5
##WEBCAM_PARAM_ZOOM 6

| --- Definición de Punteros a Funciones ---

#webcam_set_logger_p
#webcam_list_devices_p
#webcam_free_list_p
#webcam_open_p
#webcam_capture_p
#webcam_close_p
#webcam_get_actual_width_p
#webcam_get_actual_height_p
#webcam_get_parameter_p
#webcam_set_parameter_p
#webcam_set_auto_p

| --- Wrappers (Llamadas al sistema) ---
| Nota: 'drop' se usa en funciones que retornan void en C

| void webcam_set_logger(WebcamLogFunc func)
::webcam_set_logger webcam_set_logger_p sys1 drop ;

| WebcamInfo* webcam_list_devices(int *count)
::webcam_list_devices webcam_list_devices_p sys1 ;

| void webcam_free_list(WebcamInfo *list)
::webcam_free_list webcam_free_list_p sys1 drop ;

| Webcam* webcam_open(int width, int height, int device_index, WebcamPixelFormat format)
::webcam_open webcam_open_p sys4 ;

| int webcam_capture(Webcam *cam, WebcamFrame *frame)
::webcam_capture webcam_capture_p sys2 ;

| void webcam_close(Webcam *cam)
::webcam_close webcam_close_p sys1 drop ;

| int webcam_get_actual_width(Webcam *cam)
::webcam_get_actual_width webcam_get_actual_width_p sys1 ;

| int webcam_get_actual_height(Webcam *cam)
::webcam_get_actual_height webcam_get_actual_height_p sys1 ;

| long webcam_get_parameter(Webcam *cam, WebcamParameter param)
::webcam_get_parameter webcam_get_parameter_p sys2 ;

| int webcam_set_parameter(Webcam *cam, WebcamParameter param, long value)
::webcam_set_parameter webcam_set_parameter_p sys3 ;

| int webcam_set_auto(Webcam *cam, WebcamParameter param, int is_auto)
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

:
    "dll/webcam.dll" loadlib 

    dup "webcam_set_logger" getproc 'webcam_set_logger_p !
    dup "webcam_list_devices" getproc 'webcam_list_devices_p !
    dup "webcam_free_list" getproc 'webcam_free_list_p !
    dup "webcam_open" getproc 'webcam_open_p !
    dup "webcam_capture" getproc 'webcam_capture_p !
    dup "webcam_close" getproc 'webcam_close_p !
    dup "webcam_get_actual_width" getproc 'webcam_get_actual_width_p !
    dup "webcam_get_actual_height" getproc 'webcam_get_actual_height_p !
    dup "webcam_get_parameter" getproc 'webcam_get_parameter_p !
    dup "webcam_set_parameter" getproc 'webcam_set_parameter_p !
    dup "webcam_set_auto" getproc 'webcam_set_auto_p !
    
    drop 
;