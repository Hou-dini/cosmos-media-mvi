import 'dart:io'; // For Directory, File
import 'package:path/path.dart' as p; // For path manipulation

// --- Import DI Setup ---
import 'package:cosmos_media_mvi/src/dependency_ingestion/di_container.dart';

// --- Import DIL Interfaces and DTOs ---
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/dtos/dtos.dart';
import 'package:cosmos_media_mvi/src/core/enums/enums.dart';
import 'package:cosmos_media_mvi/src/domain_layer/entities/entities.dart'; // To cast Media to Song
import 'package:cosmos_media_mvi/src/core/exceptions/exceptions.dart'; // To catch AppExceptions

/// Main function to run the DIL MVI demonstration.
void main() async {
  print('--- Cosmos Media DIL MVI Demonstration ---');

  // 1. Setup Dependency Injection
  print('\n1. Setting up Dependency Injection...');
  setupDI();
  print('   DI setup complete.');

  // 2. Create a dummy local folder with MP3 files for testing
  print('\n2. Preparing dummy data...');
  final String testDirPath = p.join(Directory.current.path, 'test_media');
  final Directory testDir = Directory(testDirPath);

  if (testDir.existsSync()) {
    testDir.deleteSync(recursive: true); // Clean up previous test data
    print('   Cleaned up existing test_media directory.');
  }
  testDir.createSync(recursive: true); // Create a fresh directory

  // Create some dummy MP3 files
  final List<String> dummySongs = [
    'Artist One - Song Title A.mp3',
    'Artist Two - Another Song.mp3',
    'Artist Three - My Awesome Podcast Episode.mp3', // Will be interpreted as song
    'Invalid File.txt', // Will cause a format detection error
    'Artist Four - Short Track.mp3',
  ];

  for (final songName in dummySongs) {
    final file = File(p.join(testDirPath, songName));
    file.writeAsStringSync(
        'This is dummy content for $songName'); // Actual content doesn't matter for MVI
    print('   Created dummy file: ${file.path}');
  }
  print('   Dummy data prepared in: $testDirPath');

  // 3. Get DataCoordinator instance from DI
  print('\n3. Obtaining DataCoordinator...');
  final DataCoordinatorFactory coordinatorFactory =
      getIt<DataCoordinatorFactory>();
  final DataCoordinator coordinator =
      coordinatorFactory.createCoordinator(ImportSourceType.localFolder);
  print('   DataCoordinator instance obtained: ${coordinator.runtimeType}');

  // 4. Set up listeners for processed data and status updates
  print('\n4. Setting up stream listeners...');
  final List<Song> processedSongs = [];
  final List<AppException> encounteredErrors = [];

  // Listen to processed data (Media objects)
  final processedDataSubscription = coordinator.getProcessedData().listen(
    (media) {
      if (media is Song) {
        processedSongs.add(media);
        print(
            '   ✅ Processed Song: "${media.title}" by "${media.artist}" (ID: ${media.id})');
      } else {
        print('   ✅ Processed Unknown Media Type: ${media.runtimeType}');
      }
    },
    onError: (error) {
      if (error is AppException) {
        encounteredErrors.add(error);
        print(
            '   ❌ Pipeline Error: ${error.message} [${error.errorCode.name}]');
        if (error.context.isNotEmpty) {
          print('      Context: ${error.context}');
        }
      } else {
        print('   ❌ Unexpected Error in Processed Data Stream: $error');
      }
    },
    onDone: () {
      print('   Processed Data Stream: DONE');
    },
  );
  getIt.registerSingleton(processedDataSubscription,
      instanceName: 'processedDataSubscription'); // Keep reference for dispose

  // Listen to status updates
  final statusUpdatesSubscription = coordinator.getStatusUpdates().listen(
    (event) {
      print('   📊 Status Update: [${event.type.name}] ${event.message}');
      if (event.errorSummary != null) {
        print('      Error Summary: ${event.errorSummary}');
      }
    },
    onError: (error) {
      print('   ⚠️ Status Stream Error: $error');
    },
    onDone: () {
      print('   Status Updates Stream: DONE');
    },
  );
  getIt.registerSingleton(statusUpdatesSubscription,
      instanceName: 'statusUpdatesSubscription'); // Keep reference for dispose

  print('   Listeners set up.');

  // 5. Initiate the coordination process
  print('\n5. Initiating DIL coordination...');
  final String ownerID = 'test_user_123'; // Dummy owner ID
  final ImportSourceConfig config = ImportSourceConfig(
    sourceType: ImportSourceType.localFolder,
    resourceLocation: ResourceLocationConfig(pathOrUrl: testDirPath),
    mediaType: MediaType.song, // We are expecting songs from this source
  );

  try {
    coordinator.initiateCoordination(config, ownerID);
    print('   DIL coordination initiated. Waiting for pipeline to complete...');
  } on AppException catch (e) {
    print(
        '   🚨 CRITICAL DIL SETUP FAILURE: ${e.message} [${e.errorCode.name}]');
    if (e.stackTrace != null) {
      print('      Stack Trace:\n${e.stackTrace}');
    }
    encounteredErrors.add(e); // Add critical setup errors to the list
  } catch (e, st) {
    print('   🚨 UNEXPECTED CRITICAL FAILURE: $e');
    print('      Stack Trace:\n$st');
    encounteredErrors.add(AppException(
      errorCode: ErrorCode.dilUnknownError,
      message: 'Unexpected error during DIL initiation: $e',
      stackTrace: st.toString(),
    ));
  }

  // Allow some time for the asynchronous pipeline to complete
  // In a real app, you'd await a Future that completes when the coordinator is done.
  // For this simple demo, a delay is sufficient.
  await Future.delayed(Duration(seconds: 5));

  print('\n--- DIL MVI Demonstration Summary ---');
  print('Total Songs Processed Successfully: ${processedSongs.length}');
  print('Total Errors Encountered in Pipeline: ${encounteredErrors.length}');

  if (encounteredErrors.isNotEmpty) {
    print('\nDetails of Errors:');
    for (int i = 0; i < encounteredErrors.length; i++) {
      print('  Error ${i + 1}:');
      print('    Code: ${encounteredErrors[i].errorCode.name}');
      print('    Message: ${encounteredErrors[i].message}');
      if (encounteredErrors[i].context.isNotEmpty) {
        print('    Context: ${encounteredErrors[i].context}');
      }
      // if (encounteredErrors[i].stackTrace != null) {
      //   print('    Stack Trace:\n${encounteredErrors[i].stackTrace}');
      // }
    }
  }

  // Clean up resources
  print('\n6. Disposing resources...');
  coordinator.dispose();
  // Also dispose GetIt if it's no longer needed (e.g., in tests)
  // For a long-running app, you might not dispose GetIt until app shutdown.
  // For this demo, it's good practice.
  await getIt.reset(); // Resets all registered singletons and factories.
  print('   Resources disposed.');

  print('\n--- Demonstration Complete ---');
}
