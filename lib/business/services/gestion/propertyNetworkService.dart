import '../../models/gestion/property.dart';

abstract class PropertyNetworkService {
  Future<Property> getProperty(int id);
  Future<List<Property>> getProperties();
}
