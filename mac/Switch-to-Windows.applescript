use scripting additions

on run
	try
		do shell script "/usr/bin/open -gja BetterDisplay; /bin/sleep 1; /opt/homebrew/bin/betterdisplaycli set -feature=ddc -vcp=0x60 -value=0x10"
	on error errorMessage
		display alert "切换失败" message "请确认 BetterDisplay 正在运行，且显示器 Extra → DDC/CI 已设置为 Yes。" & return & return & errorMessage as critical
	end try
end run
