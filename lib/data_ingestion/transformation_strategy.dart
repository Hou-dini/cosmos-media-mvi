import 'package:cosmos_media_mvi/domain/media.dart';
import 'package:cosmos_media_mvi/utils.dart/interpreted_data_item.dart';

/// Defines a contract for concrete strategy objects that encapsulate the
/// algorithms for transforming structured, intermediate metadata
/// ([InterpretedDataItem]) into fully-formed [Media] domain objects.
///
/// These strategies are specialized to work with a given [MediaType] and
/// [DataFormat] combination. They consume an [InterpretedDataItem], extract
/// the relevant metadata (from its flexible key-value store), apply necessary
/// mapping and business rules, and construct the final [Media] object.
abstract class TransformationStrategy {
  /// Transforms the structured metadata encapsulated within the provided
  /// [interpretedItem] into a concrete [Media] object according to this
  /// strategy's specific [MediaType] and [DataFormat] capabilities.
  ///
  /// It extracts data from the [interpretedItem]'s flexible key-value store,
  /// applies business logic, and constructs the appropriate [Media] domain object,
  /// assigning the given [ownerID]. The [Media] object itself is responsible
  /// for generating its unique [id] during construction.
  ///
  /// Throws [AppException] if:
  /// - [ErrorCode.dilTransformationStrategyMappingError]: An error occurred during mapping.
  /// - [ErrorCode.dilTransformationStrategyInvalidData]: Data is incomplete or invalid.
  /// - [ErrorCode.dilTransformationStrategyUnsupportedFormat]: Strategy cannot handle format.
  /// - [ErrorCode.dilTransformationStrategyUnknownError]: Any other unexpected errors.
  Media transform(InterpretedDataItem interpretedItem, String ownerID);
}