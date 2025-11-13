import 'package:flutter/material.dart';
import '../../repositories/content_repository.dart';

class AddFAQDialog extends StatefulWidget {
  const AddFAQDialog({super.key});

  @override
  State<AddFAQDialog> createState() => _AddFAQDialogState();
}

class _AddFAQDialogState extends State<AddFAQDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String _selectedCategory = '';
  bool _isLoading = false;

  final List<String> _categories = [
    'Account',
    'Merchant',
    'Payments',
    'Orders',
    'Support',
    'Security',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ContentRepository();
      await repository.createFAQ(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FAQ added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add FAQ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 512,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.8),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD4A200), width: 1.67),
                            borderRadius: BorderRadius.circular(3.33),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.help_outline,
                              size: 12,
                              color: Color(0xFFD4A200),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Add New FAQ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0A0A),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    
                    // Category Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0A0A0A),
                            height: 1.43,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.transparent, width: 0.8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            hint: const Text(
                              'e.g., Account, Merchant, Payments, Orders',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF717182),
                                height: 1.15,
                              ),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF0A0A0A),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCategory = value);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Category is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Categorize this FAQ for better organization',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF717182),
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Question Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Question',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0A0A0A),
                            height: 1.43,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.transparent, width: 0.8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: TextFormField(
                            controller: _questionController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter the frequently asked question...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF717182),
                                height: 1.15,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0A0A0A),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Question is required';
                              }
                              return null;
                            },
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Answer Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Answer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0A0A0A),
                            height: 1.43,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.transparent, width: 0.8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: TextFormField(
                            controller: _answerController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Provide a clear and helpful answer...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF717182),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0A0A0A),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Answer is required';
                              }
                              return null;
                            },
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Info Box
                    Container(
                      padding: const EdgeInsets.fromLTRB(16.8, 16.8, 16.8, 0.8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBEDBFF), width: 0.8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF155DFC), width: 1.33),
                              borderRadius: BorderRadius.circular(2.67),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.info_outline,
                                size: 10,
                                color: Color(0xFF155DFC),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'This FAQ will be visible to all users in the help section. Make sure the answer is accurate and easy to understand.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF193CB8),
                                  height: 1.33,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.8),
                            ),
                            child: TextButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF0A0A0A),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFD4A200), Color(0xFFC48828)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Add FAQ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 16.8,
              right: 16.8,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Color(0xFF0A0A0A)),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
