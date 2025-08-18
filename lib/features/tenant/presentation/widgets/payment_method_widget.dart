import 'package:flutter/material.dart';

class PaymentMethodWidget extends StatefulWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;
  final bool enableSplitPayment;
  final Function(bool) onSplitPaymentChanged;

  const PaymentMethodWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.enableSplitPayment = false,
    required this.onSplitPaymentChanged,
  });

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Payment method options
        _buildPaymentOption(
          'card',
          'Credit/Debit Card',
          Icons.credit_card,
          'Visa, Mastercard, American Express',
        ),
        _buildPaymentOption(
          'bank',
          'Bank Transfer',
          Icons.account_balance,
          'Direct bank transfer (2-3 business days)',
        ),
        _buildPaymentOption(
          'paypal',
          'PayPal',
          Icons.payment,
          'Pay with your PayPal account',
        ),
        _buildPaymentOption(
          'apple_pay',
          'Apple Pay',
          Icons.apple,
          'Quick and secure payment',
        ),
        _buildPaymentOption(
          'google_pay',
          'Google Pay',
          Icons.android,
          'Pay with Google Pay',
        ),
        
        const SizedBox(height: 24),
        
        // Split payment option
        Card(
          child: SwitchListTile(
            title: const Text('Split Payment'),
            subtitle: const Text('Share the cost with roommates'),
            value: widget.enableSplitPayment,
            onChanged: widget.onSplitPaymentChanged,
            secondary: const Icon(Icons.group),
          ),
        ),
        
        if (widget.enableSplitPayment) ...[
          const SizedBox(height: 16),
          _buildSplitPaymentInfo(),
        ],
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    String description,
  ) {
    final isSelected = widget.selectedMethod == value;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 2 : 0,
      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
      child: RadioListTile<String>(
        value: value,
        groupValue: widget.selectedMethod,
        onChanged: (value) => widget.onMethodChanged(value!),
        title: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSplitPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Split Payment Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'How it works:',
            'You can invite roommates to share the payment. Each person will receive a payment link.',
          ),
          _buildInfoItem(
            'Payment deadline:',
            'All payments must be completed within 24 hours of booking.',
          ),
          _buildInfoItem(
            'Booking confirmation:',
            'The booking is confirmed only after all payments are received.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

