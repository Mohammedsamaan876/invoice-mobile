import '../../../customers/presentation/widgets/customer_entry_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../customers/models/customer_model.dart';
import '../../../customers/providers/customer_provider.dart';

class CustomerSelector extends ConsumerWidget {
  final String? selectedCustomer;
  final CustomerModel? customerInfo;
  final ValueChanged<String>? onCustomerSelected;
  final ValueChanged<CustomerModel>? onCustomerInfoSelected;
  final ValueChanged<CustomerModel>? onCustomerEdited;

  const CustomerSelector({
    super.key,
    this.selectedCustomer,
    this.customerInfo,
    this.onCustomerSelected,
    this.onCustomerInfoSelected,
    this.onCustomerEdited,
  });

  void _showCustomerPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _CustomerPickerSheet(
        selectedCustomerName: selectedCustomer ?? customerInfo?.name,
        onCustomerSelected: (customer) {
          if (onCustomerInfoSelected != null) {
            onCustomerInfoSelected!(customer);
          } else {
            onCustomerSelected?.call(customer.name);
          }
        },
      ),
    );
  }

  void _showEditCustomerModal(
    BuildContext context,
    CustomerModel customer,
    WidgetRef ref,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => CustomerEntryFormSheet(
        initialCustomer: customer,
        isEditingForInvoiceOnly: true,
        onSave: (updatedCustomer, updateSavedCustomer) async {
          CustomerModel finalCustomer = updatedCustomer;
          if (updateSavedCustomer && customer.isSaved) {
            finalCustomer = await ref
                .read(customerListNotifierProvider.notifier)
                .updateCustomer(updatedCustomer);
          }
          if (onCustomerEdited != null) {
            onCustomerEdited!(finalCustomer);
          } else if (onCustomerInfoSelected != null) {
            onCustomerInfoSelected!(finalCustomer);
          } else {
            onCustomerSelected?.call(finalCustomer.name);
          }
          if (modalContext.mounted) {
            Navigator.pop(modalContext);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCustomers = ref.watch(customerListNotifierProvider);

    // Resolve active customer details
    CustomerModel? resolvedCustomer = customerInfo;
    if (resolvedCustomer == null &&
        selectedCustomer != null &&
        selectedCustomer!.trim().isNotEmpty) {
      resolvedCustomer = savedCustomers
          .where((c) =>
              c.name.toLowerCase() == selectedCustomer!.trim().toLowerCase())
          .firstOrNull;
      resolvedCustomer ??= CustomerModel(
        id: 'legacy',
        name: selectedCustomer!.trim(),
        isSaved: false,
      );
    }

    final hasCustomer = resolvedCustomer != null &&
        resolvedCustomer.name.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main compact input field
        InkWell(
          onTap: () => _showCustomerPicker(context, ref),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasCustomer ? AppColors.primary : AppColors.borderLight,
                width: hasCustomer ? 1.2 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: hasCustomer
                      ? AppColors.primary
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasCustomer ? resolvedCustomer.name : 'Select Customer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          hasCustomer ? FontWeight.w600 : FontWeight.w400,
                      color: hasCustomer
                          ? AppColors.textPrimaryLight
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),
        ),

        // Compact customer summary card if customer is selected
        if (hasCustomer) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (resolvedCustomer.companyName != null &&
                                    resolvedCustomer.companyName!.isNotEmpty &&
                                    resolvedCustomer.companyName !=
                                        resolvedCustomer.name)
                                ? '${resolvedCustomer.name} • ${resolvedCustomer.companyName}'
                                : '${resolvedCustomer.name} • Contact',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit for this invoice button
                    InkWell(
                      onTap: () => _showEditCustomerModal(
                        context,
                        resolvedCustomer!,
                        ref,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Edit for this invoice',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if ((resolvedCustomer.phone != null &&
                        resolvedCustomer.phone!.isNotEmpty) ||
                    (resolvedCustomer.email != null &&
                        resolvedCustomer.email!.isNotEmpty)) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (resolvedCustomer.phone != null &&
                          resolvedCustomer.phone!.isNotEmpty) ...[
                        Text(
                          resolvedCustomer.phone!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        if (resolvedCustomer.email != null &&
                            resolvedCustomer.email!.isNotEmpty)
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                      if (resolvedCustomer.email != null &&
                          resolvedCustomer.email!.isNotEmpty)
                        Flexible(
                          child: Text(
                            resolvedCustomer.email!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CustomerPickerSheet extends ConsumerStatefulWidget {
  final String? selectedCustomerName;
  final ValueChanged<CustomerModel> onCustomerSelected;

  const _CustomerPickerSheet({
    required this.selectedCustomerName,
    required this.onCustomerSelected,
  });

  @override
  ConsumerState<_CustomerPickerSheet> createState() =>
      _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<_CustomerPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddCustomerForm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerEntryFormSheet(
        isEditingForInvoiceOnly: false,
        onSave: (customer, saveToCustomerList) async {
          CustomerModel finalCustomer = customer;
          if (saveToCustomerList) {
            finalCustomer = await ref
                .read(customerListNotifierProvider.notifier)
                .addCustomer(customer);
          }
          widget.onCustomerSelected(finalCustomer);
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedCustomers = ref.watch(customerListNotifierProvider);

    final filteredCustomers = savedCustomers.where((c) {
      if (_searchQuery.isEmpty) return true;
      final matchName = c.name.toLowerCase().contains(_searchQuery);
      final matchCompany =
          c.companyName?.toLowerCase().contains(_searchQuery) ?? false;
      final matchPhone = c.phone?.toLowerCase().contains(_searchQuery) ?? false;
      final matchEmail = c.email?.toLowerCase().contains(_searchQuery) ?? false;
      return matchName || matchCompany || matchPhone || matchEmail;
    }).toList();

    return Material(
      color: AppColors.surfaceLight,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Header: Title & Close Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Customer',
                      style: TextStyle(
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
              ),
              const SizedBox(height: 8),

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // "+ Add New Customer" Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () => _openAddCustomerForm(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(60),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '+ Add New Customer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Customer List or Empty States
              Flexible(
                child: savedCustomers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 36,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 44,
                              color: AppColors.textSecondaryLight.withAlpha(120),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No saved customers yet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredCustomers.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 36,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 40,
                                  color: AppColors.textSecondaryLight
                                      .withAlpha(120),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'No customer matches search.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredCustomers.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              indent: 68,
                              color: AppColors.borderLight,
                            ),
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];
                              final isSelected = widget.selectedCustomerName !=
                                      null &&
                                  widget.selectedCustomerName!.toLowerCase() ==
                                      customer.name.toLowerCase();

                              final subtitleParts = <String>[];
                              if (customer.companyName != null &&
                                  customer.companyName!.isNotEmpty &&
                                  customer.companyName != customer.name) {
                                subtitleParts.add(customer.companyName!);
                              }
                              if (customer.phone != null &&
                                  customer.phone!.isNotEmpty) {
                                subtitleParts.add(customer.phone!);
                              } else if (customer.email != null &&
                                  customer.email!.isNotEmpty) {
                                subtitleParts.add(customer.email!);
                              }

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? AppColors.primary.withAlpha(25)
                                      : AppColors.backgroundLight,
                                  child: Icon(
                                    Icons.business_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                title: Text(
                                  customer.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                subtitle: subtitleParts.isNotEmpty
                                    ? Text(
                                        subtitleParts.join(' • '),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onCustomerSelected(customer);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
