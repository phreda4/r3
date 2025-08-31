| tensorflowlite_c.dll
| PHREDA 2025

^r3/lib/win/kernel32.r3

#TfLiteModelCreateFromFile_p ::TfLiteModelCreateFromFile TfLiteModelCreateFromFile_p sys1 ;
#TfLiteInterpreterOptionsCreate_p ::TfLiteInterpreterOptionsCreate TfLiteInterpreterOptionsCreate_p sys0 ;
#TfLiteInterpreterCreate_p ::TfLiteInterpreterCreate TfLiteInterpreterCreate_p sys2 ;
#TfLiteInterpreterAllocateTensors_p ::TfLiteInterpreterAllocateTensors TfLiteInterpreterAllocateTensors_p sys1 ;
#TfLiteInterpreterGetInputTensor_p ::TfLiteInterpreterGetInputTensor TfLiteInterpreterGetInputTensor_p sys2 ;
#TfLiteTensorDim_p ::TfLiteTensorDim TfLiteTensorDim_p sys2 ;
#TfLiteInterpreterGetOutputTensor_p ::TfLiteInterpreterGetOutputTensor TfLiteInterpreterGetOutputTensor_p sys2 ;
#TfLiteInterpreterInvoke_p ::TfLiteInterpreterInvoke TfLiteInterpreterInvoke_p sys1 ;
#TfLiteInterpreterDelete_p ::TfLiteInterpreterDelete TfLiteInterpreterDelete_p sys1 ;
#TfLiteInterpreterOptionsDelete_p ::TfLiteInterpreterOptionsDelete TfLiteInterpreterOptionsDelete_p sys1 ;
#TfLiteModelDelete_p ::TfLiteModelDelete TfLiteModelDelete_p sys1 ;
#TfLiteXNNPackDelegateCreate_p ::TfLiteXNNPackDelegateCreate TfLiteXNNPackDelegateCreate_p sys1 ;
#TfLiteInterpreterOptionsAddDelegate_p ::TfLiteInterpreterOptionsAddDelegate TfLiteInterpreterOptionsAddDelegate_p sys2 ;
: 
	".\\dll" SetDllDirectory
	"tensorflowlite_c.dll" loadlib
dup "TfLiteModelCreateFromFile" getproc 'TfLiteModelCreateFromFile_p !
dup "TfLiteInterpreterOptionsCreate" getproc 'TfLiteInterpreterOptionsCreate_p !
dup "TfLiteInterpreterCreate" getproc 'TfLiteInterpreterCreate_p !
dup "TfLiteInterpreterAllocateTensors" getproc 'TfLiteInterpreterAllocateTensors_p !
dup "TfLiteInterpreterGetInputTensor" getproc 'TfLiteInterpreterGetInputTensor_p !
dup "TfLiteTensorDim" getproc 'TfLiteTensorDim_p !
dup "TfLiteInterpreterGetOutputTensor" getproc 'TfLiteInterpreterGetOutputTensor_p !
dup "TfLiteInterpreterInvoke" getproc 'TfLiteInterpreterInvoke_p !
dup "TfLiteInterpreterDelete" getproc 'TfLiteInterpreterDelete_p !
dup "TfLiteInterpreterOptionsDelete" getproc 'TfLiteInterpreterOptionsDelete_p !
dup "TfLiteModelDelete" getproc 'TfLiteModelDelete_p !
dup "TfLiteXNNPackDelegateCreate" getproc 'TfLiteXNNPackDelegateCreate_p !
dup "TfLiteInterpreterOptionsAddDelegate" getproc 'TfLiteInterpreterOptionsAddDelegate_p !
	drop
	"" SetDllDirectory
	;