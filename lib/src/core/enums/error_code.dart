// ErrorCode Enum (simplified for MVI)
enum ErrorCode {
  // General DIL errors
  dilUnknownError,

  // Provider errors
  dilProviderAccessDeniedError,
  dilProviderPathMissingError,
  dilProviderConnectionError,
  dilProviderUnknownError,
  dilProviderUnsupportedSourceType,

  // Format Detector errors
  dilFormatDetectionFailed,
  dilFormatDetectionUnsupported,

  // Interpreter errors
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

   // InterpretationStrategy errors
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

