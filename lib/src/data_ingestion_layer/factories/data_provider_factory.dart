import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/data_provider.dart';
import 'package:cosmos_media_mvi/src/core/enums/import_source_type.dart';

/// Defines a contract for creating instances of [DataProvider].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [DataProvider] implementation based on the provided
/// [ImportSourceType]. It leverages a Dependency Injection (DI) container
/// to resolve and provide the correct [DataProvider] implementation.
abstract class DataProviderFactory {
  /// Creates and returns a new instance of a [DataProvider] that is
  /// conceptually designed to handle data originating from the specified [ImportSourceType].
  ///
  /// This method will internally use the [sourceType] to query a DI container,
  /// which resolves and provides the correct concrete [DataProvider] implementation.
  /// The returned provider will later be configured with the specific
  /// [ResourceLocationConfig] and [MediaType] by its client ([DataCoordinator] or [MediaSyncService]).
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilProviderFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilProviderFactoryUnsupportedSourceType]: The [sourceType] is not supported.
  DataProvider createProvider(ImportSourceType sourceType);
}
