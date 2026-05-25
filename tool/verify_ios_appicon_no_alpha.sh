#!/usr/bin/env bash
set -euo pipefail

ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

if [[ ! -d "$ICON_DIR" ]]; then
  echo "ERROR: AppIcon directory not found: $ICON_DIR"
  exit 1
fi

failed=0

shopt -s nullglob
icons=("$ICON_DIR"/*.png)
shopt -u nullglob

if [[ ${#icons[@]} -eq 0 ]]; then
  echo "ERROR: No PNG files found in $ICON_DIR"
  exit 1
fi

for icon in "${icons[@]}"; do
  alpha="$(sips -g hasAlpha "$icon" | awk -F': ' '/hasAlpha/ {print $2}')"
  space="$(sips -g space "$icon" | awk -F': ' '/space/ {print $2}')"

  if [[ "$alpha" == "yes" || "$space" != "RGB" ]]; then
    echo "FAIL: $(basename "$icon") hasAlpha=$alpha space=$space"
    failed=1
  else
    echo "OK:   $(basename "$icon") hasAlpha=$alpha space=$space"
  fi
done

if [[ $failed -ne 0 ]]; then
  echo "ERROR: One or more iOS app icons contain alpha or are not RGB."
  exit 1
fi

echo "PASS: All iOS app icons are RGB and have no alpha channel."
