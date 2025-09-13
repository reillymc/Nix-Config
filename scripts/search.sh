#!/bin/sh
# Bound to Super+c
# Requires wl-clipboard package to be installed

firefox --new-tab https://www.google.com/search?q="$(wl-paste --primary)"
