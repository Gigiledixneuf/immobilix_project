# ImmobilX - Guide d'utilisation


## Comment cloner le projet

```bash
git clone http://{{IP}}:{{PORT}}/{{VOTRE_USERNAME}}/{{PROJET}}.git {{NOM_DU_PROJET_MOBILE}}
cd {{NOM_DU_PROJET_MOBILE}}
git checkout dev
```

⚠️ **Important** : La branche de travail est toujours `dev`. Veuillez créer vos branches de fonctionnalités à partir de celle-ci.

## Configuration du projet

### Installation des dépendances

```bash
flutter pub get
```

### Configuration du fichier .env

1. Dupliquez le fichier `.env.example` et renommez-le en `.env`
```bash
cp .env.example .env
```

2. Configurez les variables d'environnement dans le fichier `.env`:
   - `BASE_URL`: URL du backend

Pour obtenir l'adresse IP de votre machine sous Windows:
```bash
ipconfig
```
Cherchez l'adresse IPv4 dans la section de votre connexion réseau active (généralement "Ethernet adapter" ou "Wireless LAN adapter Wi-Fi").

Exemple de configuration du fichier `.env`:
```
BASE_URL=http://192.168.1.XXX:8000/api
```

## Lancement du projet

```bash
# Pour mode debug
flutter run

# Pour choisir un appareil spécifique
flutter devices
flutter run -d <device_id>
```

## Structure du projet et implémentation

### Architecture du projet

```
lib/
├── business/
│   ├── models/    # Modèles de données
│   └── services/  # Services abstraits (interfaces)
├── framework/     # Implémentations des services
├── pages/         # Interface utilisateur
├── utils/         # Utilitaires
├── main.dart      # Point d'entrée
└── routers.dart   # Configuration des routes
```

### Étapes d'implémentation

#### 1. Création d'un modèle

Dans le dossier `lib/business/models`, créez un dossier pour chaque entité:

```dart
// lib/business/models/article/article_model.dart
class Article {
  final String title;
  ...  
  Article({
    required this.title,
    ...
  });
  
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      ...
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      ...
    };
  }
}
```

#### 2. Création d'un service abstrait

Dans le dossier `lib/business/services`, créez un dossier pour chaque service:

```dart
// lib/business/services/article/article_service.dart
import '../../models/article/article_model.dart';

abstract class ArticleService {
  Future<List<Article>> getAllArticles();
  ...
}
```

#### 3. Implémentation du service

Dans le dossier `lib/framework`, créez les implémentations:

```dart
// lib/framework/article/article_service_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../business/models/article/article_model.dart';
import '../../business/services/article/article_service.dart';
import '../../utils/env.dart';

class ArticleServiceImpl implements ArticleService {
  final String baseUrl = Env.baseUrl;
  
  @override
  Future<List<Article>> getAllArticles() async {
    ...
  }
  
  ...
}
```

#### 4. Création des tests

```dart
// test/article_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import '../lib/business/models/article/article_model.dart';
import '../lib/framework/article/article_service_impl.dart';


void main() {
  // TESTS SUR LES IMPLEMENTATIONS
}
```

#### 5. Création des pages

Pour chaque page, créez trois fichiers dans un dossier dédié:

1. **État (State)**
```dart
// lib/pages/articles/articles_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/models/article/article_model.dart';

class ArticlesState {
  final bool isLoading;
  ...

  ArticlesState({
    this.isLoading = false,
    ...
  });

  ArticlesState copyWith({
    bool? isLoading,
   ...
  }) {
    return ArticlesState(
      isLoading: isLoading ?? this.isLoading,
      ...
    );
  }
}
```

2. **Contrôleur**
```dart
// lib/pages/articles/articles_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/services/article/article_service.dart';
import '../../main.dart';
import 'articles_state.dart';

final articlesControllerProvider = StateNotifierProvider<ArticlesController, ArticlesState>((ref) {
  return ArticlesController(getIt<ArticleService>());
});

class ArticlesController extends StateNotifier<ArticlesState> {
  final ArticleService _articleService;
  
  ArticlesController(this._articleService) : super(ArticlesState()) {
    // ACTION INITIALE
  }
  
  Future<void> loadArticles() async {
    // ACTION VERS UN SERVICE DEFINI
  }
  
  // Autres méthodes
}

final articleCtrlProvider = StateNotifierProvider<ArticlesController, ArticlesState>((ref) {
  //ref.keepAlive(); // SI LE CONTROLEUR ET LE STATE DOIVENT ETRE ACCESSIBLE DANS TOUTES LES AUTRES PAGES
  return ArticlesController();
});
```

3. **Page Flutter**
```dart
// lib/pages/articles/articles_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'articles_controller.dart';

class ExamplePage extends ConsumerStatefulWidget {
    const HomePage({super.key});

    @override
    ConsumerState<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends ConsumerState<ExamplePage> {
  const ArticlesPage({Key? key}) : super(key: key);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        // ACTION INITIALE DANS LA PAGE
      var ctrl = ref.read({VOTRE_PRODIVDER}.notifier);
      ctrl.loadArticles();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch({VOTRE_PROVIDER});
    
    return Scaffold(
      appBar: AppBar(title: Text('Articles')),
      body: Container(),
    );
  }
}
```

#### 6. Configuration des routes

Mettez à jour le fichier `lib/routers.dart` pour ajouter de nouvelles routes:

```dart
// Ajoutez ceci dans la liste authRoutes
GoRoute(
  path: "/app/articles",
  name: 'articles_page',
  builder: (ctx, state) {
    return ArticlesPage();
  },
),
```

## Génération d'un APK de production

Pour générer un APK de production:

1. Mettez à jour la version dans `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: version+numéro de build
```

2. Générez une clé de signature (à faire une seule fois)  (OPTIONEL):
```bash
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

3. Créez un fichier `key.properties` à la racine du projet (OPTIONEL):
```
storePassword=<mot de passe du keystore>
keyPassword=<mot de passe de la clé>
keyAlias=key
storeFile=<chemin absolu vers key.jks>
```

4. Configurez la signature dans `android/app/build.gradle`  (OPTIONEL)

5. Générez l'APK de production:
```bash
flutter build apk --release
```

L'APK sera disponible dans: `build/app/outputs/flutter-apk/app-release.apk`

## Conseils de développement

- Utilisez la branche `dev` pour le développement
- Créez des branches de fonctionnalités à partir de `dev`
- Testez votre code avant de faire un commit
- Respectez l'architecture du projet # mobile_exemple
