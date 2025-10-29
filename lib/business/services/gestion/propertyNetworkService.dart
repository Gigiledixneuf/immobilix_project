import '../../models/gestion/property.dart';

abstract class PropertyNetworkService {
  Future<List<Property>> getProperties();
}
