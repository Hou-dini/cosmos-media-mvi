import 'data_format.dart';

class DetectedFormatItem<RAW_DATA_TYPE> {
  final RAW_DATA_TYPE data; // The actual raw data payload
  final String
  sourceIdentifier; // Unique identifier for the source of this item
  final DataFormat format; // The definitively detected format of the raw data

  DetectedFormatItem({
    required this.data,
    required this.sourceIdentifier,
    required this.format,
  });
}
