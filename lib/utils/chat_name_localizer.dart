import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../models/chat/chat_model.dart';

/// System chat names come from the API and must not be treated as user content.
String localizedChatName(BuildContext context, ChatModel chat) {
  if (!chat.isFavorites) return chat.name;
  return AppLocalizations.of(context)?.savedMessages ?? 'Saved Messages';
}
