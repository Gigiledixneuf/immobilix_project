import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:immobilx/business/models/gestion/property.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';

class PublicPropertyListPage extends StatefulWidget {
  const PublicPropertyListPage({super.key});

  @override
  State<PublicPropertyListPage> createState() => _PublicPropertyListPageState();
}

class _PublicPropertyListPageState extends State<PublicPropertyListPage> {
  final _service = GetIt.I<PropertyNetworkService>();
  late Future<List<Property>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getPublicProperties(availableOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logements disponibles')),
      body: FutureBuilder<List<Property>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucun logement disponible'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = items[index];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${p.city} • ${p.price}'),
                trailing: TextButton(
                  child: const Text('Postuler'),
                  onPressed: () async {
                    try {
                      await _service.applyToProperty(propertyId: int.parse(p.id));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Candidature envoyée')),
                        );
                      }
                    } catch (e) {
                      final msg = e.toString();
                      if (msg.contains('401') || msg.contains('403')) {
                        if (mounted) Navigator.of(context).pushNamed('/public/login');
                        return;
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}


