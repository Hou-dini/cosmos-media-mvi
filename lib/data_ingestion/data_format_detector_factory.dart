import 'package:cosmos_media_mvi/data_ingestion/data_format_detector.dart';
import 'package:cosmos_media_mvi/utils.dart/import_source_type.dart';

/// Defines a contract for creating instances of [DataFormatDetector].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [DataFormatDetector] implementation based on the provided
/// [ImportSourceType]. It leverages a Dependency Injection (DI) container
/// to resolve and provide the correct [DataFormatDetector] implementation.
abstract class DataFormatDetectorFactory {
  /// Creates and returns a new instance of a [DataFormatDetector] that is
  /// conceptually designed to handle raw data originating from the specified [ImportSourceType].
  ///
  /// This method will internally use the [sourceType] to query a DI container,
  /// which resolves and provides the correct concrete [DataFormatDetector] implementation.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilFormatDetectorFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilFormatDetectionUnsupported]: The [sourceType] is not supported.
  DataFormatDetector createDetector(ImportSourceType sourceType);
}