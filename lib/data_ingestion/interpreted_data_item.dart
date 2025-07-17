import 'data_format.dart';

class InterpretedDataItem {
  final Map<String, dynamic>
  interpretedData; // Flexible key-value store of extracted metadata
  final String
  sourceIdentifier; // Unique identifier for the source of this item
  final DataFormat
  format; // The original format of the data before interpretation

  InterpretedDataItem({
    required this.interpretedData,
    required this.sourceIdentifier,
    required this.format,
  });
}
