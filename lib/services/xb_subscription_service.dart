import '../config/app_config.dart';
import '../models/xb_subscription_status.dart';
import 'api/api_client.dart';

class XbSubscriptionService {
  final ApiClient _apiClient;

  XbSubscriptionService(this._apiClient);

  String get _statusUrl => '${AppConfig.serverOrigin}/api/xb/subscription/status/';
  String get _checkoutUrl => '${AppConfig.serverOrigin}/api/xb/subscription/checkout/';
  String get _stopUrl => '${AppConfig.serverOrigin}/api/xb/subscription/stop/';

  Future<XbSubscriptionStatus?> getStatus() async {
    try {
      final res = await _apiClient.get(_statusUrl);
      if (res.data is Map<String, dynamic>) {
        return XbSubscriptionStatus.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<String?> checkout(String plan) async {
    final res = await _apiClient.post(
      _checkoutUrl,
      data: {'plan': plan},
    );
    if (res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      final payUrl = map['pay_url']?.toString();
      if (payUrl != null && payUrl.isNotEmpty) {
        return payUrl;
      }
    }
    return null;
  }

  Future<bool> stopAutoRenewal() async {
    try {
      final res = await _apiClient.post(
        _stopUrl,
        data: {},
      );
      if (res.data is Map<String, dynamic>) {
        return (res.data as Map<String, dynamic>)['ok'] == true;
      }
    } catch (_) {}
    return false;
  }
}
