import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<bool> _isExpanded = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Booking',
      'icon': Icons.book_online,
      'color': const Color(0xFF00C853),
      'questions': [
        {
          'question': 'How do I book a property?',
          'answer': 'To book a property, simply find a property you like, select your desired dates, and click the "Book Now" button. You will then be prompted to enter your payment information and confirm your booking.',
        },
        {
          'question': 'Can I modify my booking after confirmation?',
          'answer': 'Yes, you can modify your booking up to 24 hours before your check-in date. Go to "My Bookings" and select the booking you want to modify. Please note that changes may be subject to availability and additional fees.',
        },
        {
          'question': 'What payment methods do you accept?',
          'answer': 'We accept all major credit cards (Visa, MasterCard, American Express), PayPal, and bank transfers. All payments are processed securely through our encrypted payment system.',
        },
      ],
    },
    {
      'category': 'Cancellation',
      'icon': Icons.cancel,
      'color': const Color(0xFFFF6F00),
      'questions': [
        {
          'question': 'How do I cancel a booking?',
          'answer': 'You can cancel a booking from the "My Bookings" page. Select the booking you want to cancel and click "Cancel Booking". Please note that cancellation policies may vary depending on the property and timing.',
        },
        {
          'question': 'What is your cancellation policy?',
          'answer': 'Our cancellation policy varies by property. Generally, you can cancel free of charge up to 48 hours before check-in. Cancellations made within 48 hours may incur a fee. Check the specific property\'s cancellation policy before booking.',
        },
        {
          'question': 'Will I get a full refund if I cancel?',
          'answer': 'Refund amounts depend on when you cancel and the property\'s specific policy. Cancellations made within the free cancellation period typically receive a full refund, processed within 5-7 business days.',
        },
      ],
    },
    {
      'category': 'Communication',
      'icon': Icons.chat,
      'color': const Color(0xFF1A237E),
      'questions': [
        {
          'question': 'How do I contact a landlord?',
          'answer': 'Once your booking is confirmed, you will be able to contact the landlord through the app\'s messaging system. Go to "My Bookings" and select your booking to access the chat feature.',
        },
        {
          'question': 'Can I call the landlord directly?',
          'answer': 'For privacy and security reasons, we recommend using our in-app messaging system. However, landlords may choose to share their contact information with confirmed guests.',
        },
        {
          'question': 'What if the landlord doesn\'t respond?',
          'answer': 'If a landlord doesn\'t respond within 24 hours, please contact our support team. We will help facilitate communication and ensure your concerns are addressed promptly.',
        },
      ],
    },
    {
      'category': 'Account & Security',
      'icon': Icons.security,
      'color': const Color(0xFF9C27B0),
      'questions': [
        {
          'question': 'How do I reset my password?',
          'answer': 'Go to the login screen and tap "Forgot Password". Enter your email address and we\'ll send you a link to reset your password. You can also change your password from the app settings.',
        },
        {
          'question': 'Is my personal information secure?',
          'answer': 'Yes, we take your privacy and security seriously. All personal information is encrypted and stored securely. We never share your information with third parties without your consent.',
        },
        {
          'question': 'How do I enable two-factor authentication?',
          'answer': 'Go to Settings > Privacy & Security > Two-Factor Authentication. Follow the instructions to set up 2FA using your phone number or an authenticator app for enhanced account security.',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Initialize expansion states
    for (var category in _faqs) {
      for (var _ in category['questions']) {
        _isExpanded.add(false);
      }
    }

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    
    return _faqs.map((category) {
      final filteredQuestions = (category['questions'] as List).where((q) {
        return q['question'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               q['answer'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      
      return {
        ...category,
        'questions': filteredQuestions,
      };
    }).where((category) => (category['questions'] as List).isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildSearchSection(),
              Expanded(
                child: _buildFaqList(),
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
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF37474F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A237E),
                  const Color(0xFF3F51B5),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'FAQ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A237E),
            const Color(0xFF3F51B5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Find answers to common questions',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search questions...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    final filteredData = filteredFaqs;
    
    if (filteredData.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...filteredData.map((category) => _buildCategorySection(category)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category['category'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: category['color'] as Color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: category['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(category['questions'] as List).length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Questions
          ...((category['questions'] as List).asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final globalIndex = _getGlobalIndex(category, index);
            
            return _buildQuestionTile(
              question: question['question'],
              answer: question['answer'],
              isExpanded: _isExpanded[globalIndex],
              onTap: () {
                setState(() {
                  _isExpanded[globalIndex] = !_isExpanded[globalIndex];
                });
              },
              color: category['color'] as Color,
            );
          })),
        ],
      ),
    );
  }

  int _getGlobalIndex(Map<String, dynamic> targetCategory, int questionIndex) {
    int globalIndex = 0;
    for (var category in _faqs) {
      if (category == targetCategory) {
        return globalIndex + questionIndex;
      }
      globalIndex += (category['questions'] as List).length;
    }
    return globalIndex;
  }

  Widget _buildQuestionTile({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF37474F),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: color,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 80,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No questions found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search terms or browse all categories',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A237E),
                    const Color(0xFF3F51B5),
                  ],
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
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear_all, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Clear Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

