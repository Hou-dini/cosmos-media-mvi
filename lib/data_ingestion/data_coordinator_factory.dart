import 'package:cosmos_media_mvi/data_ingestion/data_coordinator.dart';
import 'package:cosmos_media_mvi/utils.dart/import_source_type.dart';

/// Defines a contract for creating instances of [DataCoordinator].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [DataCoordinator] implementation based on the provided
/// [ImportSourceType]. It leverages a Dependency Injection (DI) container
/// to resolve and provide the correct [DataCoordinator] implementation.
abstract class DataCoordinatorFactory {
  /// Creates and returns a new instance of a [DataCoordinator] that is
  /// conceptually designed to orchestrate the DIL pipeline for the specified [ImportSourceType].
  ///
  /// This method will internally use the [sourceType] to query a DI container,
  /// which resolves and provides the correct concrete [DataCoordinator] implementation.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilDataCoordinatorFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilCoordinatorInvalidConfigError]: The [sourceType] is not supported.
  DataCoordinator createCoordinator(ImportSourceType sourceType);
}