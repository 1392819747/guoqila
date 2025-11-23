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
  final bool batchMode;

  const AddItemScreen({super.key, this.item, this.batchMode = false});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _noteController;
  late DateTime _expiryDate;
  late DateTime _purchaseDate;
  String? _imagePath; // Product image path
  int _quantity = 1;

  // Initial values for dirty check
  late String _initialName;
  late String _initialCategory;
  late String _initialNote;
  late DateTime _initialExpiryDate;
  late String? _initialImagePath;
  late int _initialQuantity;

  // Production Date Mode State
  bool _isProductionMode = false;
  DateTime _productionDate = DateTime.now();
  int _shelfLifeValue = 12;
  String _shelfLifeUnit = 'Months'; // Days, Weeks, Months, Years

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _categoryController = TextEditingController(text: item?.category ?? 'Food');
    _noteController = TextEditingController(text: item?.note ?? '');
    _expiryDate = item?.expiryDate ?? DateTime.now();
    _purchaseDate = item?.purchaseDate ?? DateTime.now();
    _imagePath = item?.imagePath; // Load existing image path
    _quantity = item?.quantity ?? 1;

    // Initialize production date to today if not editing, or estimate if editing (optional, but keeping simple for now)
    _productionDate = DateTime.now();

    // Store initial values
    _initialName = _nameController.text;
    _initialCategory = _categoryController.text;
    _initialNote = _noteController.text;
    _initialExpiryDate = _expiryDate;
    _initialImagePath = _imagePath;
    _initialQuantity = _quantity;
  }

  bool get _hasChanges {
    return _nameController.text != _initialName ||
        _categoryController.text != _initialCategory ||
        _noteController.text != _initialNote ||
        _expiryDate != _initialExpiryDate ||
        _imagePath != _initialImagePath ||
        _quantity != _initialQuantity;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final l10n = AppLocalizations.of(context)!;
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => BoldDialog(
        title: l10n.unsavedChangesTitle, // You might need to add this to arb
        content: Text(
          l10n.unsavedChangesMessage, // You might need to add this to arb
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          BoldDialogButton(
            text: l10n.cancel,
            onPressed: () => Navigator.pop(context, false),
          ),
          BoldDialogButton(
            text: l10n.discard,
            textColor: Colors.red,
            onPressed: () => Navigator.pop(context, true),
          ),
          BoldDialogButton(
            text: l10n.save,
            isPrimary: true,
            onPressed: () {
              _saveItem();
              // _saveItem pops the context, so we don't need to return true here usually,
              // but since we are in onWillPop, we want to prevent the default pop if we are saving manually.
              // However, _saveItem calls Navigator.pop.
              // Let's handle it: if user clicks Save, we save and close.
              // We should return false here to prevent double pop, or let _saveItem handle it.
              // Actually, simpler:
              // If Save -> _saveItem() -> pops dialog -> pops screen.
              // So we return false here to stop the original back action.
              Navigator.pop(context, false); 
            },
          ),
        ],
      ),
    );

    return shouldPop ?? false;
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
        expiryDate: _expiryDate,
        purchaseDate: _purchaseDate,
        note: _noteController.text,
        imagePath: _imagePath,
        quantity: _quantity,
      );
      if (widget.batchMode) {
        Navigator.pop(context, newItem);
        return;
      }

      final provider = context.read<ItemProvider>();
      if (widget.item != null && widget.item!.isInBox) {
        provider.updateItem(newItem);
      } else {
        provider.addItem(newItem);
      }

      Navigator.pop(context, true);
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

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: Colors.black,
      ),
    );
  }

  void _calculateExpiryDate() {
    DateTime expiry;
    switch (_shelfLifeUnit) {
      case 'Days':
        expiry = _productionDate.add(Duration(days: _shelfLifeValue));
        break;
      case 'Weeks':
        expiry = _productionDate.add(Duration(days: _shelfLifeValue * 7));
        break;
      case 'Months':
        // Approximate month as 30 days for simplicity, or use a better date logic
        // Dart's DateTime handles month overflow correctly if we just add months to month field
        // But simpler to use DateTime(year, month + value, day)
        expiry = DateTime(_productionDate.year, _productionDate.month + _shelfLifeValue, _productionDate.day);
        break;
      case 'Years':
        expiry = DateTime(_productionDate.year + _shelfLifeValue, _productionDate.month, _productionDate.day);
        break;
      default:
        expiry = _productionDate;
    }
    setState(() {
      _expiryDate = expiry;
    });
  }

  Color _getBackgroundColor() {
    if (_expiryDate == null) return AppColors.primary;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(_expiryDate!.year, _expiryDate!.month, _expiryDate!.day);
    final daysUntilExpiry = expiry.difference(today).inDays;
    
    if (daysUntilExpiry < 0) {
      return AppColors.grey300; // Expired
    } else if (daysUntilExpiry <= 7) {
      return AppColors.primary; // Expiring Soon (<= 7 days)
    } else {
      return AppColors.secondary; // Fresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.item != null;
    final backgroundColor = _getBackgroundColor();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context, false); // Return false to indicate viewed but not saved
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.pop(context, false); // Return false to indicate viewed but not saved
              }
            },
          ),
          title: Text(
            isEditing ? l10n.editItem : l10n.addItem,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            if (isEditing)
              IconButton(
                icon: Icon(Icons.delete_outline, color: isDark ? Colors.white : Colors.black),
                onPressed: _deleteItem,
              ),
          ],
        ),
        body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5), // Shadow upwards/around
            ),
          ],
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
                      color: _imagePath != null 
                          ? Colors.transparent 
                          : (isDark ? Colors.grey[800] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white54 : Colors.black, 
                        width: 2
                      ),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                                  child: Center(
                                    child: Icon(
                                      Category.getByName(_categoryController.text).icon,
                                      size: 64,
                                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Category.getByName(_categoryController.text).icon,
                                size: 64,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '点击添加商品图片',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                  decoration: _inputDecoration(l10n.name).copyWith(
                    hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 24),

                // Quantity Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '数量',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              '$_quantity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
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
                            onDoubleTap: () {
                               _showDeleteCategoryDialog(context, category.name);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? (isDark ? theme.colorScheme.primary : Colors.black) 
                                    : (isDark ? Colors.grey[800] : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                Category.getLocalizedName(context, category.name),
                                style: TextStyle(
                                  color: isSelected 
                                      ? (isDark ? Colors.black : Colors.white) 
                                      : (isDark ? Colors.white : Colors.black),
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
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white54 : Colors.black, 
                                width: 1
                              ),
                            ),
                            child: Icon(Icons.add, size: 20, color: theme.iconTheme.color),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                
                // Date Input Mode Toggle
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isProductionMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isProductionMode 
                                  ? (isDark ? Colors.grey[700] : Colors.white) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !_isProductionMode ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '直接设置到期日',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_isProductionMode 
                                    ? (isDark ? Colors.white : Colors.black) 
                                    : (isDark ? Colors.grey[400] : Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isProductionMode = true;
                            _calculateExpiryDate(); // Initial calculation
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isProductionMode 
                                  ? (isDark ? Colors.grey[700] : Colors.white) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isProductionMode ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '生产日期 + 保质期',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isProductionMode 
                                    ? (isDark ? Colors.white : Colors.black) 
                                    : (isDark ? Colors.grey[400] : Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (!_isProductionMode) ...[
                  _buildLabel(l10n.expiryDate),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickDateChip('+3 Days', const Duration(days: 3)),
                        const SizedBox(width: 12),
                        _buildQuickDateChip('+1 Week', const Duration(days: 7)),
                        const SizedBox(width: 12),
                        _buildQuickDateChip('+1 Month', const Duration(days: 30)),
                        const SizedBox(width: 12),
                        _buildQuickDateChip('+6 Months', const Duration(days: 180)),
                        const SizedBox(width: 12),
                        _buildQuickDateChip('+1 Year', const Duration(days: 365)),
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
                        color: isDark ? Colors.grey[800] : AppColors.grey100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white54 : Colors.black, 
                          width: 2
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 20, color: theme.iconTheme.color),
                          const SizedBox(width: 8),
                          Text(
                            _expiryDate == null
                                ? '选择到期时间'
                                : DateFormat.yMMMd(l10n.localeName).format(_expiryDate!),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Production Date Input
                  _buildLabel('生产日期'),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _productionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        locale: Localizations.localeOf(context),
                      );
                      if (date != null) {
                        setState(() {
                          _productionDate = date;
                          _calculateExpiryDate();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : AppColors.grey100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white54 : Colors.black, 
                          width: 1
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat.yMMMd(l10n.localeName).format(_productionDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Shelf Life Input
                  _buildLabel('保质期'),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : AppColors.grey100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white54 : Colors.black, 
                              width: 1
                            ),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '数值',
                              hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 18,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            controller: TextEditingController(text: _shelfLifeValue.toString())
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: _shelfLifeValue.toString().length)
                              ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  _shelfLifeValue = int.parse(value);
                                  _calculateExpiryDate();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : AppColors.grey100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white54 : Colors.black, 
                              width: 1
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _shelfLifeUnit,
                              isExpanded: true,
                              dropdownColor: theme.colorScheme.surface,
                              items: ['Days', 'Weeks', 'Months', 'Years'].map((String value) {
                                String label = value;
                                if (value == 'Days') label = '天';
                                if (value == 'Weeks') label = '周';
                                if (value == 'Months') label = '个月';
                                if (value == 'Years') label = '年';
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _shelfLifeUnit = newValue!;
                                  _calculateExpiryDate();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Calculated Expiry Date Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '计算出的到期日:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd(l10n.localeName).format(_expiryDate!),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.grey[800] : AppColors.grey100,
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
        borderSide: BorderSide(
          color: isDark ? theme.colorScheme.primary : Colors.black, 
          width: 2
        ),
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
