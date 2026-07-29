#!/bin/zsh

set -u

readonly BETTERDISPLAY_CLI="/opt/homebrew/bin/betterdisplaycli"
readonly INPUT_SELECT_VCP="0x60"
readonly WINDOWS_DP2="0x10"

if [[ ! -x "${BETTERDISPLAY_CLI}" ]]; then
  osascript -e 'display alert "BetterDisplay is required" message "Install and start BetterDisplay before using this app." as critical'
  exit 1
fi

if ! pgrep -x BetterDisplay >/dev/null 2>&1; then
  open -gja BetterDisplay
  sleep 2
fi

if "${BETTERDISPLAY_CLI}" set \
  -feature=ddc \
  -vcp="${INPUT_SELECT_VCP}" \
  -value="${WINDOWS_DP2}"; then
  exit 0
fi

osascript -e 'display alert "Switch failed" message "Confirm that Extra > DDC/CI is set to Yes on the monitor and that BetterDisplay is running." as critical'
exit 1
