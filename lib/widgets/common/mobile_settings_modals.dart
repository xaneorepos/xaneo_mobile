import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/update/update_service.dart';
import '../../models/update/app_version_info.dart';
import 'base_custom_modal.dart';

// ─── 1. Личные данные (Personal Modal) ───────────────────────────────────────


class MobilePersonalModal extends BaseCustomModal {
  const MobilePersonalModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MobilePersonalModal(),
    );
  }

  @override
  State<MobilePersonalModal> createState() => _MobilePersonalModalState();
}

class _MobilePersonalModalState extends BaseCustomModalState<MobilePersonalModal> {
  @override
  double get initialExtent => 0.70;
  @override
  double get maxExtent => 0.92;

  late TextEditingController _firstNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _bioCtrl;
  bool _isSaving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
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
    try {
      final apiClient = context.read<ApiClient>();
      final res = await apiClient.dio.get('/user/profile/');
      final data = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : null;
      if (data != null && mounted) {
        setState(() {
          _firstNameCtrl.text = data['first_name']?.toString() ?? _firstNameCtrl.text;
          _bioCtrl.text = data['bio']?.toString() ?? _bioCtrl.text;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
      _success = null;
    });
    try {
      final apiClient = context.read<ApiClient>();
      final bio = _bioCtrl.text.trim();
      final firstName = _firstNameCtrl.text.trim();

      final res = await apiClient.dio.patch('/user/profile/', data: {
        'first_name': firstName,
        'bio': bio,
      });

      if (mounted) {
        if (res.statusCode == 200 || res.statusCode == 201) {
          // Обновляем провайдер авторизации
          final auth = context.read<AuthProvider>();
          auth.checkAuthStatus(); // Перезагружаем профиль

          setState(() {
            _isSaving = false;
            _success = 'Данные успешно сохранены';
          });
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.of(context).pop();
          });
        } else {
          setState(() {
            _isSaving = false;
            _error = 'Ошибка при сохранении';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = 'Не удалось сохранить: $e';
        });
      }
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Заголовок
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ЛИЧНЫЕ ДАННЫЕ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildTextField('Имя', _firstNameCtrl, hint: 'Введите ваше имя'),
        const SizedBox(height: 14),

        _buildTextField('Никнейм (@username)', _usernameCtrl, readOnly: true, note: 'Никнейм нельзя изменить'),
        const SizedBox(height: 14),

        _buildTextArea('О себе (Bio)', _bioCtrl, hint: 'Расскажите немного о себе...'),
        const SizedBox(height: 20),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        if (_success != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_success!, style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12)),
          ),

        // Кнопка Сохранить
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Сохранить', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, bool readOnly = false, String? note}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white60)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? Colors.white38 : Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(readOnly ? 0.03 : 0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note, style: const TextStyle(fontSize: 10, color: Colors.white30)),
        ],
      ],
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white60)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 2. Приватность (Privacy Modal) ──────────────────────────────────────────

class MobilePrivacyModal extends BaseCustomModal {
  const MobilePrivacyModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MobilePrivacyModal(),
    );
  }

  @override
  State<MobilePrivacyModal> createState() => _MobilePrivacyModalState();
}

class _MobilePrivacyModalState extends BaseCustomModalState<MobilePrivacyModal> {
  @override
  double get initialExtent => 0.75;
  @override
  double get maxExtent => 0.95;

  String _whoCanMessage = 'all';
  String _whoCanCall = 'all';
  String _whoCanRecordVoice = 'all';
  String _whoCanSendFiles = 'all';
  String _whoCanInvite = 'all';
  String _whoSeesAvatar = 'all';
  String _whoSeesOnlineTime = 'all';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    setState(() => _isLoading = true);
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
          _success = 'Настройки приватности сохранены';
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = 'Ошибка сохранения: $e';
        });
      }
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    const options = [
      ('all', 'Все'),
      ('contacts', 'Контакты'),
      ('nobody', 'Никто'),
    ];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ПРИВАТНОСТЬ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _sectionHeader('КОММУНИКАЦИИ'),
        _buildDropdownRow('Кто может писать', _whoCanMessage, options, (v) => setState(() => _whoCanMessage = v)),
        _buildDropdownRow('Кто может звонить', _whoCanCall, options, (v) => setState(() => _whoCanCall = v)),
        _buildDropdownRow('Запись голосовых', _whoCanRecordVoice, options, (v) => setState(() => _whoCanRecordVoice = v)),
        _buildDropdownRow('Отправка файлов', _whoCanSendFiles, options, (v) => setState(() => _whoCanSendFiles = v)),
        _buildDropdownRow('Приглашать в группы', _whoCanInvite, options, (v) => setState(() => _whoCanInvite = v)),

        const SizedBox(height: 16),
        _sectionHeader('ВИДИМОСТЬ ПРОФИЛЯ'),
        _buildDropdownRow('Кто видит аватар', _whoSeesAvatar, options, (v) => setState(() => _whoSeesAvatar = v)),
        _buildDropdownRow('Время в сети', _whoSeesOnlineTime, options, (v) => setState(() => _whoSeesOnlineTime = v)),

        const SizedBox(height: 20),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        if (_success != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_success!, style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12)),
          ),

        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text('Сохранить', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.white38),
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<(String, String)> options, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                items: options.map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2))).toList(),
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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MobileAppearanceModal(),
    );
  }

  @override
  State<MobileAppearanceModal> createState() => _MobileAppearanceModalState();
}

