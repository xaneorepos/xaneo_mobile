#!/bin/sh
# Match the iOS home-screen name to the API address passed with --dart-define.
set -eu

api_url='https://xaneo.ru/api/v1'
old_ifs=$IFS
IFS=,
for encoded in ${DART_DEFINES:-}; do
  decoded=$(printf '%s' "$encoded" | /usr/bin/base64 -D 2>/dev/null || true)
  case "$decoded" in
    API_BASE_URL=*) api_url=${decoded#API_BASE_URL=}; break ;;
    BASE_URL=*) api_url=${decoded#BASE_URL=} ;;
  esac
done
IFS=$old_ifs

host=$(printf '%s' "$api_url" | /usr/bin/sed -E 's#^[A-Za-z]+://([^/:]+).*#\1#' | /usr/bin/tr '[:upper:]' '[:lower:]')
display_name='Xaneo'
case "$host" in
  localhost|*.local|127.*|10.*|192.168.*|169.254.*)
    display_name='Xaneo Beta' ;;
  172.*)
    second=${host#172.}
    second=${second%%.*}
    if [ "$second" -ge 16 ] && [ "$second" -le 31 ]; then
      display_name='Xaneo Beta'
    fi ;;
esac
if [ "$host" = '[::1]' ]; then display_name='Xaneo Beta'; fi

plist="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
if [ -f "$plist" ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $display_name" "$plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $display_name" "$plist"
fi
