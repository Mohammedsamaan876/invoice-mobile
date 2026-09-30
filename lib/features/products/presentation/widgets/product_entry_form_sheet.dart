import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/product_model.dart';

class ProductEntryFormSheet extends StatefulWidget {
  final ProductModel? initialProduct;
  final FutureOr<void> Function(ProductModel product) onSave;

  const ProductEntryFormSheet({
    super.key,
    this.initialProduct,
    required this.onSave,
  });

  @override
  State<ProductEntryFormSheet> createState() => _ProductEntryFormSheetState();
}

class _ProductEntryFormSheetState extends State<ProductEntryFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _unitController;
  late final TextEditingController _skuController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _descriptionController;

  String? _nameError;
  String? _priceError;
  bool _isSaving = false;
  String? _errorMessage;

  static const List<String> _suggestedUnits = [
    'unit',
    'service',
    'hour',
    'day',
    'month',
    'pcs',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialProduct;
    _nameController = TextEditingController(text: init?.name ?? '');
    _priceController = TextEditingController(
      text: init != null && init.unitPrice > 0
          ? init.unitPrice.toStringAsFixed(2)
          : '',
    );
    _unitController = TextEditingController(text: init?.unit ?? 'unit');
    _skuController = TextEditingController(text: init?.sku ?? '');
    _taxRateController = TextEditingController(
      text: init?.taxRate != null ? init!.taxRate!.toString() : '5.0',
    );
    _descriptionController =
        TextEditingController(text: init?.description ?? '');

    _nameController.addListener(() {
      if (_nameError != null && _nameController.text.trim().isNotEmpty) {
        setState(() {
          _nameError = null;
        });
      }
    });

    _priceController.addListener(() {
      if (_priceError != null && _priceController.text.trim().isNotEmpty) {
        setState(() {
          _priceError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _skuController.dispose();
    _taxRateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Product or service name is required';
      });
      isValid = false;
    }

    final price = double.tryParse(priceStr);
    if (priceStr.isEmpty || price == null || price < 0) {
      setState(() {
        _priceError = 'Please enter a valid price (e.g. 100.00)';
      });
      isValid = false;
    }

    return isValid;
  }

  ProductModel _buildProductModel() {
    final parsedPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final parsedTax = double.tryParse(_taxRateController.text.trim()) ?? 0.0;
    final unit = _unitController.text.trim().isNotEmpty
        ? _unitController.text.trim()
        : 'unit';

    return ProductModel(
      id: widget.initialProduct?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      unitPrice: parsedPrice,
      unit: unit,
      sku: _skuController.text.trim().isEmpty
          ? null
          : _skuController.text.trim(),
      taxRate: parsedTax,
      isActive: widget.initialProduct?.isActive ?? true,
    );
  }

  Future<void> _handleSave() async {
    if (!_validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final product = _buildProductModel();
      await widget.onSave(product);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialProduct != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset > 0 ? bottomInset + 16 : 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Product / Service' : 'Add Product / Service',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Scrollable Form Fields
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Name
                  _buildTextField(
                    controller: _nameController,
                    label: 'Product / Service Name *',
                    hint: 'e.g. Website Development',
                    errorText: _nameError,
                    icon: Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 14),

                  // Price & Unit Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unit Price
                      Expanded(
                        flex: 6,
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Unit Price (AED) *',
                          hint: '0.00',
                          errorText: _priceError,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixText: 'AED ',
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Unit
                      Expanded(
                        flex: 5,
                        child: _buildTextField(
                          controller: _unitController,
                          label: 'Unit',
                          hint: 'unit, hr, service',
                          icon: Icons.straighten_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Unit suggestion chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _suggestedUnits.map((u) {
                      final isSelected = _unitController.text.trim().toLowerCase() == u;
                      return ChoiceChip(
                        label: Text(u, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _unitController.text = u;
                            });
                          }
                        },
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // SKU & Tax Rate Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SKU
                      Expanded(
                        child: _buildTextField(
                          controller: _skuController,
                          label: 'SKU / Code',
                          hint: 'e.g. SRV-001',
                          icon: Icons.qr_code_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tax Rate
                      Expanded(
                        child: _buildTextField(
                          controller: _taxRateController,
                          label: 'Tax / VAT (%)',
                          hint: '5.0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          suffixText: '%',
                          icon: Icons.percent_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Description
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Detailed scope, deliverables, or specifications...',
                    maxLines: 3,
                    icon: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Action Button
          ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isEditing ? 'Save Changes' : 'Create Product',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    String? suffixText,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
            suffixText: suffixText,
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: AppColors.textSecondaryLight)
                : null,
            errorText: errorText,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
