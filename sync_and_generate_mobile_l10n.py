#!/usr/bin/env python3
import json
import re
import os

MANIFEST_PATH = "/home/xaneodev/xaneo_mobile/assets/manifest.v1.json"
RU_DART_PATH = "/home/xaneodev/xaneo_mobile/lib/l10n/app_localizations_ru.dart"
APP_L10N_PATH = "/home/xaneodev/xaneo_mobile/lib/l10n/app_localizations.dart"
DYNAMIC_DART_PATH = "/home/xaneodev/xaneo_mobile/lib/l10n/dynamic_app_localizations.dart"
TSUKISHIRO_PATH = "/home/xaneodev/tsukishiro_agent_lang.json"

with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
    manifest_data = json.load(f)

manifest_keys = manifest_data.setdefault("keys", {})

with open(APP_L10N_PATH, "r", encoding="utf-8") as f:
    l10n_content = f.read()

getters = []
methods = []
for line in l10n_content.splitlines():
    line = line.strip()
    m_getter = re.match(r"String get ([a-zA-Z0-9_]+);", line)
    if m_getter:
        getters.append(m_getter.group(1))
        continue
    m_method = re.match(r"String ([a-zA-Z0-9_]+)\(([^)]*)\);", line)
    if m_method:
        methods.append((m_method.group(1), m_method.group(2)))

with open(RU_DART_PATH, "r", encoding="utf-8") as f:
    ru_content = f.read()

getter_to_ru = {}
pattern = r"String get ([a-zA-Z0-9_]+)\s*=>\s*(.*?);"
for m in re.finditer(pattern, ru_content, re.DOTALL):
    g = m.group(1)
    raw = m.group(2).strip()
    parts = re.findall(r"""(?:'([^'\\]*(?:\\.[^'\\]*)*)'|"([^"\\]*(?:\\.[^"\\]*)*)")""", raw)
    extracted = ""
    for p1, p2 in parts:
        val = p1 if p1 is not None and p1 != "" else p2
        val = val.replace(r"\'", "'").replace(r"\"", '"').replace(r"\n", "\n")
        extracted += val
    if not extracted and (raw.startswith("'") or raw.startswith('"')):
        extracted = raw.strip("'\"")
    getter_to_ru[g] = extracted

def normalize_text(t):
    if not t:
        return ""
    t = re.sub(r"[^\w\s]", "", t, flags=re.UNICODE)
    t = re.sub(r"\s+", "", t)
    return t.lower()

manifest_by_norm = {}
manifest_by_exact = {}

for k, v in manifest_keys.items():
    if isinstance(v, dict):
        ru_text = v.get("fallback_ru") or v.get("ru") or ""
        if ru_text:
            manifest_by_exact.setdefault(ru_text, []).append(k)
            norm = normalize_text(ru_text)
            if norm:
                manifest_by_norm.setdefault(norm, []).append(k)

print(f"Total getters in app_localizations.dart: {len(getters)}")
print(f"Total getters parsed in app_localizations_ru.dart: {len(getter_to_ru)}")
print(f"Total keys in manifest.v1.json: {len(manifest_keys)}")

# Let's check how many getters are resolved to manifest keys
matched = 0
for g in getters:
    ru = getter_to_ru.get(g, "")
    norm = normalize_text(ru)
    if ru in manifest_by_exact or norm in manifest_by_norm or g in manifest_keys or f"mobile.{g}" in manifest_keys:
        matched += 1

print(f"Getters matched with manifest: {matched} / {len(getters)} ({matched/len(getters)*100:.1f}%)")
