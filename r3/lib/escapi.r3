| https://github.com/jarikomppa/escapi
| lib for webcam
| PHREDA 2025
^r3/lib/win/kernel32.r3

#countCaptureDevices_p
::countCaptureDevices countCaptureDevices_p sys0 ;
#deinitCapture_p
::deinitCapture deinitCapture_p sys1 ;
#doCapture_p
::doCapture doCapture_p sys1 drop ;
#ESCAPIDLLVersion_p
::ESCAPIDLLVersion ESCAPIDLLVersion_p sys0 ;
#ESCAPIVersion_p
::ESCAPIVersion ESCAPIVersion_p sys0 ;
#getCaptureDeviceName_p
::getCaptureDeviceName getCaptureDeviceName_p
#getCaptureErrorCode_p
::getCaptureErrorCode getCaptureErrorCode_p sys1 ;
#getCaptureErrorLine_p
::getCaptureErrorLine getCaptureErrorLine_p sys1 ;
#getCapturePropertyAuto_p
::getCapturePropertyAuto getCapturePropertyAuto_p sys2 ;
#getCapturePropertyValue_p
::getCapturePropertyValue getCapturePropertyValue_p sys2 ;
#initCapture_p
::initCapture initCapture_p sys2 ;
#initCOM_p
::initCOM initCOM_p sys0 drop ;
#isCaptureDone_p
::isCaptureDone isCaptureDone_p sys1 ; 
#setCaptureProperty_p
::setCaptureProperty setCaptureProperty_p sys4 ; |*** (2do float)

|truct SimpleCapParams {
|int * mTargetBuf;
|int mWidth;
|int mHeight;

|	CAPTURE_BRIGHTNESS,
|	CAPTURE_CONTRAST,
|	CAPTURE_HUE,
|	CAPTURE_SATURATION,
|	CAPTURE_SHARPNESS,
|	CAPTURE_GAMMA,
|	CAPTURE_COLORENABLE,
|	CAPTURE_WHITEBALANCE,
|	CAPTURE_BACKLIGHTCOMPENSATION,
|	CAPTURE_GAIN,
|	CAPTURE_PAN,
|	CAPTURE_TILT,
|	CAPTURE_ROLL,
|	CAPTURE_ZOOM,
|	CAPTURE_EXPOSURE,
|	CAPTURE_IRIS,
|	CAPTURE_FOCUS,
|	CAPTURE_PROP_MAX

::setupESCAPI | -- ndevices
	|ESCAPIVersion "%h" .println
	initCOM countCaptureDevices ;
	
: 
	"dll/escapi.dll" loadlib 
dup "countCaptureDevices" getproc 'countCaptureDevices_p !
dup "deinitCapture" getproc 'deinitCapture_p !
dup "doCapture" getproc 'doCapture_p !
dup "ESCAPIDLLVersion" getproc 'ESCAPIDLLVersion_p !
dup "ESCAPIVersion" getproc 'ESCAPIVersion_p !
dup "getCaptureDeviceName" getproc 'getCaptureDeviceName_p !
dup "getCaptureErrorCode" getproc 'getCaptureErrorCode_p !
dup "getCaptureErrorLine" getproc 'getCaptureErrorLine_p !
dup "getCapturePropertyAuto" getproc 'getCapturePropertyAuto_p !
dup "getCapturePropertyValue" getproc 'getCapturePropertyValue_p !
dup "initCapture" getproc 'initCapture_p !
dup "initCOM" getproc 'initCOM_p !
dup "isCaptureDone" getproc 'isCaptureDone_p !
dup "setCaptureProperty" getproc 'setCaptureProperty_p !
	drop
	;