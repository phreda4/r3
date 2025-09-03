| onnx 
| PHREDA 2025

^r3/lib/win/kernel32.r3

#ortGetApiBase_p 0

#ortSess_CPU_p 0
#ortSess_MDL_p 0
#ortSess_tensorrt_p 0

::ortSess_CPU ortSess_CPU_p sys2 ;  | OrtStatus* OrtSess..._CPU(OrtSessionOptions*, int)
::ortSess_MDL ortSess_MDL_p sys2 ;  | OrtStatus* OrtSess..._CPU(OrtSessionOptions*, int)

#getVersionString_p
::OrtgetVersionString getVersionString_p sys0 ;

#CreateStatus_p  ::OrtCreateStatus CreateStatus_p sys2 ;
#GetErrorCode_p  ::OrtGetErrorCode GetErrorCode_p sys1 ;
#GetErrorMessage_p  ::OrtGetErrorMessage GetErrorMessage_p sys1 ;
#CreateEnv_p  ::OrtCreateEnv CreateEnv_p sys3 ;
#CreateEnvWithCustomLogger_p  ::OrtCreateEnvWithCustomLogger CreateEnvWithCustomLogger_p sys5 ;
#EnableTelemetryEvents_p  ::OrtEnableTelemetryEvents EnableTelemetryEvents_p sys1 ;
#DisableTelemetryEvents_p  ::OrtDisableTelemetryEvents DisableTelemetryEvents_p sys1 ;
#CreateSession_p  ::OrtCreateSession CreateSession_p sys4 ;
#CreateSessionFromArray_p  ::OrtCreateSessionFromArray CreateSessionFromArray_p sys5 ;
#Run_p  ::OrtRun Run_p sys8 ;
#CreateSessionOptions_p  ::OrtCreateSessionOptions CreateSessionOptions_p sys1 ;
#SetOptimizedModelFilePath_p  ::OrtSetOptimizedModelFilePath SetOptimizedModelFilePath_p sys2 ;
#CloneSessionOptions_p  ::OrtCloneSessionOptions CloneSessionOptions_p sys2 ;
#SetSessionExecutionMode_p  ::OrtSetSessionExecutionMode SetSessionExecutionMode_p sys2 ;
#EnableProfiling_p  ::OrtEnableProfiling EnableProfiling_p sys2 ;
#DisableProfiling_p  ::OrtDisableProfiling DisableProfiling_p sys1 ;
#EnableMemPattern_p  ::OrtEnableMemPattern EnableMemPattern_p sys1 ;
#DisableMemPattern_p  ::OrtDisableMemPattern DisableMemPattern_p sys1 ;
#EnableCpuMemArena_p  ::OrtEnableCpuMemArena EnableCpuMemArena_p sys1 ;
#DisableCpuMemArena_p  ::OrtDisableCpuMemArena DisableCpuMemArena_p sys1 ;
#SetSessionLogId_p  ::OrtSetSessionLogId SetSessionLogId_p sys2 ;
#SetSessionLogVerbosityLevel_p  ::OrtSetSessionLogVerbosityLevel SetSessionLogVerbosityLevel_p sys2 ;
#SetSessionLogSeverityLevel_p  ::OrtSetSessionLogSeverityLevel SetSessionLogSeverityLevel_p sys2 ;
#SetSessionGraphOptimizationLevel_p  ::OrtSetSessionGraphOptimizationLevel SetSessionGraphOptimizationLevel_p sys2 ;
#SetIntraOpNumThreads_p  ::OrtSetIntraOpNumThreads SetIntraOpNumThreads_p sys2 ;
#SetInterOpNumThreads_p  ::OrtSetInterOpNumThreads SetInterOpNumThreads_p sys2 ;
#CreateCustomOpDomain_p  ::OrtCreateCustomOpDomain CreateCustomOpDomain_p sys2 ;
#CustomOpDomain_Add_p  ::OrtCustomOpDomain_Add CustomOpDomain_Add_p sys2 ;
#AddCustomOpDomain_p  ::OrtAddCustomOpDomain AddCustomOpDomain_p sys2 ;
#RegisterCustomOpsLibrary_p  ::OrtRegisterCustomOpsLibrary RegisterCustomOpsLibrary_p sys3 ;
#SessionGetInputCount_p  ::OrtSessionGetInputCount SessionGetInputCount_p sys2 ;
#SessionGetOutputCount_p  ::OrtSessionGetOutputCount SessionGetOutputCount_p sys2 ;
#SessionGetOverridableInitializerCount_p  ::OrtSessionGetOverridableInitializerCount SessionGetOverridableInitializerCount_p sys2 ;
#SessionGetInputTypeInfo_p  ::OrtSessionGetInputTypeInfo SessionGetInputTypeInfo_p sys3 ;
#SessionGetOutputTypeInfo_p  ::OrtSessionGetOutputTypeInfo SessionGetOutputTypeInfo_p sys3 ;
#SessionGetOverridableInitializerTypeInfo_p  ::OrtSessionGetOverridableInitializerTypeInfo SessionGetOverridableInitializerTypeInfo_p sys3 ;
#SessionGetInputName_p  ::OrtSessionGetInputName SessionGetInputName_p sys4 ;
#SessionGetOutputName_p  ::OrtSessionGetOutputName SessionGetOutputName_p sys4 ;
#SessionGetOverridableInitializerName_p  ::OrtSessionGetOverridableInitializerName SessionGetOverridableInitializerName_p sys4 ;
#CreateRunOptions_p  ::OrtCreateRunOptions CreateRunOptions_p sys1 ;
#RunOptionsSetRunLogVerbosityLevel_p  ::OrtRunOptionsSetRunLogVerbosityLevel RunOptionsSetRunLogVerbosityLevel_p sys2 ;
#RunOptionsSetRunLogSeverityLevel_p  ::OrtRunOptionsSetRunLogSeverityLevel RunOptionsSetRunLogSeverityLevel_p sys2 ;
#RunOptionsSetRunTag_p  ::OrtRunOptionsSetRunTag RunOptionsSetRunTag_p sys2 ;
#RunOptionsGetRunLogVerbosityLevel_p  ::OrtRunOptionsGetRunLogVerbosityLevel RunOptionsGetRunLogVerbosityLevel_p sys2 ;
#RunOptionsGetRunLogSeverityLevel_p  ::OrtRunOptionsGetRunLogSeverityLevel RunOptionsGetRunLogSeverityLevel_p sys2 ;
#RunOptionsGetRunTag_p  ::OrtRunOptionsGetRunTag RunOptionsGetRunTag_p sys2 ;
#RunOptionsSetTerminate_p  ::OrtRunOptionsSetTerminate RunOptionsSetTerminate_p sys1 ;
#RunOptionsUnsetTerminate_p  ::OrtRunOptionsUnsetTerminate RunOptionsUnsetTerminate_p sys1 ;
#CreateTensorAsOrtValue_p  ::OrtCreateTensorAsOrtValue CreateTensorAsOrtValue_p sys6 ;
#CreateTensorWithDataAsOrtValue_p  ::OrtCreateTensorWithDataAsOrtValue CreateTensorWithDataAsOrtValue_p sys7 ;
#IsTensor_p  ::OrtIsTensor IsTensor_p sys2 ;
#GetTensorMutableData_p  ::OrtGetTensorMutableData GetTensorMutableData_p sys2 ;
#FillStringTensor_p  ::OrtFillStringTensor FillStringTensor_p sys3 ;
#GetStringTensorDataLength_p  ::OrtGetStringTensorDataLength GetStringTensorDataLength_p sys2 ;
#GetStringTensorContent_p  ::OrtGetStringTensorContent GetStringTensorContent_p sys5 ;
#CastTypeInfoToTensorInfo_p  ::OrtCastTypeInfoToTensorInfo CastTypeInfoToTensorInfo_p sys2 ;
#GetOnnxTypeFromTypeInfo_p  ::OrtGetOnnxTypeFromTypeInfo GetOnnxTypeFromTypeInfo_p sys2 ;
#CreateTensorTypeAndShapeInfo_p  ::OrtCreateTensorTypeAndShapeInfo CreateTensorTypeAndShapeInfo_p sys1 ;
#SetTensorElementType_p  ::OrtSetTensorElementType SetTensorElementType_p sys2 ;
#SetDimensions_p  ::OrtSetDimensions SetDimensions_p sys3 ;
#GetTensorElementType_p  ::OrtGetTensorElementType GetTensorElementType_p sys2 ;
#GetDimensionsCount_p  ::OrtGetDimensionsCount GetDimensionsCount_p sys2 ;
#GetDimensions_p  ::OrtGetDimensions GetDimensions_p sys3 ;
#GetSymbolicDimensions_p  ::OrtGetSymbolicDimensions GetSymbolicDimensions_p sys3 ;
#GetTensorShapeElementCount_p  ::OrtGetTensorShapeElementCount GetTensorShapeElementCount_p sys2 ;
#GetTensorTypeAndShape_p  ::OrtGetTensorTypeAndShape GetTensorTypeAndShape_p sys2 ;
#GetTypeInfo_p  ::OrtGetTypeInfo GetTypeInfo_p sys2 ;
#GetValueType_p  ::OrtGetValueType GetValueType_p sys2 ;
#CreateMemoryInfo_p  ::OrtCreateMemoryInfo CreateMemoryInfo_p sys5 ;
#CreateCpuMemoryInfo_p  ::OrtCreateCpuMemoryInfo CreateCpuMemoryInfo_p sys3 ;
#CompareMemoryInfo_p  ::OrtCompareMemoryInfo CompareMemoryInfo_p sys3 ;
#MemoryInfoGetName_p  ::OrtMemoryInfoGetName MemoryInfoGetName_p sys2 ;
#MemoryInfoGetId_p  ::OrtMemoryInfoGetId MemoryInfoGetId_p sys2 ;
#MemoryInfoGetMemType_p  ::OrtMemoryInfoGetMemType MemoryInfoGetMemType_p sys2 ;
#MemoryInfoGetType_p  ::OrtMemoryInfoGetType MemoryInfoGetType_p sys2 ;
#AllocatorAlloc_p  ::OrtAllocatorAlloc AllocatorAlloc_p sys3 ;
#AllocatorFree_p  ::OrtAllocatorFree AllocatorFree_p sys2 ;
#AllocatorGetInfo_p  ::OrtAllocatorGetInfo AllocatorGetInfo_p sys2 ;
#GetAllocatorWithDefaultOptions_p  ::OrtGetAllocatorWithDefaultOptions GetAllocatorWithDefaultOptions_p sys1 ;
#AddFreeDimensionOverride_p  ::OrtAddFreeDimensionOverride AddFreeDimensionOverride_p sys3 ;
#GetValue_p  ::OrtGetValue GetValue_p sys4 ;
#GetValueCount_p  ::OrtGetValueCount GetValueCount_p sys2 ;
#CreateValue_p  ::OrtCreateValue CreateValue_p sys4 ;
#CreateOpaqueValue_p  ::OrtCreateOpaqueValue CreateOpaqueValue_p sys5 ;
#GetOpaqueValue_p  ::OrtGetOpaqueValue GetOpaqueValue_p sys5 ;
#KernelInfoGetAttribute_float_p  ::OrtKernelInfoGetAttribute_float KernelInfoGetAttribute_float_p sys3 ;
#KernelInfoGetAttribute_int64_p  ::OrtKernelInfoGetAttribute_int64 KernelInfoGetAttribute_int64_p sys3 ;
#KernelInfoGetAttribute_string_p  ::OrtKernelInfoGetAttribute_string KernelInfoGetAttribute_string_p sys4 ;
#KernelContext_GetInputCount_p  ::OrtKernelContext_GetInputCount KernelContext_GetInputCount_p sys2 ;
#KernelContext_GetOutputCount_p  ::OrtKernelContext_GetOutputCount KernelContext_GetOutputCount_p sys2 ;
#KernelContext_GetInput_p  ::OrtKernelContext_GetInput KernelContext_GetInput_p sys3 ;
#KernelContext_GetOutput_p  ::OrtKernelContext_GetOutput KernelContext_GetOutput_p sys5 ;
#ReleaseEnv_p  ::OrtReleaseEnv ReleaseEnv_p sys1 ;
#ReleaseStatus_p  ::OrtReleaseStatus ReleaseStatus_p sys1 ;
#ReleaseMemoryInfo_p  ::OrtReleaseMemoryInfo ReleaseMemoryInfo_p sys1 ;
#ReleaseSession_p  ::OrtReleaseSession ReleaseSession_p sys1 ;
#ReleaseValue_p  ::OrtReleaseValue ReleaseValue_p sys1 ;
#ReleaseRunOptions_p  ::OrtReleaseRunOptions ReleaseRunOptions_p sys1 ;
#ReleaseTypeInfo_p  ::OrtReleaseTypeInfo ReleaseTypeInfo_p sys1 ;
#ReleaseTensorTypeAndShapeInfo_p  ::OrtReleaseTensorTypeAndShapeInfo ReleaseTensorTypeAndShapeInfo_p sys1 ;
#ReleaseSessionOptions_p  ::OrtReleaseSessionOptions ReleaseSessionOptions_p sys1 ;
#ReleaseCustomOpDomain_p  ::OrtReleaseCustomOpDomain ReleaseCustomOpDomain_p sys1 ;
#GetDenotationFromTypeInfo_p  ::OrtGetDenotationFromTypeInfo GetDenotationFromTypeInfo_p sys3 ;
#CastTypeInfoToMapTypeInfo_p  ::OrtCastTypeInfoToMapTypeInfo CastTypeInfoToMapTypeInfo_p sys2 ;
#CastTypeInfoToSequenceTypeInfo_p  ::OrtCastTypeInfoToSequenceTypeInfo CastTypeInfoToSequenceTypeInfo_p sys2 ;
#GetMapKeyType_p  ::OrtGetMapKeyType GetMapKeyType_p sys2 ;
#GetMapValueType_p  ::OrtGetMapValueType GetMapValueType_p sys2 ;
#GetSequenceElementType_p  ::OrtGetSequenceElementType GetSequenceElementType_p sys2 ;
#ReleaseMapTypeInfo_p  ::OrtReleaseMapTypeInfo ReleaseMapTypeInfo_p sys1 ;
#ReleaseSequenceTypeInfo_p  ::OrtReleaseSequenceTypeInfo ReleaseSequenceTypeInfo_p sys1 ;
#SessionEndProfiling_p  ::OrtSessionEndProfiling SessionEndProfiling_p sys3 ;
#SessionGetModelMetadata_p  ::OrtSessionGetModelMetadata SessionGetModelMetadata_p sys2 ;
#ModelMetadataGetProducerName_p  ::OrtModelMetadataGetProducerName ModelMetadataGetProducerName_p sys3 ;
#ModelMetadataGetGraphName_p  ::OrtModelMetadataGetGraphName ModelMetadataGetGraphName_p sys3 ;
#ModelMetadataGetDomain_p  ::OrtModelMetadataGetDomain ModelMetadataGetDomain_p sys3 ;
#ModelMetadataGetDescription_p  ::OrtModelMetadataGetDescription ModelMetadataGetDescription_p sys3 ;
#ModelMetadataLookupCustomMetadataMap_p  ::OrtModelMetadataLookupCustomMetadataMap ModelMetadataLookupCustomMetadataMap_p sys4 ;
#ModelMetadataGetVersion_p  ::OrtModelMetadataGetVersion ModelMetadataGetVersion_p sys2 ;
#CreateEnvWithGlobalThreadPools_p  ::OrtCreateEnvWithGlobalThreadPools CreateEnvWithGlobalThreadPools_p sys4 ;
#DisablePerSessionThreads_p  ::OrtDisablePerSessionThreads DisablePerSessionThreads_p sys1 ;
#CreateThreadingOptions_p  ::OrtCreateThreadingOptions CreateThreadingOptions_p sys1 ;
#SetGlobalIntraOpNumThreads_p  ::OrtSetGlobalIntraOpNumThreads SetGlobalIntraOpNumThreads_p sys2 ;
#SetGlobalInterOpNumThreads_p  ::OrtSetGlobalInterOpNumThreads SetGlobalInterOpNumThreads_p sys2 ;
#SetGlobalSpinControl_p  ::OrtSetGlobalSpinControl SetGlobalSpinControl_p sys2 ;
#ModelMetadataGetCustomMetadataMapKeys_p  ::OrtModelMetadataGetCustomMetadataMapKeys ModelMetadataGetCustomMetadataMapKeys_p sys4 ;
#AddFreeDimensionOverrideByName_p  ::OrtAddFreeDimensionOverrideByName AddFreeDimensionOverrideByName_p sys3 ;
#GetAvailableProviders_p  ::OrtGetAvailableProviders GetAvailableProviders_p sys2 ;
#ReleaseAvailableProviders_p  ::OrtReleaseAvailableProviders ReleaseAvailableProviders_p sys2 ;
#GetStringTensorElementLength_p  ::OrtGetStringTensorElementLength GetStringTensorElementLength_p sys3 ;
#GetStringTensorElement_p  ::OrtGetStringTensorElement GetStringTensorElement_p sys4 ;
#FillStringTensorElement_p  ::OrtFillStringTensorElement FillStringTensorElement_p sys3 ;
#AddSessionConfigEntry_p  ::OrtAddSessionConfigEntry AddSessionConfigEntry_p sys3 ;
#CreateAllocator_p  ::OrtCreateAllocator CreateAllocator_p sys3 ;
#RunWithBinding_p  ::OrtRunWithBinding RunWithBinding_p sys3 ;
#CreateIoBinding_p  ::OrtCreateIoBinding CreateIoBinding_p sys2 ;
#BindInput_p  ::OrtBindInput BindInput_p sys3 ;
#BindOutput_p  ::OrtBindOutput BindOutput_p sys3 ;
#BindOutputToDevice_p  ::OrtBindOutputToDevice BindOutputToDevice_p sys3 ;
#GetBoundOutputNames_p  ::OrtGetBoundOutputNames GetBoundOutputNames_p sys5 ;
#GetBoundOutputValues_p  ::OrtGetBoundOutputValues GetBoundOutputValues_p sys4 ;
#ClearBoundInputs_p  ::OrtClearBoundInputs ClearBoundInputs_p sys1 ;
#ClearBoundOutputs_p  ::OrtClearBoundOutputs ClearBoundOutputs_p sys1 ;
#TensorAt_p  ::OrtTensorAt TensorAt_p sys4 ;
#CreateAndRegisterAllocator_p  ::OrtCreateAndRegisterAllocator CreateAndRegisterAllocator_p sys3 ;
#SetLanguageProjection_p  ::OrtSetLanguageProjection SetLanguageProjection_p sys2 ;
#SessionGetProfilingStartTimeNs_p  ::OrtSessionGetProfilingStartTimeNs SessionGetProfilingStartTimeNs_p sys2 ;
#AddInitializer_p  ::OrtAddInitializer AddInitializer_p sys3 ;
#CreateEnvWithCustomLoggerAndGlobalThreadPools_p  ::OrtCreateEnvWithCustomLoggerAndGlobalThreadPools CreateEnvWithCustomLoggerAndGlobalThreadPools_p sys6 ;
#SessionOptionsAppendExecutionProvider_CUDA_p  ::OrtSessionOptionsAppendExecutionProvider_CUDA SessionOptionsAppendExecutionProvider_CUDA_p sys2 ;
#SessionOptionsAppendExecutionProvider_ROCM_p  ::OrtSessionOptionsAppendExecutionProvider_ROCM SessionOptionsAppendExecutionProvider_ROCM_p sys2 ;
#SessionOptionsAppendExecutionProvider_OpenVINO_p  ::OrtSessionOptionsAppendExecutionProvider_OpenVINO SessionOptionsAppendExecutionProvider_OpenVINO_p sys2 ;
#SetGlobalDenormalAsZero_p  ::OrtSetGlobalDenormalAsZero SetGlobalDenormalAsZero_p sys1 ;
#CreateArenaCfg_p  ::OrtCreateArenaCfg CreateArenaCfg_p sys5 ;
#ModelMetadataGetGraphDescription_p  ::OrtModelMetadataGetGraphDescription ModelMetadataGetGraphDescription_p sys3 ;
#SessionOptionsAppendExecutionProvider_TensorRT_p  ::OrtSessionOptionsAppendExecutionProvider_TensorRT SessionOptionsAppendExecutionProvider_TensorRT_p sys2 ;
#SetCurrentGpuDeviceId_p  ::OrtSetCurrentGpuDeviceId SetCurrentGpuDeviceId_p sys1 ;
#GetCurrentGpuDeviceId_p  ::OrtGetCurrentGpuDeviceId GetCurrentGpuDeviceId_p sys1 ;
#KernelInfoGetAttributeArray_float_p  ::OrtKernelInfoGetAttributeArray_float KernelInfoGetAttributeArray_float_p sys4 ;
#KernelInfoGetAttributeArray_int64_p  ::OrtKernelInfoGetAttributeArray_int64 KernelInfoGetAttributeArray_int64_p sys4 ;
#CreateArenaCfgV2_p  ::OrtCreateArenaCfgV2 CreateArenaCfgV2_p sys4 ;
#AddRunConfigEntry_p  ::OrtAddRunConfigEntry AddRunConfigEntry_p sys3 ;
#CreatePrepackedWeightsContainer_p  ::OrtCreatePrepackedWeightsContainer CreatePrepackedWeightsContainer_p sys1 ;
#CreateSessionWithPrepackedWeightsContainer_p  ::OrtCreateSessionWithPrepackedWeightsContainer CreateSessionWithPrepackedWeightsContainer_p sys5 ;
#CreateSessionFromArrayWithPrepackedWeightsContainer_p  ::OrtCreateSessionFromArrayWithPrepackedWeightsContainer CreateSessionFromArrayWithPrepackedWeightsContainer_p sys6 ;
#SessionOptionsAppendExecutionProvider_TensorRT_V2_p  ::OrtSessionOptionsAppendExecutionProvider_TensorRT_V2 SessionOptionsAppendExecutionProvider_TensorRT_V2_p sys2 ;
#CreateTensorRTProviderOptions_p  ::OrtCreateTensorRTProviderOptions CreateTensorRTProviderOptions_p sys1 ;
#UpdateTensorRTProviderOptions_p  ::OrtUpdateTensorRTProviderOptions UpdateTensorRTProviderOptions_p sys4 ;
#GetTensorRTProviderOptionsAsMap_p  ::OrtGetTensorRTProviderOptionsAsMap GetTensorRTProviderOptionsAsMap_p sys2 ;
#ReleaseTensorRTProviderOptions_p  ::OrtReleaseTensorRTProviderOptions ReleaseTensorRTProviderOptions_p sys1 ;
#EnableOrtCustomOps_p  ::OrtEnableOrtCustomOps EnableOrtCustomOps_p sys1 ;
#RegisterAllocator_p  ::OrtRegisterAllocator RegisterAllocator_p sys2 ;
#UnregisterAllocator_p  ::OrtUnregisterAllocator UnregisterAllocator_p sys2 ;
#IsSparseTensor_p  ::OrtIsSparseTensor IsSparseTensor_p sys2 ;
#CreateSparseTensorAsOrtValue_p  ::OrtCreateSparseTensorAsOrtValue CreateSparseTensorAsOrtValue_p sys5 ;
#FillSparseTensorCoo_p  ::OrtFillSparseTensorCoo FillSparseTensorCoo_p sys7 ;
#FillSparseTensorCsr_p  ::OrtFillSparseTensorCsr FillSparseTensorCsr_p sys9 ;
#FillSparseTensorBlockSparse_p  ::OrtFillSparseTensorBlockSparse FillSparseTensorBlockSparse_p sys8 ;
#CreateSparseTensorWithValuesAsOrtValue_p  ::OrtCreateSparseTensorWithValuesAsOrtValue CreateSparseTensorWithValuesAsOrtValue_p sys8 ;
#UseCooIndices_p  ::OrtUseCooIndices UseCooIndices_p sys3 ;
#UseCsrIndices_p  ::OrtUseCsrIndices UseCsrIndices_p sys5 ;
#UseBlockSparseIndices_p  ::OrtUseBlockSparseIndices UseBlockSparseIndices_p sys4 ;
#GetSparseTensorFormat_p  ::OrtGetSparseTensorFormat GetSparseTensorFormat_p sys2 ;
#GetSparseTensorValuesTypeAndShape_p  ::OrtGetSparseTensorValuesTypeAndShape GetSparseTensorValuesTypeAndShape_p sys2 ;
#GetSparseTensorValues_p  ::OrtGetSparseTensorValues GetSparseTensorValues_p sys2 ;
#GetSparseTensorIndicesTypeShape_p  ::OrtGetSparseTensorIndicesTypeShape GetSparseTensorIndicesTypeShape_p sys3 ;
#GetSparseTensorIndices_p  ::OrtGetSparseTensorIndices GetSparseTensorIndices_p sys4 ;
#HasValue_p  ::OrtHasValue HasValue_p sys2 ;
#KernelContext_GetGPUComputeStream_p  ::OrtKernelContext_GetGPUComputeStream KernelContext_GetGPUComputeStream_p sys2 ;
#GetTensorMemoryInfo_p  ::OrtGetTensorMemoryInfo GetTensorMemoryInfo_p sys2 ;
#GetExecutionProviderApi_p  ::OrtGetExecutionProviderApi GetExecutionProviderApi_p sys3 ;
#SessionOptionsSetCustomCreateThreadFn_p  ::OrtSessionOptionsSetCustomCreateThreadFn SessionOptionsSetCustomCreateThreadFn_p sys2 ;
#SessionOptionsSetCustomThreadCreationOptionsFn_p  ::OrtSessionOptionsSetCustomThreadCreationOptionsFn SessionOptionsSetCustomThreadCreationOptionsFn_p sys2 ;
#SetGlobalCustomCreateThreadFn_p  ::OrtSetGlobalCustomCreateThreadFn SetGlobalCustomCreateThreadFn_p sys2 ;
#SetGlobalCustomThreadCreationOptions_p  ::OrtSetGlobalCustomThreadCreationOptions SetGlobalCustomThreadCreationOptions_p sys2 ;
#SetGlobalCustomJoinThreadFn_p  ::OrtSetGlobalCustomJoinThreadFn SetGlobalCustomJoinThreadFn_p sys2 ;
#SynchronizeBoundInputs_p  ::OrtSynchronizeBoundInputs SynchronizeBoundInputs_p sys1 ;
#SynchronizeBoundOutputs_p  ::OrtSynchronizeBoundOutputs SynchronizeBoundOutputs_p sys1 ;
#SessionOptionsAppendExecutionProvider_CUDA_V2_p  ::OrtSessionOptionsAppendExecutionProvider_CUDA_V2 SessionOptionsAppendExecutionProvider_CUDA_V2_p sys2 ;
#CreateCUDAProviderOptions_p  ::OrtCreateCUDAProviderOptions CreateCUDAProviderOptions_p sys1 ;
#UpdateCUDAProviderOptions_p  ::OrtUpdateCUDAProviderOptions UpdateCUDAProviderOptions_p sys4 ;
#GetCUDAProviderOptionsAsMap_p  ::OrtGetCUDAProviderOptionsAsMap GetCUDAProviderOptionsAsMap_p sys2 ;
#ReleaseCUDAProviderOptions_p  ::OrtReleaseCUDAProviderOptions ReleaseCUDAProviderOptions_p sys1 ;
#SessionOptionsAppendExecutionProvider_MIGraphX_p  ::OrtSessionOptionsAppendExecutionProvider_MIGraphX SessionOptionsAppendExecutionProvider_MIGraphX_p sys2 ;
#AddExternalInitializers_p  ::OrtAddExternalInitializers AddExternalInitializers_p sys4 ;
#CreateOpAttr_p  ::OrtCreateOpAttr CreateOpAttr_p sys5 ;
#CreateOp_p  ::OrtCreateOp CreateOp_p sys10 ; |sys11 ; |<<<<<<<<<<<<<<<<<<<
#ReleaseOpAttr_p  ::OrtReleaseOpAttr ReleaseOpAttr_p sys1 ;
#ReleaseOp_p  ::OrtReleaseOp ReleaseOp_p sys1 ;
#SessionOptionsAppendExecutionProvider_p  ::OrtSessionOptionsAppendExecutionProvider SessionOptionsAppendExecutionProvider_p sys5 ;
#CopyKernelInfo_p  ::OrtCopyKernelInfo CopyKernelInfo_p sys2 ;
#GetTrainingApi_p  ::OrtGetTrainingApi GetTrainingApi_p sys1 ;
#SessionOptionsAppendExecutionProvider_Dnnl_p  ::OrtSessionOptionsAppendExecutionProvider_Dnnl SessionOptionsAppendExecutionProvider_Dnnl_p sys2 ;
#CreateDnnlProviderOptions_p  ::OrtCreateDnnlProviderOptions CreateDnnlProviderOptions_p sys1 ;
#UpdateDnnlProviderOptions_p  ::OrtUpdateDnnlProviderOptions UpdateDnnlProviderOptions_p sys3 ;
#GetDnnlProviderOptionsAsMap_p  ::OrtGetDnnlProviderOptionsAsMap GetDnnlProviderOptionsAsMap_p sys2 ;
#ReleaseDnnlProviderOptions_p  ::OrtReleaseDnnlProviderOptions ReleaseDnnlProviderOptions_p sys1 ;
#SessionOptionsAppendExecutionProvider_ROCM_V2_p  ::OrtSessionOptionsAppendExecutionProvider_ROCM_V2 SessionOptionsAppendExecutionProvider_ROCM_V2_p sys2 ;
#CreateROCMProviderOptions_p  ::OrtCreateROCMProviderOptions CreateROCMProviderOptions_p sys1 ;
#UpdateROCMProviderOptions_p  ::OrtUpdateROCMProviderOptions UpdateROCMProviderOptions_p sys4 ;
#GetROCMProviderOptionsAsMap_p  ::OrtGetROCMProviderOptionsAsMap GetROCMProviderOptionsAsMap_p sys2 ;
#ReleaseROCMProviderOptions_p  ::OrtReleaseROCMProviderOptions ReleaseROCMProviderOptions_p sys1 ;
#CreateLoraAdapter_p  ::OrtCreateLoraAdapter CreateLoraAdapter_p sys4 ;
#CreateLoraAdapterFromArray_p  ::OrtCreateLoraAdapterFromArray CreateLoraAdapterFromArray_p sys5 ;
#ReleaseLoraAdapter_p  ::OrtReleaseLoraAdapter ReleaseLoraAdapter_p sys1 ;
#RunOptionsAddActiveLoraAdapter_p  ::OrtRunOptionsAddActiveLoraAdapter RunOptionsAddActiveLoraAdapter_p sys2 ;
#SetEpDynamicOptions_p  ::OrtSetEpDynamicOptions SetEpDynamicOptions_p sys4 ;
#ReleaseValueInfo_p  ::OrtReleaseValueInfo ReleaseValueInfo_p sys1 ;
#ReleaseNode_p  ::OrtReleaseNode ReleaseNode_p sys1 ;
#ReleaseGraph_p  ::OrtReleaseGraph ReleaseGraph_p sys1 ;
#ReleaseModel_p  ::OrtReleaseModel ReleaseModel_p sys1 ;
#GetValueInfoName_p  ::OrtGetValueInfoName GetValueInfoName_p sys2 ;
#GetValueInfoTypeInfo_p  ::OrtGetValueInfoTypeInfo GetValueInfoTypeInfo_p sys2 ;
#GetModelEditorApi_p  ::OrtGetModelEditorApi GetModelEditorApi_p sys0 ;
#CreateTensorWithOwnedBufferAsOrtValue_p  ::OrtCreateTensorWithOwnedBufferAsOrtValue CreateTensorWithOwnedBufferAsOrtValue_p sys8 ;

