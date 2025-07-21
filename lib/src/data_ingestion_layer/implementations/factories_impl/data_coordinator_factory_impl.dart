import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';



/// Concrete implementation of [DataCoordinatorFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [DataCoordinator] implementation based on the requested [ImportSourceType].
class DataCoordinatorFactoryImpl implements DataCoordinatorFactory {
  final GetIt _getIt;

  /// Constructs a [DataCoordinatorFactoryImpl] with a [GetIt] instance for dependency resolution.
  DataCoordinatorFactoryImpl(this._getIt);

  @override
  DataCoordinator createCoordinator(ImportSourceType sourceType) {
    try {
      switch (sourceType) {
        case ImportSourceType.localFolder:
          // For MVI, we specifically return the LocalDataCoordinator instance.
          return _getIt<DataCoordinator>(instanceName: 'LocalDataCoordinator');
        // case ImportSourceType.cloudStorage:
        //   return _getIt<DataCoordinator>(instanceName: 'CloudDataCoordinator');
        // case ImportSourceType.httpApi:
        //   return _getIt<DataCoordinator>(instanceName: 'HttpApiCoordinator');
        default:
          throw AppException(
            errorCode: ErrorCode.dilCoordinatorFactoryUnsupportedSourceType,
            message: 'Unsupported ImportSourceType: ${sourceType.name} for DataCoordinator creation.',
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'DataCoordinatorFactoryImpl',
              ErrorContextKey.operation: 'createCoordinator',
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
        errorCode: ErrorCode.dilCoordinatorFactoryCreationError,
        message: 'Failed to create DataCoordinator for type ${sourceType.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'DataCoordinatorFactoryImpl',
          ErrorContextKey.operation: 'createCoordinator',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.importSourceType: sourceType.name,
        },
      );
    }
  }
}
