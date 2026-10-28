import 'package:flutter/material.dart';
import '../controllers/draft_link_preview_controller.dart';
import 'linked_message_text.dart';

/// Shared by desktop and mobile; text remains in its existing composer.
class DraftLinkPreviewComposer extends StatefulWidget {
  final DraftLinkPreviewController preview;
  final TextEditingController textController;
  final String scope;
  final Color foreground;
  final Color background;
  final Widget child;
  final double maxPreviewWidth;
  final double previewHorizontalPadding;
  const DraftLinkPreviewComposer({
    super.key,
    required this.preview,
    required this.textController,
    required this.scope,
    required this.foreground,
    required this.background,
    required this.child,
    this.maxPreviewWidth = double.infinity,
    this.previewHorizontalPadding = 0,
  });
  @override
  State<DraftLinkPreviewComposer> createState() =>
      _DraftLinkPreviewComposerState();
}

class _DraftLinkPreviewComposerState extends State<DraftLinkPreviewComposer> {
  void _sync() =>
      widget.preview.update(widget.textController.text, scope: widget.scope);
  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_sync);
    _sync();
  }

  @override
  void didUpdateWidget(DraftLinkPreviewComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textController != widget.textController) {
      oldWidget.textController.removeListener(_sync);
      widget.textController.addListener(_sync);
    }
    if (oldWidget.scope != widget.scope ||
        oldWidget.preview != widget.preview ||
        oldWidget.textController != widget.textController) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sync();
      });
    }
  }

  @override
  void dispose() {
    widget.textController.removeListener(_sync);
    widget.preview.clear(notify: false);
    super.dispose();
  }

  Widget _previewFrame(Widget child) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxPreviewWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.previewHorizontalPadding,
            ),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.preview,
        builder: (context, _) {
          final preview = widget.preview;
          final visible = preview.scope == widget.scope && preview.visible;
          final data = preview.data;
          final foreground = widget.foreground;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _previewFrame(
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: Alignment.bottomCenter,
                  child: visible
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            key: const ValueKey('draft-link-preview'),
                            color: widget.background,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: preview.url == null
                                  ? null
                                  : () => openMessageLink(preview.url!),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 4, 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: foreground.withValues(alpha: .14),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: foreground.withValues(alpha: .5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.link_rounded,
                                      color: foreground.withValues(alpha: .7),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            preview.url?.host ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: foreground.withValues(
                                                alpha: .72,
                                              ),
                                              fontSize: 11,
                                            ),
                                          ),
                                          if (data != null)
                                            Text(
                                              data['title']?.toString() ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: foreground,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          if (data != null &&
                                              (data['description']
                                                      ?.toString()
                                                      .isNotEmpty ??
                                                  false))
                                            Text(
                                              data['description'].toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: foreground.withValues(
                                                  alpha: .76,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (preview.loading)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: foreground.withValues(
                                              alpha: .65,
                                            ),
                                          ),
                                        ),
                                      ),
                                    IconButton(
                                      tooltip: MaterialLocalizations.of(
                                        context,
                                      ).closeButtonTooltip,
                                      onPressed: preview.dismiss,
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: foreground.withValues(alpha: .7),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              widget.child,
            ],
          );
        },
      );
}
