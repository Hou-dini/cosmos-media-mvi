import 'package:cosmos_media_mvi/domain/media.dart';
import 'package:cosmos_media_mvi/utils.dart/dil_status_event.dart';
import 'package:cosmos_media_mvi/utils.dart/import_source_config.dart';

/// Defines a contract for classes that orchestrate the complete pipeline for
/// retrieving raw data, detecting its format, interpreting it, and transforming
/// it into a continuous [Stream] of fully-formed [Media] objects.
///
/// Implementations mediate between clients' requests for data and the necessary
/// operations to fulfill those requests. This includes coordinating a [DataProvider]
/// for raw data retrieval, a [DataFormatDetector] for identifying the data's
/// precise format, a [DataInterpreter] for parsing raw data into an intermediate
/// format, and a [DataTransformer] for converting intermediate data into [Media]
/// objects (managing [ownerID] propagation during this step).
///
/// The [DataCoordinator] pushes the final processed [Media] objects to its own
/// internal [StreamController] sink, from which they can be consumed via [getProcessedData()].
/// Additionally, it provides pipeline-level status and progress updates via [getStatusUpdates()].
abstract class DataCoordinator {
  /// Checks whether this [DataCoordinator] is in a stable and properly configured state.
  ///
  /// Clients should invoke this operation after configuring this [DataCoordinator]
  /// and before performing any data processing operations to ensure that all
  /// necessary internal components and resources are ready for use.
  ///
  /// Returns `true` if the coordinator is ready to perform operations; `false` otherwise.
  bool isReady();

  /// Unifies and initiates the asynchronous steps involved in the retrieval,
  /// format detection, interpretation, and transformation of data from an external
  /// data source into a continuous flow of [Media] objects.
  ///
  /// This method orchestrates the pipeline by:
  /// 1. Creating [DataProvider], [DataFormatDetector], [DataInterpreter], and
  ///    [DataTransformer] instances using their respective factories, primarily
  ///    based on [config.sourceType].
  /// 2. Configuring the created [DataProvider] with [config.resourceLocation]
  ///    and setting its [MediaType] ([config.mediaType]). It also calls [DataProvider.open()].
  /// 3. Configuring the created [DataInterpreter] and [DataTransformer] by
  ///    setting their [MediaType] ([config.mediaType]).
  /// 4. Calling [DataProvider.fetchData()] to get the raw [RawDataItem] stream.
  /// 5. Calling [DataFormatDetector.detect()] with the [RawDataItem] stream to
  ///    produce [DetectedFormatItem] stream.
  /// 6. Calling [DataInterpreter.interpret()] with the [DetectedFormatItem] stream
  ///    to produce [InterpretedDataItem] stream.
  /// 7. Calling [DataTransformer.transform()] with the [InterpretedDataItem] stream
  ///    and the provided [ownerID] to produce [Media] stream.
  /// 8. Consuming the [Media] output stream from the [DataTransformer] and pushing
  ///    these final [Media] objects into this [DataCoordinator]'s own internal
  ///    [StreamController] sink for processed data.
  /// 9. Emitting [DILStatusEvent]s to its internal status sink to report progress
  ///    and overall pipeline state.
  ///
  /// The processed [Media] objects become available through [getProcessedData()].
  /// This operation is non-blocking.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilCoordinatorSetupError]: An error occurred during initial setup.
  /// - [ErrorCode.dilCoordinatorResourceAccessError]: Data source is inaccessible.
  /// - [ErrorCode.dilCoordinatorInvalidConfigError]: Provided [ImportSourceConfig] is invalid.
  /// - [ErrorCode.dilCoordinatorUnknownError]: Any other unexpected errors during initiation.
  void initiateCoordination(ImportSourceConfig config, String ownerID);

  /// Retrieves a [Stream] for consuming a continuous flow of fully processed [Media]
  /// objects from this [DataCoordinator]'s internal [StreamController] sink.
  ///
  /// This provides the final output stream of the DIL pipeline, allowing clients
  /// to "pull" the results after [initiateCoordination()] has been called and
  /// the DIL pipeline is active. This operation is non-blocking.
  ///
  /// Returns a [Stream] of [Media] providing access to the processed [Media] objects.
  Stream<Media> getProcessedData();

  /// Retrieves a [Stream] for consuming a continuous flow of [DILStatusEvent]
  /// objects from this [DataCoordinator]'s internal status [StreamController] sink.
  ///
  /// Clients can subscribe to this stream to receive high-level updates on the
  /// progress and overall state of the data ingestion pipeline. This operation is non-blocking.
  ///
  /// Returns a [Stream] of [DILStatusEvent] providing access to pipeline status updates.
  Stream<DILStatusEvent> getStatusUpdates();

  /// Releases resources used by this [DataCoordinator] or its dependencies,
  /// including any active [DataProvider], [DataFormatDetector], [DataInterpreter],
  /// [DataTransformer] instances it manages, their internal sinks, and the
  /// [DataCoordinator]'s own internal sinks.
  ///
  /// This method should be called when the coordination task is complete or cancelled.
  void dispose();
}