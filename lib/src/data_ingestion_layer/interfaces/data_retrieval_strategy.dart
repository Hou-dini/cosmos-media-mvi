import 'package:cosmos_media_mvi/src/core/enums/media_type.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/raw_data_item.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/resource_location_config.dart';

/// Defines a contract for concrete strategy objects that encapsulate the
/// algorithms for retrieving raw data from specific external sources.
///
/// Implementations enhance modularity and ensure a more flexible and maintainable
/// codebase. This interface guarantees a standard and consistent method for
/// data retrieval across various implementations of [DataProvider], providing
/// a continuous [Stream] of data encapsulated within [RawDataItem].
/// It operates using a standardized [ResourceLocationConfig] and can be configured
/// with a [MediaType] to optimize retrieval.
abstract class DataRetrievalStrategy<RAW_DATA_TYPE> {
  /// Checks whether this [DataRetrievalStrategy] is in a stable and properly configured state.
  ///
  /// Clients should invoke this operation after configuring this [DataRetrievalStrategy]
  /// and before performing any data retrieval operations to ensure that all
  /// necessary fields are set and the strategy is ready for use.
  ///
  /// Checks Performed:
  /// - Verification that a [ResourceLocationConfig] has been set and, if applicable,
  ///   that it represents a valid or accessible path/URL format.
  /// - Verification that a [MediaType] has been set (if required by the strategy).
  /// - (If applicable) Any necessary internal resources or state are prepared for
  ///   the retrieval process (e.g., database connection pools initialized, network client configured).
  /// - (If applicable) Basic validation of credentials contained within [ResourceLocationConfig].
  ///
  /// Returns `true` if the strategy is ready to perform operations; `false` otherwise.
  bool isReady();

  /// Initiates the retrieval of raw data from an external data source, utilizing
  /// the internally set [ResourceLocationConfig] and [MediaType], and returns a [Stream] for
  /// continuous delivery of [RawDataItem] objects.
  ///
  /// This operation is non-blocking, providing data elements as they become available.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilRetrievalStrategyAccessDeniedError]: The application does not have permission to access the resource.
  /// - [ErrorCode.dilRetrievalStrategyPathMissingError]: The specified resource location does not exist.
  /// - [ErrorCode.dilRetrievalStrategyAuthenticationError]: The provided authentication is incorrect or insufficient.
  /// - [ErrorCode.dilRetrievalStrategyUnknownError]: For any other unexpected errors.
  Stream<RawDataItem<RAW_DATA_TYPE>> retrieveData();

  /// Sets or updates the resource location configured for this [DataRetrievalStrategy].
  ///
  /// This [ResourceLocationConfig] object encapsulates all necessary details,
  /// including paths/URLs and any required authentication credentials.
  /// This operation ensures that subsequent data retrieval operations use the specified location.
  void setResourceLocation(ResourceLocationConfig location);

  /// Retrieves the current [ResourceLocationConfig] that is configured for this [DataRetrievalStrategy].
  ResourceLocationConfig getResourceLocation();

  /// Sets or updates the [MediaType] configured for this [DataRetrievalStrategy].
  ///
  /// This setting can inform the strategy about the expected type of [Media]
  /// to be retrieved, allowing for optimized retrieval (e.g., filtering by file type).
  void setMediaType(MediaType type);

  /// Retrieves the current [MediaType] configured for this [DataRetrievalStrategy].
  MediaType getMediaType();
}