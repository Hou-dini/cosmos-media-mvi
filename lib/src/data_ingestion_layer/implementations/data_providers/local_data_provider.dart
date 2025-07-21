import 'dart:async';
import 'dart:io'; // For File

// --- Import DTOs and Enums ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';

// --- Import DIL Interfaces ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';

// --- Import Factories ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';

// --- Import Exceptions ---
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart';


/// A concrete implementation of [DataProvider] for retrieving raw data
/// from the local file system.
///
/// This provider orchestrates data retrieval by delegating to a
/// [DataRetrievalStrategy] (e.g., [LocalSongRetrievalStrategy]). It manages
/// the lifecycle of the strategy and ensures proper configuration before use.
class LocalDataProvider implements DataProvider<File> {
  final DataRetrievalStrategyFactory _retrievalStrategyFactory;

  ResourceLocationConfig? _resourceLocation;
  MediaType? _mediaType;
  DataRetrievalStrategy<File>? _retrievalStrategy;
  bool _isOpen = false; // Internal state to track if open() has been called

  /// Constructs a [LocalDataProvider] with a [DataRetrievalStrategyFactory]
  /// for creating specific retrieval strategies.
  LocalDataProvider(this._retrievalStrategyFactory);

  @override
  bool isReady() {
    // Check if essential configurations are set
    if (_resourceLocation == null) {
      return false;
    }
    if (_mediaType == null) {
      return false;
    }

    // If the strategy hasn't been created yet (i.e., open() hasn't been called),
    // we can't fully check readiness of the strategy.
    // However, the provider itself is ready to be 'open()'-ed if config is present.
    // For a full readiness check, we should also verify the strategy's readiness.
    // This check is primarily for *after* open() is called.
    if (_isOpen && _retrievalStrategy != null) {
      return _retrievalStrategy!.isReady();
    }

    // If not yet opened, but configured, it's ready to be opened.
    return true;
  }

  @override
  void open() {
    if (_isOpen) {
      // Already open, idempotent operation
      return;
    }

    if (_resourceLocation == null || _mediaType == null) {
      throw AppException(
        errorCode: ErrorCode.dilProviderSetupError,
        message: 'LocalDataProvider cannot be opened: ResourceLocationConfig or MediaType not set.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataProvider',
          ErrorContextKey.operation: 'open',
          ErrorContextKey.resourceLocation: _resourceLocation?.pathOrUrl ?? 'N/A',
          ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
        },
      );
    }

