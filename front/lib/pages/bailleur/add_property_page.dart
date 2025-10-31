import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';
import 'package:immobilx/main.dart';
import 'package:immobilx/utils/theme/app_theme.dart';
import 'package:immobilx/pages/widget/custom_input.dart';
import 'package:immobilx/pages/widget/primary_button.dart';
import 'package:image_picker/image_picker.dart';

// --- Gestion d'État (inchangée) ---
final addPropertyControllerProvider = StateNotifierProvider.autoDispose<AddPropertyController, AddPropertyState>((ref) {
  return AddPropertyController(getIt<PropertyNetworkService>());
});

class AddPropertyState {
  final bool isLoading;
  final String? errorMessage;

  AddPropertyState({this.isLoading = false, this.errorMessage});

  AddPropertyState copyWith({bool? isLoading, String? errorMessage}) {
    return AddPropertyState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AddPropertyController extends StateNotifier<AddPropertyState> {
  final PropertyNetworkService _propertyNetworkService;
  AddPropertyController(this._propertyNetworkService) : super(AddPropertyState());

  Future<bool> createProperty(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _propertyNetworkService.createProperty(data);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erreur lors de la création du logement.");
      print(e); // Pour le débogage
      return false;
    }
  }
}

// --- La Page (Widget) mise à jour avec le Dark Mode ---
class AddPropertyPage extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _capacityController = TextEditingController(text: '1');
  String _selectedType = 'apartment'; // Utilisé ici comme valeur par défaut, sera mis à jour via le Dropdown
  XFile? _pickedImage;

  AddPropertyPage({super.key});

  // Fonction utilitaire pour le style Dropdown en dark mode
  InputDecoration _darkDropdownDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppTheme.subtleTextColor),
      floatingLabelStyle: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),

      fillColor: AppTheme.lightTextColor.withOpacity(0.05),
      filled: true,

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.lightTextColor.withOpacity(0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AddPropertyState>(addPropertyControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    final state = ref.watch(addPropertyControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor, // Fond sombre
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightTextColor),
          onPressed: () => context.goNamed('property_list_page'),
        ),
        title: Text(
          'Ajouter un logement',
          style: AppTheme.headingStyle.copyWith(fontSize: 20, color: AppTheme.lightTextColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInput(controller: _nameController, labelText: 'Nom du logement', validator: (val) => val!.isEmpty ? 'Champ requis' : null),
              const SizedBox(height: 16),
              CustomInput(controller: _addressController, labelText: 'Adresse', validator: (val) => val!.isEmpty ? 'Champ requis' : null),
              const SizedBox(height: 16),
              CustomInput(controller: _cityController, labelText: 'Ville', validator: (val) => val!.isEmpty ? 'Champ requis' : null),
              const SizedBox(height: 16),
              CustomInput(controller: _descriptionController, labelText: 'Description', maxLines: 3),
              const SizedBox(height: 16),
              CustomInput(
                  controller: _rentController,
                  labelText: 'Loyer mensuel (€)',
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Champ requis' : null
              ),
              const SizedBox(height: 16),
              // Type de propriété (stylisé)
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: _darkDropdownDecoration('Type de propriété'), // Application du style sombre
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.subtleTextColor),
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.lightTextColor), // Texte sélectionné
                    dropdownColor: AppTheme.darkBackgroundColor, // Fond du menu déroulant
                    items: const [
                      DropdownMenuItem(value: 'house', child: Text('Maison', style: TextStyle(color: AppTheme.lightTextColor))),
                      DropdownMenuItem(value: 'apartment', child: Text('Appartement', style: TextStyle(color: AppTheme.lightTextColor))),
                      DropdownMenuItem(value: 'studio', child: Text('Studio', style: TextStyle(color: AppTheme.lightTextColor))),
                      DropdownMenuItem(value: 'room', child: Text('Chambre', style: TextStyle(color: AppTheme.lightTextColor))),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedType = v;
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Surface, pièces
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      controller: _surfaceController,
                      labelText: 'Surface (m²)',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInput(
                      controller: _roomsController,
                      labelText: 'Pièces',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Capacité
              CustomInput(
                controller: _capacityController,
                labelText: 'Capacité (pers.)',
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              // Sélecteur d'image principale (stylisé)
              StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            // Style du bouton Outlined adapté au dark mode
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.image_outlined),
                            label: Text(
                              _pickedImage == null ? 'Choisir une image principale' : 'Image sélectionnée',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: state.isLoading
                                ? null
                                : () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                              if (file != null) {
                                setState(() {
                                  _pickedImage = file;
                                });
                              }
                            },
                          ),
                        ),
                        if (_pickedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: AppTheme.warningColor),
                              onPressed: () => setState(() => _pickedImage = null),
                            ),
                          ),
                      ],
                    );
                  }
              ),
              const SizedBox(height: 32),
              // Bouton d'enregistrement
              PrimaryButton(
                text: 'Enregistrer le logement',
                isLoading: state.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'name': _nameController.text,
                      'address': _addressController.text,
                      'city': _cityController.text,
                      'description': _descriptionController.text,
                      'price': double.tryParse(_rentController.text) ?? 0,
                      'type': _selectedType,
                      'surface': int.tryParse(_surfaceController.text) ?? 0,
                      'rooms': int.tryParse(_roomsController.text) ?? 0,
                      'capacity': int.tryParse(_capacityController.text) ?? 1,
                      if (_pickedImage != null) 'main_photo_local_path': _pickedImage!.path,
                    };

                    final success = await ref.read(addPropertyControllerProvider.notifier).createProperty(data);

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logement créé avec succès !'), backgroundColor: Colors.green),
                      );
                      context.pop(); // Revenir à la page précédente
                    }
                  }
                },
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Erreur: ${state.errorMessage}',
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
