import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth getters
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // Collections
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get providersCollection => _firestore.collection('providers');
  CollectionReference get bookingsCollection => _firestore.collection('bookings');
  CollectionReference get documentsCollection => _firestore.collection('documents');

  // Authentication Methods
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  // Firestore Methods
  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await usersCollection.doc(userId).get();
  }

  Future<void> createUserDocument(String userId, Map<String, dynamic> data) async {
    await usersCollection.doc(userId).set(data);
  }

  Future<void> updateUserDocument(String userId, Map<String, dynamic> data) async {
    await usersCollection.doc(userId).update(data);
  }

  Future<QuerySnapshot> getProviders() async {
    return await providersCollection.where('status', isEqualTo: 'verified').get();
  }

  Future<QuerySnapshot> getProvidersNearLocation(double lat, double lng, double radiusKm) async {
    // Simple radius query - in production, use GeoFlutterFire for better geo queries
    return await providersCollection
        .where('status', isEqualTo: 'verified')
        .where('latitude', isGreaterThan: lat - (radiusKm / 111))
        .where('latitude', isLessThan: lat + (radiusKm / 111))
        .get();
  }

  Future<void> createProvider(Map<String, dynamic> data) async {
    await providersCollection.add(data);
  }

  Future<void> updateProvider(String providerId, Map<String, dynamic> data) async {
    await providersCollection.doc(providerId).update(data);
  }

  Future<QuerySnapshot> getUserBookings(String userId) async {
    return await bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getProviderBookings(String providerId) async {
    return await bookingsCollection
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    await bookingsCollection.add(data);
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    await bookingsCollection.doc(bookingId).update(data);
  }

  // Storage Methods
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw e;
    }
  }

  Future<List<String>> uploadMultipleFiles(List<File> files, String basePath) async {
    List<String> downloadUrls = [];
    
    for (int i = 0; i < files.length; i++) {
      String path = '$basePath/file_$i.${files[i].path.split('.').last}';
      String url = await uploadFile(files[i], path);
      downloadUrls.add(url);
    }
    
    return downloadUrls;
  }

  Future<void> deleteFile(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      throw e;
    }
  }
}