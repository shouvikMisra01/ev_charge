import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String id;
  final String userId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String chargerType; // 'slow', 'fast', 'ac', 'dc'
  final double pricePerHour;
  final List<String> availableDays; // ['monday', 'tuesday', etc.]
  final String startTime; // '09:00'
  final String endTime; // '18:00'
  final List<String> images;
  final List<String> documents;
  final String status; // 'pending', 'verified', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.chargerType,
    required this.pricePerHour,
    required this.availableDays,
    required this.startTime,
    required this.endTime,
    this.images = const [],
    this.documents = const [],
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      chargerType: data['chargerType'] ?? 'slow',
      pricePerHour: data['pricePerHour']?.toDouble() ?? 0.0,
      availableDays: List<String>.from(data['availableDays'] ?? []),
      startTime: data['startTime'] ?? '09:00',
      endTime: data['endTime'] ?? '18:00',
      images: List<String>.from(data['images'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'chargerType': chargerType,
      'pricePerHour': pricePerHour,
      'availableDays': availableDays,
      'startTime': startTime,
      'endTime': endTime,
      'images': images,
      'documents': documents,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProviderModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? chargerType,
    double? pricePerHour,
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    List<String>? images,
    List<String>? documents,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      chargerType: chargerType ?? this.chargerType,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}