import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/invoice_model.dart';
import '../services/pdf_service.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'Invoice_${widget.invoice.invoiceNumber ?? '001'}';
  }

  Future<void> _handleDownload() async {
    final Uint8List pdfBytes = await PdfService.generateInvoice(widget.invoice);
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter file name:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                suffixText: '.pdf',
                hintText: 'e.g. Invoice_July',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              String fileName = _fileNameController.text.trim();
              if (fileName.isEmpty) fileName = 'Invoice';
              
              Navigator.pop(context); // Close dialog

              try {
                // Fix: Pass the bytes directly to saveFile as required by the package on mobile
                String? outputFile = await FilePicker.platform.saveFile(
                  dialogTitle: 'Select location to save PDF',
                  fileName: '$fileName.pdf',
                  bytes: pdfBytes, // THIS IS REQUIRED ON MOBILE
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );

                if (outputFile != null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving file: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('SAVE TO DEVICE'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShare() async {
    final Uint8List pdfBytes = await PdfService.generateInvoice(widget.invoice);
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/${_fileNameController.text}.pdf';
    final file = File(path);
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(path)], text: 'Invoice from Stitch');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Preview'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share via App',
            onPressed: _handleShare,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Download to Device',
            onPressed: _handleDownload,
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateInvoice(widget.invoice),
        allowPrinting: true,
        allowSharing: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: '${_fileNameController.text}.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
      ),
    );
  }
}
