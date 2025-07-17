import 'package:cosmos_media_mvi/data_ingestion/interpretation_strategy.dart';
import 'package:cosmos_media_mvi/domain/media_type.dart';
import 'package:cosmos_media_mvi/utils.dart/data_format.dart';

/// Defines a contract for creating instances of [InterpretationStrategy].
///
/// This factory is responsible for dynamically selecting and instantiating the
/// appropriate concrete [InterpretationStrategy] implementation based on the
/// provided [MediaType] and the specific [DataFormat].
abstract class InterpretationStrategyFactory {
  /// Creates and returns a new instance of an [InterpretationStrategy] that is
  /// tailored for the specified [MediaType] and [DataFormat].
  ///
  /// This method will internally use both parameters to query a DI container,
  /// which resolves and provides the correct concrete [InterpretationStrategy] implementation.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilInterpretationStrategyFactoryCreationError]: A general error occurred during creation.
  /// - [ErrorCode.dilInterpretationStrategyFactoryUnsupportedStrategyCombination]: Combination is not supported.
  InterpretationStrategy createInterpretationStrategy(MediaType mediaType, DataFormat dataFormat);
}