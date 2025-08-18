import 'package:flutter/material.dart';

class VerificationStatusWidget extends StatelessWidget {
  final Map<String, bool> verificationStatus;
  final Function(String) onVerificationTap;

  const VerificationStatusWidget({
    super.key,
    required this.verificationStatus,
    required this.onVerificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final verificationItems = [
      {
        'key': 'email',
        'title': 'Email Verification',
        'description': 'Verify your email address',
        'icon': Icons.email,
      },
      {
        'key': 'phone',
        'title': 'Phone Verification',
        'description': 'Verify your phone number',
        'icon': Icons.phone,
      },
      {
        'key': 'identity',
        'title': 'Identity Verification',
        'description': 'Upload government-issued ID',
        'icon': Icons.badge,
      },
      {
        'key': 'income',
        'title': 'Income Verification',
        'description': 'Verify your income and employment',
        'icon': Icons.work,
      },
      {
        'key': 'background_check',
        'title': 'Background Check',
        'description': 'Complete background verification',
        'icon': Icons.security,
      },
    ];

    return Column(
      children: verificationItems.map((item) {
        final key = item['key'] as String;
        final isVerified = verificationStatus[key] ?? false;
        
        return _buildVerificationItem(
          context,
          title: item['title'] as String,
          description: item['description'] as String,
          icon: item['icon'] as IconData,
          isVerified: isVerified,
          onTap: () => onVerificationTap(key),
        );
      }).toList(),
    );
  }

  Widget _buildVerificationItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isVerified ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isVerified
                      ? Colors.green.withOpacity(0.1)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: isVerified
                      ? Colors.green[700]
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verify',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

