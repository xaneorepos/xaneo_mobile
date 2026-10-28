import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../l10n/community_settings_localizations.dart';
import '../services/scheduled_messages.dart';
import 'scheduled_video_preview.dart';
import 'scheduled_modal_shell.dart';
import 'scheduled_modal_style.dart';

String scheduleText(BuildContext context, String key) =>
    CommunitySettingsLocalizations.of(context).text('messenger.scheduled.$key');

ThemeData _scheduleTheme(
        BuildContext context, Color foreground, Color background) =>
    ScheduledModalStyle.of(context).theme(Theme.of(context));

Future<bool> showScheduleCreate(
  BuildContext context, {
  required ScheduledSubmission submission,
  required String preview,
  required Color foreground,
  required Color background,
}) async {
  final result = await ScheduledModalShell.show<DateTime>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Theme(
      data: _scheduleTheme(context, foreground, background),
      child: _ScheduleTimeDialog(
        preview: preview,
        locked: () => submission.timeLocked,
        onSave: (date) async {
          await submission.send(date);
        },
      ),
    ),
  );
  return result != null;
}

Future<DateTime?> _chooseTime(BuildContext context, DateTime initial) =>
    ScheduledModalShell.show<DateTime>(
      context: context,
      builder: (_) => _ScheduleTimeDialog(initial: initial),
    );

class _ScheduleTimeDialog extends StatefulWidget {
  final String? preview;
  final DateTime? initial;
  final Future<void> Function(DateTime)? onSave;
  final bool Function()? locked;
  const _ScheduleTimeDialog({
    this.preview,
    this.initial,
    this.onSave,
    this.locked,
  });
  @override
  State<_ScheduleTimeDialog> createState() => _ScheduleTimeDialogState();
}

