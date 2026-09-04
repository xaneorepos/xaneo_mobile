import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../l10n/account_localizations.dart';
import '../../models/auth/recent_account.dart';
import '../../providers/auth_provider.dart';
import '../../styles/app_styles.dart';
import '../../screens/auth/login_screen.dart';
import 'avatar_widget.dart';
import 'base_custom_modal.dart';
import 'chat_context_menu.dart';

class MobileAccountsModal extends BaseCustomModal {
  const MobileAccountsModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show<void>(
      context: context,
      child: const MobileAccountsModal(),
    );
  }

  @override
  State<MobileAccountsModal> createState() => _MobileAccountsModalState();
}

class _MobileAccountsModalState
    extends BaseCustomModalState<MobileAccountsModal> {
  List<RecentAccount> _accounts = const [];
  String? _activeKey;
  String? _busyKey;
  bool _loading = true;
  bool _offline = false;

  @override
  bool get fitContent => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final activeKey = await auth.authService.tokenStorage.getActiveAccountKey();
    final response = await auth.getRecentAccounts();
    if (!mounted) return;
    setState(() {
      _activeKey = activeKey;
      _accounts = response.recentAccounts;
      _offline = !response.success && response.recentAccounts.isNotEmpty;
      _loading = false;
    });
  }

  Future<void> _switch(RecentAccount account) async {
    if (_busyKey != null || account.accountKey == _activeKey) return;
    if (!account.isAvailable) {
      _addAccount();
      return;
    }

    setState(() => _busyKey = account.accountKey);
    final auth = context.read<AuthProvider>();
    final success = await auth.quickLogin(accountKey: account.accountKey);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      return;
    }

    if (auth.requiresTfa || auth.hasPendingQuickLoginTfa) {
      final code = await AccountTfaConfirmationModal.ask(context);
      if (code != null && mounted) {
        final verified = await auth.verifyQuickLoginTfa(code);
        if (verified && mounted) {
          Navigator.of(context).pop();
          return;
        }
      }
    }

    if (!mounted) return;
    final strings = AccountLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.error?.message ?? strings.text('switchFailed')),
      ),
    );
    setState(() => _busyKey = null);
  }

  Future<void> _remove(RecentAccount account) async {
    final strings = AccountLocalizations.of(context);
    final confirmed = await ChatActionConfirmationModal.confirm(
      context: context,
      title: strings.text('remove'),
      message: strings.text('removeConfirm'),
      confirmLabel: strings.text('remove'),
    );
    if (!confirmed || !mounted) return;

    setState(() => _busyKey = account.accountKey);
    try {
      await context.read<AuthProvider>().removeSavedAccount(account.accountKey);
      if (!mounted) return;
      if (account.accountKey == _activeKey) {
        Navigator.of(context).pop();
      } else {
        await _load();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.text('removeFailed'))),
      );
      setState(() => _busyKey = null);
    }
  }

  void _addAccount() {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final strings = AccountLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AccountsHeader(strings: strings),
        if (_offline) ...[
          const SizedBox(height: 10),
          _OfflineNotice(label: strings.text('offline')),
        ],
        const SizedBox(height: 8),
        if (_loading)
          const _AccountSkeleton()
        else if (_accounts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              strings.text('empty'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.xaneoTextMuted,
                fontSize: 14,
              ),
            ),
          )
        else
          _buildAccountsList(scrollController, strings),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addAccount,
            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 14),
            label: Text(strings.text('add')),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsList(
    ScrollController scrollController,
    AccountLocalizations strings,
  ) {
    final viewportLimit = MediaQuery.sizeOf(context).height * 0.46;
    final contentHeight = _accounts.length * 72.0;

    return SizedBox(
      height: math.min(viewportLimit, contentHeight),
      child: ListView.separated(
        controller: scrollController,
        padding: EdgeInsets.zero,
        itemCount: _accounts.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 56,
          color: context.xaneoOverlay(0.07),
        ),
        itemBuilder: (_, index) {
          final account = _accounts[index];
          final active = account.accountKey == _activeKey;
          final busy = account.accountKey == _busyKey;

          return ListTile(
            onTap: () => _switch(account),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            leading: AvatarWidget(
              avatar: account.avatar,
              avatarGradient: account.avatarGradient,
              hasAvatar: account.hasAvatar,
              username: account.username,
              size: 44,
            ),
            title: Text(
              account.firstName?.isNotEmpty == true
                  ? account.firstName!
                  : account.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              account.isAvailable
                  ? '@${account.username}'
                  : strings.text('unavailable'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: account.isAvailable
                    ? context.xaneoTextMuted
                    : const Color(0xFFE0A76B),
              ),
            ),
            trailing: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : active
                    ? Semantics(
                        label: strings.text('current'),
                        child: FaIcon(
                          FontAwesomeIcons.circleCheck,
                          size: 18,
                          color: context.xaneoTextSecondary,
                        ),
                      )
                    : IconButton(
                        onPressed: () => _remove(account),
                        icon: const FaIcon(FontAwesomeIcons.ellipsis, size: 16),
                        tooltip: strings.text('remove'),
                      ),
          );
        },
      ),
    );
  }
}

class _AccountsHeader extends StatelessWidget {
  const _AccountsHeader({required this.strings});

  final AccountLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.text('title'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          strings.text('subtitle'),
          style: TextStyle(
            fontSize: 12,
            color: context.xaneoTextMuted,
          ),
        ),
      ],
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.wifi,
          size: 12,
          color: context.xaneoTextMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.xaneoTextMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountSkeleton extends StatelessWidget {
  const _AccountSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AccountLocalizations.of(context).text('switching'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: context.xaneoOverlay(0.08),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 13,
                    width: 132,
                    decoration: BoxDecoration(
                      color: context.xaneoDivider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 84,
                    decoration: BoxDecoration(
                      color: context.xaneoOverlay(0.055),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountTfaConfirmationModal extends BaseCustomModal {
  const AccountTfaConfirmationModal({super.key});

  static Future<String?> ask(BuildContext context) async {
    final result = await BaseCustomModal.show<String>(
      context: context,
      child: const AccountTfaConfirmationModal(),
      requestFocus: true,
    );
    final code = result?.trim();
    return code?.length == 6 ? code : null;
  }

  @override
  State<AccountTfaConfirmationModal> createState() =>
      _AccountTfaConfirmationModalState();
}

class _AccountTfaConfirmationModalState
    extends BaseCustomModalState<AccountTfaConfirmationModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  bool get fitContent => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final strings = AccountLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.text('tfaTitle'),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(hintText: strings.text('tfaHint')),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.text('cancel')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _submit,
                child: Text(strings.text('verify')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.length != 6) return;
    Navigator.of(context).pop(code);
  }
}
