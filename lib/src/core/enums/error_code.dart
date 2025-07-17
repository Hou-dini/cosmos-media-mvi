// ErrorCode Enum (simplified for MVI)
enum ErrorCode {
  // General DIL errors
  dilUnknownError,

  // Provider errors
  dilProviderAccessDeniedError,
  dilProviderPathMissingError,
  dilProviderConnectionError,
  dilProviderUnknownError,

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
  dilFormatDetectorFactoryCreationError,
  dilInterpretationStrategyFactoryCreationError,
  dilTransformationStrategyFactoryCreationError,
  dilDataCoordinatorFactoryCreationError,

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

