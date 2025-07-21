import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';



/// Concrete implementation of [DataFormatDetectorFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [DataFormatDetector] implementation based on the requested [ImportSourceType].
class DataFormatDetectorFactoryImpl implements DataFormatDetectorFactory {
  final GetIt _getIt;

  /// Constructs a [DataFormatDetectorFactoryImpl] with a [GetIt] instance for dependency resolution.
  DataFormatDetectorFactoryImpl(this._getIt);

  @override
  DataFormatDetector createDetector(ImportSourceType sourceType) {
    try {
      switch (sourceType) {
        case ImportSourceType.localFolder:
          // For MVI, we specifically return the LocalDataFormatDetector instance.
          return _getIt<DataFormatDetector>(instanceName: 'LocalDataFormatDetector');
        // case ImportSourceType.cloudStorage:
        //   return _getIt<DataFormatDetector>(instanceName: 'CloudDataFormatDetector');
        // case ImportSourceType.httpApi:
        //   return _getIt<DataFormatDetector>(instanceName: 'HttpApiFormatDetector');
        default:
          throw AppException(
            errorCode: ErrorCode.dilFormatDetectionUnsupported,
            message: 'Unsupported ImportSourceType: ${sourceType.name} for DataFormatDetector creation.',
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'DataFormatDetectorFactoryImpl',
              ErrorContextKey.operation: 'createDetector',
              ErrorContextKey.importSourceType: sourceType.name,
            },
          );
      }
    } on AppException {
      // Re-throw our custom exception
      rethrow;
    } catch (e, st) {
      // Catch any unexpected errors during resolution and wrap them in AppException
      throw AppException(
        errorCode: ErrorCode.dilFormatDetectorFactoryCreationError,
        message: 'Failed to create DataFormatDetector for type ${sourceType.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'DataFormatDetectorFactoryImpl',
          ErrorContextKey.operation: 'createDetector',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.importSourceType: sourceType.name,
        },
      );
    }
  }
}
