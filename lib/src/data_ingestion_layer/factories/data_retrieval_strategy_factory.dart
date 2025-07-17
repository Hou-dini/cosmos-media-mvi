import 'package:cosmos_media_mvi/src/core/enums/import_source_type.dart';
import 'package:cosmos_media_mvi/src/core/enums/media_type.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/data_retrieval_strategy.dart';

/// Defines a contract for creating instances of [DataRetrievalStrategy].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [DataRetrievalStrategy] implementation based on the
/// provided [ImportSourceType] and [MediaType].
abstract class DataRetrievalStrategyFactory {
  /// Creates and returns a new instance of a [DataRetrievalStrategy] that is
  /// tailored for the specified [ImportSourceType] and [MediaType].
  ///
  /// This method will internally use both parameters to query a DI container,
  /// which resolves and provides the correct concrete [DataRetrievalStrategy] implementation.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilRetrievalStrategyFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilRetrievalStrategyUnsupportedSourceType]: The [sourceType] is not supported for retrieval.
  /// - [ErrorCode.dilRetrievalStrategyUnsupportedMediaType]: The [mediaType] is not supported for retrieval from this source.
  DataRetrievalStrategy createDataRetrievalStrategy(ImportSourceType sourceType, MediaType mediaType);
}