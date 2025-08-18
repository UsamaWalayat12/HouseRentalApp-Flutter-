import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get chat messages stream
  Stream<QuerySnapshot> getChatMessages(String bookingId) {
    return _firestore
        .collection('chats')
        .doc(bookingId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String message,
    required String senderRole,
  }) async {
    try {
      final chatRef = _firestore.collection('chats').doc(bookingId);
      
      // Add message to subcollection
      await chatRef.collection('messages').add({
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'senderRole': senderRole,
      });

      // Update chat metadata
      await chatRef.set({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get user's chats
  Stream<QuerySnapshot> getUserChats({
    required String userId,
    required String userRole,
  }) {
    final String roleField = userRole == 'tenant' ? 'tenantId' : 'landlordId';
    
    return _firestore
        .collection('chats')
        .where(roleField, isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String bookingId, String userId) async {
    try {
      await _firestore.collection('chats').doc(bookingId).update({
        'unreadCount': 0,
        'lastReadBy': userId,
        'lastReadAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Get unread messages count
  Stream<int> getUnreadCount(String userId, String userRole) {
    final String roleField = userRole == 'tenant' ? 'tenantId' : 'landlordId';
    
    return _firestore
        .collection('chats')
        .where(roleField, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          int count = 0;
          for (var doc in snapshot.docs) {
            count += (doc.data() as Map<String, dynamic>)['unreadCount'] as int? ?? 0;
          }
          return count;
        });
  }

  // Delete chat
  Future<void> deleteChat(String bookingId) async {
    try {
      // Delete all messages
      final messages = await _firestore
          .collection('chats')
          .doc(bookingId)
          .collection('messages')
          .get();
      
      for (var message in messages.docs) {
        await message.reference.delete();
      }

      // Delete chat document
      await _firestore.collection('chats').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  // Get chat metadata
  Stream<DocumentSnapshot> getChatMetadata(String bookingId) {
    return _firestore
        .collection('chats')
        .doc(bookingId)
        .snapshots();
  }
} 