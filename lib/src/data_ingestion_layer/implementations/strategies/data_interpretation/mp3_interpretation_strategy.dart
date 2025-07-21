import 'dart:io'; // For File
import 'dart:math'; // For random duration in MVI simulation

// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart'; // To ensure it's for song media type
import 'package:path/path.dart' as p; // For path manipulation

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// A concrete implementation of [InterpretationStrategy] for interpreting
/// MP3 files into structured metadata for a 'song' [MediaType].
///
/// For MVI, this strategy simulates MP3 tag extraction by parsing the filename
/// (e.g., "Artist - Song Title.mp3") and assigning a random duration.
class Mp3InterpretationStrategy implements InterpretationStrategy<File> {

  /// Constructs an [Mp3InterpretationStrategy].
  Mp3InterpretationStrategy();

  @override
  InterpretedDataItem interpret(DetectedFormatItem<File> detectedItem) {
    try {
      // 1. Validate input: Ensure it's an MP3 file
      if (detectedItem.format != DataFormat.mp3) {
        throw AppException(
          errorCode: ErrorCode.dilInterpretationStrategyUnsupportedFormat,
          message: 'Mp3InterpretationStrategy received unsupported data format: ${detectedItem.format.name}. Expected MP3.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'Mp3InterpretationStrategy',
            ErrorContextKey.operation: 'interpret',
            ErrorContextKey.sourceIdentifier: detectedItem.sourceIdentifier,
            ErrorContextKey.dataFormat: detectedItem.format.name,
          },
        );
      }

      final File mp3File = detectedItem.data;
      final String fileName = p.basenameWithoutExtension(mp3File.path);

      String artist = 'Unknown Artist';
      String title = fileName;
      int durationMs = 0; // Placeholder, will be randomized

      // 2. Simulate Metadata Extraction (e.g., from filename "Artist - Title")
      final parts = fileName.split(' - ');
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      }

      // 3. Simulate Duration (random for MVI)
      // In a real scenario, you'd parse the MP3 header for actual duration.
      durationMs = Random().nextInt(300000) + 120000; // 2 to 7 minutes in ms


      // 4. Construct InterpretedDataItem
      final Map<String, dynamic> interpretedData = {
        'title': title,
        'artist': artist,
        'durationMs': durationMs,
        'mediaType': MediaType.song.name, // Explicitly state the target media type
        // Add other metadata fields as needed (e.g., album, genre, track number)
      };

      return InterpretedDataItem(
        interpretedData: interpretedData,
        sourceIdentifier: detectedItem.sourceIdentifier,
        format: detectedItem.format,
      );
    } on AppException {
      // Re-throw our custom exception
      rethrow;
    } catch (e, st) {
      // Catch any unexpected errors during interpretation and wrap them in AppException
      throw AppException(
        errorCode: ErrorCode.dilInterpretationStrategyParsingError,
        message: 'Failed to interpret MP3 data from ${detectedItem.sourceIdentifier}: $e',
        stackTrace: st.toString(),
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'Mp3InterpretationStrategy',
          ErrorContextKey.operation: 'interpret',
          ErrorContextKey.sourceIdentifier: detectedItem.sourceIdentifier,
          ErrorContextKey.dataFormat: detectedItem.format.name,
          ErrorContextKey.originalException: e.toString(),
        },
      );
    }
  }
}
