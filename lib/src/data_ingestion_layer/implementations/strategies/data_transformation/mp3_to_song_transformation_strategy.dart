// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';

// --- Import Domain Entities ---
import 'package:cosmos_media_mvi/src/domain_layer/entities/entities.dart'; // For Media abstract class
// & Concrete Song class

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';

/// A concrete implementation of [TransformationStrategy] for transforming
/// interpreted MP3 data into a [Song] domain object.
///
/// This strategy expects an [InterpretedDataItem] that was generated from an
/// MP3 file and contains 'title', 'artist', 'durationMs', and 'mediaType' (as 'song').
class Mp3ToSongTransformationStrategy implements TransformationStrategy {
  /// Constructs an [Mp3ToSongTransformationStrategy].
  Mp3ToSongTransformationStrategy();

  @override
  Media transform(InterpretedDataItem interpretedItem, String ownerID) {
    try {
      // 1. Validate input: Ensure it's the expected format and media type
      if (interpretedItem.format != DataFormat.mp3) {
        throw AppException(
          errorCode: ErrorCode.dilTransformationStrategyUnsupportedFormat,
          message:
              'Mp3ToSongTransformationStrategy received unsupported data format: ${interpretedItem.format.name}. Expected MP3.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'Mp3ToSongTransformationStrategy',
            ErrorContextKey.operation: 'transform',
            ErrorContextKey.sourceIdentifier: interpretedItem.sourceIdentifier,
            ErrorContextKey.dataFormat: interpretedItem.format.name,
          },
        );
      }

      // Check if the interpreted data explicitly states it's for a song
      final String? mediaTypeHint =
          interpretedItem.interpretedData['mediaType'];
      if (mediaTypeHint == null || mediaTypeHint != MediaType.song.name) {
        throw AppException(
          errorCode: ErrorCode.dilTransformationStrategyInvalidData,
          message:
              'Interpreted data does not indicate MediaType.song. Found: $mediaTypeHint.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'Mp3ToSongTransformationStrategy',
            ErrorContextKey.operation: 'transform',
            ErrorContextKey.sourceIdentifier: interpretedItem.sourceIdentifier,
            ErrorContextKey.dataFormat: interpretedItem.format.name,
            ErrorContextKey.mediaType: mediaTypeHint,
          },
        );
      }

      // 2. Extract and validate required fields from interpretedData
      final String? title = interpretedItem.interpretedData['title'];
      final String? artist = interpretedItem.interpretedData['artist'];
      final int? durationMs = interpretedItem.interpretedData['durationMs'];

      if (title == null || title.isEmpty) {
        throw AppException(
          errorCode: ErrorCode.dilTransformationStrategyInvalidData,
          message:
              'Missing or empty "title" in interpreted data for song transformation.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'Mp3ToSongTransformationStrategy',
            ErrorContextKey.operation: 'transform',
            ErrorContextKey.sourceIdentifier: interpretedItem.sourceIdentifier,
            ErrorContextKey.dataFormat: interpretedItem.format.name,
            ErrorContextKey.originalException: 'Missing title',
          },
        );
      }
      if (artist == null || artist.isEmpty) {
        throw AppException(
          errorCode: ErrorCode.dilTransformationStrategyInvalidData,
          message:
              'Missing or empty "artist" in interpreted data for song transformation.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'Mp3ToSongTransformationStrategy',
            ErrorContextKey.operation: 'transform',
            ErrorContextKey.sourceIdentifier: interpretedItem.sourceIdentifier,
            ErrorContextKey.dataFormat: interpretedItem.format.name,
            ErrorContextKey.originalException: 'Missing artist',
          },
        );
      }
      if (durationMs == null || durationMs <= 0) {
        throw AppException(
          errorCode: ErrorCode.dilTransformationStrategyInvalidData,
          message:
              'Missing or invalid "durationMs" in interpreted data for song transformation. Must be positive integer.',
          logLevel: LogLevel.error,
          context: {
            ErrorContextKey.componentName: 'Mp3ToSongTransformationStrategy',
            ErrorContextKey.operation: 'transform',
            ErrorContextKey.sourceIdentifier: interpretedItem.sourceIdentifier,
            ErrorContextKey.dataFormat: interpretedItem.format.name,
            ErrorContextKey.originalException: 'Invalid durationMs',
          },
        );
      }

      // 3. Construct the Song object
      return Song(
        ownerID: ownerID,
        sourceIdentifier: interpretedItem.sourceIdentifier,
        title: title,
        artist: artist,
        durationMs: durationMs,
      );
    } on AppException {
      // Re-throw our custom exception
      rethrow;
    } catch (e, st) {
      // Catch any unexpected errors during transformation and wrap them in AppException
      throw AppException(
        errorCode: ErrorCode.dilTransformationStrategyMappingError,
        message:
            'Failed to transform interpreted data from ${interpretedItem.sourceIdentifier} into a Song object: $e',
        stackTrace: st.toString(),
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'Mp3ToSongTransformationStrategy',
          ErrorContextKey.operation: 'transform',
          ErrorContextKey.sourceIdentifier: interpretedItem.sourceIdentifier,
          ErrorContextKey.dataFormat: interpretedItem.format.name,
          ErrorContextKey.originalException: e.toString(),
        },
      );
    }
  }
}
