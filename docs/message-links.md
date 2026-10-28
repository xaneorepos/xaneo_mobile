# Message links

Both native clients share the same parser and widgets. Bare domains use HTTPS;
HTTP(S), Unicode domains, paths/query strings and Markdown links are supported.
Domain zones come from the web client's MIT-licensed `tlds` 1.261.0 snapshot.
Emails, mentions, file extensions, code and non-web schemes are excluded.
Links open in the external browser and keep the message's XNX text color.

The shared-links tab uses the same detection. Parsing happens on plain Dart
strings; no HTML renderer or WebView is involved. Gesture recognizers belong
to the text widget and are disposed when content/style changes or it unmounts.

The composer detects URLs while typing and calls the existing authenticated
`/link-preview/` endpoint after a 450 ms debounce, with a three-second deadline.
It shows a themed dismissible preview above the input. Each chat/discussion has
its own generation: responses for older text/scopes are ignored. Sending reuses
the current result/request and honors dismissal; clearing the input never
invalidates the captured send payload. Failure does not block message delivery.
Only the URL is submitted to this endpoint. No previews are fetched while
scrolling received history. Metadata is sent over WebSocket as `link_preview`
and rendered from that field or `message_data.link_preview`; mobile persists
it in its existing message-data column. A card is hidden if the current text
no longer contains that URL. Card colors derive from the bubble's text color.

Desktop's legacy REST fallback has no server-side preview field, so a preview
for a message sent through that fallback is local to the current session;
clickable links remain available after reloading. No backend changes are needed.

Checks: `flutter test test/message_links_test.dart` (plus the mobile formatted
text/theme regression tests).
