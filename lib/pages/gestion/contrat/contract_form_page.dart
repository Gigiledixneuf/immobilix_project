import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';
import '../../../business/models/contrat/contrat.dart';
import 'package:immobilx/business/models/gestion/property.dart';
import 'package:immobilx/business/models/user/user.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import 'package:immobilx/main.dart';
import 'package:immobilx/utils/theme/app_theme.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// 🔹 Providers Riverpod pour récupérer les données à afficher dans le formulaire
// ---------------------------------------------------------------------------

// Provider pour récupérer la liste des locataires depuis le backend
final tenantsProvider = FutureProvider<List<User>>((ref) async {
  final contractService = getIt<ContractNetworkService>();
  return contractService.getTenants();
});

// Provider pour récupérer la liste des propriétés depuis le backend
final propertiesProvider = FutureProvider<List<Property>>((ref) async {
  final propertyService = getIt<PropertyNetworkService>();
  return propertyService.getProperties();
});

// ---------------------------------------------------------------------------
// 🔹 Widget principal : Page de création / modification de contrat
// ---------------------------------------------------------------------------
class ContractFormPage extends ConsumerStatefulWidget {
  final Contract? contract; // Si non nul → mode édition
  const ContractFormPage({Key? key, this.contract}) : super(key: key);

  @override
  _ContractFormPageState createState() => _ContractFormPageState();
}

// ---------------------------------------------------------------------------
// 🔹 Classe d’état du formulaire (gestion du contenu et des actions)
// ---------------------------------------------------------------------------
class _ContractFormPageState extends ConsumerState<ContractFormPage> {
  // Clé globale du formulaire (permet de valider/sauvegarder)
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs des champs texte
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _depositMonthsController = TextEditingController();
  final TextEditingController _depositAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variables internes pour les sélections et options
  String? _selectedPropertyId;
  String? _selectedTenantId;
  String _currency = 'USD';
  String _status = 'pending';
  String _depositStatus = 'unpaid';

  // -------------------------------------------------------------------------
  // 🔹 Initialisation des champs si on est en mode "édition"
  // -------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    if (widget.contract != null) {
      _selectedPropertyId = widget.contract!.propertyId.toString();
      _selectedTenantId = widget.contract!.tenantId.toString();
      _rentAmountController.text = widget.contract!.rentAmount.toString();
      _currency = widget.contract!.currency;
      _status = widget.contract!.status;
      _depositMonthsController.text = widget.contract!.depositMonths.toString();

      // Gestion des champs optionnels (dépôt, description)
      _depositAmountController.text = widget.contract!.depositAmount?.toString() ?? '';
      _depositStatus = widget.contract!.depositStatus;
      _descriptionController.text = widget.contract!.description ?? '';

