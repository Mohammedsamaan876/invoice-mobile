import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/create_invoice_model.dart';
import '../../models/invoice_preview_model.dart';
import '../../providers/invoice_preview_provider.dart';
import '../../services/invoice_pdf_service.dart';
import '../widgets/invoice_company_section.dart';
import '../widgets/invoice_customer_section.dart';
import '../widgets/invoice_info_section.dart';
import '../widgets/invoice_items_table.dart';
import '../widgets/invoice_notes_section.dart';
import '../widgets/invoice_preview_header.dart';
import '../widgets/invoice_totals_section.dart';
import 'invoice_pdf_viewer_screen.dart';

class InvoicePreviewScreen extends ConsumerStatefulWidget {
  final CreateInvoiceState? invoiceState;
  final CompanyInfo? companyInfo;
  final InvoicePdfService pdfService;
  final Uint8List? initialPdfBytes;
  final bool showActionsBeforeGeneration;
  final Future<void> Function(Uint8List bytes, String filename)? onPreviewPdf;
  final Future<void> Function(Uint8List bytes, String filename)? onSharePdf;
  final Future<bool> Function(Uint8List bytes, String filename)? onPrintPdf;
  final Future<bool> Function(Uint8List bytes, String name)? onLayoutPdf;

  const InvoicePreviewScreen({
    super.key,
    this.invoiceState,
    this.companyInfo,
    this.pdfService = const InvoicePdfService(),
    this.initialPdfBytes,
    this.showActionsBeforeGeneration = false,
    this.onPreviewPdf,
    this.onSharePdf,
    this.onPrintPdf,
    this.onLayoutPdf,
  });

  static String getPdfFilename(String? invoiceNumber) {
    final raw = (invoiceNumber != null && invoiceNumber.trim().isNotEmpty)
        ? invoiceNumber.trim()
        : 'INV-001';
    final sanitized = raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return '$sanitized.pdf';
  }

  @override
  ConsumerState<InvoicePreviewScreen> createState() =>
      InvoicePreviewScreenState();
}

