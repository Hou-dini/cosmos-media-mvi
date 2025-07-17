import 'package:cosmos_media_mvi/src/domain_layer/entities/media.dart';
import 'package:cosmos_media_mvi/src/core/enums/media_type.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/interpreted_data_item.dart';

/// Defines a contract for classes that perform transformation operations.
///
/// By implementing this interface, classes convert a [Stream] of structured,
/// intermediate data ([InterpretedDataItem]) into a [Stream] of fully-formed
/// [Media] objects. This transformation is performed by delegating to an
/// internal [TransformationStrategy], which is selected or configured based on
/// both the [MediaType] and the [DataFormat] identified in the input item.
abstract class DataTransformer {
  /// Checks whether this [DataTransformer] is in a stable and properly configured state.
  ///
  /// Clients should invoke this operation after configuring this [DataTransformer]
  /// and before performing any transformation operations.
  ///
  /// Returns `true` if the transformer is ready; `false` otherwise.
  bool isReady();

  /// Initiates the transformation of intermediate data by consuming
  /// [InterpretedDataItem] objects from the [inputFlow].
  ///
  /// For each [InterpretedDataItem], the item is passed to an internal
  /// [TransformationStrategy] (selected based on the current [MediaType] and
  /// the [DataFormat] within the item). The [TransformationStrategy] directly
  /// returns a complete [Media] object, which is then pushed into this
  /// [DataTransformer]'s internal [StreamController] sink. This operation is non-blocking.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilTransformationSetupError]: An error occurred during initial setup.
  /// - [ErrorCode.dilUnknownError]: Covers any other unexpected errors during setup.
  void transform(Stream<InterpretedDataItem> inputFlow, String ownerID);

  /// Retrieves a [Stream] for consuming a continuous flow of transformed [Media]
  /// objects from this [DataTransformer]'s internal [StreamController] sink.
  ///
  /// Clients can subscribe to or iterate over this stream to receive items as they
  /// become available. This operation is non-blocking.
  ///
  /// Returns a [Stream] of [Media] providing access to the transformed data.
  Stream<Media> getTransformedData();

  /// Sets or updates the [MediaType] configured for this [DataTransformer].
  ///
  /// This setting is used to inform the transformer about the expected type of [Media]
  /// to be produced, enabling it to select or configure the appropriate [TransformationStrategy].
  void setMediaType(MediaType type);

  /// Retrieves the current [MediaType] configured for this [DataTransformer].
  MediaType getMediaType();

  /// Releases resources used by this [DataTransformer] or its dependencies,
  /// including its internal [StreamController] sink.
  void dispose();
}