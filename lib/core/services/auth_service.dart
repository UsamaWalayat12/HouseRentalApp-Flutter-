import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_a_home/shared/models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<UserModel> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      print('🔄 AuthService: Firebase auth state changed - User: ${firebaseUser?.uid ?? "null"}');
      
      if (firebaseUser == null) {
        print('🔄 AuthService: No authenticated Firebase user');
        return UserModel.empty;
      }
      
      try {
        print('🔄 AuthService: Fetching user details for UID: ${firebaseUser.uid}');
        final userDetails = await getUserDetails(firebaseUser.uid);
        if (userDetails != null) {
          print('✅ AuthService: User details retrieved successfully - Role: ${userDetails.role}');
          return userDetails;
        } else {
          print('❌ AuthService: Failed to retrieve user details');
          return UserModel.empty;
        }
      } catch (e) {
        print('❌ AuthService: Error fetching user details: $e');
        return UserModel.empty;
      }
    });
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    print('🔑 Attempting to sign in with email: $email');
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (result.user == null) {
        print('❌ Firebase returned null user object');
        throw Exception('Authentication failed. Please try again.');
      }
      
      print('✅ Firebase authentication successful. User ID: ${result.user!.uid}');
      
      try {
        // Verify user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(result.user!.uid).get();
        print('📄 Firestore user document exists: ${userDoc.exists}');
        
        if (!userDoc.exists) {
          print('⚠️ User authenticated but not found in Firestore. Signing out...');
          await _firebaseAuth.signOut();
          throw Exception('User account not properly set up. Please sign up again.');
        }
        
        return result.user;
      } catch (firestoreError) {
        print('❌ Firestore error: $firestoreError');
        await _firebaseAuth.signOut();
        rethrow;
      }
      
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth Error (${e.code}): ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email. Please check your email or sign up.');
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again or reset your password.');
        case 'user-disabled':
          throw Exception('This account has been disabled. Please contact support.');
        case 'invalid-email':
          throw Exception('The email address is not valid. Please check and try again.');
        case 'too-many-requests':
          throw Exception('Too many login attempts. Please try again later or reset your password.');
        default:
          throw Exception('Login failed: ${e.message ?? 'Unknown error occurred'}');
      }
    } catch (e, stackTrace) {
      print('❌ Unexpected error during sign in: $e');
      print('Stack trace: $stackTrace');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Check if email already exists in Firestore
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (existingUser.docs.isNotEmpty) {
        throw Exception('An account with this email already exists.');
      }

      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user data map directly to ensure consistent timestamp handling
        final userData = {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'verificationStatus': 'unverified', // Default verification status
          'reviewCount': 0,
          'bookingConfirmations': true,
          'newMessages': true,
          'promotionalOffers': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userData);
      }
      return result.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account with this email already exists.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        case 'weak-password':
          throw Exception('Please choose a stronger password.');
        default:
          throw Exception('Sign up failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<UserModel?> getUserDetails(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (!docSnapshot.exists) {
        throw Exception('User profile not found.');
      }
      return UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      throw Exception('Failed to get user details: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out.');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user details: ${e.toString()}');
    }
  }
}


