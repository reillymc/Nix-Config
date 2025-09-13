output=$(hyprctl dispatch killwindow class:com.my.clipboard 2>&1)
status=$?

if [[ $status -ne 0 || "$output" == *"no window found"* ]]; then
    uwsm app -- ghostty --class=com.my.clipboard -e clipse
fi
