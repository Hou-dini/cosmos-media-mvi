import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/data_interpreter.dart';
import 'package:cosmos_media_mvi/src/core/enums/import_source_type.dart';

/// Defines a contract for creating instances of [DataInterpreter].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [DataInterpreter] implementation based on the provided
/// [ImportSourceType]. It leverages a Dependency Injection (DI) container
/// to resolve and provide the correct [DataInterpreter] implementation.
abstract class DataInterpreterFactory {
  /// Creates and returns a new instance of a [DataInterpreter] that is
  /// conceptually designed to handle raw data originating from the specified [ImportSourceType].
  ///
  /// This method will internally use the [sourceType] to query a DI container,
  /// which resolves and provides the correct concrete [DataInterpreter] implementation.
  /// The returned interpreter will later be configured with the specific [MediaType]
  /// by its client ([DataCoordinator]).
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilInterpreterFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilInterpretationUnsupportedSourceType]: The [sourceType] is not supported.
  DataInterpreter createInterpreter(ImportSourceType sourceType);
}