import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _categoryController = TextEditingController(text: widget.item?.category ?? 'Food');
    _noteController = TextEditingController(text: widget.item?.note);
    _expiryDate = widget.item?.expiryDate;
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
      );

      final provider = context.read<ItemProvider>();
      if (widget.item != null) {
        provider.updateItem(newItem);
      } else {
        provider.addItem(newItem);
      }

      Navigator.pop(context);
    }
  }

  void _deleteItem() {
    if (widget.item != null) {
      context.read<ItemProvider>().deleteItem(widget.item!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.item != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? l10n.editItem : l10n.addItem,
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(l10n.name),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(l10n.name),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 24),
                _buildLabel(l10n.category),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: Category.defaultCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = Category.defaultCategories[index];
                      final isSelected = _categoryController.text == category.name;
                      return ChoiceChip(
                        label: Text(Category.getLocalizedName(context, category.name)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _categoryController.text = category.name;
                            });
                          }
                        },
                        selectedColor: category.color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.expiryDate),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                              );
                              if (date != null) {
                                setState(() => _expiryDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _expiryDate == null ? AppColors.error : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _expiryDate == null
                                        ? 'Select Date'
                                        : DateFormat.yMMMd().format(_expiryDate!),
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.purchaseDate),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _purchaseDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _purchaseDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.history, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat.yMMMd().format(_purchaseDate),
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.save,
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.labelSmall,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}
