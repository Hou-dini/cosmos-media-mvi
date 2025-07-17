import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/data_transformer.dart';
import 'package:cosmos_media_mvi/src/core/enums/import_source_type.dart';

/// Defines a contract for creating instances of [DataTransformer].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [DataTransformer] implementation based on the provided
/// [ImportSourceType]. It leverages a Dependency Injection (DI) container
/// to resolve and provide the correct [DataTransformer] implementation.
abstract class DataTransformerFactory {
  /// Creates and returns a new instance of a [DataTransformer] that is
  /// conceptually designed to transform interpreted data originating from the
  /// specified [ImportSourceType] into [Media] objects.
  ///
  /// This method will internally use the [sourceType] to query a DI container,
  /// which resolves and provides the correct concrete [DataTransformer] implementation.
  /// The returned transformer will later be configured with the specific [MediaType]
  /// by its client ([DataCoordinator]).
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilTransformationFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilTransformationUnsupportedSourceType]: The [sourceType] is not supported.
  DataTransformer createTransformer(ImportSourceType sourceType);
}