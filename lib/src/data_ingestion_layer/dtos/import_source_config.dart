import 'package:cosmos_media_mvi/src/core/enums/media_type.dart';
import 'package:cosmos_media_mvi/src/core/enums/import_source_type.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/resource_location_config.dart';

/// A DTO encapsulating all necessary configuration details for a media import operation.
///
/// This includes the type of source, the specific resource location, the expected
/// media type, and any additional parameters relevant to the import.
class ImportSourceConfig {
  final ImportSourceType sourceType;
  final ResourceLocationConfig resourceLocation;
  final MediaType mediaType;
  final Map<String, dynamic>? additionalParams; // For future extensibility

  ImportSourceConfig({
    required this.sourceType,
    required this.resourceLocation,
    required this.mediaType,
    this.additionalParams,
  });
}