import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';



/// Concrete implementation of [DataTransformerFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [DataTransformer] implementation based on the requested [ImportSourceType].
class DataTransformerFactoryImpl implements DataTransformerFactory {
  final GetIt _getIt;

  /// Constructs a [DataTransformerFactoryImpl] with a [GetIt] instance for dependency resolution.
  DataTransformerFactoryImpl(this._getIt);

  @override
  DataTransformer createTransformer(ImportSourceType sourceType) {
    try {
      switch (sourceType) {
        case ImportSourceType.localFolder:
          // For MVI, we specifically return the LocalDataTransformer instance.
          return _getIt<DataTransformer>(instanceName: 'LocalDataTransformer');
        // case ImportSourceType.cloudStorage:
        //   return _getIt<DataTransformer>(instanceName: 'CloudStorageTransformer');
        // case ImportSourceType.httpApi:
        //   return _getIt<DataTransformer>(instanceName: 'HttpApiTransformer');
        default:
          throw AppException(
            errorCode: ErrorCode.dilTransformerFactoryUnsupportedSourceType,
            message: 'Unsupported ImportSourceType: ${sourceType.name} for DataTransformer creation.',
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'DataTransformerFactoryImpl',
              ErrorContextKey.operation: 'createTransformer',
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
        errorCode: ErrorCode.dilTransformerFactoryCreationError,
        message: 'Failed to create DataTransformer for type ${sourceType.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'DataTransformerFactoryImpl',
          ErrorContextKey.operation: 'createTransformer',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.importSourceType: sourceType.name,
        },
      );
    }
  }
}
