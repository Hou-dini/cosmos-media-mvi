import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// Concrete implementation of [InterpretationStrategyFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [InterpretationStrategy] implementation based on the requested [MediaType]
/// and [DataFormat].
class InterpretationStrategyFactoryImpl implements InterpretationStrategyFactory {
  final GetIt _getIt;

  /// Constructs an [InterpretationStrategyFactoryImpl] with a [GetIt] instance for dependency resolution.
  InterpretationStrategyFactoryImpl(this._getIt);

  @override
  InterpretationStrategy createInterpretationStrategy(MediaType mediaType, DataFormat dataFormat) {
    try {
      // For MVI, we only support song media type and MP3 data format.
      // In a full implementation, this would involve a more complex lookup
      // or a switch statement with multiple cases for different combinations.
      if (mediaType == MediaType.song && dataFormat == DataFormat.mp3) {
        return _getIt<InterpretationStrategy>(instanceName: 'Mp3InterpretationStrategy');
      } else {
        throw AppException(
          errorCode: ErrorCode.dilInterpretationStrategyFactoryUnsupportedTypeCombination,
          message: 'Unsupported combination of MediaType: ${mediaType.name} '
                   'and DataFormat: ${dataFormat.name} for InterpretationStrategy creation.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'InterpretationStrategyFactoryImpl',
            ErrorContextKey.operation: 'createInterpretationStrategy',
            ErrorContextKey.mediaType: mediaType.name,
            ErrorContextKey.dataFormat: dataFormat.name,
          },
        );
      }
    } on AppException {
      // Re-throw our custom exception
      rethrow;
    } catch (e, st) {
      // Catch any unexpected errors during resolution and wrap them in AppException
      throw AppException(
        errorCode: ErrorCode.dilInterpretationStrategyFactoryCreationError,
        message: 'Failed to create InterpretationStrategy for mediaType: ${mediaType.name}, dataFormat: ${dataFormat.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'InterpretationStrategyFactoryImpl',
          ErrorContextKey.operation: 'createInterpretationStrategy',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.mediaType: mediaType.name,
          ErrorContextKey.dataFormat: dataFormat.name,
        },
      );
    }
  }
}
