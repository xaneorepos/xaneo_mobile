import 'dart:io';

import '../config/app_config.dart';

/// Allows an invalid certificate only for the explicitly configured private
/// development backend. Public hosts always use the platform trust store.
bool allowConfiguredDevelopmentCertificate(
  X509Certificate certificate,
  String host,
  int port,
) {
  return isConfiguredPrivateDevelopmentHost(host);
}

bool isConfiguredPrivateDevelopmentHost(String host) {
  if (!AppConfig.allowInsecurePrivateCertificates) return false;

  final configuredHost = Uri.tryParse(AppConfig.apiBaseUrl)?.host;
  if (configuredHost == null || host != configuredHost) return false;

  if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
    return true;
  }

  final address = InternetAddress.tryParse(host);
  if (address == null || address.type != InternetAddressType.IPv4) {
    return false;
  }

  final octets = address.rawAddress;
  return octets[0] == 10 ||
      (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) ||
      (octets[0] == 192 && octets[1] == 168) ||
      octets[0] == 127;
}
