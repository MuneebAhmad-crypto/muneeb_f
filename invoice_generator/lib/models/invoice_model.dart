class Invoice {
  final String? id;
  final String userId;
  final String? invoiceNumber;
  final String clientName;
  final String clientEmail;
  final String clientAddress;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final double totalAmount;
  final double discount;
  final double taxPercentage;
  final double shippingCharges;
  final String? notes;
  final List<InvoiceItem> items;

  Invoice({
    this.id,
    required this.userId,
    this.invoiceNumber,
    required this.clientName,
    required this.clientEmail,
    required this.clientAddress,
    required this.invoiceDate,
    this.dueDate,
    this.totalAmount = 0.0,
    this.discount = 0.0,
    this.taxPercentage = 0.0,
    this.shippingCharges = 0.0,
    this.notes,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json, List<InvoiceItem> items) {
    return Invoice(
      id: json['id'],
      userId: json['user_id'],
      invoiceNumber: json['id']?.toString().substring(0, 8).toUpperCase(),
      clientName: json['client_name'],
      clientEmail: json['client_email'] ?? '',
      clientAddress: json['client_address'] ?? '',
      invoiceDate: DateTime.parse(json['invoice_date']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      totalAmount: (json['total_amount'] as num).toDouble(),
      discount: (json['discount'] as num? ?? 0.0).toDouble(),
      taxPercentage: (json['tax_percentage'] as num? ?? 0.0).toDouble(),
      shippingCharges: (json['shipping_charges'] as num? ?? 0.0).toDouble(),
      notes: json['notes'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_address': clientAddress,
      'invoice_date': invoiceDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'total_amount': totalAmount,
      'discount': discount,
      'tax_percentage': taxPercentage,
      'shipping_charges': shippingCharges,
      'notes': notes,
    };
  }
}

class InvoiceItem {
  final String? id;
  final String? invoiceId;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      invoiceId: json['invoice_id'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
    };
  }
}
