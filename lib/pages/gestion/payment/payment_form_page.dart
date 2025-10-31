import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../business/models/contrat/contrat.dart';
import 'package:immobilx/business/models/gestion/payment.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import 'package:immobilx/main.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

// 🧾 Page de formulaire permettant à un locataire d’effectuer un paiement
class PaymentFormPage extends ConsumerStatefulWidget {
  final Contract contract; // Le contrat concerné par le paiement

  const PaymentFormPage({Key? key, required this.contract}) : super(key: key);

  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends ConsumerState<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>(); // Clé du formulaire pour la validation
  final TextEditingController _amountController = TextEditingController(); // Contrôleur du champ "montant"
  PaymentMethods _paymentMethod = PaymentMethods.HBAR; // Méthode de paiement par défaut (HBAR)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor,
      appBar: AppBar(
        title: const Text('Effectuer un Paiement', style: TextStyle(color: AppTheme.lightTextColor)),
        backgroundColor: AppTheme.darkBackgroundColor,
        iconTheme: const IconThemeData(color: AppTheme.lightTextColor),
      ),
      body: Form(
        key: _formKey, // Liaison du formulaire à sa clé
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affichage du nom de la propriété liée au contrat
              Text(
                'Contrat pour: ${widget.contract.property.name}',
                style: AppTheme.headingStyle.copyWith(color: AppTheme.lightTextColor),
              ),
              const SizedBox(height: 24),

              // Champ de saisie du montant du paiement
              _buildTextFormField(
                controller: _amountController,
                label: 'Montant',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ce champ est requis';
                  if (double.tryParse(value) == null) return 'Veuillez entrer un nombre valide';
                  return null;
                },
              ),

              // Liste déroulante pour choisir la méthode de paiement
              _buildDropdown(
                label: 'Méthode de Paiement',
                value: _paymentMethod.toString().split('.').last, // Convertit l'enum en texte
                items: PaymentMethods.values
                    .map(
                      (m) => DropdownMenuItem(
                    value: m.toString().split('.').last,
                    child: Text(m.toString().split('.').last.replaceAll('_', ' ')),
                  ),
                )
                    .toList(),
                onChanged: (value) => setState(() =>
                _paymentMethod = PaymentMethods.values.firstWhere((e) => e.toString().split('.').last == value)),
              ),

              const SizedBox(height: 24),

              // Bouton d'envoi du formulaire
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm, // Action de validation et d’envoi
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('Payer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔤 Widget générique pour construire un champ texte avec validation
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.subtleTextColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
        ),
        style: const TextStyle(color: AppTheme.lightTextColor),
      ),
    );
  }

  // 🔽 Widget générique pour un menu déroulant stylisé
  Widget _buildDropdown({
    required String label,
    String? value,
    required List<DropdownMenuItem<String>> items,
    void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.subtleTextColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
        ),
        style: const TextStyle(color: AppTheme.lightTextColor),
        dropdownColor: AppTheme.darkBackgroundColor, // Fond sombre pour cohérence avec le thème
      ),
    );
  }

  // 💳 Fonction appelée lors de la soumission du formulaire
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Sauvegarde les valeurs du formulaire

      // Prépare les données à envoyer au serveur
      final data = {
        "contractId": widget.contract.id,
        "amount": double.parse(_amountController.text),
        "currency": widget.contract.currency,
        "paymentMethod": _paymentMethod.toString().split('.').last, // Ex: "HBAR" ou "USDC"
      };

      try {
        if (_paymentMethod == PaymentMethods.MOBILE_MONEY) {
          final res = await getIt<ContractNetworkService>().payDeposit(
            contractId: int.parse(widget.contract.id as String),
            amount: double.parse(_amountController.text),
            paymentMethod: 'MOBILE_MONEY',
          );
          final checkoutUrl = res['data']?['checkoutUrl'] ?? res['checkoutUrl'];
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(checkoutUrl != null ? 'Redirection paiement initialisée' : 'Intention de paiement créée')),
            );
          }
        } else {
          // Paiement on-chain immédiat
          await getIt<ContractNetworkService>().makePayment(data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paiement confirmé')),
            );
          }
        }
        // Retour après succès
        if (mounted) context.pop();
      } catch (e) {
        // Affiche un message d’erreur si l’appel échoue
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}
