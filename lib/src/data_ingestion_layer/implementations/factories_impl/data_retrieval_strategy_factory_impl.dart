import 'package:get_it/get_it.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import DIL Enums and Exceptions ---
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';



/// Concrete implementation of [DataRetrievalStrategyFactory].
///
/// This factory uses a [GetIt] instance to resolve and provide the appropriate
/// [DataRetrievalStrategy] implementation based on the requested [ImportSourceType]
/// and [MediaType].
class DataRetrievalStrategyFactoryImpl implements DataRetrievalStrategyFactory {
  final GetIt _getIt;

  /// Constructs a [DataRetrievalStrategyFactoryImpl] with a [GetIt] instance for dependency resolution.
  DataRetrievalStrategyFactoryImpl(this._getIt);

  @override
  DataRetrievalStrategy createDataRetrievalStrategy(ImportSourceType sourceType, MediaType mediaType) {
    try {
      // For MVI, we only support localFolder for song media type.
      // In a full implementation, this switch would have multiple cases
      // and potentially nested switches or a more complex lookup mechanism.
      if (sourceType == ImportSourceType.localFolder && mediaType == MediaType.song) {
        return _getIt<DataRetrievalStrategy>(instanceName: 'LocalSongRetrievalStrategy');
      } else {
        throw AppException(
          errorCode: ErrorCode.dilRetrievalStrategyUnsupportedTypeCombination, 
          message: 'Unsupported combination of ImportSourceType: ${sourceType.name} '
                   'and MediaType: ${mediaType.name} for DataRetrievalStrategy creation.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'DataRetrievalStrategyFactoryImpl',
            ErrorContextKey.operation: 'createDataRetrievalStrategy',
            ErrorContextKey.importSourceType: sourceType.name,
            ErrorContextKey.mediaType: mediaType.name,
          },
        );
      }
    } on AppException {
      // Re-throw our custom exception
      rethrow;
    } catch (e, st) {
      // Catch any unexpected errors during resolution and wrap them in AppException
      throw AppException(
        errorCode: ErrorCode.dilRetrievalStrategyFactoryCreationError, // Generic factory creation error
        message: 'Failed to create DataRetrievalStrategy for sourceType: ${sourceType.name}, mediaType: ${mediaType.name}.',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'DataRetrievalStrategyFactoryImpl',
          ErrorContextKey.operation: 'createDataRetrievalStrategy',
          ErrorContextKey.originalException: e.toString(),
          ErrorContextKey.importSourceType: sourceType.name,
          ErrorContextKey.mediaType: mediaType.name,
        },
      );
    }
  }
}
