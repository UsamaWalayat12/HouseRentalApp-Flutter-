import 'package:flutter/material.dart';

class SavedSearchesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> savedSearches;
  final Function(Map<String, dynamic>) onSearchTap;
  final Function(int) onDeleteSearch;

  const SavedSearchesWidget({
    super.key,
    required this.savedSearches,
    required this.onSearchTap,
    required this.onDeleteSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (savedSearches.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedSearches.length,
      itemBuilder: (context, index) {
        final search = savedSearches[index];
        return _buildSearchCard(context, search, index);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No saved searches',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Save your searches to quickly find properties later',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to search tab
            },
            icon: const Icon(Icons.search),
            label: const Text('Start Searching'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, Map<String, dynamic> search, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onSearchTap(search),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      search['name'] ?? 'Unnamed Search',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editSearch(context, search, index);
                          break;
                        case 'delete':
                          _confirmDelete(context, search['name'], index);
                          break;
                        case 'notifications':
                          _toggleNotifications(context, search, index);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'notifications',
                        child: ListTile(
                          leading: Icon(
                            search['notifications'] == true 
                                ? Icons.notifications_off 
                                : Icons.notifications,
                          ),
                          title: Text(
                            search['notifications'] == true 
                                ? 'Turn off alerts' 
                                : 'Turn on alerts',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Search criteria
              if (search['location'] != null) ...[
                _buildCriteriaChip(
                  context,
                  Icons.location_on,
                  search['location'],
                ),
                const SizedBox(height: 8),
              ],
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (search['propertyType'] != null)
                    _buildCriteriaChip(
                      context,
                      Icons.home,
                      search['propertyType'],
                    ),
                  if (search['priceRange'] != null)
                    _buildCriteriaChip(
                      context,
                      Icons.attach_money,
                      search['priceRange'],
                    ),
                  if (search['bedrooms'] != null)
                    _buildCriteriaChip(
                      context,
                      Icons.bed,
                      '${search['bedrooms']} bed',
                    ),
                  if (search['bathrooms'] != null)
                    _buildCriteriaChip(
                      context,
                      Icons.bathtub,
                      '${search['bathrooms']} bath',
                    ),
                  if (search['amenities'] != null && (search['amenities'] as List).isNotEmpty)
                    _buildCriteriaChip(
                      context,
                      Icons.star,
                      '${(search['amenities'] as List).length} amenities',
                    ),
                  if (search['minRating'] != null)
                    _buildCriteriaChip(
                      context,
                      Icons.star,
                      '${search['minRating']}+ rating',
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  if (search['notifications'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Alerts ON',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    'Saved ${_getTimeAgo(search['createdAt'])}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _editSearch(BuildContext context, Map<String, dynamic> search, int index) {
    showDialog(
      context: context,
      builder: (context) => _EditSearchDialog(
        search: search,
        onSave: (updatedSearch) {
          // TODO: Update the search in the list and save to storage
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String? searchName, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Search'),
        content: Text('Are you sure you want to delete "${searchName ?? 'this search'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteSearch(index);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications(BuildContext context, Map<String, dynamic> search, int index) {
    final bool currentState = search['notifications'] ?? false;
    // TODO: Update notifications state and save to storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          currentState 
              ? 'Alerts turned off for "${search['name']}"'
              : 'Alerts turned on for "${search['name']}"',
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'recently';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}

class _EditSearchDialog extends StatefulWidget {
  final Map<String, dynamic> search;
  final Function(Map<String, dynamic>) onSave;

  const _EditSearchDialog({
    required this.search,
    required this.onSave,
  });

  @override
  State<_EditSearchDialog> createState() => _EditSearchDialogState();
}

class _EditSearchDialogState extends State<_EditSearchDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.search['name']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Search'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Search Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get alerts when new properties match this search'),
            value: widget.search['notifications'] ?? false,
            onChanged: (value) {
              setState(() {
                widget.search['notifications'] = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedSearch = Map<String, dynamic>.from(widget.search);
            updatedSearch['name'] = _nameController.text;
            widget.onSave(updatedSearch);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

