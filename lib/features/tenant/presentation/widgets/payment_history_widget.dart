import 'package:flutter/material.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/models/booking_model.dart';

class PaymentHistoryWidget extends StatefulWidget {
  final List<PaymentModel> payments;
  final List<BookingModel> bookings;
  final Function(PaymentModel) onPaymentTap;

  const PaymentHistoryWidget({
    super.key,
    required this.payments,
    required this.bookings,
    required this.onPaymentTap,
  });

  @override
  State<PaymentHistoryWidget> createState() => _PaymentHistoryWidgetState();
}

class _PaymentHistoryWidgetState extends State<PaymentHistoryWidget> {
  String _selectedFilter = 'all';
  
  final Map<String, String> _filterOptions = {
    'all': 'All Payments',
    'completed': 'Completed',
    'pending': 'Pending',
    'failed': 'Failed',
  };

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _getFilteredPayments();
    
    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.entries.map((entry) {
                final isSelected = _selectedFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = entry.key;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // Payment summary
        if (filteredPayments.isNotEmpty) ...[
          _buildPaymentSummary(filteredPayments),
          const SizedBox(height: 16),
        ],
        
        // Payment list
        Expanded(
          child: filteredPayments.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredPayments.length,
                  itemBuilder: (context, index) {
                    final payment = filteredPayments[index];
                    final booking = _getBookingForPayment(payment);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPaymentCard(payment, booking),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<PaymentModel> _getFilteredPayments() {
    switch (_selectedFilter) {
      case 'completed':
        return widget.payments.where((p) => p.status == PaymentStatus.completed).toList();
      case 'pending':
        return widget.payments.where((p) => p.status == PaymentStatus.pending).toList();
      case 'failed':
        return widget.payments.where((p) => p.status == PaymentStatus.failed).toList();
      default:
        return widget.payments;
    }
  }

  BookingModel? _getBookingForPayment(PaymentModel payment) {
    try {
      return widget.bookings.firstWhere((b) => b.id == payment.bookingId);
    } catch (e) {
      return null;
    }
  }

  Widget _buildPaymentSummary(List<PaymentModel> payments) {
    final totalPaid = payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amount);
    
    final totalPending = payments
        .where((p) => p.status == PaymentStatus.pending)
        .fold(0.0, (sum, p) => sum + p.amount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total Paid',
              '\$${totalPaid.toStringAsFixed(2)}',
              Icons.check_circle,
              Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Pending',
              '\$${totalPending.toStringAsFixed(2)}',
              Icons.pending,
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentModel payment, BookingModel? booking) {
    return Card(
      child: InkWell(
        onTap: () => widget.onPaymentTap(payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPaymentTypeColor(payment.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getPaymentTypeIcon(payment.type),
                      color: _getPaymentTypeColor(payment.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking?.propertyTitle ?? 'Unknown Property',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getPaymentTypeText(payment.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${payment.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getPaymentStatusColor(payment.status),
                        ),
                      ),
                      _buildStatusChip(payment.status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Payment details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.payment,
                      'Method',
                      payment.method,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.calendar_today,
                      'Date',
                      _formatDate(payment.createdAt),
                    ),
                  ),
                  if (payment.transactionId != null)
                    Expanded(
                      child: _buildDetailItem(
                        Icons.receipt,
                        'Transaction',
                        payment.transactionId!.substring(0, 8) + '...',
                      ),
                    ),
                ],
              ),
              
              // Action button for pending payments
              if (payment.status == PaymentStatus.pending) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _makePayment(payment),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Pay Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(PaymentStatus status) {
    Color color = _getPaymentStatusColor(status);
    String text = _getPaymentStatusText(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Payments Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment history will appear here.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPaymentTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.rent:
        return Colors.blue;
      case PaymentType.deposit:
        return Colors.orange;
      case PaymentType.fee:
        return Colors.purple;
      case PaymentType.refund:
        return Colors.green;
    }
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.rent:
        return Icons.home;
      case PaymentType.deposit:
        return Icons.security;
      case PaymentType.fee:
        return Icons.receipt_long;
      case PaymentType.refund:
        return Icons.money_off;
    }
  }

  String _getPaymentTypeText(PaymentType type) {
    switch (type) {
      case PaymentType.rent:
        return 'Rent Payment';
      case PaymentType.deposit:
        return 'Security Deposit';
      case PaymentType.fee:
        return 'Service Fee';
      case PaymentType.refund:
        return 'Refund';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  void _makePayment(PaymentModel payment) {
    // TODO: Navigate to payment form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Make payment of \$${payment.amount.toStringAsFixed(2)}')),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

