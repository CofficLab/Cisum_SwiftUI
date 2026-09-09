#!/bin/zsh

set -euo pipefail

workspace_root="${0:A:h}/.."
cd "$workspace_root"

scope=(
  Packages/PluginBook*
  Packages/PluginAudio*
  Packages/PluginStore
)

if rg -n '^import Plugin[A-Z]' "${scope[@]}" \
  --glob '*.swift' \
  --glob '!**/Tests/**' \
  --glob '!**/.build/**'; then
  print -u2 'Plugin boundary violation: a feature source imports another Plugin module.'
  exit 1
fi

if rg -n '\.product\(name: "Plugin(Book|Audio|Store)' "${scope[@]}" \
  --glob 'Package.swift'; then
  print -u2 'Plugin boundary violation: a target depends on another Plugin product.'
  exit 1
fi

if rg -n '\.package\((name: "[^"]+", )?path: "\.\./Plugin(Book|Audio|Store)' "${scope[@]}" \
  --glob 'Package.swift'; then
  print -u2 'Plugin boundary violation: a feature package depends on another Plugin package.'
  exit 1
fi

print 'Plugin boundary check passed.'
