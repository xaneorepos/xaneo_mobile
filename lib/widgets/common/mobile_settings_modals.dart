import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/update/update_service.dart';
import '../../models/update/app_version_info.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import '../../screens/qr_scan_screen.dart';
import '../../services/runtime_translations.dart';
import '../../models/message_color_presets.dart';
import '../../providers/appearance_provider.dart';
import '../../styles/app_styles.dart';
import 'color_picker_modal.dart';
import 'avatar_cropper.dart';
import 'avatar_widget.dart';

// ─── 1. Личные данные (Personal Modal) ───────────────────────────────────────

class MobilePersonalModal extends BaseCustomModal {
  const MobilePersonalModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show(
      context: context,
      child: const MobilePersonalModal(),
    );
  }

  @override
  State<MobilePersonalModal> createState() => _MobilePersonalModalState();
}

class _MobilePersonalModalState
    extends BaseCustomModalState<MobilePersonalModal> {
  @override
  bool get isResizable => false;
  @override
  double get initialExtent => 0.88;

  late TextEditingController _firstNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _bioCtrl;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isDeleting = false;
  String? _avatar;
  File? _localAvatarFile;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _avatar = user?.avatar;
    _loadFreshProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFreshProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    try {
      final apiClient = context.read<ApiClient>();
      final res = await apiClient.dio.get('/user/profile/');
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : null;
      if (data != null && mounted) {
        setState(() {
          _firstNameCtrl.text =
              data['first_name']?.toString() ?? _firstNameCtrl.text;
          _usernameCtrl.text =
              data['username']?.toString() ?? _usernameCtrl.text;
          _bioCtrl.text = data['bio']?.toString() ?? _bioCtrl.text;
          _avatar = data['avatar']?.toString() ?? _avatar;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isSaving = true;
      _error = null;
      _success = null;
    });
    try {
      final apiClient = context.read<ApiClient>();
      final bio = _bioCtrl.text.trim();
      final firstName = _firstNameCtrl.text.trim();
      final username = _usernameCtrl.text.trim().replaceFirst('@', '');

      if (!RegExp(r'^[a-zA-Z0-9._-]{3,30}$').hasMatch(username)) {
        throw StateError(l10n.invalidNicknameFormat);
      }

      final res = await apiClient.dio.patch('/user/profile/', data: {
        'first_name': firstName,
        'username': username,
        'bio': bio,
      });

      if (mounted) {
        if (res.statusCode == 200 || res.statusCode == 201) {
          // Обновляем провайдер авторизации
          final auth = context.read<AuthProvider>();
          final profile = Map<String, dynamic>.from(res.data as Map);
          await auth.updateCurrentUser(profile);

          setState(() {
            _isSaving = false;
            _success =
                (AppLocalizations.of(context)?.dannyeUspeshnoSohraneny_2cc5 ??
                    'Fallback');
          });
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.of(context).pop();
          });
        } else {
          setState(() {
            _isSaving = false;
            _error = (AppLocalizations.of(context)?.oshibkaPriSohranenii_126f ??
                'Fallback');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = _requestMessage(
            e,
            AppLocalizations.of(context)?.oshibkaPriSohranenii_126f ??
                'Ошибка сохранения',
          );
        });
      }
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Заголовок
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.personalData,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.xaneoTextMuted,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: context.xaneoTextMuted, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildAvatarEditor(),
        const SizedBox(height: 18),

        _buildTextField(l10n.yourName, _firstNameCtrl, hint: l10n.yourName),
        const SizedBox(height: 14),

        _buildTextField(l10n.nickname, _usernameCtrl, hint: '@username'),
        const SizedBox(height: 14),

        _buildTextArea(l10n.aboutMe, _bioCtrl, hint: l10n.aboutMeHint),
        const SizedBox(height: 20),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        if (_success != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_success!,
                style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12)),
          ),

        // Кнопка Сохранить
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.xaneoTextPrimary,
            foregroundColor: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.xaneoTextPrimary),
                )
              : Text(l10n.save,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _isDeleting ? null : _confirmDeleteAccount,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: BorderSide(
              color: Colors.redAccent.withValues(alpha: 0.45),
            ),
          ),
          icon: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline_rounded, size: 19),
          label: Text(l10n.deleteAccount),
        ),
      ],
    );
  }

  Widget _buildAvatarEditor() {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (_localAvatarFile != null)
                ClipOval(
                  child: Image.file(
                    _localAvatarFile!,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                  ),
                )
              else
                AvatarWidget(
                  avatar: _avatar,
                  avatarGradient: user?.avatarGradient,
                  hasAvatar: _avatar?.isNotEmpty == true,
                  username: _firstNameCtrl.text.isNotEmpty
                      ? _firstNameCtrl.text
                      : (user?.username ?? '?'),
                  size: 82,
                ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Material(
                  color: context.xaneoTextPrimary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isUploadingAvatar ? null : _pickAvatar,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: _isUploadingAvatar
                          ? Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.xaneoSurface,
                              ),
                            )
                          : Icon(
                              Icons.camera_alt_rounded,
                              color: context.xaneoSurface,
                              size: 17,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isUploadingAvatar ? null : _pickAvatar,
            child: Text(l10n.changePhoto),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picked = await file_picker.FilePicker.pickFiles(
        type: file_picker.FileType.image,
        allowMultiple: false,
      );
      final path = picked?.files.single.path;
      if (path == null || !mounted) return;
      final cropped = await AvatarCropper.show(context, File(path));
      if (cropped == null || !mounted) return;

      setState(() {
        _isUploadingAvatar = true;
        _error = null;
      });
      final apiClient = context.read<ApiClient>();
      final auth = context.read<AuthProvider>();
      final fileName = cropped.path.split(Platform.pathSeparator).last;
      final form = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          cropped.path,
          filename: fileName,
        ),
      });
      final response = await apiClient.dio.post(
        '/user/upload-avatar/',
        data: form,
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final avatar = data['avatar_url']?.toString();
      if (!mounted) return;
      await auth.updateCurrentUser(data);
      if (!mounted) return;
      setState(() {
        _avatar = avatar ?? _avatar;
        _localAvatarFile = cropped;
        _isUploadingAvatar = false;
        _success = l10n.avatarUpdated;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isUploadingAvatar = false;
        _error = _requestMessage(error, l10n.avatarUploadFailed);
      });
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final password = await MobileDeleteAccountConfirmModal.show(context);
    if (password == null || password.isEmpty || !mounted) return;

    setState(() {
      _isDeleting = true;
      _error = null;
    });
    try {
      final response = await context.read<ApiClient>().dio.post(
        '/user/delete-account/',
        data: {'password': password},
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{};
      if (response.statusCode != 200 || data['success'] != true) {
        throw StateError(
          data['error']?.toString() ?? l10n.deleteAccountFailed,
        );
      }
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      Navigator.of(context).pop();
      await auth.logout();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _error = _requestMessage(error, l10n.deleteAccountFailed);
      });
    }
  }

  String _requestMessage(Object error, String fallback) {
    if (error is DioException && error.response?.data is Map) {
      final data = Map<String, dynamic>.from(error.response!.data as Map);
      final detail = data['error'] ?? data['detail'] ?? data['username'];
      if (detail is List && detail.isNotEmpty) return detail.first.toString();
      if (detail != null) return detail.toString();
    }
    if (error is StateError) return error.message.toString();
    return fallback;
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint, bool readOnly = false, String? note}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.xaneoTextSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(
              color:
                  readOnly ? context.xaneoTextMuted : context.xaneoTextPrimary,
              fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.xaneoTextMuted, fontSize: 13),
            filled: true,
            fillColor: context.xaneoOverlay(readOnly ? 0.03 : 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoDivider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoDivider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoTextMuted, width: 1.5),
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note,
              style: TextStyle(fontSize: 10, color: context.xaneoTextMuted)),
        ],
      ],
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.xaneoTextSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: context.xaneoTextPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.xaneoTextMuted, fontSize: 13),
            filled: true,
            fillColor: context.xaneoOverlay(0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoDivider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoDivider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoTextMuted, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class MobileDeleteAccountConfirmModal extends BaseCustomModal {
  const MobileDeleteAccountConfirmModal({super.key});

  static Future<String?> show(BuildContext context) {
    return BaseCustomModal.show<String>(
      context: context,
      child: const MobileDeleteAccountConfirmModal(),
    );
  }

  @override
  State<MobileDeleteAccountConfirmModal> createState() =>
      _MobileDeleteAccountConfirmModalState();
}

class _MobileDeleteAccountConfirmModalState
    extends BaseCustomModalState<MobileDeleteAccountConfirmModal> {
  final _passwordController = TextEditingController();

  @override
  bool get isResizable => false;

  @override
  double get initialExtent => 0.52;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${l10n.deleteAccount}?',
                style: TextStyle(
                  color: context.xaneoTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close_rounded, color: context.xaneoTextMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.deleteAccountPrompt,
          style: TextStyle(color: context.xaneoTextSecondary, height: 1.4),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _passwordController,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.password),
          onSubmitted: _submit,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () => _submit(_passwordController.text),
                style:
                    FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text(l10n.delete),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit(String value) {
    final password = value.trim();
    if (password.isNotEmpty) Navigator.of(context).pop(password);
  }
}

// ─── 2. Приватность (Privacy Modal) ──────────────────────────────────────────

class MobilePrivacyModal extends BaseCustomModal {
  const MobilePrivacyModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show(
      context: context,
      child: const MobilePrivacyModal(),
    );
  }

  @override
  State<MobilePrivacyModal> createState() => _MobilePrivacyModalState();
}

