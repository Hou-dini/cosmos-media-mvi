import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// Concrete implementation of [TransformationStrategyFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [TransformationStrategy] implementation based on the requested [MediaType]
/// and [DataFormat].
class TransformationStrategyFactoryImpl implements TransformationStrategyFactory {
  final GetIt _getIt;

  /// Constructs a [TransformationStrategyFactoryImpl] with a [GetIt] instance for dependency resolution.
  TransformationStrategyFactoryImpl(this._getIt);

  @override
  TransformationStrategy createTransformationStrategy(MediaType mediaType, DataFormat dataFormat) {
    try {
      // For MVI, we only support song media type and MP3 data format.
      // In a full implementation, this would involve a more complex lookup
      // or a switch statement with multiple cases for different combinations.
      if (mediaType == MediaType.song && dataFormat == DataFormat.mp3) {
        return _getIt<TransformationStrategy>(instanceName: 'Mp3ToSongTransformationStrategy');
      } else {
        throw AppException(
          errorCode: ErrorCode.dilTransformationStrategyFactoryUnsupportedTypeCombination,
          message: 'Unsupported combination of MediaType: ${mediaType.name} '
                   'and DataFormat: ${dataFormat.name} for TransformationStrategy creation.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'TransformationStrategyFactoryImpl',
            ErrorContextKey.operation: 'createTransformationStrategy',
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
        errorCode: ErrorCode.dilTransformationStrategyFactoryCreationError,
        message: 'Failed to create TransformationStrategy for mediaType: ${mediaType.name}, dataFormat: ${dataFormat.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'TransformationStrategyFactoryImpl',
          ErrorContextKey.operation: 'createTransformationStrategy',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.mediaType: mediaType.name,
          ErrorContextKey.dataFormat: dataFormat.name,
        },
      );
    }
  }
}
