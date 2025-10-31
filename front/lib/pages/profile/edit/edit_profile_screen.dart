import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Récupère l'utilisateur actuel pour initialiser les champs
    final user = ref.read(profileControllerProvider).user;
    _fullNameController = TextEditingController(text: user?.fullName);
    _emailController = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'fullName': _fullNameController.text,
        'email': _emailController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
        data['password_confirmation'] = _passwordConfirmationController.text;
      }

      final success = await ref.read(profileControllerProvider.notifier).updateProfile(data);

      if (success) {
        // Affiche une confirmation et ferme la page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès !'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        // L'erreur est gérée par le contrôleur et peut être affichée via un Snackbar ou autre si le contrôleur renvoie l'erreur.
      }
    }
  }

  // Fonction utilitaire pour le style des champs de texte en dark mode
  InputDecoration _darkInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppTheme.subtleTextColor),
      floatingLabelStyle: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),

      fillColor: AppTheme.lightTextColor.withOpacity(0.05), // Fond très subtil (effet glassmorphism)
      filled: true,

      // Bordure normale
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.lightTextColor.withOpacity(0.2), width: 1),
      ),
      // Bordure en focus (couleur primaire)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      // Bordure en erreur (couleur d'avertissement)
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.warningColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.warningColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      // Fond principal sombre
      backgroundColor: AppTheme.darkBackgroundColor,
      appBar: AppBar(
        // AppBar sombre et transparente
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightTextColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre en blanc
              Text(
                'Informations personnelles',
                style: AppTheme.headingStyle.copyWith(fontSize: 18, color: AppTheme.lightTextColor),
              ),
              const SizedBox(height: 16),
              // Champ Nom complet
              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(color: AppTheme.lightTextColor), // Texte utilisateur en blanc
                decoration: _darkInputDecoration('Nom complet'),
                validator: (value) => value!.isEmpty ? 'Le nom ne peut pas être vide' : null,
              ),
              const SizedBox(height: 16),
              // Champ Email
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: AppTheme.lightTextColor),
                decoration: _darkInputDecoration('Adresse mail'),
                validator: (value) => value!.isEmpty ? 'L\'email ne peut pas être vide' : null,
              ),
              const SizedBox(height: 24),
              // Titre Mot de passe
              Text(
                'Changer le mot de passe (optionnel)',
                style: AppTheme.headingStyle.copyWith(fontSize: 18, color: AppTheme.lightTextColor),
              ),
              const SizedBox(height: 16),
              // Champ Nouveau mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.lightTextColor),
                decoration: _darkInputDecoration('Nouveau mot de passe'),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 8) {
                    return 'Le mot de passe doit faire au moins 8 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Champ Confirmer mot de passe
              TextFormField(
                controller: _passwordConfirmationController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.lightTextColor),
                decoration: _darkInputDecoration('Confirmer le mot de passe'),
                validator: (value) {
                  if (_passwordController.text.isNotEmpty && value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: profileState.isUpdating
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : ElevatedButton(
                  // Style du bouton primaire avec padding vertical pour le rendre plus grand
                  style: AppTheme.primaryButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
                  ),
                  onPressed: _submit,
                  child: const Text('Enregistrer les modifications', style: TextStyle(fontSize: 16)),
                ),
              ),
              // Affichage d'erreur si le contrôleur en a une
              if (profileState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Erreur: ${profileState.error}',
                    style: const TextStyle(color: AppTheme.warningColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
