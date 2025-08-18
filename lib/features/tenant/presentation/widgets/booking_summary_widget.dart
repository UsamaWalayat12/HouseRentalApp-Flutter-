import 'package:flutter/material.dart';
import '../../../../shared/models/property_model.dart';

class BookingSummaryWidget extends StatelessWidget {
  final PropertyModel property;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;
  final double rentAmount;
  final double cleaningFee;
  final double serviceFee;
  final double taxes;
  final double totalAmount;
  final double depositAmount;

  const BookingSummaryWidget({
    super.key,
    required this.property,
    this.checkInDate,
    this.checkOutDate,
    required this.guests,
    required this.rentAmount,
    required this.cleaningFee,
    required this.serviceFee,
    required this.taxes,
    required this.totalAmount,
    required this.depositAmount,
  });

  int get totalNights {
    if (checkInDate != null && checkOutDate != null) {
      return checkOutDate!.difference(checkInDate!).inDays;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Property info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: property.imageUrls.isNotEmpty
                        ? Image.network(
                            property.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.home, size: 30);
                            },
                          )
                        : const Icon(Icons.home, size: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.address,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Booking details
            if (checkInDate != null && checkOutDate != null) ...[
              _buildDetailRow(
                'Check-in',
                _formatDate(checkInDate!),
                icon: Icons.login,
              ),
              _buildDetailRow(
                'Check-out',
                _formatDate(checkOutDate!),
                icon: Icons.logout,
              ),
              _buildDetailRow(
                'Duration',
                '$totalNights nights',
                icon: Icons.calendar_today,
              ),
            ],
            _buildDetailRow(
              'Guests',
              '$guests ${guests == 1 ? 'guest' : 'guests'}',
              icon: Icons.person,
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Price breakdown
            Text(
              'Price Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (totalNights > 0) ...[
              _buildPriceRow(
                '${property.priceDisplay} x $totalNights nights',
                '\$${rentAmount.toStringAsFixed(2)}',
              ),
            ] else ...[
              _buildPriceRow(
                'Rent (per night)',
                property.priceDisplay,
              ),
            ],
            
            _buildPriceRow(
              'Cleaning fee',
              '\$${cleaningFee.toStringAsFixed(2)}',
            ),
            _buildPriceRow(
              'Service fee',
              '\$${serviceFee.toStringAsFixed(2)}',
            ),
            _buildPriceRow(
              'Taxes',
              '\$${taxes.toStringAsFixed(2)}',
            ),
            
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            
            // Total
            _buildPriceRow(
              'Total',
              '\$${totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            
            const SizedBox(height: 16),
            
            // Security deposit info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[50]!,
                    Colors.blue[25]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Deposit',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          '\$${depositAmount.toStringAsFixed(2)} (refundable)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment schedule
            _buildPaymentSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Schedule',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildPaymentScheduleItem(
                'Due Today',
                '\$${(totalAmount * 0.5).toStringAsFixed(2)}',
                'Booking confirmation',
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildPaymentScheduleItem(
                'Due at Check-in',
                '\$${(totalAmount * 0.5).toStringAsFixed(2)}',
                'Remaining balance',
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildPaymentScheduleItem(
                'Security Deposit',
                '\$${depositAmount.toStringAsFixed(2)}',
                'Refundable after check-out',
                Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentScheduleItem(
    String title,
    String amount,
    String description,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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

