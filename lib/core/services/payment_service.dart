import '../../shared/models/payment_model.dart';
import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  // Create a new payment
  static Future<String> createPayment(PaymentModel payment) async {
    try {
      return await FirebaseService.createPayment(payment);
    } catch (e) {
      throw Exception('Failed to create payment: ${e.toString()}');
    }
  }

  // Update an existing payment
  static Future<void> updatePayment(PaymentModel payment) async {
    try {
      await FirebaseService.updatePayment(payment);
    } catch (e) {
      throw Exception('Failed to update payment: ${e.toString()}');
    }
  }

  // Get payments by tenant (stream)
  static Stream<List<PaymentModel>> getPaymentsByTenant(String tenantId) {
    return FirebaseService.getPaymentsByTenant(tenantId);
  }

  // Get payments by landlord (stream)
  static Stream<List<PaymentModel>> getPaymentsByLandlord(String landlordId) {
    return FirebaseService.getPaymentsByLandlord(landlordId);
  }

  // Get payments by booking (stream)
  static Stream<List<PaymentModel>> getPaymentsByBooking(String bookingId) {
    return FirebaseService.getPaymentsByBooking(bookingId);
  }

  // Process payment (mock implementation)
  static Future<bool> processPayment(
    String paymentId,
    String paymentMethod,
    Map<String, dynamic> paymentDetails,
  ) async {
    try {
      // In a real app, this would integrate with payment processors like Stripe, PayPal, etc.
      // For now, we'll simulate payment processing
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
      
      // Mock payment success (90% success rate)
      final isSuccess = DateTime.now().millisecond % 10 != 0;
      
      if (isSuccess) {
        // Update payment status to completed
        final paymentsStream = FirebaseService.getPaymentsByTenant(''); // This would need the actual tenant ID
        // In a real implementation, you'd get the payment by ID and update it
        return true;
      } else {
        throw Exception('Payment processing failed');
      }
    } catch (e) {
      throw Exception('Failed to process payment: ${e.toString()}');
    }
  }

  // Update payment status
  static Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus status,
  ) async {
    try {
      // In a real implementation, you'd fetch the payment first, then update it
      final payment = await getPayment(paymentId);
      if (payment != null) {
        final updatedPayment = payment.copyWith(
          status: status,
          updatedAt: DateTime.now(),
          paidDate: status == PaymentStatus.completed ? DateTime.now() : null,
        );
        await updatePayment(updatedPayment);
      }
    } catch (e) {
      throw Exception('Failed to update payment status: ${e.toString()}');
    }
  }

  // Get payment statistics for landlord
  static Future<Map<String, dynamic>> getPaymentStatistics(String landlordId) async {
    try {
      final paymentsStream = FirebaseService.getPaymentsByLandlord(landlordId);
      final payments = await paymentsStream.first;
      
      double totalRevenue = 0;
      double pendingAmount = 0;
      double completedAmount = 0;
      int totalPayments = payments.length;
      int completedPayments = 0;
      int pendingPayments = 0;
      int failedPayments = 0;
      int processingPayments = 0;
      int refundedPayments = 0;
      
      for (final payment in payments) {
        switch (payment.status) {
          case PaymentStatus.completed:
            completedAmount += payment.amount;
            completedPayments++;
            totalRevenue += payment.amount;
            break;
          case PaymentStatus.pending:
            pendingAmount += payment.amount;
            pendingPayments++;
            break;
          case PaymentStatus.failed:
            failedPayments++;
            break;
          case PaymentStatus.processing:
            processingPayments++;
            break;
          case PaymentStatus.refunded:
            refundedPayments++;
            break;
        }
      }
      
      return {
        'totalRevenue': totalRevenue,
        'completedAmount': completedAmount,
        'pendingAmount': pendingAmount,
        'totalPayments': totalPayments,
        'completedPayments': completedPayments,
        'pendingPayments': pendingPayments,
        'failedPayments': failedPayments,
        'processingPayments': processingPayments,
        'refundedPayments': refundedPayments,
        'averagePaymentAmount': totalPayments > 0 ? totalRevenue / totalPayments : 0,
        'successRate': totalPayments > 0 ? (completedPayments / totalPayments) * 100 : 0,
      };
    } catch (e) {
      throw Exception('Failed to get payment statistics: ${e.toString()}');
    }
  }

  // Get monthly revenue for landlord
  static Future<List<Map<String, dynamic>>> getMonthlyRevenue(
    String landlordId,
    int months,
  ) async {
    try {
      final paymentsStream = FirebaseService.getPaymentsByLandlord(landlordId);
      final payments = await paymentsStream.first;
      
      final now = DateTime.now();
      final monthlyData = <Map<String, dynamic>>[];
      
      for (int i = months - 1; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(now.year, now.month - i + 1, 1);
        
        final monthPayments = payments.where((payment) {
          return payment.createdAt.isAfter(month) &&
                 payment.createdAt.isBefore(nextMonth) &&
                 payment.status == PaymentStatus.completed;
        });
        
        double monthlyRevenue = 0;
        for (final payment in monthPayments) {
          monthlyRevenue += payment.amount;
        }
        
        monthlyData.add({
          'month': month,
          'revenue': monthlyRevenue,
          'paymentCount': monthPayments.length,
        });
      }
      
      return monthlyData;
    } catch (e) {
      throw Exception('Failed to get monthly revenue: ${e.toString()}');
    }
  }

  // Get payment methods statistics
  static Future<Map<String, dynamic>> getPaymentMethodsStatistics(String landlordId) async {
    try {
      final paymentsStream = FirebaseService.getPaymentsByLandlord(landlordId);
      final payments = await paymentsStream.first;
      
      final methodStats = <String, Map<String, dynamic>>{};
      
      for (final payment in payments) {
        if (payment.status == PaymentStatus.completed) {
          if (!methodStats.containsKey(payment.paymentMethod)) {
            methodStats[payment.paymentMethod] = {
              'count': 0,
              'amount': 0.0,
            };
          }
          
          methodStats[payment.paymentMethod]!['count'] += 1;
          methodStats[payment.paymentMethod]!['amount'] += payment.amount;
        }
      }
      
      return methodStats;
    } catch (e) {
      throw Exception('Failed to get payment methods statistics: ${e.toString()}');
    }
  }

  // Create payment for booking
  static Future<String> createPaymentForBooking(
    String bookingId,
    String tenantId,
    String landlordId,
    String propertyId,
    double amount,
    String paymentMethod,
  ) async {
    try {
      final payment = PaymentModel(
        id: '', // Will be set by Firestore
        bookingId: bookingId,
        propertyId: propertyId,
        tenantId: tenantId,
        landlordId: landlordId,
        amount: amount,
        type: PaymentType.rent,
        status: PaymentStatus.pending,
        paymentMethod: paymentMethod,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return await createPayment(payment);
    } catch (e) {
      throw Exception('Failed to create payment for booking: ${e.toString()}');
    }
  }

  // Refund payment
  static Future<void> refundPayment(String paymentId, double refundAmount) async {
    try {
      // In a real implementation, this would process the refund through the payment processor
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing
      
      // Update payment status to refunded
      await updatePaymentStatus(paymentId, PaymentStatus.refunded);
    } catch (e) {
      throw Exception('Failed to refund payment: ${e.toString()}');
    }
  }

  static Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseService.paymentsCollection)
          .doc(paymentId)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return PaymentModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: ${e.toString()}');
    }
  }
}