    try {
      // Create the specific retrieval strategy using the factory
      _retrievalStrategy = _retrievalStrategyFactory.createDataRetrievalStrategy(
        ImportSourceType.localFolder, // This provider is specifically for localFolder
        _mediaType!,
      ) as DataRetrievalStrategy<File>; // Cast to DataRetrievalStrategy<File>

      // Configure the created strategy
      _retrievalStrategy!.setResourceLocation(_resourceLocation!);
      _retrievalStrategy!.setMediaType(_mediaType!);

      // Verify the strategy is ready after configuration
      if (!_retrievalStrategy!.isReady()) {
        throw AppException(
          errorCode: ErrorCode.dilProviderSetupError,
          message: 'LocalDataProvider could not open: Underlying retrieval strategy is not ready after configuration.',
          logLevel: LogLevel.critical,
          context: {
            ErrorContextKey.componentName: 'LocalDataProvider',
            ErrorContextKey.operation: 'open',
            ErrorContextKey.resourceLocation: _resourceLocation!.pathOrUrl,
            ErrorContextKey.mediaType: _mediaType!.name,
            ErrorContextKey.originalException: 'Retrieval strategy not ready',
          },
        );
      }

      _isOpen = true;
    } on AppException {
      rethrow; // Re-throw our custom exception
    } catch (e, st) {
      throw AppException(
        errorCode: ErrorCode.dilProviderConnectionError, // More specific for open failures
        message: 'Failed to open LocalDataProvider or initialize retrieval strategy: $e',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'LocalDataProvider',
          ErrorContextKey.operation: 'open',
          ErrorContextKey.resourceLocation: _resourceLocation?.pathOrUrl ?? 'N/A',
          ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
          ErrorContextKey.originalException: e.toString(),
        },
      );
    }
  }

  @override
  Stream<RawDataItem<File>> fetchData() {
    if (!_isOpen || _retrievalStrategy == null) {
      throw AppException(
        errorCode: ErrorCode.dilProviderSetupError,
        message: 'LocalDataProvider is not open. Call open() before fetchData().',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataProvider',
          ErrorContextKey.operation: 'fetchData',
          ErrorContextKey.resourceLocation: _resourceLocation?.pathOrUrl ?? 'N/A',
          ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
        },
      );
    }

    try {
      // Delegate the actual data fetching to the configured retrieval strategy
      return _retrievalStrategy!.retrieveData();
    } on AppException {
      rethrow; // Re-throw our custom exception
    } catch (e, st) {
      throw AppException(
        errorCode: ErrorCode.dilProviderUnknownError,
        message: 'An unexpected error occurred during data fetching: $e',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'LocalDataProvider',
          ErrorContextKey.operation: 'fetchData',
          ErrorContextKey.resourceLocation: _resourceLocation?.pathOrUrl ?? 'N/A',
          ErrorContextKey.mediaType: _mediaType?.name ?? 'N/A',
          ErrorContextKey.originalException: e.toString(),
        },
      );
    }
  }

  @override
  Stream<ResourceChangeEvent> watchForChanges() {
    // For MVI, we will not implement real-time file system watching.
    // This would typically involve platform-specific file system watchers.
    throw AppException(
      errorCode: ErrorCode.dilProviderWatchUnsupported,
      message: 'Real-time file system watching is not supported by LocalDataProvider in MVI.',
      logLevel: LogLevel.info, // Info level as it's a known limitation for MVI
      context: {
        ErrorContextKey.componentName: 'LocalDataProvider',
        ErrorContextKey.operation: 'watchForChanges',
        ErrorContextKey.resourceLocation: _resourceLocation?.pathOrUrl ?? 'N/A',
      },
    );
  }

  @override
  void setResourceLocation(ResourceLocationConfig location) {
    _resourceLocation = location;
    // If strategy already exists, update its location too.
    _retrievalStrategy?.setResourceLocation(location);
  }

  @override
  ResourceLocationConfig getResourceLocation() {
    if (_resourceLocation == null) {
      throw AppException(
        errorCode: ErrorCode.dilProviderPathMissingError,
        message: 'ResourceLocationConfig has not been set for LocalDataProvider.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataProvider',
          ErrorContextKey.operation: 'getResourceLocation',
        },
      );
    }
    return _resourceLocation!;
  }

  @override
  void setMediaType(MediaType type) {
    _mediaType = type;
    // If strategy already exists, update its media type too.
    _retrievalStrategy?.setMediaType(type);
  }

  @override
  MediaType getMediaType() {
    if (_mediaType == null) {
      throw AppException(
        errorCode: ErrorCode.dilProviderInvalidConfigError,
        message: 'MediaType has not been set for LocalDataProvider.',
        logLevel: LogLevel.error,
        context: {
          ErrorContextKey.componentName: 'LocalDataProvider',
          ErrorContextKey.operation: 'getMediaType',
        },
      );
    }
    return _mediaType!;
  }

  @override
  void close() {
    if (!_isOpen) {
      // Already closed or not open, idempotent operation
      return;
    }
    try {
      // No explicit dispose method on DataRetrievalStrategy interface,
      // but if it had one, we would call it here.
      // For now, simply nullify the reference.
      _retrievalStrategy = null;
      _isOpen = false;
    } catch (e, st) {
      throw AppException(
        errorCode: ErrorCode.dilProviderConnectionError, // Or a more specific resource release error
        message: 'Failed to close LocalDataProvider or release resources: $e',
        stackTrace: st.toString(),
        logLevel: LogLevel.critical,
        context: {
          ErrorContextKey.componentName: 'LocalDataProvider',
          ErrorContextKey.operation: 'close',
          ErrorContextKey.resourceLocation: _resourceLocation?.pathOrUrl ?? 'N/A',
          ErrorContextKey.originalException: e.toString(),
        },
      );
    }
  }
}
