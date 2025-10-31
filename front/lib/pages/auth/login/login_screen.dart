import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';



class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

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
            height: MediaQuery.of(context).size.height * 0.60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          // Panneau coulissant
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.85,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // La petite barre grise
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const Center(
                            child: Text('Connexion', style: AppTheme.headingStyle),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _emailController,
                            decoration: AppTheme.textInputDecoration.copyWith(
                              hintText: 'Adresse mail',
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre email' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: AppTheme.textInputDecoration.copyWith(
                              hintText: 'Mot de passe',
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) => setState(() => _rememberMe = value!),
                                    activeColor: AppTheme.primaryColor,
                                  ),
                                  const Text('Resté connecté'),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Mot de passe oublié.', style: AppTheme.linkStyle),
                              ),
                            ],
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
                                  authController.login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                }
                              },
                              child: const Text('Connexion'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/public/register'),
                              child: const Text('Je n\'ai pas de compte.', style: AppTheme.linkStyle),
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
