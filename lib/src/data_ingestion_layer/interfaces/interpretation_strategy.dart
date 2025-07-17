import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/detected_format_item.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/interpreted_data_item.dart';

/// Defines a contract for concrete strategy objects that encapsulate the
/// algorithms for interpreting raw data of a specific [DataFormat] into
/// structured metadata.
///
/// These strategies are specialized to work with a given [MediaType] and
/// [DataFormat] combination. They consume a [DetectedFormatItem] and produce
/// a fully-formed [InterpretedDataItem], which contains a flexible key-value
/// store of the extracted metadata.
abstract class InterpretationStrategy<RAW_DATA_TYPE> {
  /// Interprets the raw data encapsulated within the provided [detectedItem]
  /// according to this strategy's specific [MediaType] and [DataFormat] capabilities.
  ///
  /// It extracts relevant metadata and encapsulates it into a flexible key-value store.
  /// This method then constructs and returns a complete [InterpretedDataItem],
  /// which includes the extracted metadata, the original [sourceIdentifier],
  /// and the [DataFormat].
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilInterpretationStrategyParsingError]: An error occurred during parsing.
  /// - [ErrorCode.dilInterpretationStrategyInvalidData]: Data is malformed or invalid.
  /// - [ErrorCode.dilInterpretationStrategyUnsupportedFormat]: Strategy cannot handle format.
  /// - [ErrorCode.dilInterpretationStrategyUnknownError]: Any other unexpected errors.
  InterpretedDataItem interpret(DetectedFormatItem<RAW_DATA_TYPE> detectedItem);
}