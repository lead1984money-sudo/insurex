// ---------- Models ----------
class EarningRecord {
  final String id;
  final String name;
  final String partner;
  final String phone;
  final double grossAmount;
  final double cashback;
  final double netEarning;
  final String status;
  final String created;

  EarningRecord({
    required this.id,
    required this.name,
    required this.partner,
    required this.phone,
    required this.grossAmount,
    required this.cashback,
    required this.netEarning,
    required this.status,
    required this.created,
  });
}