      // Conversion des dates en texte formaté
      _startDateController.text = DateFormat('yyyy-MM-dd').format(widget.contract!.startDate);
      _endDateController.text = widget.contract!.endDate != null
          ? DateFormat('yyyy-MM-dd').format(widget.contract!.endDate!)
          : '';
    }
  }

  // Libération des ressources des contrôleurs
  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _rentAmountController.dispose();
    _depositMonthsController.dispose();
    _depositAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // 🔹 Construction de l’interface utilisateur
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Observation des providers (Riverpod)
    final tenantsAsync = ref.watch(tenantsProvider);
    final propertiesAsync = ref.watch(propertiesProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.contract == null ? 'Créer un Contrat' : 'Modifier le Contrat',
          style: const TextStyle(color: AppTheme.lightTextColor),
        ),
        backgroundColor: AppTheme.darkBackgroundColor,
        iconTheme: const IconThemeData(color: AppTheme.lightTextColor),
      ),

      // Affiche un loader si les données ne sont pas encore prêtes
      body: (tenantsAsync.isLoading || propertiesAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection de la propriété
              _buildDropdown(
                label: 'Propriété',
                value: _selectedPropertyId,
                items: propertiesAsync.value
                    ?.map((p) => DropdownMenuItem(
                    value: p.id.toString(), child: Text(p.name)))
                    .toList() ??
                    [],
                onChanged: (value) => setState(() => _selectedPropertyId = value),
                validator: (value) => value == null ? 'Ce champ est requis' : null,
              ),

              // Sélection du locataire
              _buildDropdown(
                label: 'Locataire',
                value: _selectedTenantId,
                items: tenantsAsync.value
                    ?.map((t) => DropdownMenuItem(
                    value: t.id.toString(),
                    child: Text(t.fullName!)))
                    .toList() ??
                    [],
                onChanged: (value) => setState(() => _selectedTenantId = value),
                validator: (value) => value == null ? 'Ce champ est requis' : null,
              ),

              // Dates du contrat
              _buildDatePicker(
                context,
                controller: _startDateController,
                label: 'Date de début',
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Ce champ est requis' : null,
              ),
              _buildDatePicker(context,
                  controller: _endDateController, label: 'Date de fin (optionnel)'),

              // Montant du loyer
              _buildTextFormField(
                controller: _rentAmountController,
                label: 'Montant du Loyer',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ce champ est requis';
                  if (double.tryParse(value) == null) return 'Veuillez entrer un nombre valide';
                  return null;
                },
              ),

              // Sélection de la devise
              _buildDropdown(
                label: 'Devise',
                value: _currency,
                items: ['USD', 'EUR', 'CDF', 'XAF']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _currency = value!),
              ),

              // Statut du contrat
              _buildDropdown(
                label: 'Statut',
                value: _status,
                items: ['pending', 'active', 'terminated']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),

              // Mois de dépôt
              _buildTextFormField(
                controller: _depositMonthsController,
                label: 'Mois de Dépôt',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ce champ est requis';
                  if (int.tryParse(value) == null)
                    return 'Veuillez entrer un nombre entier valide';
                  return null;
                },
              ),

              // Montant du dépôt
              _buildTextFormField(
                controller: _depositAmountController,
                label: 'Montant du Dépôt (optionnel)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),

              // Statut du dépôt (payé / partiel / impayé)
              _buildDropdown(
                label: 'Statut du Dépôt',
                value: _depositStatus,
                items: ['unpaid', 'paid', 'partial']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _depositStatus = value!),
              ),

              // Description du contrat
              _buildTextFormField(controller: _descriptionController, label: 'Description', maxLines: 3),

              const SizedBox(height: 24),

              // Bouton d’envoi du formulaire
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  child: Text(widget.contract == null ? 'Créer le Contrat' : 'Mettre à jour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🔹 Composant réutilisable : champ de texte
  // -------------------------------------------------------------------------
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.subtleTextColor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor)),
        ),
        style: const TextStyle(color: AppTheme.lightTextColor),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🔹 Composant réutilisable : menu déroulant (Dropdown)
  //   Gère les valeurs invalides pour éviter un bug Flutter courant
  // -------------------------------------------------------------------------
  Widget _buildDropdown({
    required String label,
    String? value,
    required List<DropdownMenuItem<String>> items,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    // Vérifie si la valeur actuelle existe dans la liste
    final bool isValueInItems = value != null && items.any((item) => item.value == value);
    final String? safeValue = (items.isEmpty || !isValueInItems) ? null : value;
    final String? hintText = safeValue == null ? 'Sélectionner une option' : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        hint: hintText != null
            ? Text(hintText, style: const TextStyle(color: AppTheme.subtleTextColor))
            : null,
        items: items,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.subtleTextColor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5))),
          focusedBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
        ),
        style: const TextStyle(color: AppTheme.lightTextColor),
        dropdownColor: AppTheme.darkBackgroundColor,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🔹 Composant réutilisable : champ de sélection de date
  // -------------------------------------------------------------------------
  Widget _buildDatePicker(BuildContext context,
      {required TextEditingController controller,
        required String label,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Empêche la saisie manuelle
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.subtleTextColor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5))),
          focusedBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            onPressed: () async {
              // Affiche le sélecteur de date
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(date);
              }
            },
          ),
        ),
        style: const TextStyle(color: AppTheme.lightTextColor),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🔹 Soumission du formulaire (création ou mise à jour du contrat)
  // -------------------------------------------------------------------------
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Données à envoyer à l’API
      final data = {
        "propertyId": int.parse(_selectedPropertyId!),
        "tenantId": int.parse(_selectedTenantId!),
        "startDate": _startDateController.text,
        "endDate": _endDateController.text.isNotEmpty ? _endDateController.text : null,
        "rentAmount": _rentAmountController.text, // envoyé comme String
        "currency": _currency,
        "status": _status,
        "depositMonths": int.parse(_depositMonthsController.text),
        "depositAmount": _depositAmountController.text.isNotEmpty
            ? _depositAmountController.text
            : null,
        "depositStatus": _depositStatus,
        "description": _descriptionController.text,
      };

      print('Données envoyées au serveur: $data'); // Pour le débogage

      try {
        // Création ou mise à jour selon le mode
        if (widget.contract == null) {
          await getIt<ContractNetworkService>().createContract(data);
        } else {
          await getIt<ContractNetworkService>().updateContract(widget.contract!.id, data);
        }

        // Rafraîchit la liste des contrats si un provider existe
        // ref.refresh(contractListProvider);

        context.pop(); // Retour à la page précédente
      } catch (e) {
        // Affiche un message d’erreur (ex: erreur 400)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}