class _MobileAppearanceModalState extends BaseCustomModalState<MobileAppearanceModal> {
  @override
  double get initialExtent => 0.60;
  @override
  double get maxExtent => 0.85;

  bool _isDark = true;
  double _fontScale = 1.0;
  bool _animations = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDark = prefs.getBool('mobile_dark_mode') ?? true;
        _fontScale = prefs.getDouble('mobile_font_scale') ?? 1.0;
        _animations = prefs.getBool('mobile_animations') ?? true;
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mobile_dark_mode', _isDark);
    await prefs.setDouble('mobile_font_scale', _fontScale);
    await prefs.setBool('mobile_animations', _animations);
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ВНЕШНИЙ ВИД',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _switchRow('Тёмная тема', 'Режим оформления интерфейса', _isDark, (v) {
          setState(() => _isDark = v);
          _save();
        }),
        const SizedBox(height: 14),

        _switchRow('Анимации', 'Показывать визуальные эффекты и переходы', _animations, (v) {
          setState(() => _animations = v);
          _save();
        }),
        const SizedBox(height: 20),

        const Text('Размер текста', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('А', style: TextStyle(fontSize: 12, color: Colors.white38)),
            Expanded(
              child: Slider(
                value: _fontScale,
                min: 0.8,
                max: 1.3,
                divisions: 5,
                activeColor: Colors.white,
                inactiveColor: Colors.white12,
                onChanged: (v) {
                  setState(() => _fontScale = v);
                  _save();
                },
              ),
            ),
            const Text('А', style: TextStyle(fontSize: 20, color: Colors.white38)),
          ],
        ),
      ],
    );
  }

  Widget _switchRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
        ),
      ],
    );
  }
}

// ─── 4. Безопасность (Security Modal) ────────────────────────────────────────

class MobileSecurityModal extends BaseCustomModal {
  const MobileSecurityModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MobileSecurityModal(),
    );
  }

  @override
  State<MobileSecurityModal> createState() => _MobileSecurityModalState();
}

class _MobileSecurityModalState extends BaseCustomModalState<MobileSecurityModal> {
  @override
  double get initialExtent => 0.55;
  @override
  double get maxExtent => 0.80;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'БЕЗОПАСНОСТЬ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
                fontFamily: 'Inter',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _tile(FontAwesomeIcons.shieldHalved, 'Двухфакторная аутентификация', 'Защита аккаунта 2FA', trailing: 'Включено'),
        const SizedBox(height: 10),
        _tile(FontAwesomeIcons.mobileScreen, 'Это устройство', 'Xaneo Mobile • Активно сейчас', trailing: 'Active'),
      ],
    );
  }

  Widget _tile(dynamic icon, String title, String subtitle, {String? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(trailing, style: const TextStyle(fontSize: 10, color: Color(0xFF4ADE80), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

// ─── 5. О приложении и обновления (About Modal) ───────────────────────────────────

class MobileAboutModal extends BaseCustomModal {
  const MobileAboutModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MobileAboutModal(),
    );
  }

  @override
  State<MobileAboutModal> createState() => _MobileAboutModalState();
}

class _MobileAboutModalState extends BaseCustomModalState<MobileAboutModal> {
  @override
  double get initialExtent => 0.55;
  @override
  double get maxExtent => 0.85;

  bool _isChecking = false;
  String? _status;
  AppVersionInfo? _foundUpdate;

  Future<void> _checkUpdate() async {
    setState(() {
      _isChecking = true;
      _status = 'Проверка обновлений...';
      _foundUpdate = null;
    });

    final update = await UpdateService().checkForUpdates(force: true);
    final currentVersion = await UpdateService().getCurrentVersion();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      if (update != null) {
        _foundUpdate = update;
        _status = 'Доступна новая версия v${update.version}!';
      } else {
        _status = 'У вас установлена актуальная версия v$currentVersion';
      }
    });
  }

  @override
  Widget buildModalContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 28),
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
                    'Защищённый мессенджер',
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
                color: isDark ? const Color(0xFF1E212B) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _status!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _foundUpdate != null ? Colors.greenAccent : (isDark ? Colors.white70 : Colors.black70),
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
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh_rounded),
              label: Text(_isChecking ? 'Проверка...' : 'Проверить обновления'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  final uri = Uri.parse(_foundUpdate!.downloadUrl ?? _foundUpdate!.htmlUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.download_rounded),
                label: Text('Загрузить v${_foundUpdate!.version}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.greenAccent,
                  side: const BorderSide(color: Colors.greenAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

