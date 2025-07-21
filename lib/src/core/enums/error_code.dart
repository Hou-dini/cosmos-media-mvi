// ErrorCode Enum (simplified for MVI)
enum ErrorCode {
  // General DIL errors
  dilUnknownError,

  // Provider errors
  dilProviderSetupError,
  dilProviderWatchUnsupported,
  dilProviderInvalidConfigError,
  dilProviderAccessDeniedError,
  dilProviderPathMissingError,
  dilProviderConnectionError,
  dilProviderUnknownError,
  dilProviderUnsupportedSourceType,

  // Format Detector errors
  dilFormatDetectionFailed,
  dilFormatDetectionUnsupported,
  dilFormatDetectionUpstreamError,

  // Interpreter errors
  dilInterpretationSetupError,
  dilInterpretationStrategyParsingError,
  dilInterpretationStrategyInvalidData,
  dilInterpretationStrategyUnsupportedFormat,
  dilInterpretationParsingError,
  dilInterpretationUpstreamError,

  // Transformer errors
  dilTransformationStrategyMappingError,
  dilTransformationStrategyInvalidData,
  dilTransformationStrategyUnsupportedFormat,
  dilTransformationMappingError,
  dilTransformationUpstreamError,
  dilTransformationSetupError,

  // Factory errors
  dilProviderFactoryCreationError,
  dilProviderFactoryUnsupportedSourceType,
  dilFormatDetectorFactoryCreationError,
  dilInterpretationStrategyFactoryCreationError,
  dilInterpretationStrategyFactoryUnsupportedTypeCombination, 
  dilRetrievalStrategyUnsupportedTypeCombination, 
  dilRetrievalStrategyFactoryCreationError,
  dilTransformationStrategyFactoryCreationError,
  dilTransformationStrategyFactoryUnsupportedTypeCombination,
  dilCoordinatorFactoryCreationError,
  dilCoordinatorFactoryUnsupportedSourceType,
  dilInterpreterFactoryCreationError,
  dilInterpreterFactoryUnsupportedSourceType,
  dilTransformerFactoryCreationError,
  dilTransformerFactoryUnsupportedSourceType,

  // Coordinator errors
  dilCoordinatorSetupError,
  dilCoordinatorPipelineError,
  dilCoordinatorResourceAccessError,
  dilCoordinatorInvalidConfigError,
  dilCoordinatorUnknownError,

   // RetrievalStrategy errors
  dilRetrievalStrategyAccessDeniedError,
  dilRetrievalStrategyPathMissingError,
  dilRetrievalStrategyAuthenticationError,
  dilRetrievalStrategyUnknownError,

  // Service layer errors (for IMediaImportService example)
  serviceImportSetupError,
  serviceImportPostProcessingError,
  serviceImportInvalidConfigError,
  serviceImportUnknownError,               
}

