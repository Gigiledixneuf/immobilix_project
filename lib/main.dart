import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/framework/utils/localStorage/getStorageImpl.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import 'business/services/gestion/gestionLocalService.dart';
import 'business/services/gestion/gestionNetworkService.dart';
import 'MonApplication.dart';
import 'business/services/user/userLocalService.dart';
import 'framework/gestion/gestionNetworkServiceImpl.dart';
import 'framework/gestion/gestionLocalServiceImpl.dart';
import 'framework/user/userLocalServiceImpl.dart';
import 'framework/user/userNetworkServiceImpl.dart';
import 'framework/utils/http/remoteHttpUtils.dart';

GetIt getIt = GetIt.instance;

// configuration instance Implementations
void configureImplementations() {
  var httpUtils = RemoteHttpUtils();
  var baseUrl = dotenv.env['BASE_URL'] ?? '';
  var localManager=GetStorageImpl();
  
  getIt.registerLazySingleton<NavigationUtils>(() => NavigationUtils());
  getIt.registerLazySingleton<GestionNetworkService>(() => GestionNetworkServiceImpl(baseUrl: baseUrl, httpUtils: httpUtils));
  getIt.registerLazySingleton<GestionLocalService>(() => GestionLocalServiceImpl());
  getIt.registerLazySingleton<UserNetworkService>(() => UserNetworkServiceImpl(baseUrl: baseUrl, httpUtils: httpUtils));
  getIt.registerLazySingleton<UserLocalService>(() => UserLocalServiceImpl(box: localManager));
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
