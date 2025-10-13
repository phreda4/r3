^r3/lib/3d.r3
#name "r3/lib/3d.r3"
#words  "xf" "yf" "ox" "oy" "2dmode" "3dmode" "Omode" "whmode" "o3dmode" "p3d" "p3dz" "p3di" "p3ditest" "p3dizb" "p3dcz" "p3d1" "p3di1" "project3d" "project3dz" "invproject3d" "projectdim" "project" "projectv" "inscreen" "proyect2d" "aspect" "mtrans" "mtransi" "mrotxi" "mrotyi" "mrotzi" 0
#calls  'xf 'yf 'ox 'oy '2dmode '3dmode 'Omode 'whmode 'o3dmode 'p3d 'p3dz 'p3di 'p3ditest 'p3dizb 'p3dcz 'p3d1 'p3di1 'project3d 'project3dz 'invproject3d 'projectdim 'project 'projectv 'inscreen 'proyect2d 'aspect 'mtrans 'mtransi 'mrotxi 'mrotyi 'mrotzi
#info ( $80 $80 $80 $80 $0 $1F $0 $2E $2E $3F $30 $30 $30 $30 $10 $3F $30 $3F $30 $3F $3F $3F $3F $2 $3F $1 $3D $3D $1F $1F $1F )
#r3_lib_3d.r3 'name 'words 'calls 'info
^r3/lib/3dgl.r3
#name "r3/lib/3dgl.r3"
#words  "mat>" "matini" "matinim" "mpush" "mpushi" "mpop" "nmpop" "getfmat" "gettfmat" "mcpyf" "mcpyft" "midf" "mperspective" "mortho" "mlookat" "mtran" "mtranx" "mtrany" "mtranz" "mrotx" "mroty" "mrotz" "mscale" "mscalei" "muscalei" "transform" "transformr" "ztransform" "oztransform" "oxyztransform" "matinv" "calcrot" "makerot" "matqua" "calcvrot" "mrotxyz" "mrotxyzi" "mcpy" "m*" "mm*" "mmi*" "mtra" "mrot" "mpos" "mrpos" "packrota" "+rota" "pack21" "+p21" 0
#calls  'mat> 'matini 'matinim 'mpush 'mpushi 'mpop 'nmpop 'getfmat 'gettfmat 'mcpyf 'mcpyft 'midf 'mperspective 'mortho 'mlookat 'mtran 'mtranx 'mtrany 'mtranz 'mrotx 'mroty 'mrotz 'mscale 'mscalei 'muscalei 'transform 'transformr 'ztransform 'oztransform 'oxyztransform 'matinv 'calcrot 'makerot 'matqua 'calcvrot 'mrotxyz 'mrotxyzi 'mcpy 'm* 'mm* 'mmi* 'mtra 'mrot 'mpos 'mrpos 'packrota '+rota 'pack21 '+p21
#info ( $80 $0 $1F $0 $0 $0 $1F $1 $1 $1F $10 $1F $4C $6A $3D $3D $1F $1F $1F $1F $1F $1F $3D $3D $1F $30 $30 $3E $1 $3 $0 $3D $30 $1F $3D $3D $3D $1F $0 $1F $1F $3D $3D $3D $4C $3E $2F $3E $2F )
#r3_lib_3dgl.r3 'name 'words 'calls 'info
^r3/lib/base64.r3
#name "r3/lib/base64.r3"
#words  "base64decode" "base64encode" 0
#calls  'base64decode 'base64encode
#info ( $2F $3E )
#r3_lib_base64.r3 'name 'words 'calls 'info
^r3/lib/color.r3
#name "r3/lib/color.r3"
#words  "swapcolor" "colavg" "col50%" "col25%" "col33%" "colmix" "colmix4" "diffrgb2" "rgb2yuv" "yuv2rgb" "yuv32" "hsv2rgb" "rgb2hsv" "rgb2ycocg" "ycocg2rgb" "rgb2ycc" "rgb2yuv2" "yuv2rgb2" "RGB>Gbr" "Gbr>RGB" "RGB2YCoCg24" "YCoCg242RGB" "shadow4" "light4" "shadow8" "light8" "blend2" "b2color" "bgr2rgb" "4bcol" "4bicol" 0
#calls  'swapcolor 'colavg 'col50% 'col25% 'col33% 'colmix 'colmix4 'diffrgb2 'rgb2yuv 'yuv2rgb 'yuv32 'hsv2rgb 'rgb2hsv 'rgb2ycocg 'ycocg2rgb 'rgb2ycc 'rgb2yuv2 'yuv2rgb2 'RGB>Gbr 'Gbr>RGB 'RGB2YCoCg24 'YCoCg242RGB 'shadow4 'light4 'shadow8 'light8 'blend2 'b2color 'bgr2rgb '4bcol '4bicol
#info ( $10 $2F $2F $2F $2F $3E $3E $2F $30 $30 $3E $4E $12 $30 $30 $12 $30 $30 $30 $30 $30 $30 $2F $2F $2F $2F $3E $10 $10 $10 $10 )
#r3_lib_color.r3 'name 'words 'calls 'info
^r3/lib/console.r3
#name "r3/lib/console.r3"
#words  0
#calls 
#info ( )
#r3_lib_console.r3 'name 'words 'calls 'info
^r3/lib/crc32.r3
#name "r3/lib/crc32.r3"
#words  "crc32" "crc32n" "adler32" 0
#calls  'crc32 'crc32n 'adler32
#info ( $2F $3E $2F )
#r3_lib_crc32.r3 'name 'words 'calls 'info
^r3/lib/escapi.r3
#name "r3/lib/escapi.r3"
#words  "countCaptureDevices" "deinitCapture" "doCapture" "initCapture" "initCOM" "isCaptureDone" "getCaptureDeviceName" "getCaptureProperty" "setCaptureProperty" "setupESCAPI" 0
#calls  'countCaptureDevices 'deinitCapture 'doCapture 'initCapture 'initCOM 'isCaptureDone 'getCaptureDeviceName 'getCaptureProperty 'setCaptureProperty 'setupESCAPI
#info ( $1 $10 $1F $2F $0 $10 $1 $79 $4C $1 )
#r3_lib_escapi.r3 'name 'words 'calls 'info
^r3/lib/espeak-ng.r3
#name "r3/lib/espeak-ng.r3"
#words  "espeak_Initialize" "espeak_SetVoiceByName" "espeak_TextToPhonemes" "espeak_Terminate" 0
#calls  'espeak_Initialize 'espeak_SetVoiceByName 'espeak_TextToPhonemes 'espeak_Terminate
#info ( $4D $10 $3E $1 )
#r3_lib_espeak-ng.r3 'name 'words 'calls 'info
^r3/lib/gui.r3
#name "r3/lib/gui.r3"
#words  "xr1" "yr1" "xr2" "yr2" "foco" "clkbtn" "idf" "idl" "guin?" "gui" "guiBox" "guiPrev" "guiRect" "onClick" "onClickFoco" "onMoveA" "onMove" "onDnMove" "onDnMoveA" "onMap" "onMapA" "guiI" "guiO" "guiIO" "nextfoco" "prevfoco" "setfoco" "clickfoco" "clickfoco1" "refreshfoco" "w/foco" "focovoid" "esfoco?" "in/foco" "lostfoco" 0
#calls  'xr1 'yr1 'xr2 'yr2 'foco 'clkbtn 'idf 'idl 'guin? 'gui 'guiBox 'guiPrev 'guiRect 'onClick 'onClickFoco 'onMoveA 'onMove 'onDnMove 'onDnMoveA 'onMap 'onMapA 'guiI 'guiO 'guiIO 'nextfoco 'prevfoco 'setfoco 'clickfoco 'clickfoco1 'refreshfoco 'w/foco 'focovoid 'esfoco? 'in/foco 'lostfoco
#info ( $80 $80 $80 $80 $80 $80 $80 $80 $80 $0 $4C $0 $4C $1F $1F $1F $1F $2E $2E $3D $3D $1F $1F $2E $0 $0 $1F $0 $0 $0 $2E $0 $1 $1F $1F )
#r3_lib_gui.r3 'name 'words 'calls 'info
^r3/lib/input.r3
#name "r3/lib/input.r3"
#words  "input" "inputex" "inputdump" "inputint" "tbtn" 0
#calls  'input 'inputex 'inputdump 'inputint 'tbtn
#info ( $2E $3D $0 $1F $2E )
#r3_lib_input.r3 'name 'words 'calls 'info
^r3/lib/isospr.r3
#name "r3/lib/isospr.r3"
#words  "isang" "isalt" "isxo" "isyo" "xyz2iso" "2iso" "isocam" "resetcam" "loadss" "isospr" 0
#calls  'isang 'isalt 'isxo 'isyo 'xyz2iso '2iso 'isocam 'resetcam 'loadss 'isospr
#info ( $80 $80 $80 $80 $3F $3F $0 $0 $30 $5B )
#r3_lib_isospr.r3 'name 'words 'calls 'info
^r3/lib/jul.r3
#name "r3/lib/jul.r3"
#words  "date2jul" "jul2date" "date2day" "jul2day" "date2daystr" "jul2daystr" 0
#calls  'date2jul 'jul2date 'date2day 'jul2day 'date2daystr 'jul2daystr
#info ( $3E $12 $3E $10 $3E $10 )
#r3_lib_jul.r3 'name 'words 'calls 'info
^r3/lib/math.r3
#name "r3/lib/math.r3"
#words  "cell" "cell+" "ncell+" "1+" "1-" "2/" "2*" "*.u" "*." "/." "2/." "ceil" "int." "fix." "sign" "cos" "sin" "tan" "sincos" "xy+polar" "xy+polar2" "ar>xy" "polar" "polar2" "atan2" "distfast" "average" "min" "max" "clampmax" "clampmin" "clamp0" "clamp0max" "clamps16" "between" "msb" "sqrt." "ln." "log2." "log10." "logn2." "exp." "pow." "root." "cubicpulse" "pow" "bswap32" "bswap64" "nextpow2" "6*" "6/" "6mod" "1000*" "1000000*" "100000*" "10000*" "1000*" "100*" "10*" "10/" "10/mod" "1000000/" "i2fp" "f2fp" "fp2f" "fp2i" "fp16f" "f2fp24" "fp2f24" "byte>float32N" "float32N>byte" 0
#calls  'cell 'cell+ 'ncell+ '1+ '1- '2/ '2* '*.u '*. '/. '2/. 'ceil 'int. 'fix. 'sign 'cos 'sin 'tan 'sincos 'xy+polar 'xy+polar2 'ar>xy 'polar 'polar2 'atan2 'distfast 'average 'min 'max 'clampmax 'clampmin 'clamp0 'clamp0max 'clamps16 'between 'msb 'sqrt. 'ln. 'log2. 'log10. 'logn2. 'exp. 'pow. 'root. 'cubicpulse 'pow 'bswap32 'bswap64 'nextpow2 '6* '6/ '6mod '1000* '1000000* '100000* '10000* '1000* '100* '10* '10/ '10/mod '1000000/ 'i2fp 'f2fp 'fp2f 'fp2i 'fp16f 'f2fp24 'fp2f24 'byte>float32N 'float32N>byte
#info ( $80 $10 $2F $10 $10 $10 $10 $2F $2F $2F $10 $10 $10 $10 $11 $10 $10 $10 $11 $4E $4E $40 $20 $20 $2F $2F $2F $2F $2F $2F $2F $10 $2F $10 $3E $10 $10 $10 $10 $0 $0 $10 $2F $2F $3E $2F $10 $10 $10 $10 $10 $10 $20 $0 $10 $10 $10 $10 $10 $10 $11 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 )
#r3_lib_math.r3 'name 'words 'calls 'info
^r3/lib/mconsole.r3
#name "r3/lib/mconsole.r3"
#words  ",esc" ",[" ",fcolor" ",bcolor" ",eline" ",home" ",cls" ",at" ",col" ",eline" ",fc" ",bc" ",Black" ",Red" ",Green" ",Yellow" ",Blue" ",Magenta" ",Cyan" ",White" ",Blackl" ",Redl" ",Greenl" ",Yellowl" ",Bluel" ",Magental" ",Cyanl" ",Whitel" ",BBlack" ",BRed" ",BGreen" ",BYellow" ",BBlue" ",BMagenta" ",BCyan" ",BWhite" ",BBlackl" ",BRedl" ",BGreenl" ",BYellowl" ",BBluel" ",BMagental" ",BCyanl" ",BWhitel" ",Bold" ",Under" ",Rever" ",Reset" ",alsb" ",masb" ",showc" ",hidec" ",ovec" ",insc" ",savec" ",restc" ",print" ",println" ",printe" ",type" 0
#calls  ',esc ',[ ',fcolor ',bcolor ',eline ',home ',cls ',at ',col ',eline ',fc ',bc ',Black ',Red ',Green ',Yellow ',Blue ',Magenta ',Cyan ',White ',Blackl ',Redl ',Greenl ',Yellowl ',Bluel ',Magental ',Cyanl ',Whitel ',BBlack ',BRed ',BGreen ',BYellow ',BBlue ',BMagenta ',BCyan ',BWhite ',BBlackl ',BRedl ',BGreenl ',BYellowl ',BBluel ',BMagental ',BCyanl ',BWhitel ',Bold ',Under ',Rever ',Reset ',alsb ',masb ',showc ',hidec ',ovec ',insc ',savec ',restc ',print ',println ',printe ',type
#info ( $0 $1F $1F $1F $0 $0 $0 $2E $1F $0 $1F $1F $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $1F $1F $1F $2E )
#r3_lib_mconsole.r3 'name 'words 'calls 'info
^r3/lib/mem.r3
#name "r3/lib/mem.r3"
#words  "here" "," ",c" ",q" ",w" ",s" ",word" ",line" ",2d" ",d" ",h" ",b" ",f" ",ifp" ",ffp" ",cr" ",eol" ",sp" ",nl" ",nsp" "align32" "align16" "align8" "mark" "empty" "savemem" "sizemem" "memsize" "savememinc" "cpymem" "appendmem" ",print" "sprint" "sprintln" "sprintc" "sprintlnc" 0
#calls  'here ', ',c ',q ',w ',s ',word ',line ',2d ',d ',h ',b ',f ',ifp ',ffp ',cr ',eol ',sp ',nl ',nsp 'align32 'align16 'align8 'mark 'empty 'savemem 'sizemem 'memsize 'savememinc 'cpymem 'appendmem ',print 'sprint 'sprintln 'sprintc 'sprintlnc
#info ( $80 $1F $1F $1F $1F $1F $1F $1F $1F $1F $1F $1F $1F $1F $1F $0 $0 $0 $0 $1F $10 $10 $10 $0 $0 $1F $1 $2 $1F $1F $1F $1F $10 $10 $11 $11 )
#r3_lib_mem.r3 'name 'words 'calls 'info
^r3/lib/memavx.r3
#name "r3/lib/memavx.r3"
#words  "memcpy_rgb3f" "memcpy_bgr3f" "memcpy_rgbf" "memcpy_f32p16" "memcpy_p16f32" "memcpy_avx" 0
#calls  'memcpy_rgb3f 'memcpy_bgr3f 'memcpy_rgbf 'memcpy_f32p16 'memcpy_p16f32 'memcpy_avx
#info ( $3D $3D $3D $3D $3D $3D )
#r3_lib_memavx.r3 'name 'words 'calls 'info
^r3/lib/onnx.r3
#name "r3/lib/onnx.r3"
#words  "ortSess_CPU" "ortSess_MDL" "OrtgetVersionString" "OrtCreateStatus" "OrtGetErrorCode" "OrtGetErrorMessage" "OrtCreateEnv" "OrtCreateEnvWithCustomLogger" "OrtEnableTelemetryEvents" "OrtDisableTelemetryEvents" "OrtCreateSession" "OrtCreateSessionFromArray" "OrtRun" "OrtCreateSessionOptions" "OrtSetOptimizedModelFilePath" "OrtCloneSessionOptions" "OrtSetSessionExecutionMode" "OrtEnableProfiling" "OrtDisableProfiling" "OrtEnableMemPattern" "OrtDisableMemPattern" "OrtEnableCpuMemArena" "OrtDisableCpuMemArena" "OrtSetSessionLogId" "OrtSetSessionLogVerbosityLevel" "OrtSetSessionLogSeverityLevel" "OrtSetSessionGraphOptimizationLevel" "OrtSetIntraOpNumThreads" "OrtSetInterOpNumThreads" "OrtCreateCustomOpDomain" "OrtCustomOpDomain_Add" "OrtAddCustomOpDomain" "OrtRegisterCustomOpsLibrary" "OrtSessionGetInputCount" "OrtSessionGetOutputCount" "OrtSessionGetOverridableInitializerCount" "OrtSessionGetInputTypeInfo" "OrtSessionGetOutputTypeInfo" "OrtSessionGetOverridableInitializerTypeInfo" "OrtSessionGetInputName" "OrtSessionGetOutputName" "OrtSessionGetOverridableInitializerName" "OrtCreateRunOptions" "OrtRunOptionsSetRunLogVerbosityLevel" "OrtRunOptionsSetRunLogSeverityLevel" "OrtRunOptionsSetRunTag" "OrtRunOptionsGetRunLogVerbosityLevel" "OrtRunOptionsGetRunLogSeverityLevel" "OrtRunOptionsGetRunTag" "OrtRunOptionsSetTerminate" "OrtRunOptionsUnsetTerminate" "OrtCreateTensorAsOrtValue" "OrtCreateTensorWithDataAsOrtValue" "OrtIsTensor" "OrtGetTensorMutableData" "OrtFillStringTensor" "OrtGetStringTensorDataLength" "OrtGetStringTensorContent" "OrtCastTypeInfoToTensorInfo" "OrtGetOnnxTypeFromTypeInfo" "OrtCreateTensorTypeAndShapeInfo" "OrtSetTensorElementType" "OrtSetDimensions" "OrtGetTensorElementType" "OrtGetDimensionsCount" "OrtGetDimensions" "OrtGetSymbolicDimensions" "OrtGetTensorShapeElementCount" "OrtGetTensorTypeAndShape" "OrtGetTypeInfo" "OrtGetValueType" "OrtCreateMemoryInfo" "OrtCreateCpuMemoryInfo" "OrtCompareMemoryInfo" "OrtMemoryInfoGetName" "OrtMemoryInfoGetId" "OrtMemoryInfoGetMemType" "OrtMemoryInfoGetType" "OrtAllocatorAlloc" "OrtAllocatorFree" "OrtAllocatorGetInfo" "OrtGetAllocatorWithDefaultOptions" "OrtAddFreeDimensionOverride" "OrtGetValue" "OrtGetValueCount" "OrtCreateValue" "OrtCreateOpaqueValue" "OrtGetOpaqueValue" "OrtKernelInfoGetAttribute_float" "OrtKernelInfoGetAttribute_int64" "OrtKernelInfoGetAttribute_string" "OrtKernelContext_GetInputCount" "OrtKernelContext_GetOutputCount" "OrtKernelContext_GetInput" "OrtKernelContext_GetOutput" "OrtReleaseEnv" "OrtReleaseStatus" "OrtReleaseMemoryInfo" "OrtReleaseSession" "OrtReleaseValue" "OrtReleaseRunOptions" "OrtReleaseTypeInfo" "OrtReleaseTensorTypeAndShapeInfo" "OrtReleaseSessionOptions" "OrtReleaseCustomOpDomain" "OrtGetDenotationFromTypeInfo" "OrtCastTypeInfoToMapTypeInfo" "OrtCastTypeInfoToSequenceTypeInfo" "OrtGetMapKeyType" "OrtGetMapValueType" "OrtGetSequenceElementType" "OrtReleaseMapTypeInfo" "OrtReleaseSequenceTypeInfo" "OrtSessionEndProfiling" "OrtSessionGetModelMetadata" "OrtModelMetadataGetProducerName" "OrtModelMetadataGetGraphName" "OrtModelMetadataGetDomain" "OrtModelMetadataGetDescription" "OrtModelMetadataLookupCustomMetadataMap" "OrtModelMetadataGetVersion" "OrtCreateEnvWithGlobalThreadPools" "OrtDisablePerSessionThreads" "OrtCreateThreadingOptions" "OrtSetGlobalIntraOpNumThreads" "OrtSetGlobalInterOpNumThreads" "OrtSetGlobalSpinControl" "OrtModelMetadataGetCustomMetadataMapKeys" "OrtAddFreeDimensionOverrideByName" "OrtGetAvailableProviders" "OrtReleaseAvailableProviders" "OrtGetStringTensorElementLength" "OrtGetStringTensorElement" "OrtFillStringTensorElement" "OrtAddSessionConfigEntry" "OrtCreateAllocator" "OrtRunWithBinding" "OrtCreateIoBinding" "OrtBindInput" "OrtBindOutput" "OrtBindOutputToDevice" "OrtGetBoundOutputNames" "OrtGetBoundOutputValues" "OrtClearBoundInputs" "OrtClearBoundOutputs" "OrtTensorAt" "OrtCreateAndRegisterAllocator" "OrtSetLanguageProjection" "OrtSessionGetProfilingStartTimeNs" "OrtAddInitializer" "OrtCreateEnvWithCustomLoggerAndGlobalThreadPools" "OrtSessionOptionsAppendExecutionProvider_CUDA" "OrtSessionOptionsAppendExecutionProvider_ROCM" "OrtSessionOptionsAppendExecutionProvider_OpenVINO" "OrtSetGlobalDenormalAsZero" "OrtCreateArenaCfg" "OrtModelMetadataGetGraphDescription" "OrtSessionOptionsAppendExecutionProvider_TensorRT" "OrtSetCurrentGpuDeviceId" "OrtGetCurrentGpuDeviceId" "OrtKernelInfoGetAttributeArray_float" "OrtKernelInfoGetAttributeArray_int64" "OrtCreateArenaCfgV2" "OrtAddRunConfigEntry" "OrtCreatePrepackedWeightsContainer" "OrtCreateSessionWithPrepackedWeightsContainer" "OrtCreateSessionFromArrayWithPrepackedWeightsContainer" "OrtSessionOptionsAppendExecutionProvider_TensorRT_V2" "OrtCreateTensorRTProviderOptions" "OrtUpdateTensorRTProviderOptions" "OrtGetTensorRTProviderOptionsAsMap" "OrtReleaseTensorRTProviderOptions" "OrtEnableOrtCustomOps" "OrtRegisterAllocator" "OrtUnregisterAllocator" "OrtIsSparseTensor" "OrtCreateSparseTensorAsOrtValue" "OrtFillSparseTensorCoo" "OrtFillSparseTensorCsr" "OrtFillSparseTensorBlockSparse" "OrtCreateSparseTensorWithValuesAsOrtValue" "OrtUseCooIndices" "OrtUseCsrIndices" "OrtUseBlockSparseIndices" "OrtGetSparseTensorFormat" "OrtGetSparseTensorValuesTypeAndShape" "OrtGetSparseTensorValues" "OrtGetSparseTensorIndicesTypeShape" "OrtGetSparseTensorIndices" "OrtHasValue" "OrtKernelContext_GetGPUComputeStream" "OrtGetTensorMemoryInfo" "OrtGetExecutionProviderApi" "OrtSessionOptionsSetCustomCreateThreadFn" "OrtSessionOptionsSetCustomThreadCreationOptionsFn" "OrtSetGlobalCustomCreateThreadFn" "OrtSetGlobalCustomThreadCreationOptions" "OrtSetGlobalCustomJoinThreadFn" "OrtSynchronizeBoundInputs" "OrtSynchronizeBoundOutputs" "OrtSessionOptionsAppendExecutionProvider_CUDA_V2" "OrtCreateCUDAProviderOptions" "OrtUpdateCUDAProviderOptions" "OrtGetCUDAProviderOptionsAsMap" "OrtReleaseCUDAProviderOptions" "OrtSessionOptionsAppendExecutionProvider_MIGraphX" "OrtAddExternalInitializers" "OrtCreateOpAttr" "OrtCreateOp" "OrtReleaseOpAttr" "OrtReleaseOp" "OrtSessionOptionsAppendExecutionProvider" "OrtCopyKernelInfo" "OrtGetTrainingApi" "OrtSessionOptionsAppendExecutionProvider_Dnnl" "OrtCreateDnnlProviderOptions" "OrtUpdateDnnlProviderOptions" "OrtGetDnnlProviderOptionsAsMap" "OrtReleaseDnnlProviderOptions" "OrtSessionOptionsAppendExecutionProvider_ROCM_V2" "OrtCreateROCMProviderOptions" "OrtUpdateROCMProviderOptions" "OrtGetROCMProviderOptionsAsMap" "OrtReleaseROCMProviderOptions" "OrtCreateLoraAdapter" "OrtCreateLoraAdapterFromArray" "OrtReleaseLoraAdapter" "OrtRunOptionsAddActiveLoraAdapter" "OrtSetEpDynamicOptions" "OrtReleaseValueInfo" "OrtReleaseNode" "OrtReleaseGraph" "OrtReleaseModel" "OrtGetValueInfoName" "OrtGetValueInfoTypeInfo" "OrtGetModelEditorApi" "OrtCreateTensorWithOwnedBufferAsOrtValue" "OrtInvalidAllocator" "OrtDeviceAllocator" "OrtArenaAllocator" "OrtReadOnlyAllocator" "OrtMemTypeCPUInput" "OrtMemTypeCPUOutput" "OrtMemTypeCPU" "OrtMemTypeDefault" "ORT_DISABLE_ALL" "ORT_ENABLE_BASIC" "ORT_ENABLE_EXTENDED" "ORT_ENABLE_ALL" "ONNX_TENSOR_ELEMENT_DATA_TYPE_UNDEFINED" "ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT" "ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT8" "ONNX_TENSOR_ELEMENT_DATA_TYPE_INT8" "ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT16" "ONNX_TENSOR_ELEMENT_DATA_TYPE_INT16" "ONNX_TENSOR_ELEMENT_DATA_TYPE_INT32" "ONNX_TENSOR_ELEMENT_DATA_TYPE_INT64" "ONNX_TENSOR_ELEMENT_DATA_TYPE_STRING" "ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL" "ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT16" "ONNX_TENSOR_ELEMENT_DATA_TYPE_DOUBLE" "ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT32" "ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT64" "ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX64" "ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX128" "ONNX_TENSOR_ELEMENT_DATA_TYPE_BFLOAT16" "ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E4M3FN" "ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E4M3FNUZ" "ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E5M2" "ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E5M2FNUZ" "ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT4" "ONNX_TENSOR_ELEMENT_DATA_TYPE_INT4" 0
#calls  'ortSess_CPU 'ortSess_MDL 'OrtgetVersionString 'OrtCreateStatus 'OrtGetErrorCode 'OrtGetErrorMessage 'OrtCreateEnv 'OrtCreateEnvWithCustomLogger 'OrtEnableTelemetryEvents 'OrtDisableTelemetryEvents 'OrtCreateSession 'OrtCreateSessionFromArray 'OrtRun 'OrtCreateSessionOptions 'OrtSetOptimizedModelFilePath 'OrtCloneSessionOptions 'OrtSetSessionExecutionMode 'OrtEnableProfiling 'OrtDisableProfiling 'OrtEnableMemPattern 'OrtDisableMemPattern 'OrtEnableCpuMemArena 'OrtDisableCpuMemArena 'OrtSetSessionLogId 'OrtSetSessionLogVerbosityLevel 'OrtSetSessionLogSeverityLevel 'OrtSetSessionGraphOptimizationLevel 'OrtSetIntraOpNumThreads 'OrtSetInterOpNumThreads 'OrtCreateCustomOpDomain 'OrtCustomOpDomain_Add 'OrtAddCustomOpDomain 'OrtRegisterCustomOpsLibrary 'OrtSessionGetInputCount 'OrtSessionGetOutputCount 'OrtSessionGetOverridableInitializerCount 'OrtSessionGetInputTypeInfo 'OrtSessionGetOutputTypeInfo 'OrtSessionGetOverridableInitializerTypeInfo 'OrtSessionGetInputName 'OrtSessionGetOutputName 'OrtSessionGetOverridableInitializerName 'OrtCreateRunOptions 'OrtRunOptionsSetRunLogVerbosityLevel 'OrtRunOptionsSetRunLogSeverityLevel 'OrtRunOptionsSetRunTag 'OrtRunOptionsGetRunLogVerbosityLevel 'OrtRunOptionsGetRunLogSeverityLevel 'OrtRunOptionsGetRunTag 'OrtRunOptionsSetTerminate 'OrtRunOptionsUnsetTerminate 'OrtCreateTensorAsOrtValue 'OrtCreateTensorWithDataAsOrtValue 'OrtIsTensor 'OrtGetTensorMutableData 'OrtFillStringTensor 'OrtGetStringTensorDataLength 'OrtGetStringTensorContent 'OrtCastTypeInfoToTensorInfo 'OrtGetOnnxTypeFromTypeInfo 'OrtCreateTensorTypeAndShapeInfo 'OrtSetTensorElementType 'OrtSetDimensions 'OrtGetTensorElementType 'OrtGetDimensionsCount 'OrtGetDimensions 'OrtGetSymbolicDimensions 'OrtGetTensorShapeElementCount 'OrtGetTensorTypeAndShape 'OrtGetTypeInfo 'OrtGetValueType 'OrtCreateMemoryInfo 'OrtCreateCpuMemoryInfo 'OrtCompareMemoryInfo 'OrtMemoryInfoGetName 'OrtMemoryInfoGetId 'OrtMemoryInfoGetMemType 'OrtMemoryInfoGetType 'OrtAllocatorAlloc 'OrtAllocatorFree 'OrtAllocatorGetInfo 'OrtGetAllocatorWithDefaultOptions 'OrtAddFreeDimensionOverride 'OrtGetValue 'OrtGetValueCount 'OrtCreateValue 'OrtCreateOpaqueValue 'OrtGetOpaqueValue 'OrtKernelInfoGetAttribute_float 'OrtKernelInfoGetAttribute_int64 'OrtKernelInfoGetAttribute_string 'OrtKernelContext_GetInputCount 'OrtKernelContext_GetOutputCount 'OrtKernelContext_GetInput 'OrtKernelContext_GetOutput 'OrtReleaseEnv 'OrtReleaseStatus 'OrtReleaseMemoryInfo 'OrtReleaseSession 'OrtReleaseValue 'OrtReleaseRunOptions 'OrtReleaseTypeInfo 'OrtReleaseTensorTypeAndShapeInfo 'OrtReleaseSessionOptions 'OrtReleaseCustomOpDomain 'OrtGetDenotationFromTypeInfo 'OrtCastTypeInfoToMapTypeInfo 'OrtCastTypeInfoToSequenceTypeInfo 'OrtGetMapKeyType 'OrtGetMapValueType 'OrtGetSequenceElementType 'OrtReleaseMapTypeInfo 'OrtReleaseSequenceTypeInfo 'OrtSessionEndProfiling 'OrtSessionGetModelMetadata 'OrtModelMetadataGetProducerName 'OrtModelMetadataGetGraphName 'OrtModelMetadataGetDomain 'OrtModelMetadataGetDescription 'OrtModelMetadataLookupCustomMetadataMap 'OrtModelMetadataGetVersion 'OrtCreateEnvWithGlobalThreadPools 'OrtDisablePerSessionThreads 'OrtCreateThreadingOptions 'OrtSetGlobalIntraOpNumThreads 'OrtSetGlobalInterOpNumThreads 'OrtSetGlobalSpinControl 'OrtModelMetadataGetCustomMetadataMapKeys 'OrtAddFreeDimensionOverrideByName 'OrtGetAvailableProviders 'OrtReleaseAvailableProviders 'OrtGetStringTensorElementLength 'OrtGetStringTensorElement 'OrtFillStringTensorElement 'OrtAddSessionConfigEntry 'OrtCreateAllocator 'OrtRunWithBinding 'OrtCreateIoBinding 'OrtBindInput 'OrtBindOutput 'OrtBindOutputToDevice 'OrtGetBoundOutputNames 'OrtGetBoundOutputValues 'OrtClearBoundInputs 'OrtClearBoundOutputs 'OrtTensorAt 'OrtCreateAndRegisterAllocator 'OrtSetLanguageProjection 'OrtSessionGetProfilingStartTimeNs 'OrtAddInitializer 'OrtCreateEnvWithCustomLoggerAndGlobalThreadPools 'OrtSessionOptionsAppendExecutionProvider_CUDA 'OrtSessionOptionsAppendExecutionProvider_ROCM 'OrtSessionOptionsAppendExecutionProvider_OpenVINO 'OrtSetGlobalDenormalAsZero 'OrtCreateArenaCfg 'OrtModelMetadataGetGraphDescription 'OrtSessionOptionsAppendExecutionProvider_TensorRT 'OrtSetCurrentGpuDeviceId 'OrtGetCurrentGpuDeviceId 'OrtKernelInfoGetAttributeArray_float 'OrtKernelInfoGetAttributeArray_int64 'OrtCreateArenaCfgV2 'OrtAddRunConfigEntry 'OrtCreatePrepackedWeightsContainer 'OrtCreateSessionWithPrepackedWeightsContainer 'OrtCreateSessionFromArrayWithPrepackedWeightsContainer 'OrtSessionOptionsAppendExecutionProvider_TensorRT_V2 'OrtCreateTensorRTProviderOptions 'OrtUpdateTensorRTProviderOptions 'OrtGetTensorRTProviderOptionsAsMap 'OrtReleaseTensorRTProviderOptions 'OrtEnableOrtCustomOps 'OrtRegisterAllocator 'OrtUnregisterAllocator 'OrtIsSparseTensor 'OrtCreateSparseTensorAsOrtValue 'OrtFillSparseTensorCoo 'OrtFillSparseTensorCsr 'OrtFillSparseTensorBlockSparse 'OrtCreateSparseTensorWithValuesAsOrtValue 'OrtUseCooIndices 'OrtUseCsrIndices 'OrtUseBlockSparseIndices 'OrtGetSparseTensorFormat 'OrtGetSparseTensorValuesTypeAndShape 'OrtGetSparseTensorValues 'OrtGetSparseTensorIndicesTypeShape 'OrtGetSparseTensorIndices 'OrtHasValue 'OrtKernelContext_GetGPUComputeStream 'OrtGetTensorMemoryInfo 'OrtGetExecutionProviderApi 'OrtSessionOptionsSetCustomCreateThreadFn 'OrtSessionOptionsSetCustomThreadCreationOptionsFn 'OrtSetGlobalCustomCreateThreadFn 'OrtSetGlobalCustomThreadCreationOptions 'OrtSetGlobalCustomJoinThreadFn 'OrtSynchronizeBoundInputs 'OrtSynchronizeBoundOutputs 'OrtSessionOptionsAppendExecutionProvider_CUDA_V2 'OrtCreateCUDAProviderOptions 'OrtUpdateCUDAProviderOptions 'OrtGetCUDAProviderOptionsAsMap 'OrtReleaseCUDAProviderOptions 'OrtSessionOptionsAppendExecutionProvider_MIGraphX 'OrtAddExternalInitializers 'OrtCreateOpAttr 'OrtCreateOp 'OrtReleaseOpAttr 'OrtReleaseOp 'OrtSessionOptionsAppendExecutionProvider 'OrtCopyKernelInfo 'OrtGetTrainingApi 'OrtSessionOptionsAppendExecutionProvider_Dnnl 'OrtCreateDnnlProviderOptions 'OrtUpdateDnnlProviderOptions 'OrtGetDnnlProviderOptionsAsMap 'OrtReleaseDnnlProviderOptions 'OrtSessionOptionsAppendExecutionProvider_ROCM_V2 'OrtCreateROCMProviderOptions 'OrtUpdateROCMProviderOptions 'OrtGetROCMProviderOptionsAsMap 'OrtReleaseROCMProviderOptions 'OrtCreateLoraAdapter 'OrtCreateLoraAdapterFromArray 'OrtReleaseLoraAdapter 'OrtRunOptionsAddActiveLoraAdapter 'OrtSetEpDynamicOptions 'OrtReleaseValueInfo 'OrtReleaseNode 'OrtReleaseGraph 'OrtReleaseModel 'OrtGetValueInfoName 'OrtGetValueInfoTypeInfo 'OrtGetModelEditorApi 'OrtCreateTensorWithOwnedBufferAsOrtValue 'OrtInvalidAllocator 'OrtDeviceAllocator 'OrtArenaAllocator 'OrtReadOnlyAllocator 'OrtMemTypeCPUInput 'OrtMemTypeCPUOutput 'OrtMemTypeCPU 'OrtMemTypeDefault 'ORT_DISABLE_ALL 'ORT_ENABLE_BASIC 'ORT_ENABLE_EXTENDED 'ORT_ENABLE_ALL 'ONNX_TENSOR_ELEMENT_DATA_TYPE_UNDEFINED 'ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT 'ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT8 'ONNX_TENSOR_ELEMENT_DATA_TYPE_INT8 'ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT16 'ONNX_TENSOR_ELEMENT_DATA_TYPE_INT16 'ONNX_TENSOR_ELEMENT_DATA_TYPE_INT32 'ONNX_TENSOR_ELEMENT_DATA_TYPE_INT64 'ONNX_TENSOR_ELEMENT_DATA_TYPE_STRING 'ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL 'ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT16 'ONNX_TENSOR_ELEMENT_DATA_TYPE_DOUBLE 'ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT32 'ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT64 'ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX64 'ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX128 'ONNX_TENSOR_ELEMENT_DATA_TYPE_BFLOAT16 'ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E4M3FN 'ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E4M3FNUZ 'ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E5M2 'ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E5M2FNUZ 'ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT4 'ONNX_TENSOR_ELEMENT_DATA_TYPE_INT4
#info ( $2F $2F $1 $2F $10 $10 $3E $5C $10 $10 $4D $5C $9 $10 $2F $2F $2F $2F $10 $10 $10 $10 $10 $2F $2F $2F $2F $2F $2F $2F $2F $2F $3E $2F $2F $2F $3E $3E $3E $4D $4D $4D $10 $2F $2F $2F $2F $2F $2F $10 $10 $6B $7A $2F $2F $3E $2F $5C $2F $2F $10 $2F $3E $2F $2F $3E $3E $2F $2F $2F $2F $5C $3E $3E $2F $2F $2F $2F $3E $2F $2F $10 $3E $4D $2F $4D $5C $5C $3E $3E $4D $2F $2F $3E $5C $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $3E $2F $2F $2F $2F $2F $10 $10 $3E $2F $3E $3E $3E $3E $4D $2F $4D $10 $10 $2F $2F $2F $4D $3E $2F $2F $3E $4D $3E $3E $3E $3E $2F $3E $3E $3E $5C $4D $10 $10 $4D $3E $2F $2F $3E $6B $2F $2F $2F $10 $5C $3E $2F $10 $10 $4D $4D $4D $3E $10 $5C $6B $2F $10 $4D $2F $10 $10 $2F $2F $2F $5C $7A $18 $9 $9 $3E $5C $4D $2F $2F $2F $3E $4D $2F $2F $2F $3E $2F $2F $2F $2F $2F $10 $10 $2F $10 $4D $2F $10 $2F $4D $5C $27 $10 $10 $5C $2F $10 $2F $10 $3E $2F $10 $2F $10 $4D $2F $10 $4D $5C $10 $2F $4D $10 $10 $10 $10 $2F $2F $1 $9 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 )
#r3_lib_onnx.r3 'name 'words 'calls 'info
^r3/lib/parse.r3
#name "r3/lib/parse.r3"
#words  "str$>nro" "str%>nro" "str>nro" "?sint" "?numero" "?fnumero" "str>fix" "getnro" "str>fnro" "str>anro" "getfenro" "isHex" "isBin" "isNro" "scanp" "scanstr" "scannro" "scanc" "scann" 0
#calls  'str$>nro 'str%>nro 'str>nro '?sint '?numero '?fnumero 'str>fix 'getnro 'str>fnro 'str>anro 'getfenro 'isHex 'isBin 'isNro 'scanp 'scanstr 'scannro 'scanc 'scann
#info ( $11 $11 $11 $11 $12 $10 $31 $11 $11 $11 $11 $10 $10 $10 $2F $2F $21 $2F $2F )
#r3_lib_parse.r3 'name 'words 'calls 'info
^r3/lib/rand.r3
#name "r3/lib/rand.r3"
#words  "seed8" "rand8" "seed" "rerand" "rand" "randmax" "randminmax" "rnd" "rndmax" "rndminmax" "rnd128" "loopMix128" 0
#calls  'seed8 'rand8 'seed 'rerand 'rand 'randmax 'randminmax 'rnd 'rndmax 'rndminmax 'rnd128 'loopMix128
#info ( $80 $1 $80 $2E $1 $10 $2F $1 $10 $2F $1 $1 )
#r3_lib_rand.r3 'name 'words 'calls 'info
^r3/lib/sdl2.r3
#name "r3/lib/sdl2.r3"
#words  "SDL_Init" "SDL_GetCurrentDisplayMode" "SDL_Quit" "SDL_GetNumVideoDisplays" "SDL_CreateWindow" "SDL_SetWindowFullscreen" "SDL_RenderSetLogicalSize" "SDL_RaiseWindow" "SDL_GetWindowSize" "SDL_SetWindowSize" "SDL_GetWindowSurface" "SDL_ShowCursor" "SDL_UpdateWindowSurface" "SDL_DestroyWindow" "SDL_CreateRenderer" "SDL_CreateTexture" "SDL_QueryTexture" "SDL_SetTextureColorMod" "SDL_SetTextureAlphaMod" "SDL_DestroyTexture" "SDL_DestroyRenderer" "SDL_UpdateTexture" "SDL_RenderClear" "SDL_RenderCopy" "SDL_RenderCopyEx" "SDL_RenderPresent" "SDL_CreateTextureFromSurface" "SDL_CreateRGBSurfaceWithFormatFrom" "SDL_CreateRGBSurfaceWithFormat" "SDL_SetRenderDrawColor" "SDL_GetRenderDrawColor" "SDL_CreateRGBSurface" "SDL_LockSurface" "SDL_UnlockSurface" "SDL_BlitSurface" "SDL_SetSurfaceBlendMode" "SDL_SetSurfaceAlphaMod" "SDL_FillRect" "SDL_FreeSurface" "SDL_LockTexture" "SDL_UnlockTexture" "SDL_SetRenderDrawBlendMode" "SDL_SetTextureBlendMode" "SDL_ConvertSurfaceFormat" "SDL_RenderDrawPoint" "SDL_RenderDrawPoints" "SDL_RenderDrawLine" "SDL_RenderDrawRect" "SDL_RenderFillRect" "SDL_RenderGeometry" "SDL_RenderReadPixels" "SDL_RenderSetClipRect" "SDL_SetTextureScaleMode" "SDL_SetRenderTarget" "SDL_Delay" "SDL_PollEvent" "SDL_GetTicks" "SDL_RWFromFile" "SDL_RWclose" "SDL_GL_SetAttribute" "SDL_GL_CreateContext" "SDL_GL_DeleteContext" "SDL_GL_SetSwapInterval" "SDL_GL_SwapWindow" "SDL_GL_LoadLibrary" "SDL_GL_GetProcAddress" "SDL_GL_MakeCurrent" "SDL_SetHint" "SDL_GetError" "SDL_OpenAudioDevice" "SDL_QueueAudio" "SDL_GetQueuedAudioSize" "SDL_PauseAudioDevice" "SDL_CloseAudioDevice" "SDL_GetClipboardText" "SDL_HasClipboardText" "SDL_SetClipboardText" "SDL_free" "SDL_windows" "SDLrenderer" "sw" "sh" "SDLinit" "SDLmini" "SDLinitScr" "sdlinitR" "SDLfullw" "SDLfull" "SDLframebuffer" "SDLblend" "SDLquit" "SDLevent" "SDLkey" "SDLchar" "SDLx" "SDLy" "SDLb" "SDLw" "SDLeventR" "SDLupdate" "SDLClick" ".exit" "SDLshow" "exit" "SDLredraw" "sdlbreak" "SDLTexwh" "%w" "%h" 0
#calls  'SDL_Init 'SDL_GetCurrentDisplayMode 'SDL_Quit 'SDL_GetNumVideoDisplays 'SDL_CreateWindow 'SDL_SetWindowFullscreen 'SDL_RenderSetLogicalSize 'SDL_RaiseWindow 'SDL_GetWindowSize 'SDL_SetWindowSize 'SDL_GetWindowSurface 'SDL_ShowCursor 'SDL_UpdateWindowSurface 'SDL_DestroyWindow 'SDL_CreateRenderer 'SDL_CreateTexture 'SDL_QueryTexture 'SDL_SetTextureColorMod 'SDL_SetTextureAlphaMod 'SDL_DestroyTexture 'SDL_DestroyRenderer 'SDL_UpdateTexture 'SDL_RenderClear 'SDL_RenderCopy 'SDL_RenderCopyEx 'SDL_RenderPresent 'SDL_CreateTextureFromSurface 'SDL_CreateRGBSurfaceWithFormatFrom 'SDL_CreateRGBSurfaceWithFormat 'SDL_SetRenderDrawColor 'SDL_GetRenderDrawColor 'SDL_CreateRGBSurface 'SDL_LockSurface 'SDL_UnlockSurface 'SDL_BlitSurface 'SDL_SetSurfaceBlendMode 'SDL_SetSurfaceAlphaMod 'SDL_FillRect 'SDL_FreeSurface 'SDL_LockTexture 'SDL_UnlockTexture 'SDL_SetRenderDrawBlendMode 'SDL_SetTextureBlendMode 'SDL_ConvertSurfaceFormat 'SDL_RenderDrawPoint 'SDL_RenderDrawPoints 'SDL_RenderDrawLine 'SDL_RenderDrawRect 'SDL_RenderFillRect 'SDL_RenderGeometry 'SDL_RenderReadPixels 'SDL_RenderSetClipRect 'SDL_SetTextureScaleMode 'SDL_SetRenderTarget 'SDL_Delay 'SDL_PollEvent 'SDL_GetTicks 'SDL_RWFromFile 'SDL_RWclose 'SDL_GL_SetAttribute 'SDL_GL_CreateContext 'SDL_GL_DeleteContext 'SDL_GL_SetSwapInterval 'SDL_GL_SwapWindow 'SDL_GL_LoadLibrary 'SDL_GL_GetProcAddress 'SDL_GL_MakeCurrent 'SDL_SetHint 'SDL_GetError 'SDL_OpenAudioDevice 'SDL_QueueAudio 'SDL_GetQueuedAudioSize 'SDL_PauseAudioDevice 'SDL_CloseAudioDevice 'SDL_GetClipboardText 'SDL_HasClipboardText 'SDL_SetClipboardText 'SDL_free 'SDL_windows 'SDLrenderer 'sw 'sh 'SDLinit 'SDLmini 'SDLinitScr 'sdlinitR 'SDLfullw 'SDLfull 'SDLframebuffer 'SDLblend 'SDLquit 'SDLevent 'SDLkey 'SDLchar 'SDLx 'SDLy 'SDLb 'SDLw 'SDLeventR 'SDLupdate 'SDLClick '.exit 'SDLshow 'exit 'SDLredraw 'sdlbreak 'SDLTexwh '%w '%h
#info ( $1F $2E $0 $1 $6B $2E $3D $1F $3D $3D $10 $1F $1F $1F $3E $5C $5B $4C $2E $1F $1F $4D $1F $4C $79 $1F $2F $6B $5C $5B $5B $9 $1F $1F $4C $2E $2E $3D $1F $4C $1F $2E $2E $3E $3D $3D $5B $2E $2E $6A $5B $2E $2E $2E $1F $10 $1 $2F $1F $2E $10 $1F $1F $1F $1F $10 $2E $2E $1 $5C $3D $10 $2E $1F $1 $1 $10 $1F $80 $80 $80 $80 $3D $3D $4C $3D $2E $0 $2F $0 $0 $80 $80 $80 $80 $80 $80 $80 $1F $0 $1F $80 $1F $0 $0 $0 $11 $10 $10 )
#r3_lib_sdl2.r3 'name 'words 'calls 'info
^r3/lib/sdl2gfx.r3
#name "r3/lib/sdl2gfx.r3"
#words  "SDLColor" "SDLColorA" "SDLcls" "SDLPoint" "SDLGetPixel" "SDLLine" "SDLLineH" "SDLLineV" "SDLFRect" "SDLRect" "SDLFEllipse" "SDLEllipse" "SDLTriangle" "SDLFRound" "SDLRound" "SDLFCircle" "SDLCircle" "SDLImage" "SDLImages" "SDLImageb" "SDLImagebb" "tsload" "tscolor" "tsalpha" "tsdraw" "tsdraws" "tsbox" "tsfree" "sprite" "spriteZ" "spriteR" "spriteRZ" "ssload" "sstint" "ssnotint" "sspritewh" "ssprite" "sspriter" "sspritez" "sspriterz" "createSurf" "Surf>pix" "Surf>wha" "Surf>wh" "Surf>pixpi" "texIni" "texEnd" "texEndAlpha" "tex2static" "timer<" "timer." "timer+" "timer-" "ICS>anim" "vICS>anim" "anim>n" "anim>c" "anim>stop" 0
#calls  'SDLColor 'SDLColorA 'SDLcls 'SDLPoint 'SDLGetPixel 'SDLLine 'SDLLineH 'SDLLineV 'SDLFRect 'SDLRect 'SDLFEllipse 'SDLEllipse 'SDLTriangle 'SDLFRound 'SDLRound 'SDLFCircle 'SDLCircle 'SDLImage 'SDLImages 'SDLImageb 'SDLImagebb 'tsload 'tscolor 'tsalpha 'tsdraw 'tsdraws 'tsbox 'tsfree 'sprite 'spriteZ 'spriteR 'spriteRZ 'ssload 'sstint 'ssnotint 'sspritewh 'ssprite 'sspriter 'sspritez 'sspriterz 'createSurf 'Surf>pix 'Surf>wha 'Surf>wh 'Surf>pixpi 'texIni 'texEnd 'texEndAlpha 'tex2static 'timer< 'timer. 'timer+ 'timer- 'ICS>anim 'vICS>anim 'anim>n 'anim>c 'anim>stop
#info ( $1F $1F $1F $2E $2F $4C $3D $3D $4C $4C $4C $4C $6A $5B $5B $3D $3D $3D $5B $2E $3D $3E $2E $2E $4C $6A $3D $1F $3D $4C $4C $5B $3E $1F $0 $11 $4C $5B $5B $6A $2F $11 $11 $12 $11 $2E $1 $1 $10 $0 $0 $10 $10 $3E $4D $10 $10 $10 )
#r3_lib_sdl2gfx.r3 'name 'words 'calls 'info
^r3/lib/sdl2gl.r3
#name "r3/lib/sdl2gl.r3"
#words  "glCreateProgram" "glCreateShader" "glShaderSource" "glCompileShader" "glGetShaderiv" "glAttachShader" "glGetProgramiv" "glGetAttribLocation" "glClearColor" "glGenBuffers" "glBindBuffer" "glBindRenderbuffer" "glBufferData" "glBufferSubData" "glGetTexImage" "glMapBuffer" "glUnmapBuffer" "glGetUniformBlockIndex" "glUniformBlockBinding" "glBindBufferBase" "glClear" "glUseProgram" "glValidateProgram" "glEnableVertexAttribArray" "glVertexAttribPointer" "glVertexAttribIPointer" "glDrawElements" "glDrawElementsInstanced" "glDrawArrays" "glDrawArraysInstanced" "glDisableVertexAttribArray" "glDeleteProgram" "glIsProgram" "glIsShader" "glGenVertexArrays" "glBindVertexArray" "glGetShaderInfoLog" "glGetProgramInfoLog" "glBindFragDataLocation" "glLinkProgram" "glGenTextures" "glActiveTexture" "glBindTexture" "glTexImage2D" "glUniform1i" "glTexParameteri" "glTexSubImage2D" "glEnable" "glDisable" "glBlendFunc" "glDepthFunc" "glDetachShader" "glDeleteShader" "glDeleteTextures" "glDeleteBuffers" "glDeleteVertexArrays" "glGetError" "glGetString" "glViewport" "glScissor" "glVertexPointer" "glBegin" "glEnd" "glColor4ubv" "glVertex3fv" "glTexCoord2fv" "glVertex2fv" "glGetUniformLocation" "glUniform1iv" "glUniform2iv" "glUniform3iv" "glUniform4iv" "glUniform1fv" "glUniform2fv" "glUniform3fv" "glUniform4fv" "glVertexAttribDivisor" "glUniformMatrix4fv" "glVertexAttrib1fv" "glVertexAttrib2fv" "glVertexAttrib3fv" "glVertexAttrib4fv" "glBindAttribLocation" "glGenFramebuffers" "glTexParameterfv" "glBindFramebuffer" "glFramebufferTexture2D" "glDrawBuffer" "glReadBuffer" "glPixelStorei" "glRenderbufferStorage" "glFramebufferRenderbuffer" "glGenRenderbuffers" "glGenTextures" "InitGLAPI" "SDLinitGL" "SDLinitSGL" "SDLGLcls" "SDLGLupdate" "SDLglquit" "glInfo" 0
#calls  'glCreateProgram 'glCreateShader 'glShaderSource 'glCompileShader 'glGetShaderiv 'glAttachShader 'glGetProgramiv 'glGetAttribLocation 'glClearColor 'glGenBuffers 'glBindBuffer 'glBindRenderbuffer 'glBufferData 'glBufferSubData 'glGetTexImage 'glMapBuffer 'glUnmapBuffer 'glGetUniformBlockIndex 'glUniformBlockBinding 'glBindBufferBase 'glClear 'glUseProgram 'glValidateProgram 'glEnableVertexAttribArray 'glVertexAttribPointer 'glVertexAttribIPointer 'glDrawElements 'glDrawElementsInstanced 'glDrawArrays 'glDrawArraysInstanced 'glDisableVertexAttribArray 'glDeleteProgram 'glIsProgram 'glIsShader 'glGenVertexArrays 'glBindVertexArray 'glGetShaderInfoLog 'glGetProgramInfoLog 'glBindFragDataLocation 'glLinkProgram 'glGenTextures 'glActiveTexture 'glBindTexture 'glTexImage2D 'glUniform1i 'glTexParameteri 'glTexSubImage2D 'glEnable 'glDisable 'glBlendFunc 'glDepthFunc 'glDetachShader 'glDeleteShader 'glDeleteTextures 'glDeleteBuffers 'glDeleteVertexArrays 'glGetError 'glGetString 'glViewport 'glScissor 'glVertexPointer 'glBegin 'glEnd 'glColor4ubv 'glVertex3fv 'glTexCoord2fv 'glVertex2fv 'glGetUniformLocation 'glUniform1iv 'glUniform2iv 'glUniform3iv 'glUniform4iv 'glUniform1fv 'glUniform2fv 'glUniform3fv 'glUniform4fv 'glVertexAttribDivisor 'glUniformMatrix4fv 'glVertexAttrib1fv 'glVertexAttrib2fv 'glVertexAttrib3fv 'glVertexAttrib4fv 'glBindAttribLocation 'glGenFramebuffers 'glTexParameterfv 'glBindFramebuffer 'glFramebufferTexture2D 'glDrawBuffer 'glReadBuffer 'glPixelStorei 'glRenderbufferStorage 'glFramebufferRenderbuffer 'glGenRenderbuffers 'glGenTextures 'InitGLAPI 'SDLinitGL 'SDLinitSGL 'SDLGLcls 'SDLGLupdate 'SDLglquit 'glInfo
#info ( $1 $10 $4C $1F $3D $2E $3D $2F $4C $2E $2E $2E $4C $4C $5B $2F $1F $2F $3D $3D $1F $1F $1F $1F $6A $5B $4C $5B $3D $4C $1F $1F $10 $10 $2E $1F $4C $4C $3D $1F $2E $1F $2E $17 $2E $3D $17 $1F $1F $2E $1F $2E $1F $2E $2E $2E $1 $10 $4C $4C $4C $1F $0 $1F $1F $1F $1F $2F $3D $3D $3D $3D $3D $3D $3D $3D $2E $4C $2E $2E $2E $2E $3D $2E $3D $2E $5B $1F $1F $2E $4C $4C $2E $2E $0 $3D $3D $0 $0 $0 $0 )
#r3_lib_sdl2gl.r3 'name 'words 'calls 'info
^r3/lib/sdl2image.r3
#name "r3/lib/sdl2image.r3"
#words  "IMG_Load" "IMG_Init" "IMG_LoadTexture" "IMG_LoadSizedSVG_RW" "IMG_LoadAnimation" "IMG_FreeAnimation" "IMG_SavePNG" "IMG_SavePNG_RW" "IMG_SaveJPG" "IMG_SaveJPG_RW" "loadimg" "unloadimg" "loadsvg" 0
#calls  'IMG_Load 'IMG_Init 'IMG_LoadTexture 'IMG_LoadSizedSVG_RW 'IMG_LoadAnimation 'IMG_FreeAnimation 'IMG_SavePNG 'IMG_SavePNG_RW 'IMG_SaveJPG 'IMG_SaveJPG_RW 'loadimg 'unloadimg 'loadsvg
#info ( $10 $1F $2F $3E $10 $1F $2E $3D $3D $4C $10 $1F $3E )
#r3_lib_sdl2image.r3 'name 'words 'calls 'info
^r3/lib/sdl2mixer.r3
#name "r3/lib/sdl2mixer.r3"
#words  "Mix_Init" "Mix_Quit" "Mix_LoadWAV" "Mix_LoadMUS" "Mix_PlayChannelTimed" "Mix_HaltChannel" "Mix_FadeOutChannel" "Mix_PlayMusic" "Mix_HaltMusic" "Mix_FadeOutMusic" "Mix_VolumeMusic" "Mix_PlayingMusic" "Mix_Playing" "Mix_FreeChunk" "Mix_FreeMusic" "Mix_OpenAudio" "Mix_CloseAudio" "Mix_MasterVolume" "SNDInit" "SNDplay" "SNDplayn" "SNDQuit" 0
#calls  'Mix_Init 'Mix_Quit 'Mix_LoadWAV 'Mix_LoadMUS 'Mix_PlayChannelTimed 'Mix_HaltChannel 'Mix_FadeOutChannel 'Mix_PlayMusic 'Mix_HaltMusic 'Mix_FadeOutMusic 'Mix_VolumeMusic 'Mix_PlayingMusic 'Mix_Playing 'Mix_FreeChunk 'Mix_FreeMusic 'Mix_OpenAudio 'Mix_CloseAudio 'Mix_MasterVolume 'SNDInit 'SNDplay 'SNDplayn 'SNDQuit
#info ( $10 $0 $10 $10 $4D $1F $2E $2E $0 $1F $1F $1 $10 $1F $1F $4C $0 $1F $0 $1F $2E $0 )
#r3_lib_sdl2mixer.r3 'name 'words 'calls 'info
^r3/lib/sdl2net.r3
#name "r3/lib/sdl2net.r3"
#words  "SDLNet_Init" "SDLNet_Quit" "SDLNet_ResolveHost" "SDLNet_ResolveIP" "SDLNet_GetLocalAddresses" "SDLNet_TCP_OpenServer" "SDLNet_TCP_OpenClient" "SDLNet_TCP_Open" "SDLNet_TCP_Accept" "SDLNet_TCP_GetPeerAddress" "SDLNet_TCP_Send" "SDLNet_TCP_Recv" "SDLNet_TCP_Close" "SDLNet_AllocPacket" "SDLNet_ResizePacket" "SDLNet_FreePacket" "SDLNet_AllocPacketV" "SDLNet_FreePacketV" "SDLNet_UDP_Open" "SDLNet_UDP_SetPacketLoss" "SDLNet_UDP_Bind" "SDLNet_UDP_Unbind" "SDLNet_UDP_GetPeerAddress" "SDLNet_UDP_SendV" "SDLNet_UDP_Send" "SDLNet_UDP_RecvV" "SDLNet_UDP_Recv" "SDLNet_UDP_Close" "SDLNet_AllocSocketSet" "SDLNet_AddSocket" "SDLNet_DelSocket" "SDLNet_CheckSockets" "SDLNet_FreeSocketSet" "SDLNet_GetError" 0
#calls  'SDLNet_Init 'SDLNet_Quit 'SDLNet_ResolveHost 'SDLNet_ResolveIP 'SDLNet_GetLocalAddresses 'SDLNet_TCP_OpenServer 'SDLNet_TCP_OpenClient 'SDLNet_TCP_Open 'SDLNet_TCP_Accept 'SDLNet_TCP_GetPeerAddress 'SDLNet_TCP_Send 'SDLNet_TCP_Recv 'SDLNet_TCP_Close 'SDLNet_AllocPacket 'SDLNet_ResizePacket 'SDLNet_FreePacket 'SDLNet_AllocPacketV 'SDLNet_FreePacketV 'SDLNet_UDP_Open 'SDLNet_UDP_SetPacketLoss 'SDLNet_UDP_Bind 'SDLNet_UDP_Unbind 'SDLNet_UDP_GetPeerAddress 'SDLNet_UDP_SendV 'SDLNet_UDP_Send 'SDLNet_UDP_RecvV 'SDLNet_UDP_Recv 'SDLNet_UDP_Close 'SDLNet_AllocSocketSet 'SDLNet_AddSocket 'SDLNet_DelSocket 'SDLNet_CheckSockets 'SDLNet_FreeSocketSet 'SDLNet_GetError
#info ( $0 $0 $3E $10 $2F $10 $10 $10 $10 $10 $3E $3E $10 $10 $2F $1F $2F $1F $10 $2E $2E $2E $2F $3E $3E $2F $2F $1F $10 $2F $2F $2F $1F $1 )
#r3_lib_sdl2net.r3 'name 'words 'calls 'info
^r3/lib/sdl2poly.r3
#name "r3/lib/sdl2poly.r3"
#words  "SDLop" "SDLop2" "SDLpline" "SDLpoly" "SDLFngon" "linegr!" "linegr" "gop" "gline" "SDLngon" 0
#calls  'SDLop 'SDLop2 'SDLpline 'SDLpoly 'SDLFngon 'linegr! 'linegr 'gop 'gline 'SDLngon
#info ( $2E $2E $2E $0 $5B $1F $1 $2E $2E $5B )
#r3_lib_sdl2poly.r3 'name 'words 'calls 'info
^r3/lib/sdl2ttf.r3
#name "r3/lib/sdl2ttf.r3"
#words  "TTF_Init" "TTF_OpenFont" "TTF_SetFontStyle" "TTF_SetFontOutline" "TTF_SetFontLineSkip" "TTF_SetFontWrappedAlign" "TTF_SetFontSize" "TTF_SetFontSDF" "TTF_SizeText" "TTF_SizeUTF8" "TTF_MeasureUTF8" "TTF_RenderText_Solid" "TTF_RenderUTF8_Solid" "TTF_RenderText_Shaded" "TTF_RenderUTF8_Shaded" "TTF_RenderText_Blended" "TTF_RenderUTF8_Blended" "TTF_RenderUTF8_Blended_Wrapped" "TTF_RenderUNICODE_Blended" "TTF_CloseFont" "TTF_Quit" 0
#calls  'TTF_Init 'TTF_OpenFont 'TTF_SetFontStyle 'TTF_SetFontOutline 'TTF_SetFontLineSkip 'TTF_SetFontWrappedAlign 'TTF_SetFontSize 'TTF_SetFontSDF 'TTF_SizeText 'TTF_SizeUTF8 'TTF_MeasureUTF8 'TTF_RenderText_Solid 'TTF_RenderUTF8_Solid 'TTF_RenderText_Shaded 'TTF_RenderUTF8_Shaded 'TTF_RenderText_Blended 'TTF_RenderUTF8_Blended 'TTF_RenderUTF8_Blended_Wrapped 'TTF_RenderUNICODE_Blended 'TTF_CloseFont 'TTF_Quit
#info ( $0 $2F $2E $2E $2E $2E $2E $2F $4D $4D $5B $3E $3E $4D $4D $3E $3E $4D $3E $1F $0 )
#r3_lib_sdl2ttf.r3 'name 'words 'calls 'info
^r3/lib/sdlkeys.r3
#name "r3/lib/sdlkeys.r3"
#words  "<back>" ">back<" "<tab>" ">tab<" "<ret>" ">ret<" "<esc>" ">esc<" "<esp>" ">esp<" "<del>" ">del<" "<home>" ">home<" "<end>" ">end<" "<pgup>" ">pgup<" "<pgdn>" ">pgdn<" "<ins>" ">ins<" "<ri>" ">ri<" "<le>" ">le<" "<dn>" ">dn<" "<up>" ">up<" "<F1>" ">F1<" "<F2>" ">F2<" "<F3>" ">F3<" "<F4>" ">F4<" "<F5>" ">F5<" "<F6>" ">F6<" "<F7>" ">F7<" "<F8>" ">F8<" "<F9>" ">F9<" "<F10>" ">F10<" "<F11>" ">F11<" "<F12>" ">F12<" "<ctrl>" ">ctrl<" "<ctr2>" ">ctr2<" "<shift>" ">shift<" "<shif2>" ">shif2<" "<alt>" ">alt<" "<alt2>" ">alt2<" "<A>" "<B>" "<C>" "<D>" "<E>" "<F>" "<G>" "<H>" "<I>" "<J>" "<K>" "<L>" "<M>" "<N>" "<O>" "<P>" "<Q>" "<R>" "<S>" "<T>" "<U>" "<V>" "<W>" "<X>" "<Y>" "<Z>" ">A<" ">B<" ">C<" ">D<" ">E<" ">F<" ">G<" ">H<" ">I<" ">J<" ">K<" ">L<" ">M<" ">N<" ">O<" ">P<" ">Q<" ">R<" ">S<" ">T<" ">U<" ">V<" ">W<" ">X<" ">Y<" ">Z<" "<1>" "<2>" "<3>" "<4>" "<5>" "<6>" "<7>" "<8>" "<9>" "<0>" ">1<" ">2<" ">3<" ">4<" ">5<" ">6<" ">7<" ">8<" ">9<" ">0<" "<->" ">-<" "<+>" ">+<" 0
#calls  '<back> '>back< '<tab> '>tab< '<ret> '>ret< '<esc> '>esc< '<esp> '>esp< '<del> '>del< '<home> '>home< '<end> '>end< '<pgup> '>pgup< '<pgdn> '>pgdn< '<ins> '>ins< '<ri> '>ri< '<le> '>le< '<dn> '>dn< '<up> '>up< '<F1> '>F1< '<F2> '>F2< '<F3> '>F3< '<F4> '>F4< '<F5> '>F5< '<F6> '>F6< '<F7> '>F7< '<F8> '>F8< '<F9> '>F9< '<F10> '>F10< '<F11> '>F11< '<F12> '>F12< '<ctrl> '>ctrl< '<ctr2> '>ctr2< '<shift> '>shift< '<shif2> '>shif2< '<alt> '>alt< '<alt2> '>alt2< '<A> '<B> '<C> '<D> '<E> '<F> '<G> '<H> '<I> '<J> '<K> '<L> '<M> '<N> '<O> '<P> '<Q> '<R> '<S> '<T> '<U> '<V> '<W> '<X> '<Y> '<Z> '>A< '>B< '>C< '>D< '>E< '>F< '>G< '>H< '>I< '>J< '>K< '>L< '>M< '>N< '>O< '>P< '>Q< '>R< '>S< '>T< '>U< '>V< '>W< '>X< '>Y< '>Z< '<1> '<2> '<3> '<4> '<5> '<6> '<7> '<8> '<9> '<0> '>1< '>2< '>3< '>4< '>5< '>6< '>7< '>8< '>9< '>0< '<-> '>-< '<+> '>+<
#info ( $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 )
#r3_lib_sdlkeys.r3 'name 'words 'calls 'info
^r3/lib/str.r3
#name "r3/lib/str.r3"
#words  "strcpyl" "strcpy" "strcat" "strcpylnl" "strcpyln" "copynom" "copystr" "strpath" "toupp" "tolow" "count" "count" "utf8count" "utf8ncpy" "utf8bytes" "=" "cmpstr" "=s" "=w" "=pre" "=pos" "=lpos" "findchar" "findstr" "findstri" ".d" ".b" ".h" ".o" ".f" ".f2" ".f1" ".r." "trim" "trimc" "trimcar" "trimstr" ">>cr" ">>0" "l0count" "n>>0" "only13" ">>sp" ">>str" 0
#calls  'strcpyl 'strcpy 'strcat 'strcpylnl 'strcpyln 'copynom 'copystr 'strpath 'toupp 'tolow 'count 'count 'utf8count 'utf8ncpy 'utf8bytes '= 'cmpstr '=s '=w '=pre '=pos '=lpos 'findchar 'findstr 'findstri '.d '.b '.h '.o '.f '.f2 '.f1 '.r. 'trim 'trimc 'trimcar 'trimstr '>>cr '>>0 'l0count 'n>>0 'only13 '>>sp '>>str
#info ( $2F $2E $2E $2F $2E $2E $2E $2E $10 $10 $11 $11 $11 $3E $20 $2F $2F $2F $2F $20 $20 $20 $2F $2F $2F $10 $10 $10 $10 $10 $10 $10 $2F $10 $2F $11 $10 $10 $10 $10 $2F $10 $10 $10 )
#r3_lib_str.r3 'name 'words 'calls 'info
^r3/lib/term.r3
#name "r3/lib/term.r3"
#words  "[ESC]" "[ENTER]" "[BACK]" "[TAB]" "[DEL]" "[INS]" "[UP]" "[DN]" "[RI]" "[LE]" "[PGUP]" "[PGDN]" "[HOME]" "[END]" "[SHIFT+TAB]" "[SHIFT+DEL]" "[SHIFT+INS]" "[SHIFT+UP]" "[SHIFT+DN]" "[SHIFT+RI]" "[SHIFT+LE]" "[SHIFT+PGUP]" "[SHIFT+PGDN]" "[SHIFT+HOME]" "[SHIFT+END]" "[F1]" "[F2]" "[F3]" "[F4]" "[F5]" "[F6]" "[F7]" "[F8]" "[F9]" "[F10]" "[F11]" "[F12]" ".cl" ".flush" ".type" ".emit" ".cr" ".sp" ".nsp" ".nch" ".write" ".print" ".println" ".^[" ".[w" ".[p" ".rep" ".fwrite" ".fprint" ".fprintln" ".home" ".cls" ".at" ".col" ".eline" ".ealine" ".escreen" ".escreenup" ".showc" ".hidec" ".blc" ".unblc" ".savec" ".restorec" ".ovec" ".insc" ".blockc" ".underc" ".alsb" ".masb" ".scrolloff" ".scrollon" ".Black" ".Red" ".Green" ".Yellow" ".Blue" ".Magenta" ".Cyan" ".White" ".Blackl" ".Redl" ".Greenl" ".Yellowl" ".Bluel" ".Magental" ".Cyanl" ".Whitel" ".fc" ".BBlack" ".BRed" ".BGreen" ".BYellow" ".BBlue" ".BMagenta" ".BCyan" ".BWhite" ".BBlackl" ".BRedl" ".BGreenl" ".BYellowl" ".BBluel" ".BMagental" ".BCyanl" ".BWhitel" ".bc" ".fgrgb" ".bgrgb" ".Bold" ".Dim" ".Italic" ".Under" ".Blink" ".Rever" ".Hidden" ".Strike" ".Reset" "waitesc" "waitkey" 0
#calls  '[ESC] '[ENTER] '[BACK] '[TAB] '[DEL] '[INS] '[UP] '[DN] '[RI] '[LE] '[PGUP] '[PGDN] '[HOME] '[END] '[SHIFT+TAB] '[SHIFT+DEL] '[SHIFT+INS] '[SHIFT+UP] '[SHIFT+DN] '[SHIFT+RI] '[SHIFT+LE] '[SHIFT+PGUP] '[SHIFT+PGDN] '[SHIFT+HOME] '[SHIFT+END] '[F1] '[F2] '[F3] '[F4] '[F5] '[F6] '[F7] '[F8] '[F9] '[F10] '[F11] '[F12] '.cl '.flush '.type '.emit '.cr '.sp '.nsp '.nch '.write '.print '.println '.^[ '.[w '.[p '.rep '.fwrite '.fprint '.fprintln '.home '.cls '.at '.col '.eline '.ealine '.escreen '.escreenup '.showc '.hidec '.blc '.unblc '.savec '.restorec '.ovec '.insc '.blockc '.underc '.alsb '.masb '.scrolloff '.scrollon '.Black '.Red '.Green '.Yellow '.Blue '.Magenta '.Cyan '.White '.Blackl '.Redl '.Greenl '.Yellowl '.Bluel '.Magental '.Cyanl '.Whitel '.fc '.BBlack '.BRed '.BGreen '.BYellow '.BBlue '.BMagenta '.BCyan '.BWhite '.BBlackl '.BRedl '.BGreenl '.BYellowl '.BBluel '.BMagental '.BCyanl '.BWhitel '.bc '.fgrgb '.bgrgb '.Bold '.Dim '.Italic '.Under '.Blink '.Rever '.Hidden '.Strike '.Reset 'waitesc 'waitkey
#info ( $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $0 $0 $2E $1F $0 $0 $1F $2E $1F $1F $1F $0 $1F $1F $2E $1F $1F $1F $0 $0 $2E $1F $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $1F $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $1F $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $1F $3D $3D $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 )
#r3_lib_term.r3 'name 'words 'calls 'info
^r3/lib/tflite.r3
#name "r3/lib/tflite.r3"
#words  "TfLiteModelCreateFromFile" "TfLiteInterpreterOptionsCreate" "TfLiteInterpreterCreate" "TfLiteInterpreterAllocateTensors" "TfLiteInterpreterGetInputTensor" "TfLiteInterpreterGetOutputTensor" "TfLiteTensorDim" "TfLiteTensorData" "TfLiteInterpreterInvoke" "TfLiteInterpreterDelete" "TfLiteInterpreterOptionsDelete" "TfLiteModelDelete" "TfLiteXNNPackDelegateCreate" "TfLiteInterpreterOptionsAddDelegate" "TfLiteTensorCopyFromBuffer" "TfLiteTensorCopyToBuffer" "TfLiteTensorByteSize" 0
#calls  'TfLiteModelCreateFromFile 'TfLiteInterpreterOptionsCreate 'TfLiteInterpreterCreate 'TfLiteInterpreterAllocateTensors 'TfLiteInterpreterGetInputTensor 'TfLiteInterpreterGetOutputTensor 'TfLiteTensorDim 'TfLiteTensorData 'TfLiteInterpreterInvoke 'TfLiteInterpreterDelete 'TfLiteInterpreterOptionsDelete 'TfLiteModelDelete 'TfLiteXNNPackDelegateCreate 'TfLiteInterpreterOptionsAddDelegate 'TfLiteTensorCopyFromBuffer 'TfLiteTensorCopyToBuffer 'TfLiteTensorByteSize
#info ( $10 $1 $2F $10 $2F $2F $2F $10 $10 $10 $10 $10 $10 $2F $3E $3E $10 )
#r3_lib_tflite.r3 'name 'words 'calls 'info
^r3/lib/trace.r3
#name "r3/lib/trace.r3"
#words  "<<trace" "<<traceh" "<<memdump" "<<memdumpc" "clearlog" "filelog" "<<memmap" 0
#calls  '<<trace '<<traceh '<<memdump '<<memdumpc 'clearlog 'filelog '<<memmap
#info ( $50 $50 $2E $2E $0 $1F $1F )
#r3_lib_trace.r3 'name 'words 'calls 'info
^r3/lib/vdraw.r3
#name "r3/lib/vdraw.r3"
#words  "vset!" "vget!" "vsize!" "vop" "vline" "vfill" "vrect" "vfrect" "vellipse" "vellipseb" 0
#calls  'vset! 'vget! 'vsize! 'vop 'vline 'vfill 'vrect 'vfrect 'vellipse 'vellipseb
#info ( $1F $1F $2E $2E $20 $2E $40 $4C $2E $20 )
#r3_lib_vdraw.r3 'name 'words 'calls 'info
^r3/lib/vec2.r3
#name "r3/lib/vec2.r3"
#words  "v2=" "v2+" "v2-" "v2+*" "v2-*" "v2*" "v2/" "v2len" "v2nor" "v2lim" "v2rot" "v2dot" "v2perp" 0
#calls  'v2= 'v2+ 'v2- 'v2+* 'v2-* 'v2* 'v2/ 'v2len 'v2nor 'v2lim 'v2rot 'v2dot 'v2perp
#info ( $2E $2E $2E $3D $3D $2E $2E $10 $1F $2E $2E $2F $2E )
#r3_lib_vec2.r3 'name 'words 'calls 'info
^r3/lib/vec3.r3
#name "r3/lib/vec3.r3"
#words  "v3len" "v3nor" "v3ddot" "v3vec" "v3-" "v3+" "v3*" "v3=" "normInt2Fix" "normFix" "q4=" "q4W" "q4dot" "q4inv" "q4conj" "q4len" "q4nor" 0
#calls  'v3len 'v3nor 'v3ddot 'v3vec 'v3- 'v3+ 'v3* 'v3= 'normInt2Fix 'normFix 'q4= 'q4W 'q4dot 'q4inv 'q4conj 'q4len 'q4nor
#info ( $10 $1F $2F $2E $2E $2E $2E $2E $30 $30 $2E $2E $2F $2E $2E $10 $1F )
#r3_lib_vec3.r3 'name 'words 'calls 'info
^r3/util/arr16.r3
#name "r3/util/arr16.r3"
#words  "p.ini" "p.clear" "p.cnt" "p.adr" "p.nro" "p!+" "p!" "p.draw" "p.drawo" "p.del" "p.mapv" "p.mapd" "p.map2" "p.sort" "p.isort" 0
#calls  'p.ini 'p.clear 'p.cnt 'p.adr 'p.nro 'p!+ 'p! 'p.draw 'p.drawo 'p.del 'p.mapv 'p.mapd 'p.map2 'p.sort 'p.isort
#info ( $2E $1F $10 $2F $2F $2F $10 $1F $1F $2E $2E $2E $2E $2E $2E )
#r3_util_arr16.r3 'name 'words 'calls 'info
^r3/util/arr8.r3
#name "r3/util/arr8.r3"
#words  "p8.ini" "p8.clear" "p8!+" "p8!" "p8.draw" "p8.drawo" "p8.nro" "p8.last" "p8.cnt" "p8.cpy" "p8.del" "p8.mapv" "p8.mapd" "p8.mapi" "p8.deli" 0
#calls  'p8.ini 'p8.clear 'p8!+ 'p8! 'p8.draw 'p8.drawo 'p8.nro 'p8.last 'p8.cnt 'p8.cpy 'p8.del 'p8.mapv 'p8.mapd 'p8.mapi 'p8.deli
#info ( $2E $1F $2F $10 $1F $1F $2F $10 $10 $2E $2E $2E $2E $4C $4C )
#r3_util_arr8.r3 'name 'words 'calls 'info
^r3/util/bfont.r3
#name "r3/util/bfont.r3"
#words  "wp" "hp" "bmfont" "bcolor" "bfbox" "bbox" "bbox2" "bfillline" "bsrcsize" "bfillemit" "bfcemit" "bemit" "bprint" "bemits" "bprintd" "bemitsd" "bprint2" "bemits2" "bprintz" "bemitsz" "bat" "ccx" "ccy" "gotoxy" "gotox" "bcr" "bcr2" "bcrz" "bsp" "bnsp" "bsize" "bpos" "brect" "bcursor" "bcursori" "bcursor2" "bcursori2" "bfont1" "bfont2" 0
#calls  'wp 'hp 'bmfont 'bcolor 'bfbox 'bbox 'bbox2 'bfillline 'bsrcsize 'bfillemit 'bfcemit 'bemit 'bprint 'bemits 'bprintd 'bemitsd 'bprint2 'bemits2 'bprintz 'bemitsz 'bat 'ccx 'ccy 'gotoxy 'gotox 'bcr 'bcr2 'bcrz 'bsp 'bnsp 'bsize 'bpos 'brect 'bcursor 'bcursori 'bcursor2 'bcursori2 'bfont1 'bfont2
#info ( $80 $80 $3D $1F $0 $0 $0 $4C $40 $0 $1F $1F $1F $1F $1F $1F $1F $1F $2E $2E $2E $1 $1 $2E $1F $0 $0 $1F $0 $1F $2 $2 $4 $1F $1F $1F $1F $0 $0 )
#r3_util_bfont.r3 'name 'words 'calls 'info
^r3/util/blist.r3
#name "r3/util/blist.r3"
#words  "blistdel" "blist!" "blist-" "blist@" "blist?" 0
#calls  'blistdel 'blist! 'blist- 'blist@ 'blist?
#info ( $2E $2E $2E $10 $20 )
#r3_util_blist.r3 'name 'words 'calls 'info
^r3/util/bmap.r3
#name "r3/util/bmap.r3"
#words  "bsprdraw" "inisprite" "+sprite" "drawmaps" "loadmap" "bmap2xy" "whbmap" "xyinmap@" "xytrigger" 0
#calls  'bsprdraw 'inisprite '+sprite 'drawmaps 'loadmap 'bmap2xy 'whbmap 'xyinmap@ 'xytrigger
#info ( $80 $0 $3D $2E $10 $20 $2 $2F $20 )
#r3_util_bmap.r3 'name 'words 'calls 'info
^r3/util/boxtext.r3
#name "r3/util/boxtext.r3"
#words  "xywh64" "w%" "h%" "xywh%64" "xy%64" "64box" "textline" "textbox." "textbox" "textboxb" "textboxo" "textboxh" 0
#calls  'xywh64 'w% 'h% 'xywh%64 'xy%64 '64box 'textline 'textbox. 'textbox 'textboxb 'textboxo 'textboxh
#info ( $4D $10 $10 $4D $3E $2E $5C $5B $5B $5B $5B $4D )
#r3_util_boxtext.r3 'name 'words 'calls 'info
^r3/util/datetime.r3
#name "r3/util/datetime.r3"
#words  "str_DMA" "str_HMS" "str_HM" ">dianame" ">mesname" "str_fullday" "str_hhmmss" "dt2timesql" "dt>64" ",64>dtf" ",64>dtd" ",64>dtt" "64>dtc" 0
#calls  'str_DMA 'str_HMS 'str_HM '>dianame '>mesname 'str_fullday 'str_hhmmss 'dt2timesql 'dt>64 ',64>dtf ',64>dtd ',64>dtt '64>dtc
#info ( $1 $1 $1 $10 $10 $2 $1 $1F $10 $1F $1F $1F $1F )
#r3_util_datetime.r3 'name 'words 'calls 'info
^r3/util/db2.r3
#name "r3/util/db2.r3"
#words  "rowdb" "getnfilename" "loadnfile" ">>line" "loaddb-i" "prevdb-i" "dbfld" "loaddb" "getdbrow" "findbrow" "cntdbrow" ">>fld" "getdbfld" "cpydbfld" "cpydbfldn" 0
#calls  'rowdb 'getnfilename 'loadnfile '>>line 'loaddb-i 'prevdb-i 'dbfld 'loaddb 'getdbrow 'findbrow 'cntdbrow '>>fld 'getdbfld 'cpydbfld 'cpydbfldn
#info ( $80 $2F $10 $10 $1F $1F $10 $10 $2F $2F $10 $10 $2F $2E $3D )
#r3_util_db2.r3 'name 'words 'calls 'info
^r3/util/dbtxt.r3
#name "r3/util/dbtxt.r3"
#words  "rowdb" "getnfilename" "loadnfile" ">>line" "loaddb-i" "prevdb-i" "dbfld" "loaddb" "getdbrow" "findbrow" "cntdbrow" ">>fld" "getdbfld" "cpydbfld" "cpydbfldn" 0
#calls  'rowdb 'getnfilename 'loadnfile '>>line 'loaddb-i 'prevdb-i 'dbfld 'loaddb 'getdbrow 'findbrow 'cntdbrow '>>fld 'getdbfld 'cpydbfld 'cpydbfldn
#info ( $80 $2F $10 $10 $1F $1F $10 $10 $2F $2F $10 $10 $2F $2E $3D )
#r3_util_dbtxt.r3 'name 'words 'calls 'info
^r3/util/dlgcol.r3
#name "r3/util/dlgcol.r3"
#words  "colord" "color!" "dlgColor" "dlgColorIni" "xydlgColor!" 0
#calls  'colord 'color! 'dlgColor 'dlgColorIni 'xydlgColor!
#info ( $80 $1F $0 $0 $2E )
#r3_util_dlgcol.r3 'name 'words 'calls 'info
^r3/util/dlgfile.r3
#name "r3/util/dlgfile.r3"
#words  "dlgFileLoad" "dlgFileSave" "dlgSetPath" 0
#calls  'dlgFileLoad 'dlgFileSave 'dlgSetPath
#info ( $1 $1 $1F )
#r3_util_dlgfile.r3 'name 'words 'calls 'info
^r3/util/dlist.r3
#name "r3/util/dlist.r3"
#words  "dc.ini" "dc.clear" "dc?" "dcn@" "dc@" "dc!" "dc@-" 0
#calls  'dc.ini 'dc.clear 'dc? 'dcn@ 'dc@ 'dc! 'dc@-
#info ( $2E $1F $10 $2F $11 $2E $10 )
#r3_util_dlist.r3 'name 'words 'calls 'info
^r3/util/float_table.r3
#name "r3/util/float_table.r3"
#words  "byte2flN" 0
#calls  'byte2flN
#info ( $10 )
#r3_util_float_table.r3 'name 'words 'calls 'info
^r3/util/hash2d.r3
#name "r3/util/hash2d.r3"
#words  "H2d.ini" "H2d.clear" "H2d.list" "checkmax" "h2d+!" "h2d!" 0
#calls  'H2d.ini 'H2d.clear 'H2d.list 'checkmax 'h2d+! 'h2d!
#info ( $1F $0 $2 $80 $4C $5E )
#r3_util_hash2d.r3 'name 'words 'calls 'info
^r3/util/heap.r3
#name "r3/util/heap.r3"
#words  "heap!" "heap@" "heapini" 0
#calls  'heap! 'heap@ 'heapini
#info ( $2E $10 $2E )
#r3_util_heap.r3 'name 'words 'calls 'info
^r3/util/loadobj.r3
#name "r3/util/loadobj.r3"
#words  "verl" "nver" "facel" "nface" "norml" "texl" "ntex" "paral" "colorl" "ncolor" "]face" "]vert" "]norm" "]uv" ">>cr" "]Ka@" "]Kd@" "]Ks@" "]Ke@" "]Ns@" "]Ni@" "]d@" "]i@" "]Mkd@" "]MNs@" "]Mbp@" "cnt/" "getpath" "loadobj" "xmin" "ymin" "zmin" "xmax" "ymax" "zmax" "objminmax" "objmove" "objcentra" "objescala" "objescalax" "objescalay" "objescalaz" "objcube" 0
#calls  'verl 'nver 'facel 'nface 'norml 'texl 'ntex 'paral 'colorl 'ncolor ']face ']vert ']norm ']uv '>>cr ']Ka@ ']Kd@ ']Ks@ ']Ke@ ']Ns@ ']Ni@ ']d@ ']i@ ']Mkd@ ']MNs@ ']Mbp@ 'cnt/ 'getpath 'loadobj 'xmin 'ymin 'zmin 'xmax 'ymax 'zmax 'objminmax 'objmove 'objcentra 'objescala 'objescalax 'objescalay 'objescalaz 'objcube
#info ( $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $2F $80 $80 $80 $80 $80 $80 $0 $3D $0 $2E $2E $2E $2E $1F )
#r3_util_loadobj.r3 'name 'words 'calls 'info
^r3/util/pcfont.r3
#name "r3/util/pcfont.r3"
#words  "pccolor" "pcemit" "pcfbox" "pcbox" "pcbox2" "pcfillline" "pcsrcsize" "pcfillemit" "pcprint" "pcemits" "pcprintd" "pcemitsd" "pcprint2" "pcemits2" "pcprintz" "pcemitsz" "pcat" "ccx" "ccy" "gotoxy" "gotox" "pccr" "pcsp" "pcnsp" "pcsize" "pcpos" "pcrect" "pccursor" "pccursori" "pcfont" 0
#calls  'pccolor 'pcemit 'pcfbox 'pcbox 'pcbox2 'pcfillline 'pcsrcsize 'pcfillemit 'pcprint 'pcemits 'pcprintd 'pcemitsd 'pcprint2 'pcemits2 'pcprintz 'pcemitsz 'pcat 'ccx 'ccy 'gotoxy 'gotox 'pccr 'pcsp 'pcnsp 'pcsize 'pcpos 'pcrect 'pccursor 'pccursori 'pcfont
#info ( $1F $1F $0 $0 $0 $4C $40 $0 $1F $1F $1F $1F $1F $1F $2E $2E $2E $1 $1 $2E $1F $0 $0 $1F $2 $2 $4 $1F $1F $0 )
#r3_util_pcfont.r3 'name 'words 'calls 'info
^r3/util/penner.r3
#name "r3/util/penner.r3"
#words  "Lineal" "Quad_In" "Quad_Out" "Quad_InOut" "Cub_In" "Cub_Out" "Cub_InOut" "Quar_In" "Quar_Out" "Quar_InOut" "Quin_In" "Quin_Out" "Quin_InOut" "Sin_In" "Sin_Out" "Sin_InOut" "Exp_In" "Exp_Out" "Exp_InOut" "Cir_In" "Cir_Out" "Cir_InOut" "Ela_In" "Ela_Out" "Ela_InOut" "Bac_In" "Bac_Out" "Bac_InOut" "Bou_Out" "Bou_In" "Bou_InOut" "easet" "ease" "easem" "catmullRom" 0
#calls  'Lineal 'Quad_In 'Quad_Out 'Quad_InOut 'Cub_In 'Cub_Out 'Cub_InOut 'Quar_In 'Quar_Out 'Quar_InOut 'Quin_In 'Quin_Out 'Quin_InOut 'Sin_In 'Sin_Out 'Sin_InOut 'Exp_In 'Exp_Out 'Exp_InOut 'Cir_In 'Cir_Out 'Cir_InOut 'Ela_In 'Ela_Out 'Ela_InOut 'Bac_In 'Bac_Out 'Bac_InOut 'Bou_Out 'Bou_In 'Bou_InOut 'easet 'ease 'easem 'catmullRom
#info ( $0 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $90 $1F $1F $5C )
#r3_util_penner.r3 'name 'words 'calls 'info
^r3/util/sdlbgui.r3
#name "r3/util/sdlbgui.r3"
#words  "padx" "pady" "curx" "cury" "boxw" "boxh" "immcolorwin" "immcolortwin" "immcolortex" "immcolorbtn" "immgui" "immat" "immat+" "immbox" "immwinxy" "imm>>" "imm<<" "immdn" "immcr" "immln" "plgui" "plxywh" "immcur" "immcur>" "imm>cur" "immlabel" "immlabelc" "immlabelr" "imm." "immListBox" "immback" "immblabel" "immbtn" "immtbtn" "immzone" "immSliderf" "immSlideri" "immCheck" "immScrollv" "immRadio" "immCombo" "immInputLine" "immInputLine2" "immInputInt" "immwins" 0
#calls  'padx 'pady 'curx 'cury 'boxw 'boxh 'immcolorwin 'immcolortwin 'immcolortex 'immcolorbtn 'immgui 'immat 'immat+ 'immbox 'immwinxy 'imm>> 'imm<< 'immdn 'immcr 'immln 'plgui 'plxywh 'immcur 'immcur> 'imm>cur 'immlabel 'immlabelc 'immlabelr 'imm. 'immListBox 'immback 'immblabel 'immbtn 'immtbtn 'immzone 'immSliderf 'immSlideri 'immCheck 'immScrollv 'immRadio 'immCombo 'immInputLine 'immInputLine2 'immInputInt 'immwins
#info ( $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $0 $2E $2E $2E $2E $0 $0 $0 $0 $0 $0 $4 $4C $1 $1F $1F $1F $1F $1F $1F $1F $1F $2E $2E $1F $3D $3D $2E $3D $2E $1F $2E $2E $1F $10 )
#r3_util_sdlbgui.r3 'name 'words 'calls 'info
^r3/util/sdlfiledlg.r3
#name "r3/util/sdlfiledlg.r3"
#words  "immlist" "filedlgini" "immfileload" "immfilesave" "fullfilename" 0
#calls  'immlist 'filedlgini 'immfileload 'immfilesave 'fullfilename
#info ( $1F $0 $2E $2E $1 )
#r3_util_sdlfiledlg.r3 'name 'words 'calls 'info
^r3/util/sdlgui.r3
#name "r3/util/sdlgui.r3"
#words  "padx" "pady" "curx" "cury" "boxw" "boxh" "immcolorwin" "immcolortwin" "immcolortex" "immcolorbtn" "immgui" "immkey!" "immat" "immat+" "immbox" "immfont!" "immpad!" "immwinxy" "imm>>" "imm<<" "immdn" "immcr" "immln" "plgui" "plxywh" "immcur" "immcur>" "imm>cur" "immlabel" "immlabelc" "immlabelr" "imm." "immStrC" "immListBox" "immback" "immblabel" "immicon" "immiconb" "immwidth" "immbtn" "immibtn" "immtbtn" "immebtn" "immzone" "immSliderf" "immSlideri" "immCheck" "immScrollv" "immRadio" "immCombo" "immInputLine" "immInputInt" "immwin!" "immwin$" "winexit" "immwin" "immnowin" "immwinbottom" "immRedraw" "immwins" "immSDL" 0
#calls  'padx 'pady 'curx 'cury 'boxw 'boxh 'immcolorwin 'immcolortwin 'immcolortex 'immcolorbtn 'immgui 'immkey! 'immat 'immat+ 'immbox 'immfont! 'immpad! 'immwinxy 'imm>> 'imm<< 'immdn 'immcr 'immln 'plgui 'plxywh 'immcur 'immcur> 'imm>cur 'immlabel 'immlabelc 'immlabelr 'imm. 'immStrC 'immListBox 'immback 'immblabel 'immicon 'immiconb 'immwidth 'immbtn 'immibtn 'immtbtn 'immebtn 'immzone 'immSliderf 'immSlideri 'immCheck 'immScrollv 'immRadio 'immCombo 'immInputLine 'immInputInt 'immwin! 'immwin$ 'winexit 'immwin 'immnowin 'immwinbottom 'immRedraw 'immwins 'immSDL
#info ( $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $0 $1F $2E $2E $2E $10 $2E $2E $0 $0 $0 $0 $0 $0 $4 $4C $1 $1F $1F $1F $1F $1F $1F $1F $1F $1F $3D $1F $1F $2E $2E $2E $2E $1F $3D $3D $2E $3D $2E $2E $2E $1F $1F $1F $0 $10 $4C $1F $0 $10 $0 )
#r3_util_sdlgui.r3 'name 'words 'calls 'info
^r3/util/sort.r3
#name "r3/util/sort.r3"
#words  "shellsort" "shellsort2" "shellsort1" "sortstr" 0
#calls  'shellsort 'shellsort2 'shellsort1 'sortstr
#info ( $2E $2E $2E $2E )
#r3_util_sort.r3 'name 'words 'calls 'info
^r3/util/sortradix.r3
#name "r3/util/sortradix.r3"
#words  "radixsort32" "radixsort16" "radixsort64" 0
#calls  'radixsort32 'radixsort16 'radixsort64
#info ( $2E $2E $2E )
#r3_util_sortradix.r3 'name 'words 'calls 'info
^r3/util/sortradixm.r3
#name "r3/util/sortradixm.r3"
#words  "radixsort" "radixsortm" 0
#calls  'radixsort 'radixsortm
#info ( $2E $2E )
#r3_util_sortradixm.r3 'name 'words 'calls 'info
^r3/util/textb.r3
#name "r3/util/textb.r3"
#words  "textbox" 0
#calls  'textbox
#info ( $5C )
#r3_util_textb.r3 'name 'words 'calls 'info
^r3/util/tilesheet.r3
#name "r3/util/tilesheet.r3"
#words  "[map]" "drawtile" "tiledraw" "tiledrawv" "drawtile" "tiledraws" "tiledrawvs" "scr2view" "scr2tile" "loadtilemap" 0
#calls  '[map] 'drawtile 'tiledraw 'tiledrawv 'drawtile 'tiledraws 'tiledrawvs 'scr2view 'scr2tile 'loadtilemap
#info ( $2F $2F $79 $8 $2F $17 $26 $20 $1F $11 )
#r3_util_tilesheet.r3 'name 'words 'calls 'info
^r3/util/timeline.r3
#name "r3/util/timeline.r3"
#words  "endtimeline" "screen" "fx" "fxp" "timenow" "timeline.start" "timeline.clear" "+restart" "+stop" "64xy" "64wh" "64xywh" "64boxratio" "+box" "+img" "+imgar" "+txt" "+tbox" "+tboxb" "+tboxo" "+sound" "+music" "+event" "getscr" "+fx.on" "+fx.off" "evt.box" "+fx.box" "+ifx.box" "+ifx.text" "+ievent" "evt.color" "+fx.color" "debugtimeline" "debugtlmem" "timeline.draw" "timeline.inimem" 0
#calls  'endtimeline 'screen 'fx 'fxp 'timenow 'timeline.start 'timeline.clear '+restart '+stop '64xy '64wh '64xywh '64boxratio '+box '+img '+imgar '+txt '+tbox '+tboxb '+tboxo '+sound '+music '+event 'getscr '+fx.on '+fx.off 'evt.box '+fx.box '+ifx.box '+ifx.text '+ievent 'evt.color '+fx.color 'debugtimeline 'debugtlmem 'timeline.draw 'timeline.inimem
#info ( $80 $80 $80 $80 $80 $0 $0 $1F $1F $11 $11 $13 $2E $2E $2E $2E $3D $4C $5B $5B $2E $2E $2E $1 $1F $1F $10 $5B $6A $0 $2E $10 $5B $10 $0 $0 $0 )
#r3_util_timeline.r3 'name 'words 'calls 'info
^r3/util/ttext.r3
#name "r3/util/ttext.r3"
#words  "advx" "advy" "trgb" "tpal" "tcol" "tfbox" "tbox" "temit" "tprint" "temits" "tat" "tatx" "txy" "tx" "tcx" "tcy" "tcr" "tsp" "tnsp" "tsbox" "tpos" "trect" "tcursor" "tcursori" "tsize" "tsrcsize" "tfnt" "tini" 0
#calls  'advx 'advy 'trgb 'tpal 'tcol 'tfbox 'tbox 'temit 'tprint 'temits 'tat 'tatx 'txy 'tx 'tcx 'tcy 'tcr 'tsp 'tnsp 'tsbox 'tpos 'trect 'tcursor 'tcursori 'tsize 'tsrcsize 'tfnt 'tini
#info ( $80 $80 $1F $10 $1F $0 $0 $1F $1F $1F $2E $1F $2E $1F $1 $1 $0 $0 $1F $2 $2 $4 $1F $1F $1F $40 $4C $0 )
#r3_util_ttext.r3 'name 'words 'calls 'info
^r3/util/ttfont.r3
#name "r3/util/ttfont.r3"
#words  "ttx" "tty" "ttcolor" "ttfont!" "ttprint" "ttemits" "ttat" "+ttat" "ttsize" "ttcursor" "ttcursori" "ttrect" 0
#calls  'ttx 'tty 'ttcolor 'ttfont! 'ttprint 'ttemits 'ttat '+ttat 'ttsize 'ttcursor 'ttcursori 'ttrect
#info ( $80 $80 $1F $1F $1F $1F $2E $2E $12 $2F $2F $4 )
#r3_util_ttfont.r3 'name 'words 'calls 'info
^r3/util/txfont.r3
#name "r3/util/txfont.r3"
#words  "txloadwicon" "txload" "txfont" "txfont@" "txrgb" "txcw" "txw" "txch" "txh" "txat" "tx+at" "txpos" "txemit" "txwrite" "txemitr" "txprint" "txprintr" "txcur" "txcuri" "lwrite" "cwrite" "rwrite" "txalign" "txText" 0
#calls  'txloadwicon 'txload 'txfont 'txfont@ 'txrgb 'txcw 'txw 'txch 'txh 'txat 'tx+at 'txpos 'txemit 'txwrite 'txemitr 'txprint 'txprintr 'txcur 'txcuri 'lwrite 'cwrite 'rwrite 'txalign 'txText
#info ( $2F $2F $1F $1 $1F $10 $11 $10 $1 $2E $2E $2 $1F $1F $1F $1F $1F $2E $2E $2E $2E $2E $1F $4C )
#r3_util_txfont.r3 'name 'words 'calls 'info
^r3/util/ui.r3
#name "r3/util/ui.r3"
#words  "cifil" "cifoc" "stDang" "stWarn" "stSucc" "stInfo" "stLink" "stDark" "stLigt" "overfil" "oversel" "stFDang" "stFWarn" "stFSucc" "stFInfo" "stFLink" "stFDark" "stFWhit" "stfLigt" "curx" "cury" "uiExitWidget" "uiPush" "uiPop" "uiPushA" "uiPopA" "ttemitl" "ttemitc" "ttemitr" "uiLabelMini" "uiRectW" "uiFillW" "uiRRectW" "uiRFillW" "uiCRectW" "uiCFillW" "uiRRect10" "uiRFill10" "uiRect" "uiFill" "uiRRect" "uiRFill" "uiCRect" "uiCFill" "uiTitleF" "uiTitle" "uiLineH" "uiLineV" "uiLineWH" "uiGridBV" "uiGridBH" "uiGrid#" "uicr" "uidn" "uiri" "uiH" "uiV" "ui<" "ui>>" "ui.." "uiPad" "uiWinBox!" "uiWin!" "uiWinFit!" "uiWin@" "uiGAt" "uiGTo" "uiGrid" "uiGridA" "uiStart" "uiZone!" "uiZone" "uiZone@" "uiLabel" "uiLabelc" "uiLabelr" "uiTlabel" "uiMDText" "uiBtn" "uiRBtn" "uiCBtn" "uiTBtn" "uiNindx" "uiCheck" "uiRadio" "uiTab" "uiSliderf" "uiSlideri" "uiProgressf" "uiProgressi" "uiVSliderf" "uiVSlideri" "uiVProgressf" "uiVProgressi" "uiSlideri8" "uiVSlideri8" "guiNextlist" "GuiBoxlist" "sdlBoxListY" "uiList" "uiListV" "uisaveLast" "uiCombo" "UIGridBtn" "uiTree" "uiTable" "uiInputLine" "uiText" "uiEdit" "uiEnd" 0
#calls  'cifil 'cifoc 'stDang 'stWarn 'stSucc 'stInfo 'stLink 'stDark 'stLigt 'overfil 'oversel 'stFDang 'stFWarn 'stFSucc 'stFInfo 'stFLink 'stFDark 'stFWhit 'stfLigt 'curx 'cury 'uiExitWidget 'uiPush 'uiPop 'uiPushA 'uiPopA 'ttemitl 'ttemitc 'ttemitr 'uiLabelMini 'uiRectW 'uiFillW 'uiRRectW 'uiRFillW 'uiCRectW 'uiCFillW 'uiRRect10 'uiRFill10 'uiRect 'uiFill 'uiRRect 'uiRFill 'uiCRect 'uiCFill 'uiTitleF 'uiTitle 'uiLineH 'uiLineV 'uiLineWH 'uiGridBV 'uiGridBH 'uiGrid# 'uicr 'uidn 'uiri 'uiH 'uiV 'ui< 'ui>> 'ui.. 'uiPad 'uiWinBox! 'uiWin! 'uiWinFit! 'uiWin@ 'uiGAt 'uiGTo 'uiGrid 'uiGridA 'uiStart 'uiZone! 'uiZone 'uiZone@ 'uiLabel 'uiLabelc 'uiLabelr 'uiTlabel 'uiMDText 'uiBtn 'uiRBtn 'uiCBtn 'uiTBtn 'uiNindx 'uiCheck 'uiRadio 'uiTab 'uiSliderf 'uiSlideri 'uiProgressf 'uiProgressi 'uiVSliderf 'uiVSlideri 'uiVProgressf 'uiVProgressi 'uiSlideri8 'uiVSlideri8 'guiNextlist 'GuiBoxlist 'sdlBoxListY 'uiList 'uiListV 'uisaveLast 'uiCombo 'UIGridBtn 'uiTree 'uiTable 'uiInputLine 'uiText 'uiEdit 'uiEnd
#info ( $80 $80 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $80 $80 $0 $0 $0 $0 $0 $1F $1F $1F $1F $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $1F $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $2E $4C $4C $4C $4 $2E $2E $2E $2E $0 $4C $0 $4 $1F $1F $1F $1F $0 $2E $2E $2E $2E $10 $2E $2E $2E $3D $3D $3D $3D $3D $3D $3D $3D $3D $3D $0 $1F $1 $3D $0 $1F $2E $2F $3D $0 $2E $0 $0 $0 )
#r3_util_ui.r3 'name 'words 'calls 'info
^r3/util/uicolor.r3
#name "r3/util/uicolor.r3"
#words  "color!" "uiColor" "uiColorH" 0
#calls  'color! 'uiColor 'uiColorH
#info ( $1F $1F $1F )
#r3_util_uicolor.r3 'name 'words 'calls 'info
^r3/util/uidatetime.r3
#name "r3/util/uidatetime.r3"
#words  "uiDateTime" "uiDate" "uiTime" 0
#calls  'uiDateTime 'uiDate 'uiTime
#info ( $1F $1F $1F )
#r3_util_uidatetime.r3 'name 'words 'calls 'info
^r3/util/uiedit.r3
#name "r3/util/uiedit.r3"
#words  "ycursor" "xcursor" "edfilename" "inisel" "finsel" "fuente" "fuente>" "edcodedraw" "edfill" "edtoolbar" "edfocus" "edfocusro" "clearmark" "addmark" "addsrcmark" "showmark" "edram" "edwin" "edload" "edsave" 0
#calls  'ycursor 'xcursor 'edfilename 'inisel 'finsel 'fuente 'fuente> 'edcodedraw 'edfill 'edtoolbar 'edfocus 'edfocusro 'clearmark 'addmark 'addsrcmark 'showmark 'edram 'edwin 'edload 'edsave
#info ( $80 $80 $80 $80 $80 $80 $80 $0 $0 $0 $0 $0 $0 $1F $2E $0 $0 $4C $1F $0 )
#r3_util_uiedit.r3 'name 'words 'calls 'info
^r3/util/uifiledlg.r3
#name "r3/util/uifiledlg.r3"
#words  "immfileload" "immfilesave" "fullfilename" "uiFileName" 0
#calls  'immfileload 'immfilesave 'fullfilename 'uiFileName
#info ( $1F $1F $1 $1F )
#r3_util_uifiledlg.r3 'name 'words 'calls 'info
^r3/util/uifiles.r3
#name "r3/util/uifiles.r3"
#words  "uiDirs" "uiFiles" "uiTreePath" "uiGetFiles" "uiScanDir" 0
#calls  'uiDirs 'uiFiles 'uiTreePath 'uiGetFiles 'uiScanDir
#info ( $80 $80 $10 $1F $1F )
#r3_util_uifiles.r3 'name 'words 'calls 'info
^r3/util/varanim.r3
#name "r3/util/varanim.r3"
#words  "deltatime" "timeline" "timeline<" "timeline>" "exevar" "vareset" "vaini" "vupdate" "+vanim" "+vboxanim" "+vxyanim" "+vcolanim" "+vexe" "+vvexe" "+vvvexe" "64xy" "64wh" "64xywh" "xywh64" "64xyrz" "xyrz64" "64box" "32xy" "xy32" "vaempty" 0
#calls  'deltatime 'timeline 'timeline< 'timeline> 'exevar 'vareset 'vaini 'vupdate '+vanim '+vboxanim '+vxyanim '+vcolanim '+vexe '+vvexe '+vvvexe '64xy '64wh '64xywh 'xywh64 '64xyrz 'xyrz64 '64box '32xy 'xy32 'vaempty
#info ( $80 $80 $80 $80 $80 $0 $1F $0 $6A $6A $6A $6A $2E $3D $4C $11 $11 $13 $4D $13 $4D $2E $11 $2F $1 )
#r3_util_varanim.r3 'name 'words 'calls 'info
^r3/util/vscreen.r3
#name "r3/util/vscreen.r3"
#words  "vscreen" "vini" "vredraw" "vfree" "sdlx" "sdly" "%w" "%h" 0
#calls  'vscreen 'vini 'vredraw 'vfree 'sdlx 'sdly '%w '%h
#info ( $2E $0 $0 $0 $1 $1 $10 $10 )
#r3_util_vscreen.r3 'name 'words 'calls 'info
^r3/lib/win/conkey.r3
#name "r3/lib/win/conkey.r3"
#words  "[ESC]" "]ESC[" "[ENTER]" "[BACK]" "]BACK[" "[TAB]" "]TAB[" "[DEL]" "[UP]" "[DN]" "[RI]" "[LE]" "[PGUP]" "[PGDN]" "[HOME]" "[END]" "[INS]" "[CTRL]" "]CTRL[" "[ALT]" "[SHIFTR]" "]SHIFTR[" "[SHIFTL]" "]SHIFTL[" "[F1]" "[F2]" "[F3]" "[F4]" "[F5]" "[F6]" "[F7]" "[F8]" "[F9]" "[F10]" "[F11]" "[F12]" "k2ascii" 0
#calls  '[ESC] ']ESC[ '[ENTER] '[BACK] ']BACK[ '[TAB] ']TAB[ '[DEL] '[UP] '[DN] '[RI] '[LE] '[PGUP] '[PGDN] '[HOME] '[END] '[INS] '[CTRL] ']CTRL[ '[ALT] '[SHIFTR] ']SHIFTR[ '[SHIFTL] ']SHIFTL[ '[F1] '[F2] '[F3] '[F4] '[F5] '[F6] '[F7] '[F8] '[F9] '[F10] '[F11] '[F12] 'k2ascii
#info ( $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $80 $10 )
#r3_lib_win_conkey.r3 'name 'words 'calls 'info
^r3/lib/win/console.r3
#name "r3/lib/win/console.r3"
#words  "stdin" "stdout" "stderr" "type" ".cr" ".sp" ".nsp" ".emit" ".[" ".write" ".print" ".println" ".home" ".cls" ".at" ".eline" ".fc" ".bc" ".Black" ".Red" ".Green" ".Yellow" ".Blue" ".Magenta" ".Cyan" ".White" ".Blackl" ".Redl" ".Greenl" ".Yellowl" ".Bluel" ".Magental" ".Cyanl" ".Whitel" ".BBlack" ".BRed" ".BGreen" ".BYellow" ".BBlue" ".BMagenta" ".BCyan" ".BWhite" ".BBlackl" ".BRedl" ".BGreenl" ".BYellowl" ".BBluel" ".BMagental" ".BCyanl" ".BWhitel" ".Bold" ".Under" ".Rever" ".Reset" ".alsb" ".masb" ".showc" ".hidec" ".ovec" ".insc" "consoleinfo" "rows" "cols" ".getconsoleinfo" "getch" "inkey" "waitesc" "evtkey" "evtmxy" "evtmb" "evtmw" "evtm" "getevt" "inevt" "pad" "getcursorpos" ".input" ".inputn" ".printe" "evtmouse" ".free" 0
#calls  'stdin 'stdout 'stderr 'type '.cr '.sp '.nsp '.emit '.[ '.write '.print '.println '.home '.cls '.at '.eline '.fc '.bc '.Black '.Red '.Green '.Yellow '.Blue '.Magenta '.Cyan '.White '.Blackl '.Redl '.Greenl '.Yellowl '.Bluel '.Magental '.Cyanl '.Whitel '.BBlack '.BRed '.BGreen '.BYellow '.BBlue '.BMagenta '.BCyan '.BWhite '.BBlackl '.BRedl '.BGreenl '.BYellowl '.BBluel '.BMagental '.BCyanl '.BWhitel '.Bold '.Under '.Rever '.Reset '.alsb '.masb '.showc '.hidec '.ovec '.insc 'consoleinfo 'rows 'cols '.getconsoleinfo 'getch 'inkey 'waitesc 'evtkey 'evtmxy 'evtmb 'evtmw 'evtm 'getevt 'inevt 'pad 'getcursorpos '.input '.inputn '.printe 'evtmouse '.free
#info ( $80 $80 $80 $2E $0 $0 $1F $1F $1F $1F $1F $1F $0 $0 $2E $0 $1F $1F $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $80 $80 $80 $0 $1 $1 $0 $1 $2 $1 $1 $1 $1 $1 $80 $2 $0 $1 $1F $0 $0 )
#r3_lib_win_console.r3 'name 'words 'calls 'info
^r3/lib/win/core.r3
#name "r3/lib/win/core.r3"
#words  "ms" "msec" "time" "date" "sysdate" "findata" "ffirst" "fnext" "FNAME" "FDIR" "FSIZE" "FSIZEF" "filetimeD" "FCREADT" "FLASTDT" "FWRITEDT" "date.d" "time.ms" "date.dw" "time.s" "date.m" "time.m" "date.y" "time.h" "load" "save" "append" "delete" "filexist" "fileisize" "fileijul" "fileinfo" "filecreatetime" "filelastactime" "filelastwrtime" "sinfo" "pinfo" "sys" "sysnew" "sysdebug" 0
#calls  'ms 'msec 'time 'date 'sysdate 'findata 'ffirst 'fnext 'FNAME 'FDIR 'FSIZE 'FSIZEF 'filetimeD 'FCREADT 'FLASTDT 'FWRITEDT 'date.d 'time.ms 'date.dw 'time.s 'date.m 'time.m 'date.y 'time.h 'load 'save 'append 'delete 'filexist 'fileisize 'fileijul 'fileinfo 'filecreatetime 'filelastactime 'filelastwrtime 'sinfo 'pinfo 'sys 'sysnew 'sysdebug
#info ( $1F $1 $1 $1 $1 $1 $10 $1 $10 $10 $10 $10 $10 $10 $10 $10 $0 $10 $0 $10 $0 $10 $0 $10 $2F $3D $3D $1F $10 $1 $1 $0 $1 $1 $1 $80 $80 $10 $10 $1F )
#r3_lib_win_core.r3 'name 'words 'calls 'info
^r3/lib/win/debugapi.r3
#name "r3/lib/win/debugapi.r3"
#words  "IsDebuggerPresent" "OutputDebugStringA" "OutputDebugStringW" "DebugBreak" "ContinueDebugEvent" "WaitForDebugEvent" "DebugActiveProcess" "DebugActiveProcessStop" "CheckRemoteDebuggerPresent" 0
#calls  'IsDebuggerPresent 'OutputDebugStringA 'OutputDebugStringW 'DebugBreak 'ContinueDebugEvent 'WaitForDebugEvent 'DebugActiveProcess 'DebugActiveProcessStop 'CheckRemoteDebuggerPresent
#info ( $1 $1F $1F $0 $3E $2F $10 $10 $2F )
#r3_lib_win_debugapi.r3 'name 'words 'calls 'info
^r3/lib/win/ffm.r3
#name "r3/lib/win/ffm.r3"
#words  "FFM_init" "FFM_open" "FFM_redraw" "FFM_resize" "FFM_close" 0
#calls  'FFM_init 'FFM_open 'FFM_redraw 'FFM_resize 'FFM_close
#info ( $0 $3D $10 $2F $0 )
#r3_lib_win_ffm.r3 'name 'words 'calls 'info
^r3/lib/win/ffmapi.r3
#name "r3/lib/win/ffmapi.r3"
#words  "IniVideo" "LoadVideo" "VideoBox" "VideoPoly" "VideoFlag" "VideoTex" "PlayVideo" "StopVideo" "LOADING" "VID_NO_AUDIO" "VID_LOOP" "VID_WAIT" "VideoTime" "VideoSize" "vshow" "vshowZ" "vshowR" "vshowRZ" "FFM_open" "FFM_redraw" "FFM_close" 0
#calls  'IniVideo 'LoadVideo 'VideoBox 'VideoPoly 'VideoFlag 'VideoTex 'PlayVideo 'StopVideo 'LOADING 'VID_NO_AUDIO 'VID_LOOP 'VID_WAIT 'VideoTime 'VideoSize 'vshow 'vshowZ 'vshowR 'vshowRZ 'FFM_open 'FFM_redraw 'FFM_close
#info ( $1F $2F $2E $5B $10 $10 $1F $1F $80 $80 $80 $80 $10 $11 $3D $4C $4C $3D $10 $1 $0 )
#r3_lib_win_ffmapi.r3 'name 'words 'calls 'info
^r3/lib/win/inet.r3
#name "r3/lib/win/inet.r3"
#words  "InternetOpen" "InternetOpenUrl" "InternetReadFile" "InternetCloseHandle" "DeleteUrlCacheEntry" "openurl" 0
#calls  'InternetOpen 'InternetOpenUrl 'InternetReadFile 'InternetCloseHandle 'DeleteUrlCacheEntry 'openurl
#info ( $5C $6B $4C $1F $1F $3E )
#r3_lib_win_inet.r3 'name 'words 'calls 'info
^r3/lib/win/kernel32.r3
#name "r3/lib/win/kernel32.r3"
#words  "AllocConsole" "FreeConsole" "ExitProcess" "GetStdHandle" "SetStdHandle" "ReadFile" "WriteFile" "GetConsoleMode" "SetConsoleMode" "SetConsoleTitle" "PeekConsoleInput" "PeekNamedPipe" "ReadConsoleInput" "WriteConsole" "ReadConsole" "WriteConsoleOutput" "GetNumberOfConsoleInputEvents" "FlushConsoleInputBuffer" "Sleep" "WaitForSingleObject" "GetLastError" "CreateFile" "CreateDirectory" "CloseHandle" "FlushFileBuffers" "DeleteFile" "RemoveDirectory" "MoveFile" "SetFilePointer" "SetEndOfFile" "GetFileAttributes" "GetFileAttributesEx" "GetFileSize" "FileTimeToSystemTime" "SystemTimeToTzSpecificLocalTime" "GetProcessHeap" "HeapAlloc" "HeapFree" "HeapReAlloc" "GetTickCount" "GetLocalTime" "FindFirstFile" "FindNextFile" "FindClose" "CreateProcess" "GetConsoleScreenBufferInfo" "SetConsoleScreenBufferSize" "SetConsoleWindowInfo" "GetCommandLine" "GetConsoleWindow" "SetDllDirectory" "SetCurrentDirectory" "GetCurrentDirectory" "SetConsoleOutputCP" "SetConsoleCP" 0
#calls  'AllocConsole 'FreeConsole 'ExitProcess 'GetStdHandle 'SetStdHandle 'ReadFile 'WriteFile 'GetConsoleMode 'SetConsoleMode 'SetConsoleTitle 'PeekConsoleInput 'PeekNamedPipe 'ReadConsoleInput 'WriteConsole 'ReadConsole 'WriteConsoleOutput 'GetNumberOfConsoleInputEvents 'FlushConsoleInputBuffer 'Sleep 'WaitForSingleObject 'GetLastError 'CreateFile 'CreateDirectory 'CloseHandle 'FlushFileBuffers 'DeleteFile 'RemoveDirectory 'MoveFile 'SetFilePointer 'SetEndOfFile 'GetFileAttributes 'GetFileAttributesEx 'GetFileSize 'FileTimeToSystemTime 'SystemTimeToTzSpecificLocalTime 'GetProcessHeap 'HeapAlloc 'HeapFree 'HeapReAlloc 'GetTickCount 'GetLocalTime 'FindFirstFile 'FindNextFile 'FindClose 'CreateProcess 'GetConsoleScreenBufferInfo 'SetConsoleScreenBufferSize 'SetConsoleWindowInfo 'GetCommandLine 'GetConsoleWindow 'SetDllDirectory 'SetCurrentDirectory 'GetCurrentDirectory 'SetConsoleOutputCP 'SetConsoleCP
#info ( $0 $0 $10 $10 $2E $5C $5C $2F $2F $1F $4C $6A $4C $5B $5B $5B $2E $1F $1F $2F $1 $7A $2F $1F $10 $10 $10 $2F $4D $10 $10 $3E $2F $2E $3D $1 $3D $3D $4C $1 $1F $2F $2F $1F $27 $2F $2E $3D $1 $1 $1F $1F $2E $1F $1F )
#r3_lib_win_kernel32.r3 'name 'words 'calls 'info
^r3/lib/win/urlmon.r3
#name "r3/lib/win/urlmon.r3"
#words  "URLDownloadToFile" "URLOpenBlockingStreamA" "url2file" "url2filec" 0
#calls  'URLDownloadToFile 'URLOpenBlockingStreamA 'url2file 'url2filec
#info ( $5C $5C $2F $2F )
#r3_lib_win_urlmon.r3 'name 'words 'calls 'info
^r3/lib/win/win-term.r3
#name "r3/lib/win/win-term.r3"
#words  "stdin" "stdout" "stderr" "type" "rows" "cols" ".onresize" "evtkey" "inevt" "getevt" "inkey" "getch" "evtmxy" "evtmb" "evtmw" "evtm" ".free" ".reterm" 0
#calls  'stdin 'stdout 'stderr 'type 'rows 'cols '.onresize 'evtkey 'inevt 'getevt 'inkey 'getch 'evtmxy 'evtmb 'evtmw 'evtm '.free '.reterm
#info ( $80 $80 $80 $2E $80 $80 $1F $1 $1 $1 $1 $1 $2 $1 $1 $1 $1F $0 )
#r3_lib_win_win-term.r3 'name 'words 'calls 'info
^r3/lib/win/winhttp.r3
#name "r3/lib/win/winhttp.r3"
#words  "WinHttpOpen" "WinHttpConnect" "WinHttpOpenRequest" "WinHttpSendRequest" "WinHttpReceiveResponse" "WinHttpQueryDataAvailable" "WinHttpReadData" "WinHttpCloseHandle" "loadurl" 0
#calls  'WinHttpOpen 'WinHttpConnect 'WinHttpOpenRequest 'WinHttpSendRequest 'WinHttpReceiveResponse 'WinHttpQueryDataAvailable 'WinHttpReadData 'WinHttpCloseHandle 'loadurl
#info ( $5C $4D $7A $7A $2F $2F $4D $1F $2F )
#r3_lib_win_winhttp.r3 'name 'words 'calls 'info
^r3/lib/win/winsock.r3
#name "r3/lib/win/winsock.r3"
#words  "WSAStartup" "WSACleanup" "accept" "select" "socket" "bind" "listen" "closesocket" "shutdown" "send" "recv" "getaddrinfo" "ioctlsocket" 0
#calls  'WSAStartup 'WSACleanup 'accept 'select 'socket 'bind 'listen 'closesocket 'shutdown 'send 'recv 'getaddrinfo 'ioctlsocket
#info ( $2F $0 $3E $5C $3E $3E $2F $1F $2F $4C $4D $4D $3E )
#r3_lib_win_winsock.r3 'name 'words 'calls 'info

