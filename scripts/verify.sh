#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
cd "$ROOT"

echo "==> Running unit tests"
swift test

echo "==> Building LinkGlint.app"
ARCHS="${ARCHS:-$(uname -m)}" ./build_app.sh

APP="$ROOT/dist/LinkGlint.app"
echo "==> Verifying bundle signature"
codesign --verify --deep --strict --verbose=2 "$APP"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
ARCHITECTURES="$(lipo -archs "$APP/Contents/MacOS/LinkGlint")"
echo "Verified LinkGlint $VERSION ($ARCHITECTURES)"
