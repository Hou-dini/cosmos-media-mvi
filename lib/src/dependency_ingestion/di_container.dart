import 'package:get_it/get_it.dart';

import 'package:cosmos_media_mvi/src/data_ingestion_layer/factories/factories.dart';
import 'package:cosmos_media_mvi/src/data_ingestion_layer/interfaces/interfaces.dart';
import '../data_ingestion_layer/implementations/factories_impl/factory_implementations.dart';
import '../data_ingestion_layer/implementations/data_providers/data_providers.dart';
import '../data_ingestion_layer/implementations/data_format_detectors/data_format_detectors.dart';
import '../data_ingestion_layer/implementations/data_interpreters/data_interpreters.dart';
import '../data_ingestion_layer/implementations/data_transformers/data_transformers.dart';
import '../data_ingestion_layer/implementations/data_coordinators/data_coordinators.dart';
import '../data_ingestion_layer/implementations/strategies/data_retrieval/data_retrieval_strategies.dart';
import '../data_ingestion_layer/implementations/strategies/data_interpretation/data_interpretation_strategies.dart';
import '../data_ingestion_layer/implementations/strategies/data_transformation/data_transformation_strategies.dart';



// Create a GetIt instance
final GetIt getIt = GetIt.instance;

/// Initializes the Dependency Injection container by registering all
/// interfaces with their concrete implementations for the DIL MVI.
///
/// This function should be called once at the application startup.
void setupDI() {
  // Ensure we don't register twice in hot-reload scenarios for Flutter
  if (getIt.isRegistered<DataProviderFactory>()) {
    return;
  }

  // --- Register Strategies (as singletons or factories depending on their nature) ---
  // Strategies are typically created by their respective factories, so we register
  // the concrete strategies here for the factories to resolve.
  // For MVI, we'll register as singletons as we only have one of each.
  getIt.registerLazySingleton<DataRetrievalStrategy>(
    () => LocalSongRetrievalStrategy(),
    instanceName: 'LocalSongRetrievalStrategy',
  );
  getIt.registerLazySingleton<InterpretationStrategy>(
    () => Mp3InterpretationStrategy(),
    instanceName: 'Mp3InterpretationStrategy',
  );
  getIt.registerLazySingleton<TransformationStrategy>(
    () => Mp3ToSongTransformationStrategy(),
    instanceName: 'Mp3ToSongTransformationStrategy',
  );

  // --- Register Strategy Factories ---
  // These factories will resolve the specific strategies based on sourceType/mediaType/dataFormat
  getIt.registerLazySingleton<DataRetrievalStrategyFactory>(
    () => DataRetrievalStrategyFactoryImpl(getIt),
  );
  getIt.registerLazySingleton<InterpretationStrategyFactory>(
    () => InterpretationStrategyFactoryImpl(getIt),
  );
  getIt.registerLazySingleton<TransformationStrategyFactory>(
    () => TransformationStrategyFactoryImpl(getIt),
  );

  // --- Register DIL Components ---
  // These components will receive their strategy factories via DI
  getIt.registerFactory<DataProvider>(
    () => LocalDataProvider(getIt<DataRetrievalStrategyFactory>()),
    instanceName: 'LocalDataProvider',
  );
  getIt.registerFactory<DataFormatDetector>(
    () => LocalDataFormatDetector(), // UPDATED NAME
    instanceName: 'LocalDataFormatDetector', // UPDATED NAME
  );
  getIt.registerFactory<DataInterpreter>(
    () => LocalDataInterpreter(getIt<InterpretationStrategyFactory>()),
    instanceName: 'LocalDataInterpreter',
  );
  getIt.registerFactory<DataTransformer>(
    () => LocalDataTransformer(getIt<TransformationStrategyFactory>()),
    instanceName: 'LocalDataTransformer',
  );

  // --- Register DIL Component Factories ---
  // These factories will resolve the specific components based on sourceType
  getIt.registerLazySingleton<DataProviderFactory>(
    () => DataProviderFactoryImpl(getIt),
  );
  getIt.registerLazySingleton<DataFormatDetectorFactory>(
    () => DataFormatDetectorFactoryImpl(getIt),
  );
  getIt.registerLazySingleton<DataInterpreterFactory>(
    () => DataInterpreterFactoryImpl(getIt),
  );
  getIt.registerLazySingleton<DataTransformerFactory>(
    () => DataTransformerFactoryImpl(getIt),
  );

  // --- Register Data Coordinator ---
  // The DataCoordinator orchestrates all DIL components
  getIt.registerFactory<DataCoordinator>(
    () => LocalDataCoordinator(
      getIt<DataProviderFactory>(),
      getIt<DataFormatDetectorFactory>(),
      getIt<DataInterpreterFactory>(),
      getIt<DataTransformerFactory>(),
    ),
    instanceName: 'LocalDataCoordinator',
  );

  // --- Register Data Coordinator Factory ---
  getIt.registerLazySingleton<DataCoordinatorFactory>(
    () => DataCoordinatorFactoryImpl(getIt),
  );
}
