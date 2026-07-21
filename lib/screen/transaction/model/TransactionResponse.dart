import 'package:intl/intl.dart';

class TransactionResponse {
  final bool status;
  final String message;
  final String source;
  final List<Transaction> data;
  final Stats stats;
  final Pagination pagination;

  TransactionResponse({
    required this.status,
    required this.message,
    required this.source,
    required this.data,
    required this.stats,
    required this.pagination,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      source: json['source'] ?? '',
      data: (json['data'] as List?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ??
          [],
      stats: Stats.fromJson(json['stats'] ?? {}),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Transaction {
  final int id;
  final String transactionId;
  final String razorpayTransId;
  final int userId;
  final int planId;
  final String sourceType;
  final String billingCycle;
  final double amount;
  final double discountAmount;
  final int status; // 1 = completed, etc.
  final String statusLabel;
  final int planStatus;
  final String? failReason;
  final DateTime durationFrom;
  final DateTime durationTo;
  final DateTime createdAt;
  final String planName;
  final bool proceedNow;

  Transaction({
    required this.id,
    required this.transactionId,
    required this.razorpayTransId,
    required this.userId,
    required this.planId,
    required this.sourceType,
    required this.billingCycle,
    required this.amount,
    required this.discountAmount,
    required this.status,
    required this.statusLabel,
    required this.planStatus,
    this.failReason,
    required this.durationFrom,
    required this.durationTo,
    required this.createdAt,
    required this.planName,
    required this.proceedNow,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      razorpayTransId: json['razorpay_trans_id'] ?? '',
      userId: json['user_id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      sourceType: json['source_type'] ?? '',
      billingCycle: json['billing_cycle'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
      statusLabel: json['status_label'] ?? '',
      planStatus: json['plan_status'] ?? 0,
      failReason: json['fail_reason'],
      durationFrom: DateTime.parse(json['duration_from'] ?? ''),
      durationTo: DateTime.parse(json['duration_to'] ?? ''),
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      planName: json['plan_name'] ?? '',
      proceedNow: json['proceed_now'] ?? false,
    );
  }

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
  String get formattedDateFrom => DateFormat('dd MMM yyyy').format(durationFrom);
  String get formattedDateTo => DateFormat('dd MMM yyyy').format(durationTo);
}

class Stats {
  final int total;
  final int completed;
  final int pending;
  final int failed;

  Stats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.failed,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      pending: json['pending'] ?? 0,
      failed: json['failed'] ?? 0,
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}