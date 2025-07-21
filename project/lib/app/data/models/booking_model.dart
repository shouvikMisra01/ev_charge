import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final String providerAddress;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'refunded'
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.providerAddress,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      providerAddress: data['providerAddress'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'providerId': providerId,
      'providerName': providerName,
      'providerAddress': providerAddress,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? providerName,
    String? providerAddress,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    double? totalAmount,
    String? status,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerAddress: providerAddress ?? this.providerAddress,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}