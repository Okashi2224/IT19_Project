import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../main.dart';
import '../models/item_model.dart';
import '../models/product_model.dart';
import 'ai_features.dart';

class PostItemModal extends StatefulWidget {
  final Function(Item) onItemPosted;

  const PostItemModal({super.key, required this.onItemPosted});

  @override
  State<PostItemModal> createState() => _PostItemModalState();
}

class _PostItemModalState extends State<PostItemModal>
    with SingleTickerProviderStateMixin {
  // Step tracking
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Books';
  String _selectedCondition = 'Good';
  final List<String> _selectedTags = [];
  bool _isFree = false;
  bool _isNegotiable = true;
  bool _isLoading = false;
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  
  // AI suggestions
  double? _aiSuggestedPrice;
  List<String> _aiSuggestedTags = [];
  bool _loadingAiPrice = false;
  bool _loadingAiTags = false;

  // Animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = [
    'Books',
    'Electronics',
    'Furniture',
    'Clothing',
    'Sports',
    'Kitchen',
    'Decor',
    'Other'
  ];

  final List<String> _conditions = [
    'Like New',
    'Good',
    'Fair',
    'Well Used',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate step 1
      if (_titleController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a title'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      // Trigger AI suggestions when moving to pricing
      _getAiPriceSuggestion();
      _getAiTagSuggestions();
    }
    
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      _closeModal();
    }
  }

  void _closeModal() async {
    await _animationController.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _getAiPriceSuggestion() async {
    setState(() => _loadingAiPrice = true);
    
    // Simulate AI price suggestion based on category and condition
    await Future.delayed(const Duration(milliseconds: 800));
    
    final price = AIPriceSuggester.suggestPrice(
      category: _selectedCategory,
      condition: _selectedCondition,
      title: _titleController.text,
    );
    
    if (mounted) {
      setState(() {
        _aiSuggestedPrice = price;
        _loadingAiPrice = false;
      });
    }
  }

  Future<void> _getAiTagSuggestions() async {
    setState(() => _loadingAiTags = true);
    
    await Future.delayed(const Duration(milliseconds: 600));
    
    final tags = SmartImageTagger.suggestTags(
      title: _titleController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
    );
    
    if (mounted) {
      setState(() {
        _aiSuggestedTags = tags;
        _loadingAiTags = false;
      });
    }
  }

  Future<void> _submitItem() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Always use placeholder image (in production, upload selected images and use returned URL)
    String imageUrl = _getCategoryPlaceholderImage(_selectedCategory);
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final price = _isFree ? 0.0 : (double.tryParse(_priceController.text) ?? 0);
    
    // Create legacy Item for backward compatibility
    final newItem = Item(
      id: 'item_$timestamp',
      title: _titleController.text.trim(),
      price: price,
      category: _selectedCategory,
      imageUrl: imageUrl,
      sellerId: 'current_user',
      sellerName: 'You',
      isVerifiedStudent: true,
      description: _descriptionController.text.trim(),
    );
    
    // Also create Product for the new ProductCard display
    final newProduct = Product(
      id: 'product_$timestamp',
      title: _titleController.text.trim(),
      price: price,
      category: _selectedCategory,
      imagePath: imageUrl,
      condition: _selectedCondition,
      sellerId: 'current_user',
      sellerName: 'You',
      description: _descriptionController.text.trim(),
      tags: _selectedTags.isNotEmpty ? _selectedTags : null,
    );
    
    // Add to AppState for immediate display
    AppStateManager.instance.addProduct(newProduct);
    
    widget.onItemPosted(newItem);
    
    if (mounted) {
      setState(() => _isLoading = false);
      _closeModal();
    }
  }

  String _getCategoryPlaceholderImage(String category) {
    // Placeholder images by category for demo purposes
    switch (category) {
      case 'Books':
        return 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400';
      case 'Electronics':
        return 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400';
      case 'Furniture':
        return 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400';
      case 'Clothing':
        return 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=400';
      case 'Sports':
        return 'https://images.unsplash.com/photo-1461896836934- voices?w=400';
      case 'Kitchen':
        return 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400';
      case 'Decor':
        return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400';
      default:
        return 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400';
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final modalWidth = isWide ? 520.0 : size.width;

    return Material(
      color: Colors.black54,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _closeModal,
              child: Container(color: Colors.transparent),
            ),
            // Modal
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: modalWidth,
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.espresso.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildProgressIndicator(),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _buildStepContent(),
                        ),
                      ),
                      _buildFooter(),
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

  Widget _buildHeader() {
    final stepTitles = ['Item Details', 'Pricing', 'Review & Post'];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepTitles[_currentStep],
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.espresso,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.espresso.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closeModal,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.beigeBadge,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20, color: AppColors.espresso),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 3,
                color: stepIndex < _currentStep
                    ? AppColors.darkWalnut
                    : AppColors.cardBorder,
              ),
            );
          } else {
            // Step circle
            final stepIndex = index ~/ 2;
            final isActive = stepIndex <= _currentStep;
            final isCurrent = stepIndex == _currentStep;
            
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.darkWalnut : Colors.white,
                border: Border.all(
                  color: isActive ? AppColors.darkWalnut : AppColors.cardBorder,
                  width: 2,
                ),
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.darkWalnut.withOpacity(0.3),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: stepIndex < _currentStep
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.softOak,
                        ),
                      ),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Details();
      case 1:
        return _buildStep2Pricing();
      case 2:
        return _buildStep3Review();
      default:
        return _buildStep1Details();
    }
  }

  Future<void> _pickSingleImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null && _selectedImages.length < 5) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildPhotoUploadArea() {
    if (_selectedImages.isEmpty) {
      // Empty state - show add photo prompt
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.warmBone,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cardBorder,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickSingleImage,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkWalnut.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: AppColors.darkWalnut,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to add photos',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.espresso,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add up to 5 photos',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.espresso.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Show selected images with preview
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              // Add more button at the end
              if (index == _selectedImages.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _pickSingleImage,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.warmBone,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              color: AppColors.darkWalnut,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.darkWalnut,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Show image preview
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: index == 0
                            ? Border.all(color: AppColors.darkWalnut, width: 2)
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<Uint8List>(
                          future: _selectedImages[index].readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                width: 100,
                                height: 120,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const SizedBox(
                                width: 100,
                                height: 120,
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              );
                            }
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 120,
                            );
                          },
                        ),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Cover badge for first image
                    if (index == 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.darkWalnut,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Cover',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedImages.length}/5 photos added',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.espresso.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Upload Area
        _buildSectionLabel('Photos', Icons.camera_alt_outlined),
        const SizedBox(height: 8),
        _buildPhotoUploadArea(),
        const SizedBox(height: 24),

        // Title
        _buildSectionLabel('Title', Icons.title),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: _inputDecoration('What are you selling?'),
          maxLength: 80,
        ),
        const SizedBox(height: 20),

        // Category
        _buildSectionLabel('Category', Icons.category_outlined),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: AppColors.darkWalnut,
              checkmarkColor: Colors.white,
              backgroundColor: AppColors.warmBone,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : AppColors.espresso,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: isSelected ? AppColors.darkWalnut : AppColors.cardBorder,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Condition
        _buildSectionLabel('Condition', Icons.grade_outlined),
        const SizedBox(height: 8),
        Row(
          children: _conditions.map((condition) {
            final isSelected = _selectedCondition == condition;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: condition != _conditions.last ? 8 : 0),
                child: Material(
                  color: isSelected ? AppColors.darkWalnut : AppColors.warmBone,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCondition = condition),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        condition,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.espresso,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Description
        _buildSectionLabel('Description', Icons.description_outlined),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: _inputDecoration('Describe your item...'),
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildStep2Pricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Price Suggestion
        if (_loadingAiPrice)
          _buildAiLoadingCard('Analyzing similar items...')
        else if (_aiSuggestedPrice != null)
          _buildAiSuggestionCard(
            icon: Icons.auto_awesome,
            title: 'AI Price Suggestion',
            subtitle: 'Based on similar items in $_selectedCategory',
            action: '₱${_aiSuggestedPrice!.toStringAsFixed(0)}',
            onTap: () {
              setState(() {
                _priceController.text = _aiSuggestedPrice!.toStringAsFixed(0);
                _isFree = false;
              });
            },
          ),
        const SizedBox(height: 20),

        // Free Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isFree ? AppColors.success.withOpacity(0.1) : AppColors.warmBone,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFree ? AppColors.success : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.volunteer_activism,
                color: _isFree ? AppColors.success : AppColors.softOak,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Give it away for free',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.espresso,
                      ),
                    ),
                    Text(
                      'Help a fellow student out!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.espresso.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isFree,
                onChanged: (value) {
                  setState(() {
                    _isFree = value;
                    if (value) _priceController.clear();
                  });
                },
                activeThumbColor: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Price Input
        if (!_isFree) ...[
          _buildSectionLabel('Your Price', Icons.payments_outlined),
          const SizedBox(height: 8),
          TextFormField(
            controller: _priceController,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '₱ ',
              prefixStyle: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
              hintText: '0',
              hintStyle: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso.withOpacity(0.3),
              ),
              filled: true,
              fillColor: AppColors.warmBone,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Quick price buttons - Philippine Peso amounts
          Row(
            children: [100, 250, 500, 1000].map((price) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: price != 1000 ? 8 : 0),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _priceController.text = price.toString());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkWalnut,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('₱$price'),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Negotiable toggle
          Row(
            children: [
              const Icon(Icons.handshake_outlined, color: AppColors.softOak, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Open to offers',
                  style: GoogleFonts.inter(color: AppColors.espresso),
                ),
              ),
              Switch(
                value: _isNegotiable,
                onChanged: (value) => setState(() => _isNegotiable = value),
                activeThumbColor: AppColors.darkWalnut,
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // AI Tags
        _buildSectionLabel('Smart Tags', Icons.label_outline),
        const SizedBox(height: 8),
        if (_loadingAiTags)
          _buildAiLoadingCard('Generating tags...')
        else if (_aiSuggestedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _aiSuggestedTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.aiPurple,
                    ),
                    const SizedBox(width: 4),
                    Text(tag),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                selectedColor: AppColors.aiPurple,
                backgroundColor: AppColors.aiGlow,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.white : AppColors.espresso,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          )
        else
          Text(
            'Tags will be suggested based on your item',
            style: GoogleFonts.inter(
              color: AppColors.espresso.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  Widget _buildStep3Review() {
    final price = _isFree ? 'Free' : '₱${_priceController.text.isEmpty ? '0' : _priceController.text}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.espresso.withOpacity(0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.beigeBadge,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _selectedImages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image, size: 48, color: AppColors.softOak),
                            const SizedBox(height: 8),
                            Text(
                              'No image added',
                              style: GoogleFonts.inter(color: AppColors.softOak),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: FutureBuilder<Uint8List>(
                          future: _selectedImages.first.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.darkWalnut,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Condition
                    Row(
                      children: [
                        _buildBadge(_selectedCategory, AppColors.darkWalnut),
                        const SizedBox(width: 8),
                        _buildBadge(_selectedCondition, AppColors.softOak),
                        if (_isNegotiable && !_isFree) ...[
                          const SizedBox(width: 8),
                          _buildBadge('Negotiable', AppColors.info),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      _titleController.text.isEmpty ? 'Item Title' : _titleController.text,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.espresso,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Price
                    Text(
                      price,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isFree ? AppColors.success : AppColors.darkWalnut,
                      ),
                    ),
                    
                    if (_descriptionController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _descriptionController.text,
                        style: GoogleFonts.inter(
                          color: AppColors.espresso.withOpacity(0.7),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    if (_selectedTags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _selectedTags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.aiGlow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.aiPurple,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Checklist
        _buildCheckItem('Photo added', _selectedImages.isNotEmpty),
        _buildCheckItem('Title added', _titleController.text.isNotEmpty),
        _buildCheckItem('Category selected', true),
        _buildCheckItem('Price set', _isFree || _priceController.text.isNotEmpty),
        _buildCheckItem('Description added', _descriptionController.text.isNotEmpty),
        
        const SizedBox(height: 16),
        
        // Guidelines reminder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your listing will be visible to all verified students on campus.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.espresso.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.darkWalnut),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.espresso,
          ),
        ),
      ],
    );
  }

  Widget _buildAiLoadingCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.aiGlow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.aiPurple,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: GoogleFonts.inter(
              color: AppColors.aiPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.aiGlow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.aiPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.aiPurple, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.espresso,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.espresso.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.aiPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  action,
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isComplete ? AppColors.success : AppColors.warmBone,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete ? AppColors.success : AppColors.cardBorder,
              ),
            ),
            child: isComplete
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isComplete ? AppColors.espresso : AppColors.espresso.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: AppColors.espresso.withOpacity(0.4),
      ),
      filled: true,
      fillColor: AppColors.warmBone,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkWalnut, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildFooter() {
    final isLastStep = _currentStep == _totalSteps - 1;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            TextButton.icon(
              onPressed: _previousStep,
              icon: Icon(
                _currentStep == 0 ? Icons.close : Icons.arrow_back_ios,
                size: 18,
              ),
              label: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.espresso.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            // Next/Post button
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (isLastStep ? _submitItem : _nextStep),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLastStep ? 'Post Item' : 'Continue'),
                        if (!isLastStep) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 14),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
