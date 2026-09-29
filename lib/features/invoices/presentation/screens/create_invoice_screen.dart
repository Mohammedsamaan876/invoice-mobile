import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/create_invoice_model.dart';
import '../../providers/create_invoice_provider.dart';
import '../widgets/add_invoice_item_button.dart';
import '../widgets/customer_selector.dart';
import '../widgets/invoice_item_card.dart';
import '../widgets/invoice_notes_section.dart';
import '../widgets/invoice_summary_card.dart';
import 'invoice_preview_screen.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;
  late final FocusNode _taxFocusNode;
  String? _taxError;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController();

    final currentTax = ref.read(createInvoiceProvider).taxRate;
    final taxStr = currentTax == currentTax.roundToDouble()
        ? currentTax.toInt().toString()
        : currentTax.toString();
    _taxController = TextEditingController(text: taxStr);

    _taxFocusNode = FocusNode();
    _taxFocusNode.addListener(_onTaxFocusChanged);
  }

  void _onTaxFocusChanged() {
    if (_taxFocusNode.hasFocus) {
      _taxController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _taxController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _taxController.dispose();
    _taxFocusNode.removeListener(_onTaxFocusChanged);
    _taxFocusNode.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onDatePicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      onDatePicked(picked);
    }
  }

  void _onTaxChanged(String val, CreateInvoiceNotifier notifier) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _taxError = 'Tax rate must be between 0% and 100%.';
      });
      return;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0 || parsed > 100) {
      setState(() {
        _taxError = 'Tax rate must be between 0% and 100%.';
      });
      return;
    }

    setState(() {
      _taxError = null;
    });
    notifier.updateTaxRate(parsed);
  }

  void _onSaveDraft() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved locally'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSaveInvoice() {
    final notifier = ref.read(createInvoiceProvider.notifier);
    final error = notifier.validate();

    if (error != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const InvoicePreviewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createInvoiceProvider);
    final notifier = ref.read(createInvoiceProvider.notifier);

    ref.listen<double>(
      createInvoiceProvider.select((s) => s.taxRate),
      (previous, next) {
        if (next >= 0 && next <= 100) {
          final currentParsed = double.tryParse(_taxController.text.trim());
          if (currentParsed != next) {
            final nextStr = next == next.roundToDouble()
                ? next.toInt().toString()
                : next.toString();
            _taxController.text = nextStr;
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Invoice',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Create a new invoice',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _onSaveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // 1. Invoice Details Card
            _buildInvoiceDetailsCard(state, notifier),
            const SizedBox(height: 16),

            // 2. Invoice Items Section
            _buildItemsSection(state, notifier),
            const SizedBox(height: 16),

            // 3. Discount Section
            _buildDiscountSection(state, notifier),
            const SizedBox(height: 16),

            // 4. Tax Section
            _buildTaxSection(state, notifier),
            const SizedBox(height: 16),

            // 5. Notes Section
            InvoiceNotesSection(
              initialNotes: state.notes,
              onNotesChanged: notifier.setNotes,
            ),
            const SizedBox(height: 16),

            // 6. Summary Card
            InvoiceSummaryCard(state: state),
            const SizedBox(height: 24),

            // 7. Save Invoice Primary Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onSaveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Invoice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInvoiceDetailsCard(
    CreateInvoiceState state,
    CreateInvoiceNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 14),

          // Invoice Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Invoice Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.invoiceNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Customer
          const Text(
            'Customer',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          CustomerSelector(
            selectedCustomer: state.customer,
            customerInfo: state.customerInfo,
            onCustomerSelected: notifier.setCustomer,
            onCustomerInfoSelected: notifier.setCustomerInfo,
            onCustomerEdited: notifier.updateInvoiceCustomer,
          ),
          const SizedBox(height: 14),

          // Invoice Date & Due Date
          Row(
            children: [
              // Invoice Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice Date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _pickDate(
                        context: context,
                        initialDate: state.invoiceDate,
                        onDatePicked: notifier.setInvoiceDate,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatDate(state.invoiceDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Due Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _pickDate(
                        context: context,
                        initialDate: state.dueDate,
                        onDatePicked: notifier.setDueDate,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_available_outlined,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatDate(state.dueDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
        ],
      ),
    );
  }

  Widget _buildItemsSection(
    CreateInvoiceState state,
    CreateInvoiceNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invoice Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < state.items.length; i++) ...[
          InvoiceItemCard(
            index: i,
            item: state.items[i],
            canDelete: state.items.length > 1,
            onDelete: () => notifier.removeItem(state.items[i].id),
            onDescriptionChanged: (val) =>
                notifier.updateItem(state.items[i].id, description: val),
            onQuantityChanged: (val) =>
                notifier.updateItem(state.items[i].id, quantity: val),
            onUnitPriceChanged: (val) =>
                notifier.updateItem(state.items[i].id, unitPrice: val),
            onIncrement: () => notifier.incrementQuantity(state.items[i].id),
            onDecrement: () => notifier.decrementQuantity(state.items[i].id),
          ),
          const SizedBox(height: 10),
        ],
        AddInvoiceItemButton(
          onPressed: () => notifier.addItem(
            description: 'Website Development',
            quantity: 1,
            unitPrice: 5000.0,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountSection(
    CreateInvoiceState state,
    CreateInvoiceNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),

          // Discount Type Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DiscountType.values.map((type) {
                final isSelected = state.discountType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(type.label),
                    selected: isSelected,
                    onSelected: (_) {
                      notifier.setDiscountType(type);
                    },
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
                    ),
                    selectedColor: AppColors.primary.withAlpha(25),
                    backgroundColor: AppColors.surfaceLight,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),

          if (state.discountType != DiscountType.none) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _discountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: state.discountType == DiscountType.fixed
                    ? 'AED '
                    : null,
                suffixText: state.discountType == DiscountType.percentage
                    ? '%'
                    : null,
                hintText: state.discountType == DiscountType.percentage
                    ? '10'
                    : '500.00',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val.trim()) ?? 0.0;
                notifier.setDiscountValue(parsed);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxSection(
    CreateInvoiceState state,
    CreateInvoiceNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tax',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _taxController,
            focusNode: _taxFocusNode,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Tax Rate (%)',
              suffixText: '%',
              hintText: '5.0',
              errorText: _taxError,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: (val) => _onTaxChanged(val, notifier),
          ),
        ],
      ),
    );
  }
}