class _MobilePrivacyModalState
    extends BaseCustomModalState<MobilePrivacyModal> {
  @override
  bool get isResizable => false;
  @override
  double get initialExtent => 0.75;

  String _whoCanMessage = 'all';
  String _whoCanCall = 'all';
  String _whoCanRecordVoice = 'all';
  String _whoCanSendFiles = 'all';
  String _whoCanInvite = 'all';
  String _whoSeesAvatar = 'all';
  String _whoSeesOnlineTime = 'all';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    try {
      final apiClient = context.read<ApiClient>();
      final res = await apiClient.dio.get('/user/privacy-settings/');
      final d = res.data?['privacy_settings'] ?? res.data ?? {};
      if (mounted) {
        setState(() {
          _whoCanMessage = d['who_can_message'] ?? 'all';
          _whoCanCall = d['who_can_call'] ?? 'all';
          _whoCanRecordVoice = d['who_can_record_voice'] ?? 'all';
          _whoCanSendFiles = d['who_can_send_files'] ?? 'all';
          _whoCanInvite = d['who_can_invite'] ?? 'all';
          _whoSeesAvatar = d['who_sees_avatar'] ?? 'all';
          _whoSeesOnlineTime = d['who_sees_online_time'] ?? 'all';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
      _success = null;
    });
    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.dio.patch('/user/privacy-settings/', data: {
        'who_can_message': _whoCanMessage,
        'who_can_call': _whoCanCall,
        'who_can_record_voice': _whoCanRecordVoice,
        'who_can_send_files': _whoCanSendFiles,
        'who_can_invite': _whoCanInvite,
        'who_sees_avatar': _whoSeesAvatar,
        'who_sees_online_time': _whoSeesOnlineTime,
      });

      if (mounted) {
        setState(() {
          _isSaving = false;
          _success = (AppLocalizations.of(context)
                  ?.nastroykiPrivatnostiSohraneny_447c ??
              'Fallback');
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error =
              '${AppLocalizations.of(context)?.oshibkaSohraneniya_0387 ?? 'Save error'}: $e';
        });
      }
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.xaneoTextPrimary),
      );
    }

    var options = [
      ('all', (AppLocalizations.of(context)?.vse_984b ?? 'Fallback')),
      ('contacts', (AppLocalizations.of(context)?.kontakty_7576 ?? 'Fallback')),
      ('nobody', (AppLocalizations.of(context)?.nikto_ba19 ?? 'Fallback')),
    ];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (AppLocalizations.of(context)?.privatnost_3098 ?? 'Fallback'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.xaneoTextMuted,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: context.xaneoTextMuted, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionHeader(
            (AppLocalizations.of(context)?.kommunikatsii_e9b8 ?? 'Fallback')),
        _buildDropdownRow(
            (AppLocalizations.of(context)?.ktoMozhetPisat_3322 ?? 'Fallback'),
            _whoCanMessage,
            options,
            (v) => setState(() => _whoCanMessage = v)),
        _buildDropdownRow(
            (AppLocalizations.of(context)?.ktoMozhetZvonit_c427 ?? 'Fallback'),
            _whoCanCall,
            options,
            (v) => setState(() => _whoCanCall = v)),
        _buildDropdownRow(
            (AppLocalizations.of(context)?.zapisGolosovyh_8073 ?? 'Fallback'),
            _whoCanRecordVoice,
            options,
            (v) => setState(() => _whoCanRecordVoice = v)),
        _buildDropdownRow(
            (AppLocalizations.of(context)?.otpravkaFaylov_aaca ?? 'Fallback'),
            _whoCanSendFiles,
            options,
            (v) => setState(() => _whoCanSendFiles = v)),
        _buildDropdownRow(
            (AppLocalizations.of(context)?.priglashatVGruppy_3631 ??
                'Fallback'),
            _whoCanInvite,
            options,
            (v) => setState(() => _whoCanInvite = v)),
        const SizedBox(height: 16),
        _sectionHeader((AppLocalizations.of(context)?.vidimostProfilya_448f ??
            'Fallback')),
        _buildDropdownRow(
            (AppLocalizations.of(context)?.ktoViditAvatar_b5d8 ?? 'Fallback'),
            _whoSeesAvatar,
            options,
            (v) => setState(() => _whoSeesAvatar = v)),
        _buildDropdownRow(
            (AppLocalizations.of(context)?.vremyaVSeti_be29 ?? 'Fallback'),
            _whoSeesOnlineTime,
            options,
            (v) => setState(() => _whoSeesOnlineTime = v)),
        const SizedBox(height: 20),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        if (_success != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_success!,
                style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12)),
          ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.xaneoTextPrimary,
            foregroundColor: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.xaneoSurface),
                )
              : Text(
                  (AppLocalizations.of(context)?.sohranit_74ea ?? 'Fallback'),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.xaneoTextMuted),
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value,
      List<(String, String)> options, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 13, color: context.xaneoTextSecondary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.xaneoOverlay(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.xaneoDivider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                dropdownColor: context.xaneoSurfaceElevated,
                style: TextStyle(
                    fontSize: 12,
                    color: context.xaneoTextPrimary,
                    fontWeight: FontWeight.w500),
                items: options
                    .map(
                        (o) => DropdownMenuItem(value: o.$1, child: Text(o.$2)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3. Внешний вид (Appearance Modal) ───────────────────────────────────────

class MobileAppearanceModal extends BaseCustomModal {
  const MobileAppearanceModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show(
      context: context,
      child: const MobileAppearanceModal(),
    );
  }

  @override
  State<MobileAppearanceModal> createState() => _MobileAppearanceModalState();
}

class _MobileAppearanceModalState
    extends BaseCustomModalState<MobileAppearanceModal> {
  @override
  bool get isResizable => false;
  @override
  double get initialExtent => 0.92;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    final appearance = context.watch<AppearanceProvider>();
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (AppLocalizations.of(context)?.vneshniyVid_5a0f ?? 'Fallback'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.xaneoTextMuted,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: context.xaneoTextMuted, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _switchRow(
            context,
            (AppLocalizations.of(context)?.temnayaTema_cb48 ?? 'Fallback'),
            (AppLocalizations.of(context)?.rezhimOformleniyaInterfeysa_b91d ??
                'Fallback'),
            appearance.isDarkMode,
            appearance.setDarkMode),
        SizedBox(height: 14),
        _switchRow(
            context,
            (AppLocalizations.of(context)?.animatsii_05c7 ?? 'Fallback'),
            (AppLocalizations.of(context)
                    ?.pokazyvatVizualnyeEffektyIPerehody_3fd7 ??
                'Fallback'),
            appearance.animationsEnabled,
            appearance.setAnimationsEnabled),
        SizedBox(height: 20),
        Text(l10n.chatFontSize,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.xaneoTextSecondary)),
        const SizedBox(height: 6),
        Row(
          children: [
            Text((AppLocalizations.of(context)?.a_87a0 ?? 'Fallback'),
                style: TextStyle(fontSize: 12, color: context.xaneoTextMuted)),
            Expanded(
              child: Slider(
                value: appearance.chatFontSize,
                min: AppearanceProvider.minFontSize,
                max: AppearanceProvider.maxFontSize,
                divisions: (AppearanceProvider.maxFontSize -
                        AppearanceProvider.minFontSize)
                    .round(),
                activeColor: context.xaneoTextPrimary,
                inactiveColor: context.xaneoDivider,
                onChanged: appearance.setChatFontSize,
              ),
            ),
            Text('${appearance.chatFontSize.round()} px',
                style: TextStyle(fontSize: 12, color: context.xaneoTextMuted)),
          ],
        ),
        const SizedBox(height: 24),
        _buildWallpaperPicker(context, appearance),
        const SizedBox(height: 24),
        _buildMessageColorPicker(context, appearance, isMe: true),
        const SizedBox(height: 24),
        _buildMessageColorPicker(context, appearance, isMe: false),
        const SizedBox(height: 24),
        _buildNotificationStylePicker(context, appearance),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: context.xaneoTextMuted,
        ),
      ),
    );
  }

  Widget _buildWallpaperPicker(
    BuildContext context,
    AppearanceProvider appearance,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final presets = <WallpaperPresetId, Widget>{
      WallpaperPresetId.defaultWp: Container(color: const Color(0xFF0C0C0E)),
      WallpaperPresetId.blue: Container(
        decoration: BoxDecoration(gradient: kWallpaperGradients['blue']),
      ),
      WallpaperPresetId.green: Container(
        decoration: BoxDecoration(gradient: kWallpaperGradients['green']),
      ),
      WallpaperPresetId.purple: Container(
        decoration: BoxDecoration(gradient: kWallpaperGradients['purple']),
      ),
      WallpaperPresetId.dark: Container(color: const Color(0xFF1A1A1A)),
      WallpaperPresetId.gradient: Container(
        decoration: BoxDecoration(gradient: kWallpaperGradients['gradient']),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, l10n.chatWallpaper),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...presets.entries.map(
              (entry) => _swatch(
                selected: appearance.wallpaper.preset == entry.key,
                onTap: () => appearance.setWallpaperPreset(entry.key),
                child: entry.value,
              ),
            ),
            _swatch(
              selected: appearance.wallpaper.preset == WallpaperPresetId.custom,
              onTap: () => _pickCustomWallpaper(context, appearance),
              child: appearance.wallpaper.preset == WallpaperPresetId.custom &&
                      appearance.wallpaper.customImagePath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(appearance.wallpaper.customImagePath!),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 3,
                          right: 3,
                          child: GestureDetector(
                            onTap: appearance.removeCustomWallpaper,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.close,
                                  color: context.xaneoTextPrimary,
                                  size: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      Icons.add_photo_alternate_outlined,
                      color: context.xaneoTextMuted,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickCustomWallpaper(
    BuildContext context,
    AppearanceProvider appearance,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await file_picker.FilePicker.pickFiles(
        type: file_picker.FileType.image,
        allowMultiple: false,
      );
      final path = result?.files.single.path;
      if (path != null) {
        await appearance.setCustomWallpaperFromPickedFile(path);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.wallpaperUploadFailed}: $error'),
        ),
      );
    }
  }

  Widget _swatch({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 160),
        width: 48,
        height: 48,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.xaneoOverlay(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? context.xaneoTextPrimary : context.xaneoDivider,
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildMessageColorPicker(
    BuildContext context,
    AppearanceProvider appearance, {
    required bool isMe,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final solids = isMe ? kMyMessageSolidPresets : kOtherMessageSolidPresets;
    final gradients =
        isMe ? kMyMessageGradientPresets : kOtherMessageGradientPresets;
    final fallback =
        isMe ? kMyMessageDefaultCustomSolid : kOtherMessageDefaultCustomSolid;
    final current =
        isMe ? appearance.myMessageColor : appearance.otherMessageColor;

    void apply(MessageColorSetting value) {
      if (isMe) {
        appearance.setMyMessageColor(value);
      } else {
        appearance.setOtherMessageColor(value);
      }
    }

    Widget preset(String id, Widget child) => _swatch(
          selected: current.presetId == id,
          onTap: () => apply(MessageColorSetting(presetId: id)),
          child: child,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
            context, isMe ? l10n.myMessageColor : l10n.otherMessageColor),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            preset('default', Container(color: context.xaneoOverlay(0.10))),
            ...solids.entries.map(
              (entry) => preset(entry.key, Container(color: entry.value)),
            ),
            ...gradients.entries.map(
              (entry) => preset(
                entry.key,
                Container(decoration: BoxDecoration(gradient: entry.value)),
              ),
            ),
            _swatch(
              selected: current.presetId == 'custom',
              onTap: () async {
                final color = await MobileColorPickerModal.pick(
                  context: context,
                  initial: _resolvedColor(
                    current,
                    solids,
                    gradients,
                    fallback,
                  ),
                );
                if (color != null) {
                  apply(MessageColorSetting(
                    presetId: 'custom',
                    customSolid: color,
                  ));
                }
              },
              child: current.presetId == 'custom' && current.customSolid != null
                  ? Container(color: current.customSolid)
                  : Icon(Icons.colorize_rounded, color: context.xaneoTextMuted),
            ),
            _swatch(
              selected: current.presetId == 'custom-gradient',
              onTap: () async {
                final gradient = await MobileGradientPickerModal.pick(
                  context: context,
                  initial: _resolvedGradient(
                    current,
                    solids,
                    gradients,
                    fallback,
                  ),
                );
                if (gradient != null) {
                  apply(MessageColorSetting(
                    presetId: 'custom-gradient',
                    customGradient: gradient,
                  ));
                }
              },
              child: current.presetId == 'custom-gradient' &&
                      current.customGradient != null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: current.customGradient!.toLinearGradient(),
                      ),
                    )
                  : Icon(Icons.gradient_rounded, color: context.xaneoTextMuted),
            ),
          ],
        ),
      ],
    );
  }

  Color _resolvedColor(
    MessageColorSetting current,
    Map<String, Color> solids,
    Map<String, LinearGradient> gradients,
    Color fallback,
  ) {
    final value = current.resolve(
      solidPresets: solids,
      gradientPresets: gradients,
      defaultCustomSolid: fallback,
    );
    return value.solidColor ?? value.gradient?.colors.first ?? fallback;
  }

  GradientSpec _resolvedGradient(
    MessageColorSetting current,
    Map<String, Color> solids,
    Map<String, LinearGradient> gradients,
    Color fallback,
  ) {
    final value = current.resolve(
      solidPresets: solids,
      gradientPresets: gradients,
      defaultCustomSolid: fallback,
    );
    final gradient = value.gradient;
    if (gradient != null) {
      return GradientSpec(
        color1: gradient.colors.first,
        color2: gradient.colors.last,
      );
    }
    final color = value.solidColor ?? fallback;
    return GradientSpec(
      color1: color,
      color2: gradients.values.first.colors.last,
    );
  }

  Widget _buildNotificationStylePicker(
    BuildContext context,
    AppearanceProvider appearance,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, l10n.notificationStyle),
        RadioListTile<NotificationStyle>(
          value: NotificationStyle.standard,
          groupValue: appearance.notificationStyle,
          onChanged: (value) {
            if (value != null) appearance.setNotificationStyle(value);
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.standardNotificationStyle),
        ),
        RadioListTile<NotificationStyle>(
          value: NotificationStyle.raven,
          groupValue: appearance.notificationStyle,
          onChanged: (value) {
            if (value != null) appearance.setNotificationStyle(value);
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.blackRavenNotificationStyle),
        ),
      ],
    );
  }

  Widget _switchRow(BuildContext context, String title, String subtitle,
      bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.xaneoTextPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      TextStyle(fontSize: 11, color: context.xaneoTextMuted)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: context.xaneoTextPrimary,
        ),
      ],
    );
  }
}

