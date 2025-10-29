import 'dart:convert';

import '../../../business/models/gestion/property.dart';
import '../../../business/services/gestion/propertyNetworkService.dart';
import '../../../utils/http/HttpUtils.dart';

class PropertyNetworkServiceImpl extends PropertyNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  PropertyNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<Property> getProperty(int id) async {
    final response = await httpUtils.getData('$baseUrl/api/properties/$id');
    final data = jsonDecode(response);
    return Property.fromJson(data['data']);
  }

  @override
  Future<List<Property>> getProperties() async {
    final response = await httpUtils.getData('$baseUrl/api/properties');
    final data = jsonDecode(response);
    final List<dynamic> propertiesJson = data['data'];
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }
}
