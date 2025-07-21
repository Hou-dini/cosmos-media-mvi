import 'dart:async';
import 'dart:io'; // For File (RAW_DATA_TYPE for DataProvider)

// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';

// --- Import Domain Entities ---
import 'package:cosmos_media_mvi/src/domain_layer/entities/entities.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';

// --- Import DIL Factories ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// A concrete implementation of [DataCoordinator] for orchestrating the
/// Data Ingestion Layer (DIL) pipeline specifically for local data sources.
///
/// This coordinator is responsible for creating, configuring, and chaining
/// [DataProvider], [DataFormatDetector], [DataInterpreter], and [DataTransformer]
/// instances to process raw data into [Media] objects. It also provides
/// status updates and error propagation for the entire pipeline.
class LocalDataCoordinator implements DataCoordinator {
  final DataProviderFactory _dataProviderFactory;
  final DataFormatDetectorFactory _dataFormatDetectorFactory;
  final DataInterpreterFactory _dataInterpreterFactory;
  final DataTransformerFactory _dataTransformerFactory;

  // Internal references to instantiated DIL components
  DataProvider<File>? _dataProvider;
  DataFormatDetector<File>? _dataFormatDetector;
  DataInterpreter<File>? _dataInterpreter;
  DataTransformer? _dataTransformer;

  // StreamControllers for output streams
  final StreamController<Media> _processedDataController = StreamController<Media>.broadcast();
  final StreamController<DILStatusEvent> _statusUpdatesController = StreamController<DILStatusEvent>.broadcast();

  // Keep track of active subscriptions to cancel on dispose
  final List<StreamSubscription> _subscriptions = [];

  // Internal state for progress tracking
  int _processedCount = 0;
  int _errorCount = 0;
  String? _currentOwnerID; // Store ownerID for context in errors/status

  /// Constructs a [LocalDataCoordinator] with factories for all necessary
  /// DIL components. These factories will be used to create specific component
  /// instances during the coordination process.
  LocalDataCoordinator(
    this._dataProviderFactory,
    this._dataFormatDetectorFactory,
    this._dataInterpreterFactory,
    this._dataTransformerFactory,
  );

  @override
  bool isReady() {
    // Factories are guaranteed to be non-null because they are final and
    // initialized in the constructor. This method is primarily for checking
    // runtime state or external configurations if any were applicable here.
    return true; // Always true as long as the object is constructed.
  }

  @override
  void initiateCoordination(ImportSourceConfig config, String ownerID) {
    if (!isReady()) {
      throw AppException(
        errorCode: ErrorCode.dilCoordinatorSetupError,
        message: 'LocalDataCoordinator is not ready. Ensure all factory dependencies are injected.',
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'LocalDataCoordinator',
          ErrorContextKey.operation: 'initiateCoordination',
          ErrorContextKey.ownerID: ownerID,
        },
      );
    }

    // Reset counts for a new initiation
    _processedCount = 0;
    _errorCount = 0;
    _currentOwnerID = ownerID;

    _statusUpdatesController.sink.add(DILStatusEvent(
      type: DILStatusEventType.started,
      message: 'DIL pipeline started for source: ${config.resourceLocation.pathOrUrl}',
      currentStage: 'Initialization',
    ));

