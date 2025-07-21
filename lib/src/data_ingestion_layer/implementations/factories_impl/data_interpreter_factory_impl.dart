import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';



/// Concrete implementation of [DataInterpreterFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [DataInterpreter] implementation based on the requested [ImportSourceType].
class DataInterpreterFactoryImpl implements DataInterpreterFactory {
  final GetIt _getIt;

  /// Constructs a [DataInterpreterFactoryImpl] with a [GetIt] instance for dependency resolution.
  DataInterpreterFactoryImpl(this._getIt);

  @override
  DataInterpreter createInterpreter(ImportSourceType sourceType) {
    try {
      switch (sourceType) {
        case ImportSourceType.localFolder:
          // For MVI, we specifically return the LocalDataInterpreter instance.
          return _getIt<DataInterpreter>(instanceName: 'LocalDataInterpreter');
        // case ImportSourceType.cloudStorage:
        //   return _getIt<DataInterpreter>(instanceName: 'CloudDataInterpreter');
        // case ImportSourceType.httpApi:
        //   return _getIt<DataInterpreter>(instanceName: 'HttpApiInterpreter');
        default:
          throw AppException(
            errorCode: ErrorCode.dilInterpreterFactoryUnsupportedSourceType,
            message: 'Unsupported ImportSourceType: ${sourceType.name} for DataInterpreter creation.',
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'DataInterpreterFactoryImpl',
              ErrorContextKey.operation: 'createInterpreter',
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
        errorCode: ErrorCode.dilInterpreterFactoryCreationError,
        message: 'Failed to create DataInterpreter for type ${sourceType.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'DataInterpreterFactoryImpl',
          ErrorContextKey.operation: 'createInterpreter',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.importSourceType: sourceType.name,
        },
      );
    }
  }
}