##liblist 'r3_lib_3d.r3 'r3_lib_3dgl.r3 'r3_lib_base64.r3 'r3_lib_color.r3 'r3_lib_console.r3 'r3_lib_crc32.r3 'r3_lib_escapi.r3 'r3_lib_espeak-ng.r3 'r3_lib_gui.r3 'r3_lib_input.r3 'r3_lib_isospr.r3 'r3_lib_jul.r3 'r3_lib_math.r3 'r3_lib_mconsole.r3 'r3_lib_mem.r3 'r3_lib_memavx.r3 'r3_lib_onnx.r3 'r3_lib_parse.r3 'r3_lib_rand.r3 'r3_lib_sdl2.r3 'r3_lib_sdl2gfx.r3 'r3_lib_sdl2gl.r3 'r3_lib_sdl2image.r3 'r3_lib_sdl2mixer.r3 'r3_lib_sdl2net.r3 'r3_lib_sdl2poly.r3 'r3_lib_sdl2ttf.r3 'r3_lib_sdlkeys.r3 'r3_lib_str.r3 'r3_lib_term.r3 'r3_lib_tflite.r3 'r3_lib_trace.r3 'r3_lib_vdraw.r3 'r3_lib_vec2.r3 'r3_lib_vec3.r3 'r3_util_arr16.r3 'r3_util_arr8.r3 'r3_util_bfont.r3 'r3_util_blist.r3 'r3_util_bmap.r3 'r3_util_boxtext.r3 'r3_util_datetime.r3 'r3_util_db2.r3 'r3_util_dbtxt.r3 'r3_util_dlgcol.r3 'r3_util_dlgfile.r3 'r3_util_dlist.r3 'r3_util_float_table.r3 'r3_util_hash2d.r3 'r3_util_heap.r3 'r3_util_loadobj.r3 'r3_util_pcfont.r3 'r3_util_penner.r3 'r3_util_sdlbgui.r3 'r3_util_sdlfiledlg.r3 'r3_util_sdlgui.r3 'r3_util_sort.r3 'r3_util_sortradix.r3 'r3_util_sortradixm.r3 'r3_util_textb.r3 'r3_util_tilesheet.r3 'r3_util_timeline.r3 'r3_util_ttext.r3 'r3_util_ttfont.r3 'r3_util_txfont.r3 'r3_util_ui.r3 'r3_util_uicolor.r3 'r3_util_uidatetime.r3 'r3_util_uiedit.r3 'r3_util_uifiledlg.r3 'r3_util_uifiles.r3 'r3_util_varanim.r3 'r3_util_vscreen.r3 'r3_lib_win_conkey.r3 'r3_lib_win_console.r3 'r3_lib_win_core.r3 'r3_lib_win_debugapi.r3 'r3_lib_win_ffm.r3 'r3_lib_win_ffmapi.r3 'r3_lib_win_inet.r3 'r3_lib_win_kernel32.r3 'r3_lib_win_urlmon.r3 'r3_lib_win_win-term.r3 'r3_lib_win_winhttp.r3 'r3_lib_win_winsock.r3 0
