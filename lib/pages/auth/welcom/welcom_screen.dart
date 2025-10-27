import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Partie supérieure avec le logo et le slogan
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png', // Assurez-vous que le chemin est correct
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Une application qui te permet de\ngérer tes locataire en toute simplicité.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
          // Panneau coulissant
          DraggableScrollableSheet(
            initialChildSize: 0.4, // Hauteur initiale du panneau
            minChildSize: 0.4,     // Hauteur minimale
            maxChildSize: 0.6,     // Hauteur maximale
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        // La petite barre grise
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Bouton Connexion
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: AppTheme.primaryButtonStyle,
                            onPressed: () => context.go('/public/login'),
                            child: const Text('Connexion'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Bouton S'inscrire
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: AppTheme.secondaryButtonStyle,
                            onPressed: () => context.go('/public/register'),
                            child: const Text('S\'inscrire'),
                          ),
                        ),
                      ],
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