    try {
      // 1. Create DIL Components using factories based on ImportSourceType
      _dataProvider = _dataProviderFactory.createProvider(config.sourceType) as DataProvider<File>;
      _dataFormatDetector = _dataFormatDetectorFactory.createDetector(config.sourceType) as DataFormatDetector<File>;
      _dataInterpreter = _dataInterpreterFactory.createInterpreter(config.sourceType) as DataInterpreter<File>;
      _dataTransformer = _dataTransformerFactory.createTransformer(config.sourceType);

      // 2. Configure Components
      _dataProvider!.setResourceLocation(config.resourceLocation);
      _dataProvider!.setMediaType(config.mediaType);
      _dataInterpreter!.setMediaType(config.mediaType);
      _dataTransformer!.setMediaType(config.mediaType);

      // 3. Open DataProvider and check readiness of all components
      _dataProvider!.open(); // This also checks the readiness of its internal strategy

      if (!_dataProvider!.isReady()) {
        throw AppException(
          errorCode: ErrorCode.dilCoordinatorSetupError,
          message: 'DataProvider is not ready after opening.',
          logLevel: LogLevel.critical,
          context: {
            ErrorContextKey.componentName: 'LocalDataCoordinator',
            ErrorContextKey.operation: 'initiateCoordination',
            ErrorContextKey.resourceLocation: config.resourceLocation.pathOrUrl,
            ErrorContextKey.mediaType: config.mediaType.name,
            ErrorContextKey.originalException: 'DataProvider not ready',
          },
        );
      }
      if (!_dataFormatDetector!.isReady()) {
        throw AppException(
          errorCode: ErrorCode.dilCoordinatorSetupError,
          message: 'DataFormatDetector is not ready.',
          logLevel: LogLevel.critical,
          context: {
            ErrorContextKey.componentName: 'LocalDataCoordinator',
            ErrorContextKey.operation: 'initiateCoordination',
            ErrorContextKey.resourceLocation: config.resourceLocation.pathOrUrl,
            ErrorContextKey.mediaType: config.mediaType.name,
            ErrorContextKey.originalException: 'DataFormatDetector not ready',
          },
        );
      }
      if (!_dataInterpreter!.isReady()) {
        throw AppException(
          errorCode: ErrorCode.dilCoordinatorSetupError,
          message: 'DataInterpreter is not ready.',
          logLevel: LogLevel.critical,
          context: {
            ErrorContextKey.componentName: 'LocalDataCoordinator',
            ErrorContextKey.operation: 'initiateCoordination',
            ErrorContextKey.resourceLocation: config.resourceLocation.pathOrUrl,
            ErrorContextKey.mediaType: config.mediaType.name,
            ErrorContextKey.originalException: 'DataInterpreter not ready',
          },
        );
      }
      if (!_dataTransformer!.isReady()) {
        throw AppException(
          errorCode: ErrorCode.dilCoordinatorSetupError,
          message: 'DataTransformer is not ready.',
          logLevel: LogLevel.critical,
          context: {
            ErrorContextKey.componentName: 'LocalDataCoordinator',
            ErrorContextKey.operation: 'initiateCoordination',
            ErrorContextKey.resourceLocation: config.resourceLocation.pathOrUrl,
            ErrorContextKey.mediaType: config.mediaType.name,
            ErrorContextKey.originalException: 'DataTransformer not ready',
          },
        );
      }

      _statusUpdatesController.sink.add(DILStatusEvent(
        type: DILStatusEventType.progress,
        message: 'DIL components initialized and ready.',
        currentStage: 'Data Retrieval',
      ));

      // 4. Chain the streams
      // DataProvider -> DataFormatDetector
      _dataFormatDetector!.detect(_dataProvider!.fetchData());
      final Stream<DetectedFormatItem<File>> detectedDataStream = _dataFormatDetector!.getDetectedData();

      // DataFormatDetector -> DataInterpreter
      _dataInterpreter!.interpret(detectedDataStream);
      final Stream<InterpretedDataItem> interpretedDataStream = _dataInterpreter!.getInterpretedData();

      // DataInterpreter -> DataTransformer
      _dataTransformer!.transform(interpretedDataStream, ownerID);
      final Stream<Media> transformedDataStream = _dataTransformer!.getTransformedData();

      // DataTransformer -> Coordinator's output stream
      _subscriptions.add(transformedDataStream.listen(
        (mediaObject) {
          _processedCount++;
          _processedDataController.sink.add(mediaObject);
          _statusUpdatesController.sink.add(DILStatusEvent(
            type: DILStatusEventType.progress,
            message: 'Processed $_processedCount media items.',
            processedCount: _processedCount,
            currentStage: 'Transformation & Output',
          ));
        },
        onError: (error, stackTrace) {
          _errorCount++;
          // Propagate errors from the pipeline to the coordinator's error sink
          _processedDataController.sink.addError(
            AppException(
              errorCode: ErrorCode.dilCoordinatorPipelineError,
              message: 'Error in DIL pipeline: $error',
              stackTrace: stackTrace.toString(),
              logLevel: LogLevel.error,
              context: {
                ErrorContextKey.componentName: 'LocalDataCoordinator',
                ErrorContextKey.operation: 'pipeline_error',
                ErrorContextKey.ownerID: _currentOwnerID,
                ErrorContextKey.originalException: error.toString(),
              },
            ),
          );
          _statusUpdatesController.sink.add(DILStatusEvent(
            type: DILStatusEventType.progress, // Still progress, but with errors
            message: 'Pipeline encountered an error. Total errors: $_errorCount',
            errorSummary: error.toString(),
            currentStage: 'Error Handling',
          ));
        },
        onDone: () {
          // When the final stream closes, the pipeline is complete
          _statusUpdatesController.sink.add(DILStatusEvent(
            type: _errorCount > 0 ? DILStatusEventType.completedWithErrors : DILStatusEventType.completedSuccessfully,
            message: 'DIL pipeline completed. Processed: $_processedCount, Errors: $_errorCount',
            processedCount: _processedCount,
            errorSummary: _errorCount > 0 ? 'See error stream for details.' : null,
            currentStage: 'Completion',
          ));
          _processedDataController.close(); // Close the output stream
          _statusUpdatesController.close(); // Close the status stream
          dispose(); // Dispose all internal components
        },
      ));

    } on AppException catch (e) {
      // Catch setup errors and propagate them
      _statusUpdatesController.sink.add(DILStatusEvent(
        type: DILStatusEventType.criticalFailure,
        message: 'DIL pipeline failed during setup: ${e.message}',
        errorSummary: e.toString(),
        currentStage: 'Setup Failure',
      ));
      _processedDataController.sink.addError(e); // Also add to processed data error stream
      dispose(); // Dispose components on critical failure
      rethrow; // Re-throw to the caller
    } catch (e, st) {
      // Catch any unexpected critical errors during setup
      final AppException criticalError = AppException(
        errorCode: ErrorCode.dilCoordinatorUnknownError,
        message: 'An unexpected critical error occurred during DIL pipeline initiation: $e',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'LocalDataCoordinator',
          ErrorContextKey.operation: 'initiateCoordination_critical_failure',
          ErrorContextKey.resourceLocation: config.resourceLocation.pathOrUrl,
          ErrorContextKey.mediaType: config.mediaType.name,
          ErrorContextKey.ownerID: _currentOwnerID,
          ErrorContextKey.originalException: e.toString(),
        },
      );
      _statusUpdatesController.sink.add(DILStatusEvent(
        type: DILStatusEventType.criticalFailure,
        message: 'DIL pipeline failed due to unexpected error: ${criticalError.message}',
        errorSummary: criticalError.toString(),
        currentStage: 'Critical Failure',
      ));
      _processedDataController.sink.addError(criticalError); // Add to processed data error stream
      dispose(); // Dispose components on critical failure
      throw criticalError; // Re-throw to the caller
    }
  }

  @override
  Stream<Media> getProcessedData() {
    return _processedDataController.stream;
  }

  @override
  Stream<DILStatusEvent> getStatusUpdates() {
    return _statusUpdatesController.stream;
  }

  @override
  void dispose() {
    // Cancel all active subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Dispose DIL components
    _dataProvider?.close(); // DataProvider has a close method
    _dataFormatDetector?.dispose();
    _dataInterpreter?.dispose();
    _dataTransformer?.dispose();

    // Close internal StreamControllers if they are still open
    if (!_processedDataController.isClosed) {
      _processedDataController.close();
    }
    if (!_statusUpdatesController.isClosed) {
      _statusUpdatesController.close();
    }

    // Nullify references
    _dataProvider = null;
    _dataFormatDetector = null;
    _dataInterpreter = null;
    _dataTransformer = null;
    _currentOwnerID = null;
    _processedCount = 0;
    _errorCount = 0;
  }
}
