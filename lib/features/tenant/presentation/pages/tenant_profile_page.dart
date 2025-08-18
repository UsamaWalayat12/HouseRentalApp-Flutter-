import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../shared/models/user_model.dart';
import '../widgets/profile_section_widget.dart';
import '../widgets/verification_status_widget.dart';
import '../widgets/preferences_widget.dart';
import 'package:rent_a_home/shared/mixins/animations_mixin.dart';
import 'package:rent_a_home/shared/components/page_layout.dart';

class TenantProfilePage extends StatefulWidget {
  const TenantProfilePage({super.key});

  @override
  State<TenantProfilePage> createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage>
    with TickerProviderStateMixin, LandlordAnimationsMixin {
  late TabController _tabController;
  
  // User data
  UserModel? _currentUser;
  File? _profileImage;
  
  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  
  // Preferences
  Map<String, dynamic> _preferences = {
    'budget_min': 500.0,
    'budget_max': 2000.0,
    'preferred_locations': <String>[],
    'property_types': <String>[],
    'amenities': <String>[],
    'move_in_date': null,
    'lease_duration': 12,
    'pets': false,
    'smoking': false,
    'notifications': {
      'new_properties': true,
      'price_drops': true,
      'saved_searches': true,
      'booking_updates': true,
      'messages': true,
    },
  };
  
  // Verification status
  Map<String, bool> _verificationStatus = {
    'email': false,
    'phone': false,
    'identity': false,
    'income': false,
    'background_check': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // TODO: Load user data from backend or local storage
    setState(() {
      _currentUser = UserModel(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        profileImageUrl: null,
        bio: 'Looking for a comfortable place to call home.',
        occupation: 'Software Engineer',
        emergencyContact: 'Jane Doe',
        emergencyPhone: '+1234567891',
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      _firstNameController.text = _currentUser!.firstName;
      _lastNameController.text = _currentUser!.lastName;
      _emailController.text = _currentUser!.email;
      _phoneController.text = _currentUser!.phone ?? '';
      _bioController.text = _currentUser!.bio ?? '';
      _occupationController.text = _currentUser!.occupation ?? '';
      _emergencyContactController.text = _currentUser!.emergencyContact ?? '';
      _emergencyPhoneController.text = _currentUser!.emergencyPhone ?? '';
      
      // Mock verification status
      _verificationStatus = {
        'email': true,
        'phone': true,
        'identity': false,
        'income': false,
        'background_check': false,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return LandlordPageLayout(
      appBar: _buildAppBar(),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Column(
            children: [
              _buildProfileHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildVerificationTab(),
                    _buildPreferencesTab(),
                    _buildDocumentsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'My Profile',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00F5FF).withOpacity(0.2),
                const Color(0xFF7C4DFF).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00F5FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00F5FF).withOpacity(0.1),
                const Color(0xFF7C4DFF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00F5FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00F5FF),
                  const Color(0xFF7C4DFF),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F5FF).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            tabs: const [
              Tab(text: 'Profile', icon: Icon(Icons.person, size: 16)),
              Tab(text: 'Verify', icon: Icon(Icons.verified_user, size: 16)),
              Tab(text: 'Preferences', icon: Icon(Icons.tune, size: 16)),
              Tab(text: 'Documents', icon: Icon(Icons.folder, size: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A237E),
                      const Color(0xFF3F51B5),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_currentUser?.profileImageUrl != null
                          ? NetworkImage(_currentUser!.profileImageUrl!)
                          : null) as ImageProvider?,
                  child: _profileImage == null && _currentUser?.profileImageUrl == null
                      ? Text(
                          _currentUser != null
                              ? '${_currentUser!.firstName[0]}${_currentUser!.lastName[0]}'
                              : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00C853),
                        const Color(0xFF4CAF50),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _pickProfileImage,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser != null
                ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                : 'User Name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser?.email ?? 'user@example.com',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getVerificationColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getVerificationColor().withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getVerificationIcon(),
                  color: _getVerificationColor(),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _getVerificationText(),
                  style: TextStyle(
                    color: _getVerificationColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Basic information
          _buildSection(
            title: 'Basic Information',
            icon: Icons.person,
            color: const Color(0xFF1A237E),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                enabled: false,
                suffixIcon: const Icon(Icons.verified, color: Color(0xFF00C853)),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                suffixIcon: const Icon(Icons.verified, color: Color(0xFF00C853)),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.info_outline,
                maxLines: 3,
                hintText: 'Tell us about yourself...',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _occupationController,
                label: 'Occupation',
                icon: Icons.work_outline,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Emergency contact
          _buildSection(
            title: 'Emergency Contact',
            icon: Icons.emergency,
            color: const Color(0xFFFF6F00),
            children: [
              _buildTextField(
                controller: _emergencyContactController,
                label: 'Contact Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emergencyPhoneController,
                label: 'Contact Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Save button
          _buildSaveButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? const Color(0xFF37474F) : Colors.grey[600],
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: Colors.grey[600]),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A237E), const Color(0xFF3F51B5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _saveProfile,
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Account Verification',
            icon: Icons.verified_user,
            color: const Color(0xFF00C853),
            children: [
              Text(
                'Verify your account to increase your chances of getting approved by landlords.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ..._verificationStatus.entries.map((entry) {
                return _buildVerificationItem(
                  title: _getVerificationTitle(entry.key),
                  subtitle: _getVerificationSubtitle(entry.key),
                  isVerified: entry.value,
                  onTap: () => _startVerification(entry.key),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 24),
          
          // Verification benefits
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C853).withOpacity(0.1),
                  const Color(0xFF00C853).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00C853).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Verification Benefits',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBenefitItem('Higher approval rates from landlords'),
                _buildBenefitItem('Priority in property applications'),
                _buildBenefitItem('Access to premium properties'),
                _buildBenefitItem('Faster booking process'),
                _buildBenefitItem('Enhanced trust and credibility'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem({
    required String title,
    required String subtitle,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFF00C853).withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? const Color(0xFF00C853).withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isVerified ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isVerified ? const Color(0xFF00C853) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isVerified ? Icons.check : Icons.close,
                    color: isVerified ? Colors.white : Colors.grey[600],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isVerified ? const Color(0xFF00C853) : const Color(0xFF37474F),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isVerified)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          PreferencesWidget(
            preferences: _preferences,
            onPreferencesChanged: (newPreferences) {
              setState(() {
                _preferences = newPreferences;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Documents',
            icon: Icons.folder,
            color: const Color(0xFF9C27B0),
            children: [
              Text(
                'Upload documents to verify your identity and income.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildDocumentSection('Identity Documents', [
            {'name': 'Driver\'s License', 'status': 'uploaded', 'required': true},
            {'name': 'Passport', 'status': 'not_uploaded', 'required': false},
            {'name': 'National ID', 'status': 'not_uploaded', 'required': false},
          ]),
          
          const SizedBox(height: 24),
          
          _buildDocumentSection('Income Documents', [
            {'name': 'Pay Stubs (Last 3 months)', 'status': 'pending', 'required': true},
            {'name': 'Employment Letter', 'status': 'not_uploaded', 'required': true},
            {'name': 'Bank Statements', 'status': 'not_uploaded', 'required': false},
            {'name': 'Tax Returns', 'status': 'not_uploaded', 'required': false},
          ]),
          
          const SizedBox(height: 24),
          
          _buildDocumentSection('Additional Documents', [
            {'name': 'References', 'status': 'not_uploaded', 'required': false},
            {'name': 'Background Check', 'status': 'not_uploaded', 'required': false},
            {'name': 'Credit Report', 'status': 'not_uploaded', 'required': false},
          ]),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(String title, List<Map<String, dynamic>> documents) {
    return _buildSection(
      title: title,
      icon: Icons.description,
      color: const Color(0xFF9C27B0),
      children: documents.map((doc) => _buildDocumentItem(doc)).toList(),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document) {
    final status = document['status'] as String;
    final isRequired = document['required'] as bool;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'uploaded':
        statusColor = const Color(0xFF00C853);
        statusIcon = Icons.check_circle;
        statusText = 'Uploaded';
        break;
      case 'pending':
        statusColor = const Color(0xFFFF6F00);
        statusIcon = Icons.schedule;
        statusText = 'Pending';
        break;
      default:
        statusColor = Colors.grey[400]!;
        statusIcon = Icons.upload_file;
        statusText = 'Upload';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: status == 'not_uploaded' ? () => _uploadDocument(document) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            document['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF37474F),
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 4),
                            const Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == 'not_uploaded')
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getVerificationIcon() {
    final verifiedCount = _verificationStatus.values.where((v) => v).length;
    if (verifiedCount >= 3) return Icons.verified;
    if (verifiedCount >= 1) return Icons.verified_outlined;
    return Icons.warning;
  }

  Color _getVerificationColor() {
    final verifiedCount = _verificationStatus.values.where((v) => v).length;
    if (verifiedCount >= 3) return const Color(0xFF00C853);
    if (verifiedCount >= 1) return const Color(0xFFFF6F00);
    return Colors.red[600]!;
  }

  String _getVerificationText() {
    final verifiedCount = _verificationStatus.values.where((v) => v).length;
    if (verifiedCount >= 3) return 'Verified Account';
    if (verifiedCount >= 1) return 'Partially Verified';
    return 'Unverified Account';
  }

  String _getVerificationTitle(String key) {
    switch (key) {
      case 'email': return 'Email Verification';
      case 'phone': return 'Phone Verification';
      case 'identity': return 'Identity Verification';
      case 'income': return 'Income Verification';
      case 'background_check': return 'Background Check';
      default: return 'Verification';
    }
  }

  String _getVerificationSubtitle(String key) {
    switch (key) {
      case 'email': return 'Verify your email address';
      case 'phone': return 'Verify your phone number';
      case 'identity': return 'Upload government-issued ID';
      case 'income': return 'Verify your income documents';
      case 'background_check': return 'Complete background verification';
      default: return 'Complete verification';
    }
  }

  void _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _saveProfile() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Profile updated successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _startVerification(String type) {
    // TODO: Implement verification flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Starting ${_getVerificationTitle(type).toLowerCase()}...')),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _uploadDocument(Map<String, dynamic> document) {
    // TODO: Implement document upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.upload_file, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Uploading ${document['name']}...')),
          ],
        ),
        backgroundColor: const Color(0xFF9C27B0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    // TODO: Implement settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

