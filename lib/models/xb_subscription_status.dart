class XbSubscriptionStatus {
  final bool ok;
  final String? checkoutMode; // 'live' | 'sandbox'
  final String? plan; // 'month' | 'year'
  final String? state; // 'new' | 'active' | 'stop'
  final String? billingStatus; // 'consent_pending' | 'enabled' | 'stop_pending' | 'stopped'
  final String? payUrl;
  final bool checkoutPaid;
  final bool canStop;
  final DateTime? activeUntil;
  final bool isTestActive;

  const XbSubscriptionStatus({
    required this.ok,
    this.checkoutMode,
    this.plan,
    this.state,
    this.billingStatus,
    this.payUrl,
    this.checkoutPaid = false,
    this.canStop = false,
    this.activeUntil,
    this.isTestActive = false,
  });

  bool get isActive =>
      activeUntil != null && activeUntil!.isAfter(DateTime.now());

  bool get isAutoRenewActive =>
      state == 'active' || billingStatus == 'enabled';

  bool get isStopPending => billingStatus == 'stop_pending';

  factory XbSubscriptionStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final dateStr = json['active_until']?.toString();
    if (dateStr != null && dateStr.isNotEmpty) {
      parsedDate = DateTime.tryParse(dateStr)?.toLocal();
    }

    return XbSubscriptionStatus(
      ok: json['ok'] == true,
      checkoutMode: json['checkout_mode']?.toString(),
      plan: json['plan']?.toString(),
      state: json['state']?.toString(),
      billingStatus: json['billing_status']?.toString(),
      payUrl: json['pay_url']?.toString(),
      checkoutPaid: json['checkout_paid'] == true,
      canStop: json['can_stop'] == true,
      activeUntil: parsedDate,
      isTestActive: json['is_test_active'] == true,
    );
  }
}
