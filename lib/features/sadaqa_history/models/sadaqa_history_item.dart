enum SadaqaHistoryStatus { pending, success, failed }

class SadaqaHistoryItem {
  final int id;
  final String title;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final String? companyName;
  final String? paymentMethod;
  final String? receiptId;
  final SadaqaHistoryStatus status;

  const SadaqaHistoryItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.createdAt,
    required this.status,
    this.companyName,
    this.paymentMethod,
    this.receiptId,
  });

  factory SadaqaHistoryItem.fromJson(Map<String, Object?> json) {
    final meta = json['sadaqa'] as Map<String, Object?>?;
    final company = json['company'] as Map<String, Object?>?;

    return SadaqaHistoryItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: '${json['title'] ?? meta?['title'] ?? ''}'.trim(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: '${json['currency'] ?? meta?['currency'] ?? 'KZT'}',
      createdAt: _parseDate(json),
      companyName: _parseCompany(json, company),
      paymentMethod: (json['payment_method'] ?? json['method'])?.toString(),
      receiptId: (json['receipt_id'] ?? json['receipt'])?.toString(),
      status: _mapStatus(json['status']),
    );
  }

  static DateTime _parseDate(Map<String, Object?> json) {
    final rawDate =
        json['created_at'] ?? json['date'] ?? json['timestamp'] ?? '';
    if (rawDate is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawDate * 1000);
    }

    if (rawDate is String && rawDate.isNotEmpty) {
      return DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return DateTime.now();
  }

  static SadaqaHistoryStatus _mapStatus(Object? value) {
    final normalized = '${value ?? ''}'.toLowerCase();
    switch (normalized) {
      case 'paid':
      case 'done':
      case 'success':
      case 'completed':
        return SadaqaHistoryStatus.success;
      case 'pending':
      case 'processing':
      case 'in_progress':
        return SadaqaHistoryStatus.pending;
      case 'failed':
      case 'canceled':
      case 'cancelled':
      case 'error':
        return SadaqaHistoryStatus.failed;
      default:
        return SadaqaHistoryStatus.pending;
    }
  }

  static String? _parseCompany(
    Map<String, Object?> json,
    Map<String, Object?>? company,
  ) {
    final fromFlat = json['company_name'] ?? json['company'];
    if (fromFlat is String && fromFlat.isNotEmpty) return fromFlat;
    final fromNested = company?['name'];
    if (fromNested is String && fromNested.isNotEmpty) return fromNested;
    return null;
  }
}
