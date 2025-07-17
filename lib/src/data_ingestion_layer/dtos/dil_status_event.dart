import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dil_status_event_type.dart';

class DILStatusEvent {
  final DILStatusEventType type;
  final String message;
  final int? processedCount;
  final int? totalCount;
  final String? currentStage;
  final String? errorSummary;

  DILStatusEvent({
    required this.type,
    required this.message,
    this.processedCount,
    this.totalCount,
    this.currentStage,
    this.errorSummary,
  });

  @override
  String toString() {
    return 'DILStatusEvent: [${type.name}] $message'
           '${processedCount != null ? ', Processed: $processedCount' : ''}'
           '${totalCount != null ? ', Total: $totalCount' : ''}'
           '${currentStage != null ? ', Stage: $currentStage' : ''}'
           '${errorSummary != null ? ', Error Summary: $errorSummary' : ''}';
  }
}