class _ScheduleTimeDialogState extends State<_ScheduleTimeDialog> {
  late final DateTime _minimum;
  late final DateTime _maximum;
  late DateTime _date;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _minimum = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));
    _maximum = _minimum
        .add(const Duration(days: 365))
        .subtract(const Duration(minutes: 2));
    final initial = widget.initial;
    _date = initial != null &&
            initial.isAfter(_minimum) &&
            initial.isBefore(_maximum)
        ? initial
        : _minimum.add(const Duration(minutes: 14));
  }

  Future<void> _save() async {
    if (_busy) return;
    if (!(widget.locked?.call() ?? false) && !_date.isAfter(DateTime.now())) {
      setState(() => _error = scheduleText(context, 'futureRequired'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSave?.call(_date);
      if (mounted) Navigator.of(context).pop(_date);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return PopScope(
      canPop: !_busy,
      child: ScheduledModalShell(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScheduledModalHeader(
              title: scheduleText(
                  context, widget.onSave == null ? 'reschedule' : 'title'),
              actions: [
                IconButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    tooltip: scheduleText(context, 'close'),
                    icon: const Icon(Icons.close))
              ]),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.preview?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        widget.preview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  IgnorePointer(
                    ignoring: _busy || (widget.locked?.call() ?? false),
                    child: SizedBox(
                      height: 180,
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          brightness: Theme.of(context).brightness,
                          primaryColor: fg,
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              color: fg,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          use24hFormat: true,
                          initialDateTime: _date,
                          minimumDate: _minimum,
                          maximumDate: _maximum,
                          onDateTimeChanged: (date) => _date = date,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    scheduleText(context, 'timezone'),
                    style: TextStyle(
                      fontSize: 12,
                      color: fg.withValues(alpha: .7),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ScheduledModalFooter(
              label: scheduleText(
                  context, widget.onSave == null ? 'done' : 'schedule'),
              busy: _busy,
              onSave: _save,
              onCancel: () => Navigator.pop(context),
              cancelLabel: scheduleText(context, 'discard')),
        ],
      )),
    );
  }
}

Future<void> showScheduledMessages(
  BuildContext context, {
  required ScheduledMessagesApi api,
  required String chatId,
  required ScheduleSeal seal,
  required ScheduleDecrypt decrypt,
  required Color foreground,
  required Color background,
}) =>
    ScheduledModalShell.show<void>(
      context: context,
      builder: (context) => Theme(
        data: _scheduleTheme(context, foreground, background),
        child: _ScheduledListDialog(
          api: api,
          chatId: chatId,
          seal: seal,
          decrypt: decrypt,
        ),
      ),
    );

class _ScheduledListDialog extends StatefulWidget {
  final ScheduledMessagesApi api;
  final String chatId;
  final ScheduleSeal seal;
  final ScheduleDecrypt decrypt;
  const _ScheduledListDialog({
    required this.api,
    required this.chatId,
    required this.seal,
    required this.decrypt,
  });
  @override
  State<_ScheduledListDialog> createState() => _ScheduledListDialogState();
}

class _ScheduledListDialogState extends State<_ScheduledListDialog> {
  final _jobs = <ScheduledJob>[];
  final _decryptions = <String, Future<String>>{};
  final _busy = <String>{};
  bool _loading = true;
  bool _more = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.api.list(
        widget.chatId,
        offset: more ? _jobs.length : 0,
      );
      if (!mounted) return;
      setState(() {
        if (!more) {
          _jobs.clear();
          _decryptions.clear();
        }
        _jobs.addAll(page.jobs);
        _more = page.hasMore;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _change(ScheduledJob job, Future<void> Function() action) async {
    if (_busy.contains(job.id)) return;
    setState(() {
      _busy.add(job.id);
      _error = null;
    });
    try {
      await action();
      if (mounted) await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy.remove(job.id));
    }
  }

  String _date(DateTime value) {
    final l10n = MaterialLocalizations.of(context);
    return '${l10n.formatMediumDate(value)} · ${l10n.formatTimeOfDay(TimeOfDay.fromDateTime(value), alwaysUse24HourFormat: true)}';
  }

  @override
  Widget build(BuildContext context) => ScheduledModalShell(
      fillHeight: true,
      child: Column(
        children: [
          ScheduledModalHeader(title: scheduleText(context, 'list'), actions: [
            IconButton(
                onPressed: _loading ? null : () => _load(),
                tooltip: scheduleText(context, 'refresh'),
                icon: const Icon(Icons.refresh)),
            IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: scheduleText(context, 'close'),
                icon: const Icon(Icons.close))
          ]),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _jobs.isEmpty
                ? Center(
                    child: _loading
                        ? const CupertinoActivityIndicator()
                        : Text(scheduleText(context, 'empty')),
                  )
                : ListView.builder(
                    itemCount: _jobs.length + (_more ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _jobs.length) {
                        return TextButton(
                          onPressed: _loading ? null : () => _load(more: true),
                          child: Text(scheduleText(context, 'loadMore')),
                        );
                      }
                      final job = _jobs[index];
                      final text = _decryptions.putIfAbsent(
                        job.id,
                        () => widget.decrypt(job.payload),
                      );
                      return FutureBuilder<String>(
                        key: ValueKey(
                          '${job.id}:${job.payload['encrypted_text']}',
                        ),
                        future: text,
                        builder: (context, snapshot) {
                          final value =
                              snapshot.connectionState == ConnectionState.done
                                  ? snapshot.data
                                  : null;
                          final busy = _busy.contains(job.id) || _loading;
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ScheduledModalPanel(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _date(job.sendAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        scheduleText(context, job.status),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    value?.isNotEmpty == true
                                        ? value!
                                        : scheduleText(
                                            context,
                                            snapshot.hasError
                                                ? 'encryptedPreview'
                                                : 'attachments',
                                          ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  for (final file in job.attachments)
                                    _ScheduledFile(
                                      key: ValueKey('${job.id}:${file.id}'),
                                      file: file,
                                      api: widget.api,
                                    ),
                                  if (job.error.isNotEmpty)
                                    Text(
                                      job.error,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                        ),
                                        label: Text(
                                          scheduleText(context, 'edit'),
                                        ),
                                        onPressed: busy || value == null
                                            ? null
                                            : () async {
                                                final changed =
                                                    await ScheduledModalShell
                                                        .show<bool>(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (_) =>
                                                      _ScheduledEditDialog(
                                                    api: widget.api,
                                                    job: job,
                                                    text: value,
                                                    seal: widget.seal,
                                                  ),
                                                );
                                                if (changed == true &&
                                                    mounted) {
                                                  await _load();
                                                }
                                              },
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(
                                          Icons.event,
                                          size: 16,
                                        ),
                                        label: Text(
                                          scheduleText(context, 'reschedule'),
                                        ),
                                        onPressed: busy
                                            ? null
                                            : () async {
                                                final date = await _chooseTime(
                                                  context,
                                                  job.sendAt,
                                                );
                                                if (date != null && mounted) {
                                                  await _change(
                                                    job,
                                                    () => widget.api.move(
                                                      job,
                                                      date,
                                                    ),
                                                  );
                                                }
                                              },
                                      ),
                                      TextButton(
                                        onPressed: busy
                                            ? null
                                            : () => _change(
                                                  job,
                                                  () => widget.api.cancel(job),
                                                ),
                                        child: Text(
                                          scheduleText(context, 'cancel'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )));
                        },
                      );
                    },
                  ),
          ),
        ],
      ));
}

class _ScheduledEditDialog extends StatefulWidget {
  final ScheduledMessagesApi api;
  final ScheduledJob job;
  final String text;
  final ScheduleSeal seal;
  const _ScheduledEditDialog({
    required this.api,
    required this.job,
    required this.text,
    required this.seal,
  });
  @override
  State<_ScheduledEditDialog> createState() => _ScheduledEditDialogState();
}

class _ScheduledEditDialogState extends State<_ScheduledEditDialog> {
  late final TextEditingController _text;
  late final List<ScheduledAttachment> _files;
  bool _busy = false;
  String? _error;
  DateTime? _sendAt;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.text);
    _files = [...widget.job.attachments];
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pick([int? index]) async {
    final result = await FilePicker.pickFiles(allowMultiple: index == null);
    if (result == null || !mounted) return;
    final picked = result.files
        .where((item) => item.path != null)
        .map((item) => ScheduledAttachment.local(File(item.path!)))
        .toList();
    if (_files.length - (index == null ? 0 : 1) + picked.length > 10) {
      setState(() => _error = scheduleText(context, 'fileLimit'));
      return;
    }
    if (picked.isEmpty) return;
    setState(() {
      _error = null;
      if (index == null) {
        _files.addAll(picked);
      } else {
        _files.replaceRange(index, index + 1, picked);
      }
    });
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_text.text.length > 4096 ||
        (_text.text.trim().isEmpty && _files.isEmpty)) {
      setState(() => _error = scheduleText(context, 'draftRequired'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      for (var i = 0; i < _files.length; i++) {
        if (_files[i].id == null && _files[i].localFile != null) {
          _files[i] = await widget.api.upload(
            _files[i].localFile!,
            widget.job.chatId,
          );
        }
      }
      final encrypted = await widget.seal(_text.text);
      await widget.api.edit(widget.job, encrypted, _files, sendAt: _sendAt);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: ScheduledModalShell(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScheduledModalHeader(
                title: scheduleText(context, 'edit'),
                actions: [
                  IconButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      tooltip: scheduleText(context, 'close'),
                      icon: const Icon(Icons.close))
                ]),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScheduledModalLabel(
                        label: scheduleText(context, 'messageText'),
                        child: TextField(
                          controller: _text,
                          enabled: !_busy,
                          maxLines: 4,
                          minLines: 2,
                          maxLength: 4096,
                          decoration: const InputDecoration(),
                          style: ScheduledModalStyle.of(context).fieldTextStyle,
                        )),
                    for (var i = 0; i < _files.length; i++)
                      Column(
                        children: [
                          _ScheduledFile(
                            key: ValueKey(
                              '${_files[i].id}:${_files[i].localFile?.path}',
                            ),
                            file: _files[i],
                            api: widget.api,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _busy ? null : () => _pick(i),
                                child: Text(
                                  scheduleText(context, 'replaceFile'),
                                ),
                              ),
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => setState(() => _files.removeAt(i)),
                                child: Text(
                                  scheduleText(context, 'removeFile'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (_error != null)
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                onPressed: _busy || _files.length >= 10 ? null : () => _pick(),
                icon: const Icon(Icons.attach_file),
                label: Text(scheduleText(context, 'addFiles')),
              ),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        final date = await _chooseTime(
                          context,
                          _sendAt ?? widget.job.sendAt,
                        );
                        if (date != null && mounted) {
                          setState(() => _sendAt = date);
                        }
                      },
                icon: const Icon(Icons.schedule),
                label: Text(scheduleText(context, 'reschedule')),
              ),
            ]),
            ScheduledModalFooter(
                label: scheduleText(context, 'save'),
                busy: _busy,
                onSave: _save,
                onCancel: () => Navigator.pop(context),
                cancelLabel: scheduleText(context, 'discard')),
          ],
        )),
      );
}

