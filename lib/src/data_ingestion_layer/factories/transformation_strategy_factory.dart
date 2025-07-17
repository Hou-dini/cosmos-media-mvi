import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/transformation_strategy.dart';
import 'package:cosmos_media_mvi/src/core/enums/media_type.dart';
import 'package:cosmos_media_mvi/src/core/enums/data_format.dart';

/// Defines a contract for creating instances of [TransformationStrategy].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [TransformationStrategy] implementation based on the
/// provided [MediaType] and the specific [DataFormat].
abstract class TransformationStrategyFactory {
  /// Creates and returns a new instance of a [TransformationStrategy] that is
  /// tailored for the specified [MediaType] and [DataFormat].
  ///
  /// This method will internally use both parameters to query a DI container,
  /// which resolves and provides the correct concrete [TransformationStrategy] implementation.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilTransformationStrategyFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilTransformationStrategyFactoryUnsupportedStrategyCombination]: Combination is not supported.
  TransformationStrategy createTransformationStrategy(MediaType mediaType, DataFormat dataFormat);
}