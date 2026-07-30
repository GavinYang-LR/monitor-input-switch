#!/bin/zsh

set -euo pipefail

readonly VERSION="${1:-dev}"
readonly MAC_INPUT_NAME="${2:-DP1}"
readonly MAC_INPUT_VALUE="${3:-0x0F}"
readonly WINDOWS_INPUT_NAME="${4:-DP2}"
readonly WINDOWS_INPUT_VALUE="${5:-0x10}"
readonly SCRIPT_DIR="${0:A:h}"
readonly PROJECT_DIR="${SCRIPT_DIR:h}"
readonly DIST_DIR="${PROJECT_DIR}/dist"
readonly ZIP_PATH="${DIST_DIR}/Windows-To-Mac-${MAC_INPUT_NAME}-v${VERSION}.zip"
readonly TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/display-switch.XXXXXX")"
readonly PACKAGE_DIR="${TEMP_ROOT}/Windows-To-Mac-${MAC_INPUT_NAME}"

cleanup() {
  rm -rf "${TEMP_ROOT}"
}
trap cleanup EXIT

mkdir -p "${DIST_DIR}"
cp -R "${PROJECT_DIR}/windows" "${PACKAGE_DIR}"

sed -i '' \
  's/^\$MacInputSource = 0x[0-9A-Fa-f]*/$MacInputSource = '"${MAC_INPUT_VALUE}"'/' \
  "${PACKAGE_DIR}/Switch-To-Mac.ps1"

cat > "${PACKAGE_DIR}/CONFIGURATION.txt" <<EOF
Display Switch Windows installer
Mac input source: ${MAC_INPUT_NAME} (${MAC_INPUT_VALUE})
Windows input source: ${WINDOWS_INPUT_NAME} (${WINDOWS_INPUT_VALUE})
EOF

rm -f "${ZIP_PATH}"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent \
  "${PACKAGE_DIR}" "${ZIP_PATH}"

echo "Built ${ZIP_PATH}"
