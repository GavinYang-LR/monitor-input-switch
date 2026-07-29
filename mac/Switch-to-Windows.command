#!/bin/zsh

set -u

readonly BETTERDISPLAY_CLI="/opt/homebrew/bin/betterdisplaycli"
readonly INPUT_SELECT_VCP="0x60"
readonly WINDOWS_DP2="0x10"

if [[ ! -x "${BETTERDISPLAY_CLI}" ]]; then
  osascript -e 'display alert "缺少 BetterDisplay" message "请先安装并启动 BetterDisplay。" as critical'
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

osascript -e 'display alert "切换失败" message "请确认显示器菜单 Extra → DDC/CI 已设置为 Yes，且 BetterDisplay 正在运行。" as critical'
exit 1
