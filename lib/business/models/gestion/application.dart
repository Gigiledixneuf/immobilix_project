import 'package:immobilx/business/models/user/user.dart';

class ApplicationModel {
  final String id;
  final int propertyId;
  final int tenantId;
  final String? message;
  final String status;
  final DateTime createdAt;
  final User? tenant;

  ApplicationModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.tenant,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      propertyId: int.parse(json['propertyId'].toString()),
      tenantId: int.parse(json['tenantId'].toString()),
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      tenant: json['tenant'] != null ? User.fromJson(json['tenant']) : null,
    );
  }
}