class _ScheduledFile extends StatefulWidget {
  final ScheduledAttachment file;
  final ScheduledMessagesApi api;
  const _ScheduledFile({super.key, required this.file, required this.api});
  @override
  State<_ScheduledFile> createState() => _ScheduledFileState();
}

class _ScheduledFileState extends State<_ScheduledFile> {
  AudioPlayer? _audio;
  StreamSubscription<PlayerState>? _state;
  bool _playing = false;
  bool _loading = false;
  String? _error;
  @override
  void dispose() {
    _state?.cancel();
    _audio?.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_loading) return;
    try {
      if (_audio == null) {
        setState(() => _loading = true);
        final player = AudioPlayer();
        _audio = player;
        _state = player.playerStateStream.listen((state) {
          if (!mounted) return;
          setState(
            () => _playing = state.playing &&
                state.processingState != ProcessingState.completed,
          );
          if (state.processingState == ProcessingState.completed) {
            player.pause();
            player.seek(Duration.zero);
          }
        });
        if (widget.file.localFile != null) {
          await player.setFilePath(widget.file.localFile!.path);
        } else {
          final url = widget.api.mediaUrl(widget.file.url);
          if (url == null) throw StateError('File unavailable');
          await player.setUrl(url);
        }
      }
      if (!mounted) return;
      setState(() => _loading = false);
      if (_playing) {
        await _audio!.pause();
      } else {
        unawaited(
          _audio!.play().catchError((Object error) {
            if (mounted) setState(() => _error = error.toString());
          }),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final url = widget.api.mediaUrl(file.url);
    final icon = file.kind == 'audio'
        ? Icons.music_note_rounded
        : file.kind == 'video'
            ? Icons.videocam_outlined
            : Icons.insert_drive_file_outlined;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ScheduledModalPanel(
          padding: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (file.kind == 'image' &&
                  (file.localFile != null || url != null))
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: file.localFile != null
                        ? Image.file(
                            file.localFile!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined),
                          )
                        : Image.network(
                            url!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                  ),
                ),
              if (file.kind == 'video' &&
                  (file.localFile != null || url != null))
                ScheduledVideoPreview(file: file.localFile, url: url),
              Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (file.kind == 'audio' && !file.unavailable)
                    IconButton(
                      onPressed: _loading ? null : _play,
                      icon: _loading
                          ? const CupertinoActivityIndicator()
                          : Icon(
                              _playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                    ),
                ],
              ),
              if (file.unavailable)
                Text(
                  scheduleText(context, 'fileUnavailable'),
                  style: const TextStyle(fontSize: 11),
                ),
              if (_error != null)
                Text(
                  _error!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          )),
    );
  }
}
