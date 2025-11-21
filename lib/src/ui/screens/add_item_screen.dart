import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderables/reorderables.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/bold_dialog.dart';

class AddItemScreen extends StatefulWidget {
  final Item? item;

  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _noteController;
  DateTime? _expiryDate;
  DateTime _purchaseDate = DateTime.now();
  String? _imagePath; // Product image path

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _categoryController = TextEditingController(text: widget.item?.category ?? 'Food');
    _noteController = TextEditingController(text: widget.item?.note);
    _expiryDate = widget.item?.expiryDate;
    _imagePath = widget.item?.imagePath; // Load existing image path
    if (widget.item != null) {
      _purchaseDate = widget.item!.purchaseDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate() && _expiryDate != null) {
      final newItem = Item(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text,
        category: _categoryController.text,
        expiryDate: _expiryDate!,
        purchaseDate: _purchaseDate,
        note: _noteController.text,
        imagePath: _imagePath, // Save image path
      );

      final provider = context.read<ItemProvider>();
      // Check if item exists in the box (has a valid key) or if it's a new scanned item
      if (widget.item != null && widget.item!.isInBox) {
        // Update existing item that's already in the database
        provider.updateItem(newItem);
      } else {
        // Add new item (including scanned items)
        provider.addItem(newItem);
      }

      Navigator.pop(context);
    }
  }

  void _deleteItem() {
    if (widget.item != null) {
      // Delete image file if exists
      if (widget.item!.imagePath != null) {
        final imageFile = File(widget.item!.imagePath!);
        if (imageFile.existsSync()) {
          imageFile.deleteSync();
        }
      }
      context.read<ItemProvider>().deleteItem(widget.item!.id);
      Navigator.pop(context);
    }
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // Save image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/product_images');
      if (!imageDir.existsSync()) {
        imageDir.createSync(recursive: true);
      }

      final fileName = '${widget.item?.id ?? const Uuid().v4()}.jpg';
      final savedImage = await File(pickedFile.path).copy('${imageDir.path}/$fileName');

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addDuration(Duration duration) {
    setState(() {
      _expiryDate = DateTime.now().add(duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.item != null;

    return Scaffold(
      backgroundColor: AppColors.primary, // Yellow background for this screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? l10n.editItem : l10n.addItem,
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image Section
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: _imagePath != null ? Colors.transparent : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Category.getByName(_categoryController.text).icon,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '点击添加商品图片',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Name Field
                _buildLabel(l10n.name),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(l10n.name),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 24),
                _buildLabel(l10n.category),
                Consumer<ItemProvider>(
                  builder: (context, provider, child) {
                    return ReorderableWrap(
                      spacing: 12,
                      runSpacing: 12,
                      onReorder: provider.reorderCategories,
                      children: [
                        ...provider.categories.map((category) {
                          final isSelected = _categoryController.text == category.name;
                          return GestureDetector(
                            key: ValueKey(category.name),
                            onTap: () {
                              setState(() {
                                _categoryController.text = category.name;
                              });
                            },
                            onLongPress: () {
                              // ReorderableWrap handles long press for dragging
                              // We might need another way to delete, or use double tap?
                              // Or maybe ReorderableWrap allows long press if not dragging?
                              // Usually dragging starts on long press.
                              // Let's keep delete on double tap or maybe just rely on reordering.
                              // User asked for reordering on long press.
                            },
                            onDoubleTap: () {
                               _showDeleteCategoryDialog(context, category.name);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                Category.getLocalizedName(context, category.name),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          key: const ValueKey('add_button'),
                          onTap: () => _showAddCategoryDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: const Icon(Icons.add, size: 20, color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildLabel(l10n.expiryDate),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickDateChip('+3 Days', const Duration(days: 3)),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('+1 Week', const Duration(days: 7)),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('+2 Week', const Duration(days: 14)),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('+1 Month', const Duration(days: 30)),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('+6 Months', const Duration(days: 180)),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('+12 Months', const Duration(days: 365)),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('+24 Months', const Duration(days: 730)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                      locale: Localizations.localeOf(context),
                    );
                    if (date != null) {
                      setState(() => _expiryDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          _expiryDate == null
                              ? '选择到期时间'
                              : DateFormat.yMMMd(l10n.localeName).format(_expiryDate!),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel(l10n.note),
                TextFormField(
                  controller: _noteController,
                  decoration: _inputDecoration(l10n.note).copyWith(
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.save,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, Duration duration) {
    // Localize label if possible, or just use Chinese for now as requested
    String localizedLabel = label;
    if (label.contains('Days')) localizedLabel = label.replaceAll('Days', '天').replaceAll('+', '+ ');
    if (label.contains('Week')) localizedLabel = label.replaceAll('Week', '周').replaceAll('Weeks', '周').replaceAll('+', '+ ');
    if (label.contains('Month')) localizedLabel = label.replaceAll('Month', '个月').replaceAll('+', '+ ');

    return GestureDetector(
      onTap: () => _addDuration(duration),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          localizedLabel,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w900,
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      contentPadding: const EdgeInsets.all(20),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => BoldDialog(
        title: l10n.addCategory,
        content: TextField(
          controller: controller,
          decoration: _inputDecoration(l10n.newCategoryName),
        ),
        actions: [
          BoldDialogButton(
            text: l10n.cancel,
            onPressed: () => Navigator.pop(context),
          ),
          BoldDialogButton(
            text: l10n.add,
            isPrimary: true,
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ItemProvider>().addCategory(controller.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String categoryName) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => BoldDialog(
        title: l10n.deleteCategory,
        content: Text(
          l10n.deleteCategoryConfirm(categoryName),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          BoldDialogButton(
            text: l10n.cancel,
            onPressed: () => Navigator.pop(context),
          ),
          BoldDialogButton(
            text: l10n.delete,
            textColor: Colors.red,
            onPressed: () {
              context.read<ItemProvider>().deleteCategory(categoryName);
              Navigator.pop(context);
              // If the deleted category was selected, reset selection
              if (_categoryController.text == categoryName) {
                setState(() {
                  _categoryController.text = 'Food'; // Default fallback
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

