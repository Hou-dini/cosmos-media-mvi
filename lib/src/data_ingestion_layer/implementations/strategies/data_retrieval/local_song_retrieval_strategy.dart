import 'dart:async';
import 'dart:io'; // For File, Directory, FileSystemEntity

// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:path/path.dart' as p; // For path manipulation

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// A concrete implementation of [DataRetrievalStrategy] for retrieving
/// song-related raw data (e.g., MP3 files) from the local file system.
///
/// This strategy operates in a stateful manner, requiring [setResourceLocation]
/// and [setMediaType] to be called before [fetchData()]. It uses the `path`
/// package for robust path manipulation.
class LocalSongRetrievalStrategy implements DataRetrievalStrategy<File> {
  ResourceLocationConfig? _resourceLocation;
  MediaType? _mediaType;

  /// Constructs a [LocalSongRetrievalStrategy].
  LocalSongRetrievalStrategy();

  @override
  bool isReady() {
    // Check if resource location is set
    if (_resourceLocation == null) {
      return false;
    }

    // Check if media type is set and is 'song'
    if (_mediaType == null || _mediaType != MediaType.song) {
      return false;
    }

    // Basic validation of the path: check if it's a valid directory or file path
    // For MVI, we'll assume it's a directory for simplicity.
    try {
      final path = _resourceLocation!.pathOrUrl;
      final directory = Directory(path);
      // Check if the directory exists and is accessible.
      // This is a synchronous check, might be slow for large directories.
      // For a real app, consider asynchronous checks or deferring.
      return directory.existsSync();
    } on PathNotFoundException {
      return false; // Path does not exist
    } on FileSystemException {
      return false; // Permission denied or other file system error
    } catch (e) {
      // Catch any other unexpected errors during readiness check
      return false;
    }
  }

  @override
  Stream<RawDataItem<File>> retrieveData() async* {
    if (!isReady()) {
      throw AppException(
        errorCode: ErrorCode.dilProviderSetupError, // More specific error code for setup issues
        message: 'LocalSongRetrievalStrategy is not ready. Ensure resource location and media type are set and valid.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalSongRetrievalStrategy',
          ErrorContextKey.operation: 'fetchData',
          ErrorContextKey.resourceLocation: _resourceLocation?.pathOrUrl ?? 'N/A',
          ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
        },
      );
    }

    final directoryPath = _resourceLocation!.pathOrUrl;
    final directory = Directory(directoryPath);

    try {
      // List all files and directories recursively
      final entities = directory.list(recursive: true, followLinks: false);

      await for (final entity in entities) {
        if (entity is File) {
          final fileExtension = p.extension(entity.path).toLowerCase();
          // For MVI, we're focusing on 'song' media type, and assuming MP3 format.
          // In a full implementation, this would involve a more robust format detection
          // or delegation to a specialized helper.
          if (fileExtension == '.mp3') {
            yield RawDataItem<File>(
              data: entity,
              sourceIdentifier: entity.path,
              formatHint: DataFormat.mp3.name, // Provide a hint
            );
          }
        }
      }
    } on FileSystemException catch (e, st) {
      throw AppException(
        errorCode: ErrorCode.dilProviderAccessDeniedError, // Assuming access issue
        message: 'Failed to access local directory "$directoryPath": ${e.message}',
        stackTrace: st.toString(),
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalSongRetrievalStrategy',
          ErrorContextKey.operation: 'fetchData',
          ErrorContextKey.resourceLocation: directoryPath,
          ErrorContextKey.originalException: e.toString(),
        },
      );
    } catch (e, st) {
      throw AppException(
        errorCode: ErrorCode.dilProviderUnknownError,
        message: 'An unexpected error occurred while fetching data from "$directoryPath": $e',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'LocalSongRetrievalStrategy',
          ErrorContextKey.operation: 'fetchData',
          ErrorContextKey.resourceLocation: directoryPath,
          ErrorContextKey.originalException: e.toString(),
        },
      );
    }
  }

  @override
  void setResourceLocation(ResourceLocationConfig location) {
    _resourceLocation = location;
  }

  @override
  ResourceLocationConfig getResourceLocation() {
    if (_resourceLocation == null) {
      throw AppException(
        errorCode: ErrorCode.dilProviderPathMissingError,
        message: 'ResourceLocationConfig has not been set for LocalSongRetrievalStrategy.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalSongRetrievalStrategy',
          ErrorContextKey.operation: 'getResourceLocation',
        },
      );
    }
    return _resourceLocation!;
  }

  @override
  void setMediaType(MediaType type) {
    _mediaType = type;
  }

  @override
  MediaType getMediaType() {
    if (_mediaType == null) {
      throw AppException(
        errorCode: ErrorCode.dilProviderInvalidConfigError, // Using a more general config error
        message: 'MediaType has not been set for LocalSongRetrievalStrategy.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalSongRetrievalStrategy',
          ErrorContextKey.operation: 'getMediaType',
        },
      );
    }
    return _mediaType!;
  }
}