// ─── 4. Безопасность (Security Modal) ────────────────────────────────────────

class MobileSecurityModal extends BaseCustomModal {
  const MobileSecurityModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show(
      context: context,
      child: const MobileSecurityModal(),
    );
  }

  @override
  State<MobileSecurityModal> createState() => _MobileSecurityModalState();
}

class _MobileSecurityModalState
    extends BaseCustomModalState<MobileSecurityModal> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = true;
  bool _isBusy = false;
  bool _tfaEnabled = false;
  String? _pendingTfaAction;
  String? _error;
  String? _success;
  List<Map<String, dynamic>> _sessions = const [];

  @override
  bool get isResizable => false;
  @override
  double get initialExtent => 0.75;

  @override
  void initState() {
    super.initState();
    _loadSecurity();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _text(String ru, String en) {
    if (RuntimeTranslations.instance.hasActiveCustomPack) {
      return RuntimeTranslations.instance.resolveByText(ru);
    }
    return Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
  }

  String _requestError(Object error) {
    if (error is DioException && error.response?.data is Map) {
      final data = Map<String, dynamic>.from(error.response!.data as Map);
      return data['error']?.toString() ??
          data['message']?.toString() ??
          (AppLocalizations.of(context)?.serverError ?? 'Server error');
    }
    return AppLocalizations.of(context)?.serverError ?? 'Server error';
  }

  Future<void> _loadSecurity() async {
    try {
      final response = await context.read<ApiClient>().get('/security/');
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _tfaEnabled = data['tfa_enabled'] == true;
        _sessions = (data['sessions'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.of(context)?.serverError ?? 'Server error';
      });
    }
  }

  Future<void> _requestTfaCode() async {
    final action = _tfaEnabled ? 'disable' : 'enable';
    setState(() {
      _isBusy = true;
      _error = null;
      _success = null;
    });
    try {
      final response = await context.read<ApiClient>().post(
        '/security/tfa/send-code/',
        data: {'action': action},
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (!mounted) return;
      if (data['success'] == true) {
        setState(() {
          _pendingTfaAction = action;
          _success = AppLocalizations.of(context)?.codeSent ??
              _text('Код отправлен на email', 'Code sent to email');
        });
      } else {
        setState(() => _error = data['error']?.toString() ??
            (AppLocalizations.of(context)?.sendCodeError ??
                _text('Ошибка отправки кода', 'Failed to send code')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = _requestError(e));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmTfa() async {
    final action = _pendingTfaAction;
    final code = _codeController.text.trim();
    if (action == null || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = _text(
          'Введите корректный 6-значный код', 'Enter a valid 6-digit code'));
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final response = await context.read<ApiClient>().post(
        '/security/tfa/confirm/',
        data: {'action': action, 'code': code},
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (!mounted) return;
      if (data['success'] == true) {
        _codeController.clear();
        setState(() {
          _tfaEnabled = action == 'enable';
          _pendingTfaAction = null;
          _success = data['message']?.toString() ??
              _text('Настройки 2FA обновлены', '2FA settings updated');
        });
        context.read<AuthProvider>().checkAuthStatus();
      } else {
        setState(() => _error =
            data['error']?.toString() ?? _text('Неверный код', 'Invalid code'));
      }
    } catch (e) {
      if (mounted) setState(() => _error = _requestError(e));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _terminateSession(int id) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final response =
          await context.read<ApiClient>().delete('/security/sessions/$id/');
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (!mounted) return;
      if (data['success'] == true) {
        setState(() => _sessions.removeWhere((item) => item['id'] == id));
      } else {
        setState(() => _error = data['error']?.toString() ??
            _text(
                'Не удалось завершить сессию', 'Failed to terminate session'));
      }
    } catch (e) {
      if (mounted) setState(() => _error = _requestError(e));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (AppLocalizations.of(context)?.bezopasnost_fcbc ?? 'Fallback'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.xaneoTextMuted,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: context.xaneoTextMuted, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          _tile(
            FontAwesomeIcons.shieldHalved,
            l10n?.twoFactorAuth ??
                _text('Двухфакторная аутентификация',
                    'Two-factor authentication'),
            l10n?.twoFactorAuthDesc ??
                _text('Защита аккаунта одноразовым кодом',
                    'Protect your account with a one-time code'),
            action: Switch.adaptive(
              value: _tfaEnabled,
              onChanged: _isBusy ? null : (_) => _requestTfaCode(),
              activeThumbColor: const Color(0xFF4ADE80),
              activeTrackColor: const Color(0x734ADE80),
            ),
          ),
          const SizedBox(height: 12),
          _tile(
            FontAwesomeIcons.qrcode,
            l10n?.qrScanTitle ??
                _text('Авторизация устройства', 'Device Authorization'),
            l10n?.qrScanSubtitle ??
                _text(
                    'Наведите камеру на QR-код на экране веб-версии или ПК-клиента Xaneo',
                    'Point your camera at the QR code on the Xaneo web or PC client screen'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrScanScreen()),
              );
            },
            action: Icon(Icons.arrow_forward_ios_rounded,
                color: context.xaneoTextPrimary, size: 16),
          ),
          if (_pendingTfaAction != null) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              enabled: !_isBusy,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(letterSpacing: 8, fontSize: 20),
              decoration: InputDecoration(
                counterText: '',
                labelText: l10n?.kodPodtverzhdeniya_1c9d ??
                    _text('Код подтверждения', 'Verification code'),
                suffixIcon: IconButton(
                  onPressed: _isBusy ? null : _confirmTfa,
                  icon: const Icon(Icons.check_rounded),
                ),
              ),
              onSubmitted: (_) => _confirmTfa(),
            ),
          ],
          if (_error != null || _success != null) ...[
            const SizedBox(height: 10),
            Text(
              _error ?? _success!,
              style: TextStyle(
                color:
                    _error != null ? Colors.redAccent : const Color(0xFF4ADE80),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(
            l10n?.activeSessions ?? _text('Активные сессии', 'Active sessions'),
            style: TextStyle(
                color: context.xaneoTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (_sessions.isEmpty)
            Text(_text('Нет активных сессий', 'No active sessions'),
                style: TextStyle(color: context.xaneoTextMuted))
          else
            ..._sessions.map(_sessionTile),
        ],
      ],
    );
  }

  Widget _sessionTile(Map<String, dynamic> session) {
    final current = session['is_current'] == true;
    final agent = session['user_agent']?.toString() ??
        _text('Неизвестное устройство', 'Unknown device');
    final ip = session['ip_address']?.toString() ?? '—';
    final id = (session['id'] as num?)?.toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _tile(
        agent.toLowerCase().contains('mobile')
            ? FontAwesomeIcons.mobileScreen
            : FontAwesomeIcons.desktop,
        current
            ? (AppLocalizations.of(context)?.thisDevice ??
                _text('Это устройство', 'This device'))
            : agent,
        current ? '$agent • $ip' : ip,
        trailing: current
            ? (AppLocalizations.of(context)?.activeNow ??
                _text('Активно', 'Active'))
            : null,
        trailingEnabled: true,
        action: !current && id != null
            ? IconButton(
                tooltip: AppLocalizations.of(context)?.zavershit_b0e3 ??
                    _text('Завершить', 'Terminate'),
                onPressed: _isBusy ? null : () => _terminateSession(id),
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 19),
              )
            : null,
      ),
    );
  }

  Widget _tile(dynamic icon, String title, String subtitle,
      {String? trailing,
      bool trailingEnabled = true,
      VoidCallback? onTap,
      Widget? action}) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.xaneoOverlay(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.xaneoDivider),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 16, color: context.xaneoTextSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.xaneoTextPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 11, color: context.xaneoTextMuted)),
              ],
            ),
          ),
          if (action != null)
            action
          else if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (trailingEnabled
                        ? const Color(0xFF4ADE80)
                        : context.xaneoTextMuted)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(trailing,
                  style: TextStyle(
                      fontSize: 10,
                      color: trailingEnabled
                          ? const Color(0xFF4ADE80)
                          : context.xaneoTextMuted,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }
}

