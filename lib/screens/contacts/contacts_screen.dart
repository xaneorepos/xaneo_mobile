import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/chat/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/api_client.dart';
import '../../services/webrtc/call_manager.dart';
import '../../widgets/common/avatar_widget.dart';
import '../chat/chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<dynamic> _contacts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = context.read<ApiClient>();
      final res = await apiClient.dio.get('/contacts/list/');
      final data = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {};
      final list = data['contacts'] is List ? data['contacts'] as List : [];
      if (mounted) {
        setState(() {
          _contacts = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Не удалось загрузить контакты';
        });
      }
    }
  }

  Future<void> _deleteContact(int contactUserId) async {
    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.dio.post('/contacts/delete/', data: {'user_id': contactUserId});
      _fetchContacts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось удалить контакт: $e')),
        );
      }
    }
  }

  void _showAddContactModal() {
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    bool isSubmitting = false;
    String? addError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF18181B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ДОБАВИТЬ КОНТАКТ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white54,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: usernameCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Никнейм пользователя (@username)',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Отображаемое имя (необязательно)',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    if (addError != null) ...[
                      const SizedBox(height: 8),
                      Text(addError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final un = usernameCtrl.text.trim().replaceAll('@', '');
                                final cn = nameCtrl.text.trim();
                                if (un.isEmpty) return;

                                setModalState(() {
                                  isSubmitting = true;
                                  addError = null;
                                });

                                try {
                                  final apiClient = context.read<ApiClient>();
                                  await apiClient.dio.post('/contacts/create/', data: {
                                    'username': un,
                                    if (cn.isNotEmpty) 'custom_name': cn,
                                  });
                                  if (context.mounted) {
                                    Navigator.of(ctx).pop();
                                    _fetchContacts();
                                  }
                                } catch (e) {
                                  setModalState(() {
                                    isSubmitting = false;
                                    addError = 'Не удалось найти или добавить пользователя';
                                  });
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Text('Добавить', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startCall(dynamic contact) {
    final userId = contact['contact_user_id'] ?? 0;
    final username = contact['contact_user_username']?.toString() ?? '';
    final firstName = contact['contact_user_first_name']?.toString() ?? '';
    final customName = contact['custom_name']?.toString();
    final avatar = contact['custom_avatar'] ?? contact['contact_user_avatar'];
    final gradient = contact['contact_user_avatar_gradient']?.toString();

    final displayName = (customName != null && customName.isNotEmpty)
        ? customName
        : (firstName.isNotEmpty ? firstName : username);

    final authUser = context.read<AuthProvider>().user;
    final callerName = authUser?.firstName ?? authUser?.username ?? 'Я';

    final callManager = context.read<CallManager>();
    callManager.startOutgoingCall(
      targetUserId: userId.toString(),
      targetName: displayName,
      callerName: callerName,
      targetAvatar: avatar?.toString(),
      targetGradient: gradient,
      callType: 'audio',
    );
  }

  void _openChat(dynamic contact) {
    final userId = contact['contact_user_id'] ?? 0;
    final username = contact['contact_user_username']?.toString() ?? '';
    final firstName = contact['contact_user_first_name']?.toString() ?? '';
    final customName = contact['custom_name']?.toString();
    final avatar = contact['custom_avatar'] ?? contact['contact_user_avatar'];
    final gradient = contact['contact_user_avatar_gradient']?.toString();

    final displayName = (customName != null && customName.isNotEmpty)
        ? customName
        : (firstName.isNotEmpty ? firstName : username);

    final chatModel = ChatModel(
      id: userId.toString(),
      name: displayName,
      isPersonal: true,
      avatar: avatar?.toString(),
      avatarGradient: gradient,
      otherUser: {
        'id': userId,
        'username': username,
        'first_name': firstName,
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chat: chatModel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _contacts.where((item) {
      if (_searchQuery.isEmpty) return true;
      final username = (item['contact_user_username'] ?? '').toString().toLowerCase();
      final firstName = (item['contact_user_first_name'] ?? '').toString().toLowerCase();
      final customName = (item['custom_name'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return username.contains(query) || firstName.contains(query) || customName.contains(query);
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Контакты',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.userPlus, color: Colors.white, size: 18),
                  onPressed: _showAddContactModal,
                ),
              ],
            ),
          ),

          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Поиск контактов...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                filled: true,
                fillColor: const Color(0xFF141416),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Список
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _error != null
                    ? Center(
                        child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                      )
                    : filteredContacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.users,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _contacts.isEmpty ? 'Список контактов пуст' : 'Контакты не найдены',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchContacts,
                            color: Colors.white,
                            backgroundColor: const Color(0xFF18181B),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: filteredContacts.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = filteredContacts[index];
                                final userId = item['contact_user_id'] ?? 0;
                                final username = item['contact_user_username']?.toString() ?? '';
                                final firstName = item['contact_user_first_name']?.toString() ?? '';
                                final customName = item['custom_name']?.toString();
                                final avatar = item['custom_avatar'] ?? item['contact_user_avatar'];
                                final gradient = item['contact_user_avatar_gradient']?.toString();

                                final displayName = (customName != null && customName.isNotEmpty)
                                    ? customName
                                    : (firstName.isNotEmpty ? firstName : username);

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141416),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.06),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Аватарка
                                      AvatarWidget(
                                        avatar: avatar?.toString(),
                                        avatarGradient: gradient,
                                        hasAvatar: avatar != null && avatar.toString().isNotEmpty,
                                        username: displayName,
                                        size: 48,
                                      ),
                                      const SizedBox(width: 14),
                                      // Имя и юзернейм
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (username.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                '@$username',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white38,
                                                  fontFamily: 'Inter',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      // Действия: Позвонить, Написать, Вертикальное троеточие (⋮)
                                      IconButton(
                                        icon: const FaIcon(FontAwesomeIcons.phone, size: 15),
                                        color: Colors.white70,
                                        tooltip: 'Позвонить',
                                        onPressed: () => _startCall(item),
                                      ),
                                      IconButton(
                                        icon: const FaIcon(FontAwesomeIcons.comment, size: 15),
                                        color: Colors.white70,
                                        tooltip: 'Написать',
                                        onPressed: () => _openChat(item),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const FaIcon(FontAwesomeIcons.ellipsisVertical, size: 15, color: Colors.white38),
                                        color: const Color(0xFF1E1E22),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        onSelected: (val) {
                                          if (val == 'delete') {
                                            _deleteContact(userId);
                                          }
                                        },
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                                SizedBox(width: 8),
                                                Text('Удалить контакт', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
