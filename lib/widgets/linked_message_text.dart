import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/message_links.dart';

Future<void> openMessageLink(Uri uri) async {
  if (safeMessageLinkUri(uri.toString(), allowBare: false) == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

/// Keeps selection/formatting while owning and disposing every recognizer.
class LinkedMessageText extends StatefulWidget {
  final String content;
  final TextStyle baseStyle;
  final List<InlineSpan> Function(String, TextStyle) format;
  final bool selectable;
  final ValueChanged<Uri>? onOpenLink;
  const LinkedMessageText({
    super.key,
    required this.content,
    required this.baseStyle,
    required this.format,
    this.selectable = false,
    this.onOpenLink,
  });
  @override
  State<LinkedMessageText> createState() => _LinkedMessageTextState();
}

class _LinkedMessageTextState extends State<LinkedMessageText> {
  final _recognizers = <TapGestureRecognizer>[];
  TextSpan? _span;
  @override
  void didUpdateWidget(LinkedMessageText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _clear();
  }

  void _clear() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    _span = null;
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  TextSpan _buildSpan() {
    final links = findMessageLinks(widget.content);
    var prefix = '\uE000XANEOLINK';
    while (widget.content.contains(prefix)) {
      prefix += 'X';
    }
    final tokens = <String, MessageLink>{};
    var cursor = 0;
    final text = StringBuffer();
    for (final link in links) {
      final token = '$prefix${tokens.length}\uE001';
      text.write(widget.content.substring(cursor, link.start));
      text.write(token);
      tokens[token] = link;
      cursor = link.end;
    }
    text.write(widget.content.substring(cursor));
    final pattern = RegExp('${RegExp.escape(prefix)}[0-9]+\uE001');
    InlineSpan restore(InlineSpan span) {
      if (span is! TextSpan) return span;
      final children = <InlineSpan>[];
      final value = span.text ?? '';
      var previous = 0;
      for (final match in pattern.allMatches(value)) {
        if (match.start > previous) {
          children.add(TextSpan(text: value.substring(previous, match.start)));
        }
        final link = tokens[match.group(0)]!;
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            if (widget.onOpenLink != null) {
              widget.onOpenLink!(link.uri);
            } else {
              openMessageLink(link.uri);
            }
          };
        _recognizers.add(recognizer);
        children.add(
          TextSpan(
            text: link.text,
            style: const TextStyle(decoration: TextDecoration.underline),
            recognizer: recognizer,
            mouseCursor: SystemMouseCursors.click,
          ),
        );
        previous = match.end;
      }
      if (previous < value.length) {
        children.add(TextSpan(text: value.substring(previous)));
      }
      children.addAll((span.children ?? []).map(restore));
      return TextSpan(style: span.style, children: children);
    }

    return TextSpan(
      style: widget.baseStyle,
      children: widget
          .format(text.toString(), widget.baseStyle)
          .map(restore)
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _span ??= _buildSpan();
    return widget.selectable
        ? SelectableText.rich(_span!)
        : RichText(text: _span!);
  }
}

class MessageLinkPreview extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Color foreground;
  const MessageLinkPreview({
    super.key,
    required this.data,
    required this.foreground,
  });
  @override
  Widget build(BuildContext context) {
    final uri = safeMessageLinkUri(data?['url']?.toString() ?? '');
    final title = data?['title']?.toString().trim() ?? '';
    if (uri == null || title.isEmpty) return const SizedBox.shrink();
    final description = data?['description']?.toString().trim() ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Semantics(
        link: true,
        child: InkWell(
          onTap: () => openMessageLink(uri),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: foreground.withValues(alpha: .12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 18,
                  color: foreground.withValues(alpha: .7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uri.host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground.withValues(alpha: .74),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground.withValues(alpha: .78),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
