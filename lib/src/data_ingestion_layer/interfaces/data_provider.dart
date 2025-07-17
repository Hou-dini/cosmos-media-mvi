import 'package:cosmos_media_mvi/src/core/enums/media_type.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/raw_data_item.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/resource_change_event.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/resource_location_config.dart';

/// Defines a contract for classes that interact with external systems to retrieve
/// raw data and optionally monitor for changes in the external source.
///
/// Implementations standardize raw data retrieval and change detection operations
/// across various systems. It delegates raw data retrieval operations to a
/// [DataRetrievalStrategy] object, selected via a [DataRetrievalStrategyFactory]
/// based on the provider's [ImportSourceType] and its configured [MediaType].
///
/// It acts as a source for a continuous [Stream] of [RawDataItem] via [fetchData()],
/// and can also provide a continuous [Stream] of [ResourceChangeEvent] via [watchForChanges()].
abstract class DataProvider<RAW_DATA_TYPE> {
  /// Checks whether this [DataProvider] is in a stable and properly configured state.
  ///
  /// Clients should invoke this operation after configuring this [DataProvider]
  /// and before performing any fetch or watch operations to ensure that all
  /// necessary fields are set and the [DataProvider] is ready for use.
  ///
  /// Checks Performed:
  /// - Verification that a [ResourceLocationConfig] has been set.
  /// - Verification that a [MediaType] has been set.
  /// - Confirmation that essential internal dependencies (e.g., [DataRetrievalStrategyFactory])
  ///   are properly injected and initialized.
  /// - (If applicable) Basic connectivity checks to the external source without
  ///   initiating data transfer.
  ///
  /// Returns `true` if the provider is ready to perform operations; `false` otherwise.
  bool isReady();

  /// Initiates the retrieval of raw data from the configured resource location.
  ///
  /// It returns a [Stream] for continuous delivery of [RawDataItem] objects.
  /// Each [RawDataItem] contains the raw payload ([RAW_DATA_TYPE]), a [sourceIdentifier],
  /// and any initial [formatHint]. This operation is non-blocking, providing
  /// data elements as they become available.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilProviderAccessDeniedError]: The application does not have permission.
  /// - [ErrorCode.dilProviderPathMissingError]: The specified resource location does not exist.
  /// - [ErrorCode.dilProviderAuthenticationError]: Authentication is incorrect.
  /// - [ErrorCode.dilProviderUnknownError]: Any other unexpected errors.
  Stream<RawDataItem<RAW_DATA_TYPE>> fetchData();

  /// Initiates a continuous monitoring process on the configured [ResourceLocationConfig]
  /// to detect changes (additions, modifications, deletions) in the external data source.
  ///
  /// It returns a [Stream] for continuous delivery of [ResourceChangeEvent] objects.
  /// Each event describes a specific change detected. This operation is non-blocking
  /// and continues until [close()] is called on the provider.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilProviderWatchUnsupported]: The implementation does not support watching.
  /// - [ErrorCode.dilProviderWatchSetupError]: An error occurred during setup.
  /// - [ErrorCode.dilProviderWatchAccessDenied]: Lacks permissions to set up watching.
  /// - [ErrorCode.dilProviderWatchUnknownError]: Any other unexpected errors.
  Stream<ResourceChangeEvent> watchForChanges();

  /// Sets or updates the configuration for accessing the external data source.
  ///
  /// This [ResourceLocationConfig] object encapsulates all necessary details,
  /// including paths/URLs and any required authentication credentials.
  void setResourceLocation(ResourceLocationConfig location);

  /// Retrieves the current [ResourceLocationConfig] that is configured for this [DataProvider].
  ResourceLocationConfig getResourceLocation();

  /// Sets or updates the [MediaType] configured for this [DataProvider].
  ///
  /// This crucial setting informs the [DataProvider] about the expected type of [Media]
  /// that will eventually be produced, enabling it to select or configure the
  /// appropriate [DataRetrievalStrategy].
  void setMediaType(MediaType type);

  /// Retrieves the current [MediaType] configured for this [DataProvider].
  MediaType getMediaType();

  /// Establishes a connection or initializes resources necessary for data retrieval
  /// and change watching operations with the configured [ResourceLocationConfig] and [MediaType].
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilProviderConnectionError]: Indicates an error in establishing a connection.
  void open();

  /// Releases resources used by this data provider, including any active watch mechanisms.
  /// Implementations should ensure this operation is idempotent.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilProviderResourceReleaseError]: Indicates an error during resource cleanup.
  void close();
}