class Property {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String address;
  final String city;
  final String type;
  final int? surface;
  final int? rooms;
  final int capacity;
  final double price;
  final String? mainPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.address,
    required this.city,
    required this.type,
    this.surface,
    this.rooms,
    required this.capacity,
    required this.price,
    this.mainPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      name: json['name'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      type: json['type'],
      surface: json['surface'],
      rooms: json['rooms'],
      capacity: json['capacity'],
      price: double.parse(json['price']),
      mainPhotoUrl: json['mainPhotoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'type': type,
      'surface': surface,
      'rooms': rooms,
      'capacity': capacity,
      'price': price.toString(),
      'mainPhotoUrl': mainPhotoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
