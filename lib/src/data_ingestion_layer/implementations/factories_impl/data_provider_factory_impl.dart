import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';



/// Concrete implementation of [DataProviderFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [DataProvider] implementation based on the requested [ImportSourceType].
class DataProviderFactoryImpl implements DataProviderFactory {
  final GetIt _getIt;

  /// Constructs a [DataProviderFactoryImpl] with a [GetIt] instance for dependency resolution.
  DataProviderFactoryImpl(this._getIt);

  @override
  DataProvider createProvider(ImportSourceType sourceType) {
    try {
      switch (sourceType) {
        case ImportSourceType.localFolder:
          // For MVI, we specifically return the LocalDataProvider instance.
          // In a more complex setup, this might involve a named registration
          // or a more dynamic lookup if multiple LocalDataProviders existed.
          return _getIt<DataProvider>(instanceName: 'LocalDataProvider');
        // case ImportSourceType.cloudStorage:
        //   return _getIt<DataProvider>(instanceName: 'CloudStorageDataProvider');
        // case ImportSourceType.httpApi:
        //   return _getIt<DataProvider>(instanceName: 'HttpApiDataProvider');
        default:
          throw AppException(
            errorCode: ErrorCode.dilProviderFactoryUnsupportedSourceType,
            message: 'Unsupported ImportSourceType: ${sourceType.name} for DataProvider creation.',
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'DataProviderFactoryImpl',
              ErrorContextKey.operation: 'createProvider',
              ErrorContextKey.importSourceType: sourceType.name, // Add new context key for source type
            },
          );
      }
    } on AppException {
      // Re-throw our custom exception
      rethrow;
    } catch (e, st) {
      // Catch any unexpected errors during resolution and wrap them in AppException
      throw AppException(
        errorCode: ErrorCode.dilProviderFactoryCreationError,
        message: 'Failed to create DataProvider for type ${sourceType.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'DataProviderFactoryImpl',
          ErrorContextKey.operation: 'createProvider',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.importSourceType: sourceType.name,
        },
      );
    }
  }
}
