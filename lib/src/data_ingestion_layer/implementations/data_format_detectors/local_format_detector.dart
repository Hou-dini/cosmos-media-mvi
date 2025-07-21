import 'dart:async';
import 'dart:io'; // For File
import 'package:path/path.dart' as p; // For path manipulation

// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// A concrete implementation of [DataFormatDetector] for local file system sources.
///
/// This detector analyzes [RawDataItem] objects (containing [File] data) to
/// determine their [DataFormat]. For the MVI, it primarily relies on file
/// extensions to detect common media formats like MP3.
class LocalDataFormatDetector implements DataFormatDetector<File> {
  // StreamController to manage the output stream of DetectedFormatItem
  final StreamController<DetectedFormatItem<File>> _outputController =
      StreamController<DetectedFormatItem<File>>.broadcast();

  /// Constructs a [LocalDataFormatDetector].
  LocalDataFormatDetector();

  @override
  bool isReady() {
    // For this simple detector, readiness implies it's initialized.
    // No external dependencies or complex setup required beyond construction.
    return true;
  }

  @override
  void detect(Stream<RawDataItem<File>> inputFlow) {
    inputFlow.listen(
      (rawDataItem) async {
        try {
          final File file = rawDataItem.data;
          final String fileExtension = p.extension(file.path).toLowerCase();
          DataFormat? detectedFormat;

          // Simple detection based on file extension for MVI
          switch (fileExtension) {
            case '.mp3':
              detectedFormat = DataFormat.mp3;
              break;
            // Add more cases for other formats as needed in a full implementation
            // case '.mp4':
            //   detectedFormat = DataFormat.mpeg4;
            //   break;
            // case '.wav':
            //   detectedFormat = DataFormat.wav;
            //   break;
            default:
              // If no specific format is detected, we can throw an error or
              // assign an 'unknown' format if we had one. For MVI, we throw.
              throw AppException(
                errorCode: ErrorCode.dilFormatDetectionUnsupported,
                message: 'Unsupported file format detected for: ${rawDataItem.sourceIdentifier}. Extension: $fileExtension',
                logLevel: LogLevel.warning, // Warning level as it's a known unsupported case
                context: {
                  ErrorContextKey.componentName: 'LocalDataFormatDetector',
                  ErrorContextKey.operation: 'detect',
                  ErrorContextKey.sourceIdentifier: rawDataItem.sourceIdentifier,
                  ErrorContextKey.originalException: 'Unsupported file extension',
                  ErrorContextKey.dataFormat: fileExtension,
                },
              );
          }

          _outputController.sink.add(
            DetectedFormatItem<File>(
              data: rawDataItem.data,
              sourceIdentifier: rawDataItem.sourceIdentifier,
              format: detectedFormat,
            ),
          );
                } on AppException catch (e) {
          // If our own AppException is thrown, add it to the error sink
          _outputController.sink.addError(e);
        } catch (e, st) {
          // Catch any unexpected errors during detection and add to error sink
          _outputController.sink.addError(
            AppException(
              errorCode: ErrorCode.dilFormatDetectionFailed,
              message: 'Failed to detect format for ${rawDataItem.sourceIdentifier}: $e',
              stackTrace: st.toString(),
              logLevel: LogLevel.error,
              context: {
                ErrorContextKey.componentName: 'LocalDataFormatDetector',
                ErrorContextKey.operation: 'detect',
                ErrorContextKey.sourceIdentifier: rawDataItem.sourceIdentifier,
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
            errorCode: ErrorCode.dilFormatDetectionUpstreamError,
            message: 'Upstream error in DataFormatDetector input flow: $error',
            stackTrace: stackTrace.toString(),
            logLevel: LogLevel.error,
            context: {
              ErrorContextKey.componentName: 'LocalDataFormatDetector',
              ErrorContextKey.operation: 'detect_input_flow_error',
              ErrorContextKey.originalException: error.toString(),
            },
          ),
        );
      },
      onDone: () {
        // When the input stream closes, close the output stream
        _outputController.close();
      },
      cancelOnError: false, // Don't cancel the subscription on first error, allow processing subsequent items
    );
  }

  @override
  Stream<DetectedFormatItem<File>> getDetectedData() {
    return _outputController.stream;
  }

  @override
  void dispose() {
    _outputController.close();
  }
}
