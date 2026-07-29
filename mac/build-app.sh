#!/bin/zsh

set -euo pipefail

readonly VERSION="${1:-dev}"
readonly SCRIPT_DIR="${0:A:h}"
readonly PROJECT_DIR="${SCRIPT_DIR:h}"
readonly DIST_DIR="${PROJECT_DIR}/dist"
readonly APP_PATH="${DIST_DIR}/To Windows.app"
readonly ZIP_PATH="${DIST_DIR}/Mac-To-Windows-v${VERSION}.zip"

mkdir -p "${DIST_DIR}"
rm -rf "${APP_PATH}"

/usr/bin/ditto "${SCRIPT_DIR}/AppTemplate" "${APP_PATH}"
mkdir -p "${APP_PATH}/Contents/Resources"
cp "${PROJECT_DIR}/assets/MonitorSwitch.icns" \
  "${APP_PATH}/Contents/Resources/MonitorSwitch.icns"

chmod +x "${APP_PATH}/Contents/MacOS/to-windows"
plutil -replace CFBundleShortVersionString -string "${VERSION}" \
  "${APP_PATH}/Contents/Info.plist"
plutil -replace CFBundleVersion -string "${VERSION//./}" \
  "${APP_PATH}/Contents/Info.plist"

codesign --force --deep --sign - "${APP_PATH}"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent \
  "${APP_PATH}" "${ZIP_PATH}"

codesign --verify --deep --strict "${APP_PATH}"
echo "Built ${ZIP_PATH}"
