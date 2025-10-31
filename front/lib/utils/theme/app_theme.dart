import 'package:flutter/material.dart';

class AppTheme {
  // COULEURS DOMINANTES DE VOTRE PALETTE
  static const Color primaryBlue = Color(0xFF168BF2); // Bleu Vif Principal
  static const Color darkPrimary = Color(0xFF0D0D0D); // Noir Profond

  // Couleurs de base
  static const Color primaryColor = primaryBlue; // Bleu vif pour les accents
  static const Color backgroundColor = Color(0xFFF2F2F7); // Fond clair standard
  static const Color textColor = Color(0xFF333333); // Texte sombre pour fonds clairs
  static const Color linkColor = primaryBlue; // Liens en bleu vif

  // Couleurs du tableau de bord
  static const Color darkBackgroundColor = darkPrimary; // Utilisé pour le fond du Scaffold
  static const Color lightTextColor = Colors.white; // Utilisé pour le texte/icônes sur fonds sombres
  static const Color subtleTextColor = Colors.white70; // Texte subtil sur fonds sombres

  // Couleurs sémantiques
  static const Color successColor = Color(0xFF4CAF50); // Vert standard
  static const Color warningColor = Color(0xFFFF9800); // Orange standard
  static const Color accentOrange = Color(0xFFFFA726); // Accent orange (gardé pour les warnings/Ajouter)
  static const Color lightOrange = Color(0xFFFFF3E0); // Fond clair pour accent orange

  // Couleurs des filtres et icônes
  static const Color chipBackgroundColor = primaryBlue; // Bleu Vif pour les chips actives
  static const Color chipLabelColor = Colors.white; // Texte blanc sur chip bleue
  static const Color unselectedChipColor = Color(0xFFEEEEEE); // Fond gris clair pour chips inactives
  static const Color unselectedChipLabelColor = Colors.black; // Texte noir pour chips inactives
  static const Color iconBackgroundColor = Color(0xFFF2F2F7); // Fond des icônes sur fonds clairs

  // Styles de texte
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle linkStyle = TextStyle(
    fontSize: 16,
    color: linkColor,
    fontWeight: FontWeight.w600,
  );

  // Styles de bouton
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 16),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 16),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  // Décoration des champs de texte
  static final InputDecoration textInputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
  );
}