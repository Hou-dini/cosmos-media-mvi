import 'package:cosmos_media_mvi/utils.dart/detected_format_item.dart';
import 'package:cosmos_media_mvi/utils.dart/raw_data_item.dart';

/// Defines a contract for classes that detect the specific data format of raw data.
///
/// Implementations consume a [Stream] of [RawDataItem] and produce a [Stream]
/// of [DetectedFormatItem], encapsulating the raw data with its definitively
/// identified [DataFormat]. This component standardizes format detection operations
/// across various raw data sources.
abstract class DataFormatDetector<RAW_DATA_TYPE> {
  /// Checks whether this [DataFormatDetector] is in a stable and properly configured state.
  ///
  /// Clients should invoke this operation after configuring this [DataFormatDetector]
  /// and before performing any detection operations to ensure that all necessary
  /// internal components and resources are ready for use.
  ///
  /// Returns `true` if the detector is ready to perform operations; `false` otherwise.
  bool isReady();

  /// Initiates the detection of data formats by consuming [RawDataItem] objects
  /// from the [inputFlow].
  ///
  /// For each [RawDataItem], it analyzes the raw data payload to definitively
  /// identify its [DataFormat]. The raw data is then encapsulated along with its
  /// [sourceIdentifier] and the detected [DataFormat] into a [DetectedFormatItem],
  /// which is pushed to this [DataFormatDetector]'s internal [StreamController] sink.
  /// This operation is non-blocking and sets up the detection process.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilFormatDetectionFailed]: A general error occurred during detection setup.
  /// - [ErrorCode.dilUnknownError]: Covers any other unexpected errors during detection setup.
  void detect(Stream<RawDataItem<RAW_DATA_TYPE>> inputFlow);

  /// Retrieves a [Stream] for consuming a continuous flow of [DetectedFormatItem]
  /// objects from this [DataFormatDetector]'s internal [StreamController] sink.
  ///
  /// Clients can subscribe to or iterate over this stream to receive items as they
  /// become available. This operation is non-blocking.
  ///
  /// Returns a [Stream] of [DetectedFormatItem] providing access to the detected data.
  Stream<DetectedFormatItem<RAW_DATA_TYPE>> getDetectedData();

  /// Releases resources used by this [DataFormatDetector] or its dependencies,
  /// including its internal [StreamController] sink.
  void dispose();
}