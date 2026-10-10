import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xaneo/providers/appearance_provider.dart';
import 'package:xaneo/providers/playback_provider.dart';
import 'package:xaneo/services/chat/chat_local_repository.dart';
import 'package:xaneo/services/database/app_database.dart';
import 'package:xaneo/widgets/common/music_playlist_modal.dart';

class _Repository implements LocalChatRepository {
  int queries = 0;
  int subscriptions = 0;
  int cancellations = 0;

  @override
  Stream<List<Message>> watchMessagesForServerChat(String serverChatId,
      {int? limit}) {
    queries++;
    return StreamController<List<Message>>(
      onListen: () => subscriptions++,
      onCancel: () => cancellations++,
    ).stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Playback extends ChangeNotifier implements PlaybackProvider {
  @override
  List<PlaybackItem> get playlist => const [];
  @override
  String? get currentAudioUrl => null;
  @override
  bool get isPlaying => false;
  @override
  Duration get position => Duration.zero;
  @override
  Duration get duration => Duration.zero;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final duration in [const Duration(milliseconds: 300), Duration.zero]) {
    testWidgets('history waits for opening ($duration) and keeps one stream',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _Repository();
      final playback = _Playback();
      final appearance = AppearanceProvider();
      addTearDown(playback.dispose);
      addTearDown(appearance.dispose);
      late StateSetter rebuildSheet;
      late BuildContext sheetContext;

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AppearanceProvider>.value(value: appearance),
          ChangeNotifierProvider<PlaybackProvider>.value(value: playback),
          Provider<LocalChatRepository>.value(value: repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  sheetAnimationStyle: AnimationStyle(duration: duration),
                  builder: (context) {
                    sheetContext = context;
                    return StatefulBuilder(builder: (context, setState) {
                      rebuildSheet = setState;
                      return MusicPlaylistModal(
                        chatServerId: 'chat_1',
                        initialPlaylist: playback.playlist,
                      );
                    });
                  },
                ),
                child: const Text('Open'),
              );
            }),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pump();
      if (duration != Duration.zero) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(repository.queries, 0);
        expect(repository.subscriptions, 0);
      }
      await tester.pumpAndSettle();
      expect(repository.queries, 1);
      expect(repository.subscriptions, 1);

      rebuildSheet(() {});
      await tester.pumpAndSettle();
      playback.notifyListeners();
      await tester.pump();
      expect(repository.queries, 1);
      expect(repository.subscriptions, 1);

      Navigator.of(sheetContext).pop();
      await tester.pumpAndSettle();
      expect(repository.cancellations, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