// ─── 5. О приложении и обновления (About Modal) ───────────────────────────────────

class MobileAboutModal extends BaseCustomModal {
  const MobileAboutModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show(
      context: context,
      child: const MobileAboutModal(),
    );
  }

  @override
  State<MobileAboutModal> createState() => _MobileAboutModalState();
}

class _MobileAboutModalState extends BaseCustomModalState<MobileAboutModal> {
  @override
  bool get isResizable => false;
  @override
  double get initialExtent => 0.55;

  bool _isChecking = false;
  String? _status;
  AppVersionInfo? _foundUpdate;

  Future<void> _checkUpdate() async {
    setState(() {
      _isChecking = true;
      _status =
          (AppLocalizations.of(context)?.proverkaObnovleniy_f3e0 ?? 'Fallback');
      _foundUpdate = null;
    });

    final update = await UpdateService().checkForUpdates(force: true);
    final currentVersion = await UpdateService().getCurrentVersion();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      if (update != null) {
        _foundUpdate = update;
        _status =
            '${AppLocalizations.of(context)?.newVersionAvailableTitle ?? 'New version available'} v${update.version}!';
      } else {
        _status =
            '${AppLocalizations.of(context)?.youHaveLatestVersion ?? 'You have the latest version'} v$currentVersion';
      }
    });
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2563EB).withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF2563EB), size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xaneo Mobile v2',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    (AppLocalizations.of(context)
                            ?.zaschischennyyMessendzher_2f59 ??
                        'Fallback'),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_status != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E212B) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _status!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _foundUpdate != null
                      ? Colors.greenAccent
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkUpdate,
              icon: _isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh_rounded),
              label: Text(_isChecking
                  ? (AppLocalizations.of(context)?.proverka_13bc ?? 'Fallback')
                  : (AppLocalizations.of(context)?.proveritObnovleniya_ab45 ??
                      'Fallback')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (_foundUpdate != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(
                      _foundUpdate!.downloadUrl ?? _foundUpdate!.htmlUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.download_rounded),
                label: Text(
                    '${AppLocalizations.of(context)?.downloadVersion ?? 'Download'} v${_foundUpdate!.version}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.greenAccent,
                  side: const BorderSide(color: Colors.greenAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
