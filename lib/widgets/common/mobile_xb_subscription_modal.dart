import '../../config/feature_flags.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/xb_subscription_localizations.dart';
import '../../models/xb_subscription_status.dart';
import '../../services/api/api_client.dart';
import '../../services/xb_subscription_service.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';

class MobileXbSubscriptionModal extends BaseCustomModal {
  const MobileXbSubscriptionModal({super.key});

  static Future<void> show(BuildContext context) {
    if (!FeatureFlags.xbSubscriptionEnabled) return Future<void>.value();
    return BaseCustomModal.show<void>(
      context: context,
      enableDrag: true,
      child: const MobileXbSubscriptionModal(),
    );
  }

  @override
  State<MobileXbSubscriptionModal> createState() =>
      _MobileXbSubscriptionModalState();
}

class _MobileXbSubscriptionModalState
    extends BaseCustomModalState<MobileXbSubscriptionModal> {
  @override
  bool get isResizable => true;
  @override
  double get initialExtent => 0.88;
  @override
  double get maxExtent => 0.95;

  String _selectedPlan = 'month'; // 'month' or 'year'
  bool _isLoading = true;
  bool _isProcessingAction = false;
  String? _errorMessage;
  String? _statusBannerMessage;

  XbSubscriptionStatus? _status;
  String? _checkoutUrl;
  bool _isCheckoutView = false;
  Timer? _checkoutPollTimer;

  final Map<String, int> _prices = {
    'month': 159,
    'year': 999,
  };

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _checkoutPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final apiClient = context.read<ApiClient>();
      final service = XbSubscriptionService(apiClient);
      final status = await service.getStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _isLoading = false;
        if (status != null) {
          if (status.checkoutPaid && status.isActive) {
            _checkoutPollTimer?.cancel();
          }
          if (status.plan == 'year' || status.plan == 'month') {
            _selectedPlan = status.plan!;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (!silent) {
          _errorMessage = e.toString();
        }
      });
    }
  }

  Future<void> _handleBuy() async {
    final l10n = XbSubscriptionLocalizations.of(context);
    setState(() {
      _isProcessingAction = true;
      _errorMessage = null;
      _statusBannerMessage = l10n.text('messenger.premium.openingCheckout');
    });

    try {
      final apiClient = context.read<ApiClient>();
      final service = XbSubscriptionService(apiClient);
      final payUrl = await service.checkout(_selectedPlan);
      if (!mounted) return;

      if (payUrl != null && payUrl.isNotEmpty) {
        final uri = Uri.tryParse(payUrl);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        setState(() {
          _isProcessingAction = false;
          _checkoutUrl = payUrl;
          _isCheckoutView = true;
          _statusBannerMessage = null;
        });

        _checkoutPollTimer?.cancel();
        _checkoutPollTimer = Timer.periodic(
          const Duration(seconds: 10),
          (_) => _loadStatus(silent: true),
        );
      } else {
        setState(() {
          _isProcessingAction = false;
          _errorMessage =
              l10n.text('messenger.premium.paymentUnavailable');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingAction = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleStopAutoRenewal() async {
    final l10n = XbSubscriptionLocalizations.of(context);
    final apiClient = context.read<ApiClient>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF18181B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.text('messenger.premium.stopConfirmTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            l10n.text('messenger.premium.stopConfirmText'),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                l10n.text('messenger.premium.cancel'),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.text('messenger.premium.confirmStop')),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isProcessingAction = true;
      _statusBannerMessage = l10n.text('messenger.premium.stoppingRenewal');
    });

    try {
      final service = XbSubscriptionService(apiClient);
      final ok = await service.stopAutoRenewal();
      if (!mounted) return;
      setState(() {
        _isProcessingAction = false;
        if (ok) {
          _statusBannerMessage =
              l10n.text('messenger.premium.renewalStopped');
        }
      });
      await _loadStatus(silent: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingAction = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget buildContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final l10n = XbSubscriptionLocalizations.of(context);
    final isDark = context.isDarkTheme;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.xaneoOverlay(0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Brand badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF18181B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.text('messenger.premium.pill'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: Text(
              l10n.text('messenger.premium.title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: context.xaneoTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Center(
            child: Text(
              l10n.text('messenger.premium.lead'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.xaneoTextSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),

          if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (_errorMessage != null) ...[
            _buildMessageBanner(
              text: _errorMessage!,
              color: const Color(0xFFEF4444),
              icon: Icons.error_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 14),
          ],

          if (_statusBannerMessage != null) ...[
            _buildMessageBanner(
              text: _statusBannerMessage!,
              color: isDark ? Colors.white70 : const Color(0xFF374151),
              icon: Icons.info_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 14),
          ],

          if (_status != null && _status!.isActive) ...[
            _buildActiveSubscriptionBanner(l10n, isDark),
            const SizedBox(height: 16),
          ],

          if (_isCheckoutView) ...[
            _buildCheckoutSection(l10n, isDark),
          ] else ...[
            Text(
              l10n.text('messenger.premium.planChoice'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: context.xaneoTextMuted,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildPlanCard(
                    plan: 'month',
                    title: l10n.text('messenger.premium.planMonth'),
                    price: '${_prices['month']} ₽',
                    perPeriod: l10n.text('messenger.premium.perMonth'),
                    note: l10n.text('messenger.premium.planMonthNote'),
                    isSelected: _selectedPlan == 'month',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPlanCard(
                    plan: 'year',
                    title: l10n.text('messenger.premium.planYear'),
                    price: '${_prices['year']} ₽',
                    perPeriod: l10n.text('messenger.premium.perYear'),
                    badge: l10n.text('messenger.premium.planYearBadge'),
                    note: l10n.text('messenger.premium.planYearNote'),
                    isSelected: _selectedPlan == 'year',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.025)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFE4E4E7),
                ),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    icon: Icons.tune_rounded,
                    title: l10n.text('messenger.premium.benefitCustomization'),
                    sub: l10n.text('messenger.premium.benefitCustomizationSub'),
                    isDark: isDark,
                  ),
                  Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    height: 18,
                  ),
                  _buildBenefitRow(
                    icon: Icons.cloud_outlined,
                    title: l10n.text('messenger.premium.benefitUpload'),
                    sub: l10n.text('messenger.premium.benefitUploadSub'),
                    isDark: isDark,
                  ),
                  Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    height: 18,
                  ),
                  _buildBenefitRow(
                    icon: Icons.verified_outlined,
                    title: l10n.text('messenger.premium.benefitStatus'),
                    sub: l10n.text('messenger.premium.benefitStatusSub'),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildActions(l10n, isDark),
          ],

          const SizedBox(height: 12),
          Center(
            child: Text(
              l10n.text('messenger.premium.footnote'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : const Color(0xFFA1A1AA),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String plan,
    required String title,
    required String price,
    required String perPeriod,
    required String note,
    String? badge,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.025)
                  : const Color(0xFFFAFAFA)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF18181B))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE4E4E7)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isDark
                        ? (isSelected ? Colors.white : Colors.white70)
                        : (isSelected
                            ? const Color(0xFF18181B)
                            : const Color(0xFF52525B)),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.45)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF059669).withValues(alpha: 0.35)
                            : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF047857),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF09090B),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  perPeriod,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : const Color(0xFF71717A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              note,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : const Color(0xFF71717A),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String sub,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 15,
              color: isDark ? Colors.white : const Color(0xFF18181B),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : const Color(0xFF71717A),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionBanner(
    XbSubscriptionLocalizations l10n,
    bool isDark,
  ) {
    final status = _status!;
    String dateStr = '';
    if (status.activeUntil != null) {
      final d = status.activeUntil!;
      dateStr =
          '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: Color(0xFF10B981),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.isTestActive
                      ? l10n.text('messenger.premium.sandboxActive')
                      : l10n.text('messenger.premium.renewalEnabled'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.text('messenger.premium.activeUntil',
                        params: {'date': dateStr}),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.xaneoTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    XbSubscriptionLocalizations l10n,
    bool isDark,
  ) {
    final isPaid = _status?.checkoutPaid == true && _status?.isActive == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.xaneoSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.xaneoDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.text('messenger.premium.checkoutTitle'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.xaneoTextPrimary,
                ),
              ),
              if (_status?.checkoutMode == 'sandbox')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    l10n.text('messenger.premium.checkoutSandboxBadge'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.text('messenger.premium.checkoutSubtitle'),
            style: TextStyle(
              fontSize: 12,
              color: context.xaneoTextSecondary,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPaid
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: isPaid
                      ? const Icon(Icons.check,
                          color: Color(0xFF10B981), size: 16)
                      : CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.white70 : const Color(0xFF18181B),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isPaid
                        ? l10n.text('messenger.premium.checkoutPaid')
                        : l10n.text('messenger.premium.checkoutPending'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPaid
                          ? const Color(0xFF10B981)
                          : context.xaneoTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_checkoutUrl != null && !isPaid) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF09090B),
                foregroundColor: isDark ? const Color(0xFF09090B) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final uri = Uri.tryParse(_checkoutUrl!);
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                l10n.text('messenger.premium.payNow'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: isDark ? Colors.white : const Color(0xFF09090B),
              side: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE4E4E7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _loadStatus(),
            child: Text(
              l10n.text('messenger.premium.checkStatus'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),

          TextButton(
            onPressed: () => setState(() => _isCheckoutView = false),
            child: Text(
              l10n.text('messenger.premium.planChoice'),
              style: TextStyle(
                fontSize: 12,
                color: context.xaneoTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    XbSubscriptionLocalizations l10n,
    bool isDark,
  ) {
    final isAutoRenew = _status?.isAutoRenewActive == true;
    final canStop = _status?.canStop == true;

    final buyLabel = _selectedPlan == 'year'
        ? l10n.text('messenger.premium.buyYear')
        : l10n.text('messenger.premium.buy');

    final primaryBg = isDark ? Colors.white : const Color(0xFF09090B);
    final primaryFg = isDark ? const Color(0xFF09090B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBg,
            foregroundColor: primaryFg,
            disabledBackgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.15),
            disabledForegroundColor: isDark
                ? Colors.white38
                : Colors.black38,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isProcessingAction || isAutoRenew ? null : _handleBuy,
          child: _isProcessingAction
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryFg),
                  ),
                )
              : Text(
                  buyLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
        if (canStop) ...[
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: _isProcessingAction ? null : _handleStopAutoRenewal,
            child: Text(
              l10n.text('messenger.premium.stopAutoRenew'),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.white54 : const Color(0xFF71717A),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.text('messenger.premium.later'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBanner({
    required String text,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: context.xaneoTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
