import 'package:cosmos_media_mvi/utils.dart/resource_change_event_type.dart';

class ResourceChangeEvent {
  final ResourceChangeType type;
  final String resourceIdentifier;
  final Map<String, dynamic>? resourceMetadata;
  final dynamic rawData; // Use dynamic for RAW_DATA_TYPE to avoid generic complexity here

  ResourceChangeEvent({
    required this.type,
    required this.resourceIdentifier,
    this.resourceMetadata,
    this.rawData,
  });
}