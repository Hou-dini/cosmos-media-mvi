import 'dart:async';

// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';

// --- Import Domain Entities ---
import 'package:cosmos_media_mvi/src/domain_layer/entities/entities.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// A concrete implementation of [DataTransformer] for local data sources.
///
/// This transformer consumes a stream of [InterpretedDataItem]s, and for each item,
/// it delegates the actual transformation logic to an appropriate [TransformationStrategy].
/// The strategy is created via an injected [TransformationStrategyFactory]
/// based on the configured [MediaType] and the item's [DataFormat].
class LocalDataTransformer implements DataTransformer {
  final TransformationStrategyFactory _transformationStrategyFactory;

  MediaType? _mediaType;
  // StreamController to manage the output stream of Media objects
  final StreamController<Media> _outputController =
      StreamController<Media>.broadcast();

  /// Constructs a [LocalDataTransformer] with a [TransformationStrategyFactory]
  /// for creating specific transformation strategies.
  LocalDataTransformer(this._transformationStrategyFactory);

  @override
  bool isReady() {
    // Readiness depends on the MediaType being set.
    return _mediaType != null;
  }

  @override
  void transform(Stream<InterpretedDataItem> inputFlow, String ownerID) {
    if (!isReady()) {
      throw AppException(
        errorCode: ErrorCode.dilTransformationSetupError,
        message: 'LocalDataTransformer is not ready. MediaType must be set before calling transform().',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataTransformer',
          ErrorContextKey.operation: 'transform',
          ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
          ErrorContextKey.ownerID: ownerID,
        },
      );
    }

    inputFlow.listen(
      (interpretedItem) async {
        try {
          // Create the specific transformation strategy using the factory
          // The factory will select the correct strategy based on _mediaType and interpretedItem.format
          final TransformationStrategy strategy =
              _transformationStrategyFactory.createTransformationStrategy(
            _mediaType!, // Use the configured media type
            interpretedItem.format,
          );

          // Delegate the transformation to the strategy
          final Media mediaObject = strategy.transform(interpretedItem, ownerID);

          _outputController.sink.add(mediaObject);
        } on AppException catch (e) {
          // If our own AppException is thrown, add it to the error sink
          _outputController.sink.addError(e);
        } catch (e, st) {
          // Catch any unexpected errors during transformation and add to error sink
          _outputController.sink.addError(
            AppException(
              errorCode: ErrorCode.dilTransformationMappingError,
              message: 'Failed to transform interpreted data from ${interpretedItem.sourceIdentifier} into Media object: $e',
              stackTrace: st.toString(),
              logLevel: LogLevel.error,
              context: {
                ErrorContextKey.componentName: 'LocalDataTransformer',
                ErrorContextKey.operation: 'transform_item',
                ErrorContextKey.sourceIdentifier: interpretedItem.sourceIdentifier,
                ErrorContextKey.dataFormat: interpretedItem.format.name,
                ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
                ErrorContextKey.ownerID: ownerID,
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
            errorCode: ErrorCode.dilTransformationUpstreamError,
            message: 'Upstream error in DataTransformer input flow: $error',
            stackTrace: stackTrace.toString(),
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'LocalDataTransformer',
              ErrorContextKey.operation: 'transform_input_flow_error',
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
  Stream<Media> getTransformedData() {
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
        errorCode: ErrorCode.dilTransformationSetupError,
        message: 'MediaType has not been set for LocalDataTransformer.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataTransformer',
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
