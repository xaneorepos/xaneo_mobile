import 'message_link_tlds.dart';

class MessageLink {
  final int start;
  final int end;
  final String text;
  final Uri uri;
  const MessageLink(this.start, this.end, this.text, this.uri);
}

const _letter =
    r'a-z0-9\u00c0-\u02ff\u0370-\u052f\u0590-\u06ff\u0900-\u0fff\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af';
const _domain = '[$_letter](?:[$_letter-]*[$_letter])?';
final _candidate = RegExp(
  'https?://[^\\s<>"`]+|(?:$_domain\\.)+$_domain(?::[0-9]{1,5})?(?:[/?#][^\\s<>"`]*)?',
  caseSensitive: false,
  unicode: true,
);
final _code = RegExp(r'`[^`]*`', dotAll: true);
final _markdownLink = RegExp(r'\[([^\]\n]+)\]\(([^\s)]+)\)');
final _boundary = RegExp(
  '[$_letter@_./:-]',
  caseSensitive: false,
  unicode: true,
);

Uri? safeMessageLinkUri(String value, {bool allowBare = true}) {
  var text = value.trim();
  if (text.isEmpty || RegExp(r'[\x00-\x20\x7f]').hasMatch(text)) return null;
  final explicit = RegExp(r'^https?://', caseSensitive: false).hasMatch(text);
  if (!explicit) {
    if (!allowBare ||
        text.startsWith('//') ||
        text.contains(RegExp(r'^[^/?#]*@'))) {
      return null;
    }
    final host = text.split(RegExp(r'[/:?#]')).first.toLowerCase();
    if (!host.contains('.') ||
        !messageLinkTlds.contains(host.split('.').last)) {
      return null;
    }
    text = 'https://$text';
  }
  final uri = Uri.tryParse(text);
  if (uri == null ||
      !{'http', 'https'}.contains(uri.scheme.toLowerCase()) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  if (uri.hasPort && (uri.port < 1 || uri.port > 65535)) return null;
  return uri;
}

List<MessageLink> findMessageLinks(String text) {
  final code = [
    ..._code.allMatches(text),
    ...RegExp(
      r'\b(?:javascript|data|vbscript|file|ftp):[^\s<>]*',
      caseSensitive: false,
    ).allMatches(text),
  ];
  final links = <MessageLink>[];
  final markdown = _markdownLink.allMatches(text).toList();
  bool overlaps(int start, int end, Iterable<Match> ranges) =>
      ranges.any((range) => start < range.end && end > range.start);
  for (final match in markdown) {
    if (overlaps(match.start, match.end, code)) continue;
    final uri = safeMessageLinkUri(match.group(2)!);
    if (uri != null) {
      links.add(MessageLink(match.start, match.end, match.group(1)!, uri));
    }
  }
  for (final match in _candidate.allMatches(text)) {
    if (overlaps(match.start, match.end, code) ||
        overlaps(match.start, match.end, markdown)) {
      continue;
    }
    final before = text.substring(0, match.start);
    final underscoreFormatting = RegExp(r'(?:^|[\s(])_{1,2}$').hasMatch(before);
    if (match.start > 0 &&
        _boundary.hasMatch(text.substring(match.start - 1, match.start)) &&
        !underscoreFormatting) {
      continue;
    }
    var raw = match.group(0)!;
    String previous;
    var removedFormatting = false;
    do {
      previous = raw;
      while (raw.isNotEmpty) {
        final last = raw[raw.length - 1];
        const pairs = {')': '(', ']': '[', '}': '{'};
        if (RegExp(r'[.,!?:;\u00bb\u201d\u2019\u3002]').hasMatch(last) ||
            (pairs.containsKey(last) &&
                last.allMatches(raw).length >
                    pairs[last]!.allMatches(raw).length)) {
          raw = raw.substring(0, raw.length - 1);
        } else {
          break;
        }
      }
      for (final marker in ['**', '__', '~~', '*', '_', '~']) {
        if (!removedFormatting &&
            before.endsWith(marker) &&
            raw.endsWith(marker)) {
          raw = raw.substring(0, raw.length - marker.length);
          removedFormatting = true;
          break;
        }
      }
    } while (raw != previous);
    final uri = safeMessageLinkUri(raw);
    if (uri != null) {
      links.add(MessageLink(match.start, match.start + raw.length, raw, uri));
    }
  }
  links.sort((a, b) => a.start.compareTo(b.start));
  return links;
}

/// Only called for a user's outgoing draft, never while scrolling history.
/// A failed preview must not prevent the encrypted message from being sent.
Future<Map<String, dynamic>?> loadMessageLinkPreview(
  String text,
  Future<dynamic> Function(Uri) fetch,
) async {
  final links = findMessageLinks(text);
  if (links.isEmpty) return null;
  try {
    final result = await fetch(
      links.first.uri,
    ).timeout(const Duration(seconds: 3));
    if (result is! Map ||
        result['title'] is! String ||
        (result['title'] as String).trim().isEmpty) {
      return null;
    }
    return {
      'url': links.first.uri.toString(),
      'domain': links.first.uri.host,
      'title': (result['title'] as String).trim(),
      'description':
          result['description'] is String ? result['description'] : '',
    };
  } catch (_) {
    return null;
  }
}

/// Do not keep a preview for an old address after a message is edited.
Map<String, dynamic>? matchingMessageLinkPreview(dynamic data, String text) {
  if (data is! Map) return null;
  final uri = safeMessageLinkUri(data['url']?.toString() ?? '');
  if (uri == null) return null;
  Uri canonical(Uri value) =>
      value.replace(path: value.path.isEmpty ? '/' : value.path);
  if (!findMessageLinks(text)
      .any((link) => canonical(link.uri) == canonical(uri))) {
    return null;
  }
  return Map<String, dynamic>.from(data);
}