##OrtInvalidAllocator -1
##OrtDeviceAllocator 0
##OrtArenaAllocator 1
##OrtReadOnlyAllocator 2

##OrtMemTypeCPUInput -2
##OrtMemTypeCPUOutput -1
##OrtMemTypeCPU -1 
##OrtMemTypeDefault 0

##ORT_DISABLE_ALL 0
##ORT_ENABLE_BASIC 1
##ORT_ENABLE_EXTENDED 2
##ORT_ENABLE_ALL 99

##ONNX_TENSOR_ELEMENT_DATA_TYPE_UNDEFINED 0
##ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT   1 | maps to c type float
##ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT8   2 | maps to c type uint8_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_INT8    3 | maps to c type int8_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT16  4 | maps to c type uint16_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_INT16   5 | maps to c type int16_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_INT32   6 | maps to c type int32_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_INT64   7 | maps to c type int64_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_STRING  8 | maps to c++ type std::string
##ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL	9
##ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT16	10
##ONNX_TENSOR_ELEMENT_DATA_TYPE_DOUBLE	11	| maps to c type double
##ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT32  12	| maps to c type uint32_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT64  13	| maps to c type uint64_t
##ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX64 14	| complex with float32 real and imaginary components
##ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX128 15	| complex with float64 real and imaginary components
##ONNX_TENSOR_ELEMENT_DATA_TYPE_BFLOAT16 16	| Non-IEEE floating-point format based on IEEE754 single-precision
| float 8 types were introduced in onnx 1.14 se\e https:|onnx.ai/onnx/technical/float8.html
##ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E4M3FN	17	| Non-IEEE floating-point format based on IEEE754 single-precision
##ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E4M3FNUZ	18	| Non-IEEE floating-point format based on IEEE754 single-precision
##ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E5M2		19	| Non-IEEE floating-point format based on IEEE754 single-precision
##ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT8E5M2FNUZ	20	| Non-IEEE floating-point format based on IEEE754 single-precision
| Int4 types were introduced in ONNX 1.16. See https:|onnx.ai/onnx/technical/int4.html
##ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT4	21	| maps to a pair of packed uint4 values (size == 1 byte)
##ONNX_TENSOR_ELEMENT_DATA_TYPE_INT4	22	| maps to a pair of packed int4 values (size == 1 byte)

