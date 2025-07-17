import 'package:cosmos_media_mvi/domain/media_type.dart';
import 'package:cosmos_media_mvi/utils.dart/detected_format_item.dart';
import 'package:cosmos_media_mvi/utils.dart/interpreted_data_item.dart';

/// Defines a contract for classes that interpret raw data.
///
/// By implementing this interface, classes transform a [Stream] of raw,
/// format-identified data ([DetectedFormatItem]) into a [Stream] of structured,
/// intermediate format ([InterpretedDataItem]). This interpretation is performed
/// by delegating to an internal [InterpretationStrategy], which is selected
/// or configured based on both the [MediaType] and the [DataFormat] identified
/// in the input item.
abstract class DataInterpreter<RAW_DATA_TYPE> {
  /// Checks whether this [DataInterpreter] is in a stable and properly configured state.
  ///
  /// Clients should invoke this operation after configuring this [DataInterpreter]
  /// and before performing any interpretation operations.
  ///
  /// Returns `true` if the interpreter is ready; `false` otherwise.
  bool isReady();

  /// Initiates the interpretation of raw data by consuming [DetectedFormatItem]
  /// objects from the [inputFlow].
  ///
  /// For each [DetectedFormatItem], the item is passed to an internal
  /// [InterpretationStrategy] (selected based on the current [MediaType] and
  /// the [DataFormat] within the item). The [InterpretationStrategy] directly
  /// returns a complete [InterpretedDataItem], which is then pushed to this
  /// [DataInterpreter]'s internal [StreamController] sink. This operation is non-blocking.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilInterpretationSetupError]: An error occurred during initial setup.
  /// - [ErrorCode.dilUnknownError]: Covers any other unexpected errors during setup.
  void interpret(Stream<DetectedFormatItem<RAW_DATA_TYPE>> inputFlow);

  /// Retrieves a [Stream] for consuming a continuous flow of [InterpretedDataItem]
  /// objects from this [DataInterpreter]'s internal [StreamController] sink.
  ///
  /// Clients can subscribe to or iterate over this stream to receive items as they
  /// become available. This operation is non-blocking.
  ///
  /// Returns a [Stream] of [InterpretedDataItem] providing access to the interpreted data.
  Stream<InterpretedDataItem> getInterpretedData();

  /// Sets or updates the [MediaType] configured for this [DataInterpreter].
  ///
  /// This setting is used to inform the interpreter about the expected type of [Media]
  /// that will eventually be produced, enabling it to select or configure the
  /// appropriate [InterpretationStrategy] for parsing.
  void setMediaType(MediaType type);

  /// Retrieves the current [MediaType] configured for this [DataInterpreter].
  MediaType getMediaType();

  /// Releases resources used by this [DataInterpreter] or its dependencies,
  /// including its internal [StreamController] sink.
  void dispose();
}