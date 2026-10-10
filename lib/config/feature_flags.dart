/// Release switches for features that are not yet available to users.
class FeatureFlags {
  FeatureFlags._();

  /// Enable once the subscription and billing flow is ready for release.
  static const bool xbSubscriptionEnabled = bool.fromEnvironment(
    'XB_SUBSCRIPTION_ENABLED',
    defaultValue: false,
  );
}
