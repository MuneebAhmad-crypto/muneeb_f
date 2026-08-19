import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';
import '../screens/preview_screen.dart';
import 'database_service.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<Uint8List> generateInvoice(Invoice invoice) async {
    final pdf = pw.Document();
    final db = DatabaseService();
    final profile = await db.getUserProfile();
    
    final primaryColor = PdfColor.fromInt(0xFF1A237E); // Deep Indigo
    final accentColor = PdfColor.fromInt(0xFF00BFA5); // Teal
    final darkGrey = PdfColor.fromInt(0xFF333333);
    final lightGrey = PdfColor.fromInt(0xFFF5F5F5);

    // Calculate Totals
    final double subtotal = invoice.totalAmount;
    final double discount = invoice.discount;
    final double taxAmount = (subtotal - discount) * (invoice.taxPercentage / 100);
    final double grandTotal = (subtotal - discount) + taxAmount + invoice.shippingCharges;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          return pw.Column(
            children: [
              // Stylish Header
              pw.Container(
                height: 200,
                width: double.infinity,
                decoration: pw.BoxDecoration(color: primaryColor),
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.white, width: 2),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text('STITCH', 
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Text(profile['company_name'] ?? 'Your Company Name',
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        pw.Text('Tax ID: ${profile['tax_id'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey300)),
                        pw.Text(profile['address'] ?? '', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey300)),
                        pw.Text(profile['phone'] ?? '', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey300)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: accentColor)),
                        pw.SizedBox(height: 10),
                        pw.Text('Date: ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}', 
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
                        if (invoice.dueDate != null)
                          pw.Text('Due Date: ${DateFormat('dd MMM yyyy').format(invoice.dueDate!)}', 
                            style: pw.TextStyle(color: accentColor, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Invoice #: ${invoice.invoiceNumber ?? 'INV-0001'}', 
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Billing Info
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('BILL TO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                              pw.SizedBox(height: 8),
                              pw.Text(invoice.clientName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                              pw.Text(invoice.clientAddress, style: const pw.TextStyle(fontSize: 10)),
                              pw.Text(invoice.clientEmail, style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Align(
                            alignment: pw.Alignment.topRight,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(12),
                              decoration: pw.BoxDecoration(color: lightGrey, borderRadius: pw.BorderRadius.circular(8)),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text('TOTAL AMOUNT', style: pw.TextStyle(fontSize: 9, color: darkGrey)),
                                  pw.Text('\$${grandTotal.toStringAsFixed(2)}', 
                                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    pw.SizedBox(height: 40),

                    // Table
                    pw.Table(
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2))
                          ),
                          children: [
                            _headerCell('Description', flex: 4),
                            _headerCell('Quantity', align: pw.TextAlign.center),
                            _headerCell('Unit Price', align: pw.TextAlign.right),
                            _headerCell('Amount', align: pw.TextAlign.right),
                          ],
                        ),
                        ...invoice.items.map((item) => pw.TableRow(
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
                          children: [
                            _dataCell(item.description),
                            _dataCell(item.quantity.toString(), align: pw.TextAlign.center),
                            _dataCell('\$${item.unitPrice.toStringAsFixed(2)}', align: pw.TextAlign.right),
                            _dataCell('\$${item.total.toStringAsFixed(2)}', align: pw.TextAlign.right),
                          ],
                        )),
                      ],
                    ),

                    pw.SizedBox(height: 30),

                    // Totals & Payment Info
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Payment Details
                        pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('PAYMENT INFORMATION', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                              pw.SizedBox(height: 5),
                              pw.Text('Bank: ${profile['bank_name'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('Account: ${profile['account_number'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('Holder: ${profile['account_holder'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 9)),
                              pw.SizedBox(height: 20),
                              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                                pw.Text('NOTES / TERMS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                                pw.SizedBox(height: 5),
                                pw.Text(invoice.notes!, style: const pw.TextStyle(fontSize: 8)),
                              ],
                            ],
                          ),
                        ),
                        // Summary
                        pw.Container(
                          width: 200,
                          child: pw.Column(
                            children: [
                              _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                              if (discount > 0) _summaryRow('Discount', '-\$${discount.toStringAsFixed(2)}', color: PdfColors.red700),
                              if (invoice.taxPercentage > 0) 
                                _summaryRow('Tax (${invoice.taxPercentage}%)', '\$${taxAmount.toStringAsFixed(2)}'),
                              if (invoice.shippingCharges > 0)
                                _summaryRow('Shipping', '\$${invoice.shippingCharges.toStringAsFixed(2)}'),
                              pw.Divider(color: PdfColors.grey400),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Grand Total', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                  pw.Text('\$${grandTotal.toStringAsFixed(2)}', 
                                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Container(
                height: 60,
                width: double.infinity,
                color: lightGrey,
                padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Thank you for choosing ${profile['company_name'] ?? 'STITCH'}', 
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
                    pw.Text('Powered by Stitch Invoice', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _headerCell(String text, {int flex = 1, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
    );
  }

  static pw.Widget _dataCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: pw.Text(text, textAlign: align, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color ?? PdfColors.black)),
        ],
      ),
    );
  }

  static Future<void> previewPdf(BuildContext context, Invoice invoice) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePreviewScreen(invoice: invoice),
      ),
    );
  }
}