#getApi

| Cargar bibliotecas
: 
	"dll/onnxruntime.dll" loadlib
	dup "OrtGetApiBase" getproc 'ortGetApiBase_p !
	dup "OrtSessionOptionsAppendExecutionProvider_CPU" getproc 'ortSess_CPU_p !
	dup "OrtSessionOptionsAppendExecutionProvider_MDL" getproc 'ortSess_MDL_p !
	drop
	
	
	ortGetApiBase_p sys0 
	@+ 'getApi !
	@ 'getVersionString_p !
	
	22 getApi sys1 
@+ 'CreateStatus_p !
@+ 'GetErrorCode_p !
@+ 'GetErrorMessage_p !
@+ 'CreateEnv_p !
@+ 'CreateEnvWithCustomLogger_p !
@+ 'EnableTelemetryEvents_p !
@+ 'DisableTelemetryEvents_p !
@+ 'CreateSession_p !
@+ 'CreateSessionFromArray_p !
@+ 'Run_p !
@+ 'CreateSessionOptions_p !
@+ 'SetOptimizedModelFilePath_p !
@+ 'CloneSessionOptions_p !
@+ 'SetSessionExecutionMode_p !
@+ 'EnableProfiling_p !
@+ 'DisableProfiling_p !
@+ 'EnableMemPattern_p !
@+ 'DisableMemPattern_p !
@+ 'EnableCpuMemArena_p !
@+ 'DisableCpuMemArena_p !
@+ 'SetSessionLogId_p !
@+ 'SetSessionLogVerbosityLevel_p !
@+ 'SetSessionLogSeverityLevel_p !
@+ 'SetSessionGraphOptimizationLevel_p !
@+ 'SetIntraOpNumThreads_p !
@+ 'SetInterOpNumThreads_p !
@+ 'CreateCustomOpDomain_p !
@+ 'CustomOpDomain_Add_p !
@+ 'AddCustomOpDomain_p !
@+ 'RegisterCustomOpsLibrary_p !
@+ 'SessionGetInputCount_p !
@+ 'SessionGetOutputCount_p !
@+ 'SessionGetOverridableInitializerCount_p !
@+ 'SessionGetInputTypeInfo_p !
@+ 'SessionGetOutputTypeInfo_p !
@+ 'SessionGetOverridableInitializerTypeInfo_p !
@+ 'SessionGetInputName_p !
@+ 'SessionGetOutputName_p !
@+ 'SessionGetOverridableInitializerName_p !
@+ 'CreateRunOptions_p !
@+ 'RunOptionsSetRunLogVerbosityLevel_p !
@+ 'RunOptionsSetRunLogSeverityLevel_p !
@+ 'RunOptionsSetRunTag_p !
@+ 'RunOptionsGetRunLogVerbosityLevel_p !
@+ 'RunOptionsGetRunLogSeverityLevel_p !
@+ 'RunOptionsGetRunTag_p !
@+ 'RunOptionsSetTerminate_p !
@+ 'RunOptionsUnsetTerminate_p !
@+ 'CreateTensorAsOrtValue_p !
@+ 'CreateTensorWithDataAsOrtValue_p !
@+ 'IsTensor_p !
@+ 'GetTensorMutableData_p !
@+ 'FillStringTensor_p !
@+ 'GetStringTensorDataLength_p !
@+ 'GetStringTensorContent_p !
@+ 'CastTypeInfoToTensorInfo_p !
@+ 'GetOnnxTypeFromTypeInfo_p !
@+ 'CreateTensorTypeAndShapeInfo_p !
@+ 'SetTensorElementType_p !
@+ 'SetDimensions_p !
@+ 'GetTensorElementType_p !
@+ 'GetDimensionsCount_p !
@+ 'GetDimensions_p !
@+ 'GetSymbolicDimensions_p !
@+ 'GetTensorShapeElementCount_p !
@+ 'GetTensorTypeAndShape_p !
@+ 'GetTypeInfo_p !
@+ 'GetValueType_p !
@+ 'CreateMemoryInfo_p !
@+ 'CreateCpuMemoryInfo_p !
@+ 'CompareMemoryInfo_p !
@+ 'MemoryInfoGetName_p !
@+ 'MemoryInfoGetId_p !
@+ 'MemoryInfoGetMemType_p !
@+ 'MemoryInfoGetType_p !
@+ 'AllocatorAlloc_p !
@+ 'AllocatorFree_p !
@+ 'AllocatorGetInfo_p !
@+ 'GetAllocatorWithDefaultOptions_p !
@+ 'AddFreeDimensionOverride_p !
@+ 'GetValue_p !
@+ 'GetValueCount_p !
@+ 'CreateValue_p !
@+ 'CreateOpaqueValue_p !
@+ 'GetOpaqueValue_p !
@+ 'KernelInfoGetAttribute_float_p !
@+ 'KernelInfoGetAttribute_int64_p !
@+ 'KernelInfoGetAttribute_string_p !
@+ 'KernelContext_GetInputCount_p !
@+ 'KernelContext_GetOutputCount_p !
@+ 'KernelContext_GetInput_p !
@+ 'KernelContext_GetOutput_p !
@+ 'ReleaseEnv_p !
@+ 'ReleaseStatus_p !
@+ 'ReleaseMemoryInfo_p !
@+ 'ReleaseSession_p !
@+ 'ReleaseValue_p !
@+ 'ReleaseRunOptions_p !
@+ 'ReleaseTypeInfo_p !
@+ 'ReleaseTensorTypeAndShapeInfo_p !
@+ 'ReleaseSessionOptions_p !
@+ 'ReleaseCustomOpDomain_p !
@+ 'GetDenotationFromTypeInfo_p !
@+ 'CastTypeInfoToMapTypeInfo_p !
@+ 'CastTypeInfoToSequenceTypeInfo_p !
@+ 'GetMapKeyType_p !
@+ 'GetMapValueType_p !
@+ 'GetSequenceElementType_p !
@+ 'ReleaseMapTypeInfo_p !
@+ 'ReleaseSequenceTypeInfo_p !
@+ 'SessionEndProfiling_p !
@+ 'SessionGetModelMetadata_p !
@+ 'ModelMetadataGetProducerName_p !
@+ 'ModelMetadataGetGraphName_p !
@+ 'ModelMetadataGetDomain_p !
@+ 'ModelMetadataGetDescription_p !
@+ 'ModelMetadataLookupCustomMetadataMap_p !
@+ 'ModelMetadataGetVersion_p !
@+ 'CreateEnvWithGlobalThreadPools_p !
@+ 'DisablePerSessionThreads_p !
@+ 'CreateThreadingOptions_p !
@+ 'SetGlobalIntraOpNumThreads_p !
@+ 'SetGlobalInterOpNumThreads_p !
@+ 'SetGlobalSpinControl_p !
@+ 'ModelMetadataGetCustomMetadataMapKeys_p !
@+ 'AddFreeDimensionOverrideByName_p !
@+ 'GetAvailableProviders_p !
@+ 'ReleaseAvailableProviders_p !
@+ 'GetStringTensorElementLength_p !
@+ 'GetStringTensorElement_p !
@+ 'FillStringTensorElement_p !
@+ 'AddSessionConfigEntry_p !
@+ 'CreateAllocator_p !
@+ 'RunWithBinding_p !
@+ 'CreateIoBinding_p !
@+ 'BindInput_p !
@+ 'BindOutput_p !
@+ 'BindOutputToDevice_p !
@+ 'GetBoundOutputNames_p !
@+ 'GetBoundOutputValues_p !
@+ 'ClearBoundInputs_p !
@+ 'ClearBoundOutputs_p !
@+ 'TensorAt_p !
@+ 'CreateAndRegisterAllocator_p !
@+ 'SetLanguageProjection_p !
@+ 'SessionGetProfilingStartTimeNs_p !
@+ 'AddInitializer_p !
@+ 'CreateEnvWithCustomLoggerAndGlobalThreadPools_p !
@+ 'SessionOptionsAppendExecutionProvider_CUDA_p !
@+ 'SessionOptionsAppendExecutionProvider_ROCM_p !
@+ 'SessionOptionsAppendExecutionProvider_OpenVINO_p !
@+ 'SetGlobalDenormalAsZero_p !
@+ 'CreateArenaCfg_p !
@+ 'ModelMetadataGetGraphDescription_p !
@+ 'SessionOptionsAppendExecutionProvider_TensorRT_p !
@+ 'SetCurrentGpuDeviceId_p !
@+ 'GetCurrentGpuDeviceId_p !
@+ 'KernelInfoGetAttributeArray_float_p !
@+ 'KernelInfoGetAttributeArray_int64_p !
@+ 'CreateArenaCfgV2_p !
@+ 'AddRunConfigEntry_p !
@+ 'CreatePrepackedWeightsContainer_p !
@+ 'CreateSessionWithPrepackedWeightsContainer_p !
@+ 'CreateSessionFromArrayWithPrepackedWeightsContainer_p !
@+ 'SessionOptionsAppendExecutionProvider_TensorRT_V2_p !
@+ 'CreateTensorRTProviderOptions_p !
@+ 'UpdateTensorRTProviderOptions_p !
@+ 'GetTensorRTProviderOptionsAsMap_p !
@+ 'ReleaseTensorRTProviderOptions_p !
@+ 'EnableOrtCustomOps_p !
@+ 'RegisterAllocator_p !
@+ 'UnregisterAllocator_p !
@+ 'IsSparseTensor_p !
@+ 'CreateSparseTensorAsOrtValue_p !
@+ 'FillSparseTensorCoo_p !
@+ 'FillSparseTensorCsr_p !
@+ 'FillSparseTensorBlockSparse_p !
@+ 'CreateSparseTensorWithValuesAsOrtValue_p !
@+ 'UseCooIndices_p !
@+ 'UseCsrIndices_p !
@+ 'UseBlockSparseIndices_p !
@+ 'GetSparseTensorFormat_p !
@+ 'GetSparseTensorValuesTypeAndShape_p !
@+ 'GetSparseTensorValues_p !
@+ 'GetSparseTensorIndicesTypeShape_p !
@+ 'GetSparseTensorIndices_p !
@+ 'HasValue_p !
@+ 'KernelContext_GetGPUComputeStream_p !
@+ 'GetTensorMemoryInfo_p !
@+ 'GetExecutionProviderApi_p !
@+ 'SessionOptionsSetCustomCreateThreadFn_p !
@+ 'SessionOptionsSetCustomThreadCreationOptionsFn_p !
@+ 'SetGlobalCustomCreateThreadFn_p !
@+ 'SetGlobalCustomThreadCreationOptions_p !
@+ 'SetGlobalCustomJoinThreadFn_p !
@+ 'SynchronizeBoundInputs_p !
@+ 'SynchronizeBoundOutputs_p !
@+ 'SessionOptionsAppendExecutionProvider_CUDA_V2_p !
@+ 'CreateCUDAProviderOptions_p !
@+ 'UpdateCUDAProviderOptions_p !
@+ 'GetCUDAProviderOptionsAsMap_p !
@+ 'ReleaseCUDAProviderOptions_p !
@+ 'SessionOptionsAppendExecutionProvider_MIGraphX_p !
@+ 'AddExternalInitializers_p !
@+ 'CreateOpAttr_p !
@+ 'CreateOp_p !
@+ 'ReleaseOpAttr_p !
@+ 'ReleaseOp_p !
@+ 'SessionOptionsAppendExecutionProvider_p !
@+ 'CopyKernelInfo_p !
@+ 'GetTrainingApi_p !
@+ 'SessionOptionsAppendExecutionProvider_Dnnl_p !
@+ 'CreateDnnlProviderOptions_p !
@+ 'UpdateDnnlProviderOptions_p !
@+ 'GetDnnlProviderOptionsAsMap_p !
@+ 'ReleaseDnnlProviderOptions_p !
@+ 'SessionOptionsAppendExecutionProvider_ROCM_V2_p !
@+ 'CreateROCMProviderOptions_p !
@+ 'UpdateROCMProviderOptions_p !
@+ 'GetROCMProviderOptionsAsMap_p !
@+ 'ReleaseROCMProviderOptions_p !
@+ 'CreateLoraAdapter_p !
@+ 'CreateLoraAdapterFromArray_p !
@+ 'ReleaseLoraAdapter_p !
@+ 'RunOptionsAddActiveLoraAdapter_p !
@+ 'SetEpDynamicOptions_p !
@+ 'ReleaseValueInfo_p !
@+ 'ReleaseNode_p !
@+ 'ReleaseGraph_p !
@+ 'ReleaseModel_p !
@+ 'GetValueInfoName_p !
@+ 'GetValueInfoTypeInfo_p !
@+ 'GetModelEditorApi_p !
@+ 'CreateTensorWithOwnedBufferAsOrtValue_p !
	drop ;