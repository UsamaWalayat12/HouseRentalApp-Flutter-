import 'package:flutter/material.dart';

class MaintenanceRequestWidget extends StatefulWidget {
  final List<Map<String, dynamic>> requests;
  final Function(Map<String, dynamic>) onRequestTap;
  final VoidCallback onCreateRequest;

  const MaintenanceRequestWidget({
    super.key,
    required this.requests,
    required this.onRequestTap,
    required this.onCreateRequest,
  });

  @override
  State<MaintenanceRequestWidget> createState() => _MaintenanceRequestWidgetState();
}

class _MaintenanceRequestWidgetState extends State<MaintenanceRequestWidget> {
  String _selectedFilter = 'all';
  
  final Map<String, String> _filterOptions = {
    'all': 'All Requests',
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
  };

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _getFilteredRequests();
    
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
        
        // Request list
        Expanded(
          child: filteredRequests.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRequestCard(request),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredRequests() {
    switch (_selectedFilter) {
      case 'pending':
        return widget.requests.where((r) => r['status'] == 'Pending').toList();
      case 'in_progress':
        return widget.requests.where((r) => r['status'] == 'In Progress').toList();
      case 'completed':
        return widget.requests.where((r) => r['status'] == 'Completed').toList();
      default:
        return widget.requests;
    }
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      child: InkWell(
        onTap: () => widget.onRequestTap(request),
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
                      color: _getCategoryColor(request['category']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getCategoryIcon(request['category']),
                      color: _getCategoryColor(request['category']),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          request['propertyTitle'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPriorityChip(request['priority']),
                      const SizedBox(height: 4),
                      _buildStatusChip(request['status']),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                request['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.category,
                      'Category',
                      request['category'],
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.calendar_today,
                      'Created',
                      _formatDate(request['createdAt']),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time,
                      'Status',
                      request['status'],
                    ),
                  ),
                ],
              ),
              
              // Action buttons
              if (request['status'] != 'Completed') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateRequest(request),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Update'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _contactSupport(request),
                        icon: const Icon(Icons.support_agent, size: 16),
                        label: const Text('Contact'),
                      ),
                    ),
                  ],
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

  Widget _buildPriorityChip(String priority) {
    Color color = _getPriorityColor(priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
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
            Icons.build_circle_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Maintenance Requests',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your maintenance requests will appear here.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.onCreateRequest,
            icon: const Icon(Icons.add),
            label: const Text('Create Request'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Colors.blue;
      case 'electrical':
        return Colors.yellow[700]!;
      case 'hvac':
        return Colors.green;
      case 'appliance':
        return Colors.purple;
      case 'general':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'hvac':
        return Icons.air;
      case 'appliance':
        return Icons.kitchen;
      case 'general':
        return Icons.build;
      default:
        return Icons.handyman;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateRequest(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => _UpdateRequestDialog(
        request: request,
        onUpdate: (updatedRequest) {
          // TODO: Update request in the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request updated successfully')),
          );
        },
      ),
    );
  }

  void _contactSupport(Map<String, dynamic> request) {
    // TODO: Navigate to support chat or contact form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact support for request: ${request['title']}')),
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

class _UpdateRequestDialog extends StatefulWidget {
  final Map<String, dynamic> request;
  final Function(Map<String, dynamic>) onUpdate;

  const _UpdateRequestDialog({
    required this.request,
    required this.onUpdate,
  });

  @override
  State<_UpdateRequestDialog> createState() => _UpdateRequestDialogState();
}

class _UpdateRequestDialogState extends State<_UpdateRequestDialog> {
  late TextEditingController _descriptionController;
  late String _selectedPriority;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.request['description']);
    _selectedPriority = widget.request['priority'];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
            items: _priorities.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
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
            final updatedRequest = Map<String, dynamic>.from(widget.request);
            updatedRequest['description'] = _descriptionController.text;
            updatedRequest['priority'] = _selectedPriority;
            widget.onUpdate(updatedRequest);
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