class InvoicePreviewScreenState extends ConsumerState<InvoicePreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isGeneratingPdf = false;

  Uint8List? get pdfBytes => _pdfBytes;
  bool get isGeneratingPdf => _isGeneratingPdf;

  @override
  void initState() {
    super.initState();
    _pdfBytes = widget.initialPdfBytes;
  }

  InvoicePreviewModel _getFullModel() {
    final previewModel = ref.read(invoicePreviewProvider);
    final invoice = widget.invoiceState ?? previewModel.invoice;
    final company = widget.companyInfo ?? previewModel.company;
    return InvoicePreviewModel(company: company, invoice: invoice);
  }

  String _getFilename([InvoicePreviewModel? model]) {
    final m = model ?? _getFullModel();
    return InvoicePreviewScreen.getPdfFilename(m.invoice.invoiceNumber);
  }

  Future<void> generatePdf() => _handleGeneratePdf();
  Future<void> previewPdf() => _handlePreviewPdf();
  Future<void> sharePdf() => _handleSharePdf();
  Future<void> printPdf() => _handlePrintPdf();
  Future<void> savePdf() => _handleSavePdf();

  Future<void> _handleGeneratePdf() async {
    if (_isGeneratingPdf) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final model = _getFullModel();
      final bytes = await widget.pdfService.generateInvoicePdf(model);

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
        });
      }

      if (widget.onLayoutPdf != null) {
        await widget.onLayoutPdf!(bytes, _getFilename(model));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to generate invoice PDF. Please try again.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  Future<void> _handlePreviewPdf() async {
    if (_pdfBytes == null) {
      _showNotGeneratedSnackBar();
      return;
    }

    try {
      final filename = _getFilename();
      if (widget.onPreviewPdf != null) {
        await widget.onPreviewPdf!(_pdfBytes!, filename);
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InvoicePdfViewerScreen(
              pdfBytes: _pdfBytes!,
              filename: filename,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to preview invoice PDF. Please try again.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSharePdf() async {
    if (_pdfBytes == null) {
      _showNotGeneratedSnackBar();
      return;
    }

    try {
      final filename = _getFilename();
      if (widget.onSharePdf != null) {
        await widget.onSharePdf!(_pdfBytes!, filename);
      } else {
        await Printing.sharePdf(
          bytes: _pdfBytes!,
          filename: filename,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share invoice PDF. Please try again.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handlePrintPdf() async {
    if (_pdfBytes == null) {
      _showNotGeneratedSnackBar();
      return;
    }

    try {
      final filename = _getFilename();
      if (widget.onPrintPdf != null) {
        await widget.onPrintPdf!(_pdfBytes!, filename);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => _pdfBytes!,
          name: filename,
          format: PdfPageFormat.a4,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to print invoice PDF. Please try again.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSavePdf() async {
    if (_pdfBytes == null) {
      _showNotGeneratedSnackBar();
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Save PDF will be available soon.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotGeneratedSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please generate the PDF first.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewModel = ref.watch(invoicePreviewProvider);
    final invoice = widget.invoiceState ?? previewModel.invoice;
    final company = widget.companyInfo ?? previewModel.company;
    final filename = InvoicePreviewScreen.getPdfFilename(invoice.invoiceNumber);

    final showActions = (_pdfBytes != null || widget.showActionsBeforeGeneration);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Invoice Preview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryLight),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subtitle / Preview Header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: const InvoicePreviewHeader(),
          ),

          // Scrollable A4 Document Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Company Header
                      InvoiceCompanySection(company: company),
                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFE2E8F0), height: 1),
                      const SizedBox(height: 16),

                      // 2. Info & Customer Rows
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InvoiceCustomerSection(
                              customerName: invoice.customer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InvoiceInfoSection(
                              invoiceNumber: invoice.invoiceNumber,
                              invoiceDate: invoice.invoiceDate,
                              dueDate: invoice.dueDate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. Items Table
                      InvoiceItemsTable(items: invoice.items),
                      const SizedBox(height: 16),

                      // 4. Totals Section
                      InvoiceTotalsSection(state: invoice),
                      const SizedBox(height: 20),

                      // 5. Notes & Terms
                      InvoiceNotesSection(
                        initialNotes: invoice.notes,
                        isPreview: true,
                      ),
                      const SizedBox(height: 24),

                      // 6. Footer
                      const Center(
                        child: Text(
                          'Thank you for your business.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Generated with Invoice App',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action Buttons outside invoice document
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: _buildBottomActions(filename, showActions),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(String filename, bool showActions) {
    if (_isGeneratingPdf) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withAlpha(160),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Generating PDF...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!showActions) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              onPressed: _handleGeneratePdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              label: const Text(
                'Generate PDF',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimaryLight,
                side: const BorderSide(color: AppColors.borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Edit Invoice',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // PDF Actions Section
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 6),
            const Text(
              'PDF Actions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                filename,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Primary: Preview PDF
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text(
              'Preview PDF',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _handlePreviewPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Secondary: Share PDF and Print PDF
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text(
                    'Share PDF',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _handleSharePdf,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimaryLight,
                    side: const BorderSide(color: AppColors.borderLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.print_outlined, size: 16),
                  label: const Text(
                    'Print PDF',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _handlePrintPdf,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimaryLight,
                    side: const BorderSide(color: AppColors.borderLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Optional: Save PDF
        SizedBox(
          width: double.infinity,
          height: 38,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text(
              'Save PDF',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _handleSavePdf,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondaryLight,
              side: const BorderSide(color: AppColors.borderLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Edit Invoice
        Center(
          child: TextButton.icon(
            icon: const Icon(
              Icons.edit_outlined,
              size: 15,
              color: AppColors.textSecondaryLight,
            ),
            label: const Text(
              'Edit Invoice',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
