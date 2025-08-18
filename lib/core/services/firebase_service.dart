import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/property_model.dart';
import '../../shared/models/booking.dart';
import '../../shared/models/payment_model.dart';
import '../../shared/models/payment_model.dart';
import '../../shared/models/review_model.dart';
import '../../shared/models/tour_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String propertiesCollection = 'properties';
  static const String bookingsCollection = 'bookings';
  static const String paymentsCollection = 'payments';
  static const String reviewsCollection = 'reviews';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String toursCollection = 'tours';

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Authentication Methods
  static Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // User Management
  static Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return UserModel.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  static Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Image Upload from XFile (web compatible)
  static Future<List<String>> uploadImagesFromXFiles(List<XFile> images) async {
    try {
      final List<String> imageUrls = [];
      for (final image in images) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'property_images/${timestamp}_${image.name.replaceAll(' ', '_')}';
        final ref = _storage.ref().child(fileName);
        
        // Read bytes from XFile - works on both web and mobile
        final Uint8List imageBytes = await image.readAsBytes();
        
        // Set metadata to help with CORS
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_by': 'flutter_web_app',
            'upload_time': timestamp.toString(),
          },
        );
        
        // Use putData with metadata and custom error handling
        final uploadTask = ref.putData(imageBytes, metadata);
        
        // Listen to upload progress for better error handling
        await uploadTask.whenComplete(() => null);
        final snapshot = await uploadTask;
        
        if (snapshot.state == TaskState.success) {
          final downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        } else {
          throw Exception('Upload failed with state: ${snapshot.state}');
        }
      }
      return imageUrls;
    } catch (e) {
      if (e.toString().contains('CORS')) {
        throw Exception('CORS Error: Please configure Firebase Storage CORS settings or try refreshing the page');
      }
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }

  // Image Upload from File (legacy - for backward compatibility)
  static Future<List<String>> uploadImages(List<File> images) async {
    try {
      final List<String> imageUrls = [];
      for (final image in images) {
        final ref = _storage
            .ref()
            .child('property_images/${DateTime.now().millisecondsSinceEpoch}');
        
        UploadTask uploadTask;
        if (kIsWeb) {
          // For web, read file as bytes and use putData
          final Uint8List imageBytes = await image.readAsBytes();
          uploadTask = ref.putData(imageBytes);
        } else {
          // For mobile platforms, use putFile
          uploadTask = ref.putFile(image);
        }
        
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }

  // Booking Management
    static Future<void> bookProperty(Booking booking) async {
    try {
      await _firestore.collection(bookingsCollection).add(booking.toJson());
    } catch (e) {
      throw Exception('Failed to book property: ${e.toString()}');
    }
  }

  // Tour Management
  static Future<void> scheduleTour(TourModel tour) async {
    try {
      await _firestore.collection(toursCollection).add(tour.toJson());
    } catch (e) {
      throw Exception('Failed to schedule tour: ${e.toString()}');
    }
  }

  // Property Management
  static Future<String> addProperty(PropertyModel property) async {
    try {
      final docRef = await _firestore.collection(propertiesCollection).add(property.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add property: ${e.toString()}');
    }
  }

  static Future<void> updateProperty(PropertyModel property) async {
    try {
      final jsonData = property.toJson();
      
      // Debug print to check what's being saved
      print('=== FIREBASE UPDATE DEBUG ===');
      print('Property ID: ${property.id}');
      print('ImageUrls in JSON: ${jsonData['imageUrls']}');
      print('JSON Keys: ${jsonData.keys.toList()}');
      print('=============================');
      
      await _firestore.collection(propertiesCollection).doc(property.id).update(jsonData);
      
      print('Property updated successfully in Firebase!');
    } catch (e) {
      print('Firebase update error: ${e.toString()}');
      throw Exception('Failed to update property: ${e.toString()}');
    }
  }

  static Future<void> deleteProperty(String propertyId) async {
    try {
      await _firestore.collection(propertiesCollection).doc(propertyId).delete();
    } catch (e) {
      throw Exception('Failed to delete property: ${e.toString()}');
    }
  }

  static Future<PropertyModel?> getProperty(String propertyId) async {
    try {
      final doc = await _firestore.collection(propertiesCollection).doc(propertyId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return PropertyModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get property: ${e.toString()}');
    }
  }

  static Stream<List<PropertyModel>> getProperties() {
    return _firestore
        .collection(propertiesCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return PropertyModel.fromJson(data);
            }).toList());
  }

  static Stream<List<PropertyModel>> getPropertiesByLandlord(String landlordId) {
    return _firestore
        .collection(propertiesCollection)
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return PropertyModel.fromJson(data);
            }).toList());
  }

  static Future<List<PropertyModel>> searchProperties({
    String? query,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    String? city,
  }) async {
    try {
      Query queryRef = _firestore.collection(propertiesCollection)
          .where('isAvailable', isEqualTo: true);

      if (propertyType != null && propertyType.isNotEmpty) {
        queryRef = queryRef.where('type', isEqualTo: propertyType);
      }

      if (minPrice != null) {
        queryRef = queryRef.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        queryRef = queryRef.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (bedrooms != null) {
        queryRef = queryRef.where('bedrooms', isGreaterThanOrEqualTo: bedrooms);
      }

      if (bathrooms != null) {
        queryRef = queryRef.where('bathrooms', isGreaterThanOrEqualTo: bathrooms);
      }

      if (city != null && city.isNotEmpty) {
        queryRef = queryRef.where('city', isEqualTo: city);
      }

      final snapshot = await queryRef.get();
      List<PropertyModel> properties = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PropertyModel.fromJson(data);
      }).toList();

      // Filter by query text if provided
      if (query != null && query.isNotEmpty) {
        properties = properties.where((property) {
          return property.title.toLowerCase().contains(query.toLowerCase()) ||
                 property.description.toLowerCase().contains(query.toLowerCase()) ||
                 property.city.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      return properties;
    } catch (e) {
      throw Exception('Failed to search properties: ${e.toString()}');
    }
  }

  // Booking Management
    static Future<String> createBooking(Booking booking) async {
    try {
      final docRef = await _firestore.collection(bookingsCollection).add(booking.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

    static Future<void> updateBooking(Booking booking) async {
    try {
      await _firestore.collection(bookingsCollection).doc(booking.id).update(booking.toJson());
    } catch (e) {
      throw Exception('Failed to update booking: ${e.toString()}');
    }
  }

  static Future<Booking?> getBooking(String bookingId) async {
    try {
      final doc = await _firestore.collection(bookingsCollection).doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: ${e.toString()}');
    }
  }

  static Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection(bookingsCollection).doc(bookingId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: ${e.toString()}');
    }
  }

  static Stream<List<Booking>> getBookingsByTenant(String tenantId) {
    return _firestore
        .collection(bookingsCollection)
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  static Stream<List<Booking>> getBookingsByLandlord(String landlordId) {
    return _firestore
        .collection(bookingsCollection)
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) =>
              Booking.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    });
  }

  static Stream<List<Booking>> getBookingsByProperty(String propertyId) {
    return _firestore
        .collection(bookingsCollection)
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  // Payment Management
  static Future<String> createPayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore.collection(paymentsCollection).add(payment.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payment: ${e.toString()}');
    }
  }

  static Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _firestore.collection(paymentsCollection).doc(payment.id).update(payment.toJson());
    } catch (e) {
      throw Exception('Failed to update payment: ${e.toString()}');
    }
  }

  static Stream<List<PaymentModel>> getPaymentsByTenant(String tenantId) {
    return _firestore
        .collection(paymentsCollection)
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return PaymentModel.fromJson(data);
            }).toList());
  }

  static Stream<List<PaymentModel>> getPaymentsByLandlord(String landlordId) {
    return _firestore
        .collection(paymentsCollection)
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) {
      final payments = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PaymentModel.fromJson(data);
      }).toList();
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return payments;
    });
  }

  static Stream<List<PaymentModel>> getPaymentsByBooking(String bookingId) {
    return _firestore
        .collection(paymentsCollection)
        .where('bookingId', isEqualTo: bookingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return PaymentModel.fromJson(data);
            }).toList());
  }

  // Review Management
  static Future<String> addReview(ReviewModel review) async {
    try {
      final docRef = await _firestore.collection(reviewsCollection).add(review.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add review: ${e.toString()}');
    }
  }

  static Future<void> updateReview(ReviewModel review) async {
    try {
      await _firestore.collection(reviewsCollection).doc(review.id).update(review.toJson());
    } catch (e) {
      throw Exception('Failed to update review: ${e.toString()}');
    }
  }

  static Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(reviewsCollection).doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: ${e.toString()}');
    }
  }

  static Stream<List<ReviewModel>> getReviewsByProperty(String propertyId) {
    return _firestore
        .collection(reviewsCollection)
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ReviewModel.fromJson(data);
            }).toList());
  }

  static Stream<List<ReviewModel>> getReviewsByUser(String userId) {
    return _firestore
        .collection(reviewsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ReviewModel.fromJson(data);
            }).toList());
  }

  // Chat and Messaging
  static Future<String> createChatRoom(String tenantId, String landlordId, String propertyId) async {
    try {
      final chatId = '${tenantId}_${landlordId}_$propertyId';
      await _firestore.collection(chatsCollection).doc(chatId).set({
        'id': chatId,
        'tenantId': tenantId,
        'landlordId': landlordId,
        'propertyId': propertyId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      return chatId;
    } catch (e) {
      throw Exception('Failed to create chat room: ${e.toString()}');
    }
  }

  static Future<void> sendMessage(String chatId, String senderId, String message) async {
    try {
      // Add message to messages subcollection
      await _firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesCollection)
          .add({
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update chat room with last message
      await _firestore.collection(chatsCollection).doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  static Stream<List<Map<String, dynamic>>> getChatMessages(String chatId) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  static Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection(chatsCollection)
        .where('tenantId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<Map<String, dynamic>>> getLandlordChats(String landlordId) {
    return _firestore
        .collection(chatsCollection)
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Analytics and Statistics
  static Future<Map<String, dynamic>> getLandlordAnalytics(String landlordId) async {
    try {
      // Get properties count
      final propertiesSnapshot = await _firestore
          .collection(propertiesCollection)
          .where('landlordId', isEqualTo: landlordId)
          .get();

      // Get bookings count
      final bookingsSnapshot = await _firestore
          .collection(bookingsCollection)
          .where('landlordId', isEqualTo: landlordId)
          .get();

      // Get total revenue
      final paymentsSnapshot = await _firestore
          .collection(paymentsCollection)
          .where('landlordId', isEqualTo: landlordId)
          .get();

      double totalRevenue = 0;
      final completedPayments = paymentsSnapshot.docs.where((doc) => doc.data()['status'] == 'completed');
      for (var doc in completedPayments) {
        totalRevenue += (doc.data()['amount'] as num).toDouble();
      }

      return {
        'propertiesCount': propertiesSnapshot.docs.length,
        'bookingsCount': bookingsSnapshot.docs.length,
        'totalRevenue': totalRevenue,
        'averageRating': 4.5, // Calculate from reviews
      };
    } catch (e) {
      throw Exception('Failed to get analytics: ${e.toString()}');
    }
  }

  // Utility Methods
  static Future<bool> checkEmailExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<void> updatePropertyRating(String propertyId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection(reviewsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }
        
        final averageRating = totalRating / reviewsSnapshot.docs.length;
        final reviewCount = reviewsSnapshot.docs.length;

        await _firestore.collection(propertiesCollection).doc(propertyId).update({
          'rating': averageRating,
          'reviewCount': reviewCount,
        });
      }
    } catch (e) {
      throw Exception('Failed to update property rating: ${e.toString()}');
    }
  }

  // Alternative upload method with retry logic and better error handling
  static Future<List<String>> uploadImagesWithRetry(List<XFile> images, {int maxRetries = 3}) async {
    final List<String> imageUrls = [];
    
    for (final image in images) {
      bool uploaded = false;
      int retryCount = 0;
      
      while (!uploaded && retryCount < maxRetries) {
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'property_images/${timestamp}_${retryCount}_${image.name.replaceAll(' ', '_')}';
          final ref = _storage.ref().child(fileName);
          
          final Uint8List imageBytes = await image.readAsBytes();
          
          // Create upload task
          final uploadTask = ref.putData(
            imageBytes,
            SettableMetadata(
              contentType: _getContentType(image.name),
              cacheControl: 'max-age=3600',
              customMetadata: {
                'uploaded_by': 'flutter_web',
                'retry_count': retryCount.toString(),
              },
            ),
          );
          
          // Wait for upload to complete
          final snapshot = await uploadTask;
          
          if (snapshot.state == TaskState.success) {
            final downloadUrl = await snapshot.ref.getDownloadURL();
            imageUrls.add(downloadUrl);
            uploaded = true;
          } else {
            throw Exception('Upload failed with state: ${snapshot.state}');
          }
          
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('Failed to upload ${image.name} after $maxRetries attempts: ${e.toString()}');
          }
          // Wait before retry
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    }
    
    return imageUrls;
  }
  
  static String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

