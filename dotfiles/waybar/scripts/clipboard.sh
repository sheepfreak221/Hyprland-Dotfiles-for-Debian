#!/bin/bash

COUNT=$(cliphist list | wc -l)

if [ "$COUNT" -gt 99 ]; then
    DISPLAY="99+"
else
    DISPLAY="$COUNT"
fi

printf '{"text":"󰅍 %s","tooltip":"Clipboard entries: %s"}\n' \
"$DISPLAY" "$COUNT"
