import 'media.dart';
import 'media_type.dart';

// Song Class (Concrete IMedia implementation for MVI)
class Song extends Media {
  final String _title;
  final String _artist;
  final int _durationMs; // Duration in milliseconds

  Song({
    String? id,
    required super.ownerID,
    required super.sourceIdentifier,
    required String title,
    required String artist,
    required int durationMs,
  }) : _title = title,
       _artist = artist,
       _durationMs = durationMs;
       
  @override
  String get title => _title;

  String get artist => _artist;

  @override
  Duration get duration => Duration(milliseconds: _durationMs);

  int get durationMs => _durationMs;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerID': ownerID,
      'sourceIdentifier': sourceIdentifier,
      'title': _title,
      'artist': _artist,
      'durationMs': _durationMs,
      'mediaType': MediaType.song.name, // Add media type for persistence
    };
  }
}
