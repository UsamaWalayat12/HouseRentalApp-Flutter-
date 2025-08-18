import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if a property is in favorites
  static Future<bool> isFavorite(String propertyId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final favoriteIds = List<String>.from(userData['favorites'] ?? []);
        return favoriteIds.contains(propertyId);
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Add property to favorites
  static Future<bool> addToFavorites(String propertyId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'favorites': FieldValue.arrayUnion([propertyId])
      });
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove property from favorites
  static Future<bool> removeFromFavorites(String propertyId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'favorites': FieldValue.arrayRemove([propertyId])
      });
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(String propertyId) async {
    try {
      final isFav = await isFavorite(propertyId);
      if (isFav) {
        return await removeFromFavorites(propertyId);
      } else {
        return await addToFavorites(propertyId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Get user's favorite property IDs
  static Future<List<String>> getFavoriteIds() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return List<String>.from(userData['favorites'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }
}
