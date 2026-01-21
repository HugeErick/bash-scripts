#!/bin/bash

PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")

cd "$PANE_PATH" || exit

RAW_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$RAW_URL" ]; then
    echo "No git remote 'origin' found in $PANE_PATH"
    exit 1
fi

# convert SSH/Git format to HTTPS
# handles git@github.com:user/repo.git -> https://github.com/user/repo
URL=$(echo "$RAW_URL" | sed -E 's/git@([^:]+):/https:\/\/\1\//;s/\.git$//')

# open the URL (works on macOS 'open', Linux 'xdg-open')
if command -v xdg-open >/dev/null; then
    xdg-open "$URL"
else
    echo "Could not find a browser opener. URL: $URL"
fi
