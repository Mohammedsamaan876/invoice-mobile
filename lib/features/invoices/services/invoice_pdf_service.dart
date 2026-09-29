import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/create_invoice_model.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_preview_model.dart';

class InvoicePdfService {
  const InvoicePdfService();

  static String formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = 'AED $wholePart.${parts[1]}';
    return isNegative ? '- $formatted' : formatted;
  }

  static String formatDate(DateTime date) {
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
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  Future<Uint8List> generateInvoicePdf(InvoicePreviewModel model) async {
    final pdf = pw.Document();

    final invoice = model.invoice;
    final company = model.company;

    // Palette matching the app design system
    const primaryColor = PdfColor.fromInt(0xFF2563EB);
    const textPrimary = PdfColor.fromInt(0xFF0F172A);
    const textSecondary = PdfColor.fromInt(0xFF64748B);
    const borderColor = PdfColor.fromInt(0xFFE2E8F0);
    const tableHeaderBg = PdfColor.fromInt(0xFFF8FAFC);
    const errorColor = PdfColor.fromInt(0xFFEF4444);

    final regularFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();
    final obliqueFont = pw.Font.helveticaOblique();

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        italic: obliqueFont,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        footer: (pw.Context context) => _buildFooter(context, textSecondary),
        build: (pw.Context context) => [
          // 1. Header (Company details on left, Invoice details on right)
          _buildHeader(
            company: company,
            invoice: invoice,
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: borderColor, thickness: 1),
          pw.SizedBox(height: 16),

          // 2. Bill To
          _buildBillTo(
            customer: invoice.customer,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          pw.SizedBox(height: 18),

          // 3. Items Table
          _buildItemsTable(
            items: invoice.items,
            tableHeaderBg: tableHeaderBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          pw.SizedBox(height: 16),

          // 4. Totals Section
          _buildTotals(
            invoice: invoice,
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            borderColor: borderColor,
            errorColor: errorColor,
          ),
          pw.SizedBox(height: 20),

          // 5. Notes & Payment Terms
          if (invoice.notes.trim().isNotEmpty) ...[
            _buildNotes(
              notes: invoice.notes,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            pw.SizedBox(height: 20),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader({
    required CompanyInfo company,
    required CreateInvoiceState invoice,
    required PdfColor primaryColor,
    required PdfColor textPrimary,
    required PdfColor textSecondary,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Left: Company Info (Mock placeholder data)
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                company.name,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                company.subtitle,
                style: pw.TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                company.address,
                style: pw.TextStyle(
                  fontSize: 9.5,
                  lineSpacing: 1.5,
                  color: textSecondary,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Phone: ${company.phone}',
                style: pw.TextStyle(
                  fontSize: 9.5,
                  color: textSecondary,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                'Email: ${company.email}',
                style: pw.TextStyle(
                  fontSize: 9.5,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        // Right: Invoice Metadata
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 8),
            _buildMetaRow(
              'Invoice Number:',
              invoice.invoiceNumber,
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isHighlighted: true,
            ),
            pw.SizedBox(height: 4),
            _buildMetaRow(
              'Invoice Date:',
              formatDate(invoice.invoiceDate),
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            pw.SizedBox(height: 4),
            _buildMetaRow(
              'Due Date:',
              formatDate(invoice.dueDate),
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildMetaRow(
    String label,
    String value, {
    required PdfColor primaryColor,
    required PdfColor textPrimary,
    required PdfColor textSecondary,
    bool isHighlighted = false,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9.5,
            color: textSecondary,
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isHighlighted ? 11.5 : 9.5,
            fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHighlighted ? primaryColor : textPrimary,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBillTo({
    required String? customer,
    required PdfColor textPrimary,
    required PdfColor textSecondary,
  }) {
    final displayName = customer != null && customer.trim().isNotEmpty
        ? customer.trim()
        : 'N/A';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'BILL TO',
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          displayName,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable({
    required List<InvoiceItemModel> items,
    required PdfColor tableHeaderBg,
    required PdfColor borderColor,
    required PdfColor textPrimary,
    required PdfColor textSecondary,
  }) {
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(5),
        1: pw.FixedColumnWidth(40),
        2: pw.FixedColumnWidth(95),
        3: pw.FixedColumnWidth(95),
      },
      children: [
        // Header Row (repeat: true repeats on subsequent pages)
        pw.TableRow(
          repeat: true,
          decoration: pw.BoxDecoration(
            color: tableHeaderBg,
            border: pw.Border(
              top: pw.BorderSide(color: borderColor, width: 1),
              bottom: pw.BorderSide(color: borderColor, width: 1.5),
            ),
          ),
          children: [
            _buildTableCell('Description', isHeader: true, align: pw.TextAlign.left, textPrimary: textPrimary, textSecondary: textSecondary),
            _buildTableCell('Qty', isHeader: true, align: pw.TextAlign.center, textPrimary: textPrimary, textSecondary: textSecondary),
            _buildTableCell('Rate', isHeader: true, align: pw.TextAlign.right, textPrimary: textPrimary, textSecondary: textSecondary),
            _buildTableCell('Amount', isHeader: true, align: pw.TextAlign.right, textPrimary: textPrimary, textSecondary: textSecondary),
          ],
        ),
        // Item Rows
        ...items.map((item) {
          final amount = item.quantity * item.unitPrice;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            children: [
              _buildTableCell(
                item.description.trim().isNotEmpty ? item.description : 'Item',
                align: pw.TextAlign.left,
                isBold: true,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _buildTableCell(
                item.quantity.toString(),
                align: pw.TextAlign.center,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _buildTableCell(
                formatCurrency(item.unitPrice),
                align: pw.TextAlign.right,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _buildTableCell(
                formatCurrency(amount),
                align: pw.TextAlign.right,
                isBold: true,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    required PdfColor textPrimary,
    required PdfColor textSecondary,
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 9.5 : 9,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? textSecondary : textPrimary,
        ),
      ),
    );
  }

  pw.Widget _buildTotals({
    required CreateInvoiceState invoice,
    required PdfColor primaryColor,
    required PdfColor textPrimary,
    required PdfColor textSecondary,
    required PdfColor borderColor,
    required PdfColor errorColor,
  }) {
    final discountValueStr =
        invoice.discountValue == invoice.discountValue.roundToDouble()
            ? invoice.discountValue.toInt().toString()
            : invoice.discountValue.toString();

    final String discountLabel;
    final String discountAmountFormatted;

    if (invoice.discountType == DiscountType.percentage && invoice.discountValue > 0) {
      discountLabel = 'Discount ($discountValueStr%)';
      discountAmountFormatted = '- ${formatCurrency(invoice.discountAmount)}';
    } else if (invoice.discountType == DiscountType.fixed && invoice.discountValue > 0) {
      discountLabel = 'Discount';
      discountAmountFormatted = '- ${formatCurrency(invoice.discountAmount)}';
    } else {
      discountLabel = 'Discount';
      discountAmountFormatted = formatCurrency(0.0);
    }

    final taxRateStr = invoice.taxRate == invoice.taxRate.roundToDouble()
        ? invoice.taxRate.toInt().toString()
        : invoice.taxRate.toString();
    final taxLabel = 'Tax ($taxRateStr%)';
    final taxAmountFormatted = formatCurrency(invoice.taxAmount);

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 240,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildTotalRow('Subtotal', formatCurrency(invoice.subtotal), textPrimary: textPrimary, textSecondary: textSecondary, primaryColor: primaryColor, errorColor: errorColor),
            pw.SizedBox(height: 5),
            _buildTotalRow(
              discountLabel,
              discountAmountFormatted,
              isNegative: invoice.discountAmount > 0,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              primaryColor: primaryColor,
              errorColor: errorColor,
            ),
            pw.SizedBox(height: 5),
            _buildTotalRow(taxLabel, taxAmountFormatted, textPrimary: textPrimary, textSecondary: textSecondary, primaryColor: primaryColor, errorColor: errorColor),
            pw.SizedBox(height: 8),
            pw.Divider(color: borderColor, thickness: 1),
            pw.SizedBox(height: 8),
            _buildTotalRow(
              'Grand Total',
              formatCurrency(invoice.grandTotal),
              isGrandTotal: true,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              primaryColor: primaryColor,
              errorColor: errorColor,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    String value, {
    required PdfColor textPrimary,
    required PdfColor textSecondary,
    required PdfColor primaryColor,
    required PdfColor errorColor,
    bool isNegative = false,
    bool isGrandTotal = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isGrandTotal ? 11 : 9.5,
            fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isGrandTotal ? textPrimary : textSecondary,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isGrandTotal ? 12.5 : 9.5,
            fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isGrandTotal
                ? primaryColor
                : (isNegative ? errorColor : textPrimary),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildNotes({
    required String notes,
    required PdfColor textPrimary,
    required PdfColor textSecondary,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'NOTES & PAYMENT TERMS',
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          notes,
          style: pw.TextStyle(
            fontSize: 9.5,
            color: textPrimary,
            lineSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, PdfColor textSecondary) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
        ),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Thank you for your business.',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: textSecondary,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Generated with Invoice App',
            style: pw.TextStyle(
              fontSize: 8,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
