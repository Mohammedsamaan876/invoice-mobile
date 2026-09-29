import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/customer_model.dart';

class CustomerEntryFormSheet extends StatefulWidget {
  final CustomerModel? initialCustomer;
  final bool isEditingForInvoiceOnly;
  final bool showUseOnce;
  final FutureOr<void> Function(CustomerModel customer, bool saveToCustomerList) onSave;

  const CustomerEntryFormSheet({
    super.key,
    this.initialCustomer,
    required this.isEditingForInvoiceOnly,
    this.showUseOnce = true,
    required this.onSave,
  });

  @override
  State<CustomerEntryFormSheet> createState() => _CustomerEntryFormSheetState();
}

class _CustomerEntryFormSheetState extends State<CustomerEntryFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _taxNumberController;

  String? _nameError;
  bool _updateSavedCustomer = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final init = widget.initialCustomer;
    _nameController = TextEditingController(text: init?.name ?? '');
    _companyController = TextEditingController(text: init?.companyName ?? '');
    _phoneController = TextEditingController(text: init?.phone ?? '');
    _emailController = TextEditingController(text: init?.email ?? '');
    _addressController = TextEditingController(text: init?.address ?? '');
    _cityController = TextEditingController(text: init?.city ?? '');
    _countryController = TextEditingController(text: init?.country ?? '');
    _taxNumberController = TextEditingController(text: init?.taxNumber ?? '');

    _nameController.addListener(() {
      if (_nameError != null && _nameController.text.trim().isNotEmpty) {
        setState(() {
          _nameError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Customer name is required';
      });
      return false;
    }
    return true;
  }

  CustomerModel _buildCustomerModel({String? id, required bool isSaved}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return CustomerModel(
      id: id ??
          widget.initialCustomer?.id ??
          (isSaved ? 'cust_$now' : 'manual_$now'),
      name: _nameController.text.trim(),
      companyName: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      taxNumber: _taxNumberController.text.trim().isEmpty
          ? null
          : _taxNumberController.text.trim(),
      isSaved: isSaved,
    );
  }

  void _handleUseOnce() {
    if (!_validate()) return;
    final customer = _buildCustomerModel(isSaved: false);
    widget.onSave(customer, false);
  }

  Future<void> _handleSave() async {
    if (!_validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final isSaved = widget.isEditingForInvoiceOnly
        ? (widget.initialCustomer?.isSaved ?? false)
        : true;
    final customer = _buildCustomerModel(
      id: widget.initialCustomer?.id,
      isSaved: isSaved,
    );

    try {
      await widget.onSave(
        customer,
        widget.isEditingForInvoiceOnly ? _updateSavedCustomer : true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.isEditingForInvoiceOnly;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing
                                ? 'Edit Customer (This Invoice)'
                                : 'Add New Customer',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEditing
                                ? 'Modify customer details for this invoice.'
                                : 'Enter customer contact and billing details.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondaryLight,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),
              // Form fields scrollable area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Customer Name (required)
                      _buildFieldLabel('Customer Name', isRequired: true),
                      const SizedBox(height: 4),
                      TextField(
                        key: const Key('customer_name_field'),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'e.g. Acme Corporation LLC',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            size: 18,
                            color: AppColors.textSecondaryLight,
                          ),
                          errorText: _nameError,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Company Name
                      _buildFieldLabel('Company Name'),
                      const SizedBox(height: 4),
                      TextField(
                        key: const Key('customer_company_field'),
                        controller: _companyController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Acme Group',
                          prefixIcon: Icon(
                            Icons.business_outlined,
                            size: 18,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Phone & Email Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Phone'),
                                const SizedBox(height: 4),
                                TextField(
                                  key: const Key('customer_phone_field'),
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    hintText: '+971 50 000 0000',
                                    prefixIcon: Icon(
                                      Icons.phone_outlined,
                                      size: 18,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Email'),
                                const SizedBox(height: 4),
                                TextField(
                                  key: const Key('customer_email_field'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    hintText: 'info@acme.com',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: 18,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Billing Address
                      _buildFieldLabel('Billing Address'),
                      const SizedBox(height: 4),
                      TextField(
                        key: const Key('customer_address_field'),
                        controller: _addressController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Street address, office / unit number',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // City & Country Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('City'),
                                const SizedBox(height: 4),
                                TextField(
                                  key: const Key('customer_city_field'),
                                  controller: _cityController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Dubai',
                                    prefixIcon: Icon(
                                      Icons.location_city_outlined,
                                      size: 18,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Country'),
                                const SizedBox(height: 4),
                                TextField(
                                  key: const Key('customer_country_field'),
                                  controller: _countryController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. UAE',
                                    prefixIcon: Icon(
                                      Icons.flag_outlined,
                                      size: 18,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tax/VAT Number
                      _buildFieldLabel('Tax/VAT Number'),
                      const SizedBox(height: 4),
                      TextField(
                        key: const Key('customer_tax_field'),
                        controller: _taxNumberController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 100XXXXXXXXX003',
                          prefixIcon: Icon(
                            Icons.tag_outlined,
                            size: 18,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),

                      // Checkbox for Edit mode
                      if (isEditing && (widget.initialCustomer?.isSaved ?? false)) ...[
                        const SizedBox(height: 10),
                        Material(
                          color: AppColors.backgroundLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.borderLight),
                          ),
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            title: const Text(
                              'Also update original saved customer',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            subtitle: const Text(
                              'If unchecked, changes apply only to this invoice.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            value: _updateSavedCustomer,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _updateSavedCustomer = val ?? false;
                              });
                            },
                          ),
                        ),
                      ],

                      // Error banner if any
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withAlpha(76),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 18, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),
              // Action buttons pinned at bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: isEditing
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: AppColors.borderLight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: _isSaving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.showUseOnce
                                        ? 'Save Customer & Use'
                                        : 'Save Customer',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          if (widget.showUseOnce) ...[
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _isSaving ? null : _handleUseOnce,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Use Once',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
