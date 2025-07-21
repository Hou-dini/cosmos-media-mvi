import 'dart:async';
import 'dart:io'; // For File

// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// A concrete implementation of [DataInterpreter] for local data sources.
///
/// This interpreter consumes a stream of [DetectedFormatItem]s, and for each item,
/// it delegates the actual interpretation logic to an appropriate [InterpretationStrategy].
/// The strategy is created via an injected [InterpretationStrategyFactory]
/// based on the configured [MediaType] and the item's [DataFormat].
class LocalDataInterpreter implements DataInterpreter<File> {
  final InterpretationStrategyFactory _interpretationStrategyFactory;

  MediaType? _mediaType;
  // StreamController to manage the output stream of InterpretedDataItem
  final StreamController<InterpretedDataItem> _outputController =
      StreamController<InterpretedDataItem>.broadcast();

  /// Constructs a [LocalDataInterpreter] with an [InterpretationStrategyFactory]
  /// for creating specific interpretation strategies.
  LocalDataInterpreter(this._interpretationStrategyFactory);

  @override
  bool isReady() {
    // Readiness depends on the MediaType being set.
    return _mediaType != null;
  }

  @override
  void interpret(Stream<DetectedFormatItem<File>> inputFlow) {
    if (!isReady()) {
      throw AppException(
        errorCode: ErrorCode.dilInterpretationSetupError,
        message: 'LocalDataInterpreter is not ready. MediaType must be set before calling interpret().',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataInterpreter',
          ErrorContextKey.operation: 'interpret',
          ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
        },
      );
    }

    inputFlow.listen(
      (detectedItem) async {
        try {
          // Create the specific interpretation strategy using the factory
          // The factory will select the correct strategy based on _mediaType and detectedItem.format
          final InterpretationStrategy<File> strategy =
              _interpretationStrategyFactory.createInterpretationStrategy(
            _mediaType!, // Use the configured media type
            detectedItem.format,
          ) as InterpretationStrategy<File>; // Cast to InterpretationStrategy<File>

          // Delegate the interpretation to the strategy
          final InterpretedDataItem interpretedDataItem =
              strategy.interpret(detectedItem);

          _outputController.sink.add(interpretedDataItem);
        } on AppException catch (e) {
          // If our own AppException is thrown, add it to the error sink
          _outputController.sink.addError(e);
        } catch (e, st) {
          // Catch any unexpected errors during interpretation and add to error sink
          _outputController.sink.addError(
            AppException(
              errorCode: ErrorCode.dilInterpretationParsingError,
              message: 'Failed to interpret data from ${detectedItem.sourceIdentifier}: $e',
              stackTrace: st.toString(),
              logLevel: LogLevel.error,
              context: {
                ErrorContextKey.componentName: 'LocalDataInterpreter',
                ErrorContextKey.operation: 'interpret_item',
                ErrorContextKey.sourceIdentifier: detectedItem.sourceIdentifier,
                ErrorContextKey.dataFormat: detectedItem.format.name,
                ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
                ErrorContextKey.originalException: e.toString(),
              },
            ),
          );
        }
      },
      onError: (error, stackTrace) {
        // Propagate errors from the upstream input flow
        _outputController.sink.addError(
          AppException(
            errorCode: ErrorCode.dilInterpretationUpstreamError,
            message: 'Upstream error in DataInterpreter input flow: $error',
            stackTrace: stackTrace.toString(),
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'LocalDataInterpreter',
              ErrorContextKey.operation: 'interpret_input_flow_error',
              ErrorContextKey.originalException: error.toString(),
            },
          ),
        );
      },
      onDone: () {
        // When the input stream closes, close the output stream
        _outputController.close();
      },
      cancelOnError: false, // Don't cancel the subscription on first error
    );
  }

  @override
  Stream<InterpretedDataItem> getInterpretedData() {
    return _outputController.stream;
  }

  @override
  void setMediaType(MediaType type) {
    _mediaType = type;
  }

  @override
  MediaType getMediaType() {
    if (_mediaType == null) {
      throw AppException(
        errorCode: ErrorCode.dilInterpretationSetupError,
        message: 'MediaType has not been set for LocalDataInterpreter.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataInterpreter',
          ErrorContextKey.operation: 'getMediaType',
        },
      );
    }
    return _mediaType!;
  }

  @override
  void dispose() {
    _outputController.close();
  }
}
