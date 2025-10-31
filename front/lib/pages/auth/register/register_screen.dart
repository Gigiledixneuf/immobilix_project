import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../login/auth_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';



class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _portableController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Partie supérieure avec le logo
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          // Panneau coulissant
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.75,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text('S\'inscrire', style: AppTheme.headingStyle),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _fullNameController,
                            decoration: AppTheme.textInputDecoration.copyWith(hintText: 'Nom complet'),
                            validator: (v) => v!.isEmpty ? 'Veuillez entrer votre nom' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: AppTheme.textInputDecoration.copyWith(hintText: 'Adresse mail'),
                            validator: (v) => v!.isEmpty ? 'Veuillez entrer votre email' : null,
                          ),
                          const SizedBox(height: 20),
                          // Champ de téléphone stylisé
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Text('+243', style: TextStyle(fontSize: 16)),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _portableController,
                                  decoration: AppTheme.textInputDecoration.copyWith(
                                    hintText: '822 222 22',
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.isEmpty ? 'Veuillez entrer votre numéro' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: AppTheme.textInputDecoration.copyWith(hintText: 'Mot de passe'),
                            validator: (v) => v!.length < 8 ? 'Le mot de passe doit faire 8 caractères' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordConfirmationController,
                            obscureText: true,
                            decoration: AppTheme.textInputDecoration.copyWith(hintText: 'Confirmer mot de passe'),
                            validator: (v) => v != _passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: authState.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              style: AppTheme.primaryButtonStyle,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  authController.register(
                                    _fullNameController.text,
                                    _emailController.text,
                                    "+243${_portableController.text}", // Ajout de l'indicatif
                                    _passwordController.text,
                                    _passwordConfirmationController.text,
                                  );
                                }
                              },
                              child: const Text('S\'inscrire'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/public/login'),
                              child: const Text('Déjà un compte.', style: AppTheme.linkStyle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
