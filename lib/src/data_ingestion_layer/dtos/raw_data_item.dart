class RawDataItem<RAW_DATA_TYPE> {
  final RAW_DATA_TYPE data; // The actual raw data payload (e.g., File, List<int>, HttpResponse)
  final String sourceIdentifier; // Unique identifier for the source of this item (e.g., file path, URL)
  final String? formatHint; // Optional hint about the format (e.g., file extension like '.mp3')

  RawDataItem({
    required this.data,
    required this.sourceIdentifier,
    this.formatHint,
  });
}