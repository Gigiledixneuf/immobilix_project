import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immobilx/utils/navigationUtils.dart';
import 'business/services/gestion/gestionLocalService.dart';
import 'business/services/gestion/gestionNetworkService.dart';
import 'MonApplication.dart';
import 'business/services/user/userLocalService.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';
import 'package:immobilx/framework/gestion/propertyNetworkServiceImpl.dart';
import 'business/services/user/userNetworkService.dart';
import 'framework/gestion/gestionNetworkServiceImpl.dart';
import 'framework/gestion/gestionLocalServiceImpl.dart';
import 'framework/user/userLocalServiceImpl.dart';
import 'framework/user/userNetworkServiceImpl.dart';
import 'framework/utils/http/remoteHttpUtils.dart';
import 'framework/utils/localStorage/getStorageImpl.dart';

GetIt getIt = GetIt.instance;

// configuration instance Implementations
void configureImplementations() {
  var baseUrl = dotenv.env['BASE_URL'] ?? '';
  var localManager = GetStorageImpl();

  // 1. Enregistrer d'abord le service de stockage local
  getIt.registerLazySingleton<UserLocalService>(() => UserLocalServiceImpl(box: localManager));

  // 2. Créer l'utilitaire HTTP en lui injectant le service de stockage
  var httpUtils = RemoteHttpUtils(userLocalService: getIt<UserLocalService>());

  // 3. Enregistrer les autres services qui dépendent de httpUtils
  getIt.registerLazySingleton<NavigationUtils>(() => NavigationUtils());
  getIt.registerLazySingleton<GestionNetworkService>(() => GestionNetworkServiceImpl(baseUrl: baseUrl, httpUtils: httpUtils));
  getIt.registerLazySingleton<GestionLocalService>(() => GestionLocalServiceImpl());
  getIt.registerLazySingleton<UserNetworkService>(() => UserNetworkServiceImpl(baseUrl: baseUrl, httpUtils: httpUtils, token: ''));
  getIt.registerLazySingleton<PropertyNetworkService>(() => PropertyNetworkServiceImpl(baseUrl: baseUrl, httpUtils: httpUtils));
}

void main() async {
  //initialisation de certaines fonctionnalités Flutter
  WidgetsFlutterBinding.ensureInitialized();

  //chargement du fichier .env
  await dotenv.load(fileName: ".env");

  //initialisation du GetStorage pour stocker les donnees en local
  await GetStorage.init();

  // configuration des Implementations
  configureImplementations();

  runApp(ProviderScope(child: MonApplication()));
}
