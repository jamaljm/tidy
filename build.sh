#!/bin/zsh
# Builds Tidy.app and installs it to ~/Applications.
set -e
cd "$(dirname "$0")"

APP=build/Tidy.app
rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# App icon: icon.png (1024px, drawn by icon.swift) -> Tidy.icns
ICONSET=build/Tidy.iconset
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s icon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) icon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/Tidy.icns"

SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk swiftc -O -swift-version 5 -target arm64-apple-macos13.0 main.swift -o "$APP/Contents/MacOS/Tidy" \
  -framework Cocoa -framework Carbon -framework ApplicationServices

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key><string>com.jamal.tidy</string>
  <key>CFBundleName</key><string>Tidy</string>
  <key>CFBundleExecutable</key><string>Tidy</string>
  <key>CFBundleIconFile</key><string>Tidy</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - -r='designated => identifier "com.jamal.tidy"' "$APP"

mkdir -p ~/Applications
rm -rf ~/Applications/Tidy.app
cp -R "$APP" ~/Applications/Tidy.app
echo "Installed: ~/Applications/Tidy.app"
