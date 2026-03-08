import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/item_model.dart';
import '../providers/app_state.dart';

class PostItemModal extends StatefulWidget {
  final Function(Item) onItemPosted;

  const PostItemModal({super.key, required this.onItemPosted});

  @override
  State<PostItemModal> createState() => _PostItemModalState();
}

class _PostItemModalState extends State<PostItemModal> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Books';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate a brief delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        final newItem = Item(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          imageUrl: _getPlaceholderImage(_selectedCategory),
          category: _selectedCategory,
          sellerId: 'current_user',
          sellerName: 'You',
          sellerMajorYear: 'Your Major / Year',
          isVerifiedStudent: true,
          description: _descriptionController.text,
        );
        
        widget.onItemPosted(newItem);
      });
    }
  }

  String _getPlaceholderImage(String category) {
    switch (category.toLowerCase()) {
      case 'books':
        return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400';
      case 'tech':
        return 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400';
      case 'furniture':
        return 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400';
      case 'transport':
        return 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=400';
      default:
        return 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.creamWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softOak.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Post New Item',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.beigeBadge,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.darkWalnut,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image placeholder
                      GestureDetector(
                        onTap: () {
                          // TODO: Add image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image picker coming soon!'),
                              backgroundColor: AppColors.softOak,
                            ),
                          );
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.beigeBadge,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.softOak.withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: AppColors.softOak,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Photos',
                                  style: GoogleFonts.inter(
                                    color: AppColors.softOak,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Title field
                      _buildFieldLabel('Item Title'),
                      _buildTextField(
                        controller: _titleController,
                        hint: 'e.g., Calculus Textbook 4th Edition',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Price field
                      _buildFieldLabel('Price (₱)'),
                      _buildTextField(
                        controller: _priceController,
                        hint: '0.00 for free items',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Category dropdown
                      _buildFieldLabel('Category'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, 
                                color: AppColors.softOak),
                            items: categories
                                .where((c) => c.name != 'All')
                                .map((category) => DropdownMenuItem(
                                      value: category.name,
                                      child: Row(
                                        children: [
                                          Icon(category.icon, 
                                              color: AppColors.softOak, size: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            category.name,
                                            style: GoogleFonts.inter(
                                              color: AppColors.deepEspresso,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategory = value!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Description field
                      _buildFieldLabel('Description'),
                      _buildTextField(
                        controller: _descriptionController,
                        hint: 'Describe your item, condition, etc.',
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please add a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkWalnut,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Post Item',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.deepEspresso,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: AppColors.deepEspresso),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: AppColors.softOak.withOpacity(0.5),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkWalnut, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
