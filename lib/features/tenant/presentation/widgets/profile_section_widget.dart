import 'package:flutter/material.dart';

class ProfileSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  final bool isCollapsible;
  final bool initiallyExpanded;

  const ProfileSectionWidget({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.isCollapsible = false,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsible) {
      return Card(
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: icon != null ? Icon(icon) : null,
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

