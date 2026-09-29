import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/features/invoices/models/create_invoice_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_item_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_preview_model.dart';
import 'package:invoice_app/features/invoices/services/invoice_pdf_service.dart';

void main() {
  group('InvoicePdfService Tests', () {
    const service = InvoicePdfService();

    test('1. PDF generation succeeds and returns non-empty bytes with PDF header', () async {
      final model = InvoicePreviewModel(
        invoice: CreateInvoiceState(
          invoiceNumber: 'INV-006',
          customer: 'Tech Solutions',
          invoiceDate: DateTime(2026, 9, 26),
          dueDate: DateTime(2026, 10, 10),
          items: const [
            InvoiceItemModel(
              id: '1',
              description: 'Website Development',
              quantity: 1,
              unitPrice: 5000.0,
            ),
          ],
          discountType: DiscountType.none,
          discountValue: 0.0,
          taxRate: 5.0,
          notes: 'Payment due within 14 days.',
        ),
      );

      final bytes = await service.generateInvoicePdf(model);

      expect(bytes, isNotEmpty);
      // Valid PDF files begin with '%PDF'
      final header = ascii.decode(bytes.sublist(0, 4));
      expect(header, '%PDF');
    });

    test('2. Section 19 Regression Test: Subtotal=30000, Discount=12%, Tax=5%, Grand Total=27720', () async {
      final state = CreateInvoiceState(
        invoiceNumber: 'INV-006',
        customer: 'Tech Solutions',
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Website Development',
            quantity: 2,
            unitPrice: 5000.0,
          ),
          InvoiceItemModel(
            id: '2',
            description: 'Website Development',
            quantity: 4,
            unitPrice: 5000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 12.0,
        taxRate: 5.0,
        notes: 'Payment due within 14 days.',
      );

      // Verify the calculations on the invoice state match Section 19 requirements
      expect(state.subtotal, 30000.0);
      expect(state.discountAmount, 3600.0);
      expect(state.taxableAmount, 26400.0);
      expect(state.taxAmount, 1320.0);
      expect(state.grandTotal, 27720.0);

      final model = InvoicePreviewModel(invoice: state);
      final bytes = await service.generateInvoicePdf(model);

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('3. Section 20 Decimal Regression Test: Subtotal=50000, Discount=9.5%, Tax=5.5%, Grand Total=47738.75', () async {
      final state = CreateInvoiceState(
        invoiceNumber: 'INV-006',
        customer: 'Tech Solutions',
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Enterprise Solution',
            quantity: 1,
            unitPrice: 50000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 9.5,
        taxRate: 5.5,
        notes: 'Payment due within 14 days.',
      );

      // Verify calculation values
      expect(state.subtotal, 50000.0);
      expect(state.discountAmount, 4750.0);
      expect(state.taxableAmount, 45250.0);
      expect(state.taxAmount, 2488.75);
      expect(state.grandTotal, 47738.75);

      final model = InvoicePreviewModel(invoice: state);
      final bytes = await service.generateInvoicePdf(model);

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('4. Empty notes do not cause failure', () async {
      final model = InvoicePreviewModel(
        invoice: CreateInvoiceState(
          invoiceNumber: 'INV-007',
          customer: 'ZAHURUDDIN',
          invoiceDate: DateTime(2026, 9, 26),
          dueDate: DateTime(2026, 10, 10),
          items: const [
            InvoiceItemModel(
              id: '1',
              description: 'Quick Consultation',
              quantity: 1,
              unitPrice: 1500.0,
            ),
          ],
          discountType: DiscountType.none,
          discountValue: 0.0,
          taxRate: 5.0,
          notes: '', // Empty notes
        ),
      );

      final bytes = await service.generateInvoicePdf(model);
      expect(bytes, isNotEmpty);
    });

    test('5. Multi-page support: Many items (35 items) generate without overflow', () async {
      final items = List.generate(
        35,
        (i) => InvoiceItemModel(
          id: 'item_$i',
          description: 'Consulting & Engineering Task Item #${i + 1} with detailed scope of work',
          quantity: (i % 5) + 1,
          unitPrice: 500.0 + (i * 50.0),
        ),
      );

      final model = InvoicePreviewModel(
        invoice: CreateInvoiceState(
          invoiceNumber: 'INV-099',
          customer: 'Global Logistics Corp',
          invoiceDate: DateTime(2026, 9, 26),
          dueDate: DateTime(2026, 10, 26),
          items: items,
          discountType: DiscountType.percentage,
          discountValue: 10.0,
          taxRate: 5.0,
          notes: 'Standard 30-day payment term applies.',
        ),
      );

      final bytes = await service.generateInvoicePdf(model);
      expect(bytes, isNotEmpty);
      // Multi-page document should have substantial byte size
      expect(bytes.length, greaterThan(5000));
    });

    test('6. Currency and Date formatters work correctly', () {
      expect(InvoicePdfService.formatCurrency(5000.0), 'AED 5,000.00');
      expect(InvoicePdfService.formatCurrency(30000.0), 'AED 30,000.00');
      expect(InvoicePdfService.formatCurrency(2488.75), 'AED 2,488.75');
      expect(InvoicePdfService.formatCurrency(-4750.0), '- AED 4,750.00');

      final date = DateTime(2026, 9, 26);
      expect(InvoicePdfService.formatDate(date), '26 Sep 2026');

      final dueDate = DateTime(2026, 10, 10);
      expect(InvoicePdfService.formatDate(dueDate), '10 Oct 2026');
    });
  });
}
