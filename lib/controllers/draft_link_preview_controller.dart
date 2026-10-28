import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/message_links.dart';

/// One draft/scope at a time. Old responses never update a new draft or chat.
class DraftLinkPreviewController extends ChangeNotifier {
  final Future<dynamic> Function(Uri) fetch;
  final Duration debounce;
  DraftLinkPreviewController({
    required this.fetch,
    this.debounce = const Duration(milliseconds: 450),
  });

  Timer? _timer;
  int _generation = 0;
  bool _disposed = false;
  String? _scope;
  String? _key;
  Uri? _url;
  bool _dismissed = false;
  bool _failed = false;
  Map<String, dynamic>? _data;
  Future<Map<String, dynamic>?>? _inFlight;

  String? get scope => _scope;
  Uri? get url => _url;
  Map<String, dynamic>? get data => _data;
  bool get visible => _url != null && !_dismissed && !_failed;
  bool get loading => visible && _data == null;

  void update(String text, {required String scope}) {
    if (_disposed) return;
    final links = findMessageLinks(text);
    final url = links.isEmpty ? null : links.first.uri;
    final key =
        url?.replace(path: url.path.isEmpty ? '/' : url.path).toString();
    if (_scope == scope && _key == key) return;
    _invalidate();
    _scope = scope;
    _key = key;
    _url = url;
    _dismissed = false;
    _failed = false;
    _data = null;
    _inFlight = null;
    if (url != null) _timer = Timer(debounce, _start);
    notifyListeners();
  }

  void _invalidate() {
    _generation++;
    _timer?.cancel();
    _timer = null;
  }

  Future<Map<String, dynamic>?> _start() {
    _timer?.cancel();
    _timer = null;
    if (_disposed || _url == null || _dismissed || _failed) {
      return Future.value(null);
    }
    if (_inFlight != null) return _inFlight!;
    final generation = _generation;
    final future = loadMessageLinkPreview(_url.toString(), fetch);
    _inFlight = future;
    future.then((result) {
      if (_disposed || generation != _generation) return;
      _data = result;
      _failed = result == null;
      notifyListeners();
    });
    return future;
  }

  void dismiss() {
    if (_disposed || !visible) return;
    _invalidate();
    _dismissed = true;
    _data = null;
    _inFlight = null;
    notifyListeners();
  }

  /// Capture before clearing the TextEditingController. The returned future
  /// survives UI reset, reuses an in-flight request and honors dismissal.
  Future<Map<String, dynamic>?> snapshotForSend(
    String text, {
    required String scope,
  }) {
    if (_disposed) return Future.value(null);
    update(text, scope: scope);
    if (_dismissed || _failed || _url == null) return Future.value(null);
    if (_data != null) return Future.value(Map<String, dynamic>.from(_data!));
    return _start();
  }

  void clear({bool notify = true}) {
    if (_disposed) return;
    _invalidate();
    _scope = null;
    _key = null;
    _url = null;
    _data = null;
    _inFlight = null;
    _dismissed = false;
    _failed = false;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _invalidate();
    _disposed = true;
    super.dispose();
  }
}
