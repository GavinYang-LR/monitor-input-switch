#!/bin/zsh

set -euo pipefail

readonly VERSION="${1:-dev}"
readonly SCRIPT_DIR="${0:A:h}"
readonly PROJECT_DIR="${SCRIPT_DIR:h}"
readonly DIST_DIR="${PROJECT_DIR}/dist"
readonly APP_PATH="${DIST_DIR}/Display Switch.app"
readonly QUICK_APP_PATH="${DIST_DIR}/To Windows.app"
readonly ZIP_PATH="${DIST_DIR}/Mac-To-Windows-v${VERSION}.zip"
readonly FALLBACK_SDK="/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk"

if [[ -d "${FALLBACK_SDK}" ]]; then
  readonly SDK_PATH="${FALLBACK_SDK}"
else
  readonly SDK_PATH="$(xcrun --show-sdk-path)"
fi

mkdir -p "${DIST_DIR}"
rm -rf "${APP_PATH}"
rm -rf "${QUICK_APP_PATH}"

/usr/bin/ditto "${SCRIPT_DIR}/AppTemplate" "${APP_PATH}"
mkdir -p "${APP_PATH}/Contents/Resources"
cp "${PROJECT_DIR}/assets/MonitorSwitch.icns" \
  "${APP_PATH}/Contents/Resources/MonitorSwitch.icns"
cp -R "${PROJECT_DIR}/windows" \
  "${APP_PATH}/Contents/Resources/WindowsPackage"
cp "${PROJECT_DIR}/vendor/m1ddc/LICENSE" \
  "${APP_PATH}/Contents/Resources/m1ddc-LICENSE"

mkdir -p "${DIST_DIR}/ModuleCache"
CLANG_MODULE_CACHE_PATH="${DIST_DIR}/ModuleCache" xcrun clang \
  -fmodules \
  -I "${PROJECT_DIR}/vendor/m1ddc/headers" \
  -framework CoreDisplay \
  -o "${APP_PATH}/Contents/Resources/m1ddc" \
  "${PROJECT_DIR}/vendor/m1ddc/sources/i2c.m" \
  "${PROJECT_DIR}/vendor/m1ddc/sources/ioregistry.m" \
  "${PROJECT_DIR}/vendor/m1ddc/sources/m1ddc.m"
xcrun swiftc \
  -sdk "${SDK_PATH}" \
  -module-cache-path "${DIST_DIR}/ModuleCache" \
  -framework AppKit \
  -o "${APP_PATH}/Contents/MacOS/DisplaySwitch" \
  "${SCRIPT_DIR}/DisplaySwitchApp.swift" \
  "${SCRIPT_DIR}/main.swift"
chmod +x "${APP_PATH}/Contents/Resources/m1ddc"
plutil -replace CFBundleShortVersionString -string "${VERSION}" \
  "${APP_PATH}/Contents/Info.plist"
plutil -replace CFBundleVersion -string "${VERSION//./}" \
  "${APP_PATH}/Contents/Info.plist"

codesign --force --deep --sign - "${APP_PATH}"

/usr/bin/ditto "${SCRIPT_DIR}/QuickSwitchTemplate" "${QUICK_APP_PATH}"
mkdir -p "${QUICK_APP_PATH}/Contents/Resources"
cp "${PROJECT_DIR}/assets/MonitorSwitch.icns" \
  "${QUICK_APP_PATH}/Contents/Resources/MonitorSwitch.icns"
cp "${APP_PATH}/Contents/Resources/m1ddc" \
  "${QUICK_APP_PATH}/Contents/Resources/m1ddc"
cp "${PROJECT_DIR}/vendor/m1ddc/LICENSE" \
  "${QUICK_APP_PATH}/Contents/Resources/m1ddc-LICENSE"
chmod +x "${QUICK_APP_PATH}/Contents/MacOS/to-windows"
chmod +x "${QUICK_APP_PATH}/Contents/Resources/m1ddc"
plutil -replace CFBundleShortVersionString -string "${VERSION}" \
  "${QUICK_APP_PATH}/Contents/Info.plist"
plutil -replace CFBundleVersion -string "${VERSION//./}" \
  "${QUICK_APP_PATH}/Contents/Info.plist"
codesign --force --deep --sign - "${QUICK_APP_PATH}"

readonly PACKAGE_DIR="${DIST_DIR}/Display Switch ${VERSION}"
rm -rf "${PACKAGE_DIR}"
mkdir -p "${PACKAGE_DIR}"
/usr/bin/ditto "${APP_PATH}" "${PACKAGE_DIR}/Display Switch.app"
/usr/bin/ditto "${QUICK_APP_PATH}" "${PACKAGE_DIR}/To Windows.app"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent \
  "${PACKAGE_DIR}" "${ZIP_PATH}"

codesign --verify --deep --strict "${APP_PATH}"
codesign --verify --deep --strict "${QUICK_APP_PATH}"
echo "Built ${ZIP_PATH}"
