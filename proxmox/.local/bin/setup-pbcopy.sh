#!/bin/sh
set -eu

BIN_DIR="$HOME/.local/bin"
PBCOPY="$BIN_DIR/pbcopy"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

mkdir -p "$BIN_DIR"

cat > "$PBCOPY" << 'EOF'
#!/bin/sh
input="$(cat)"
payload="$(printf '%s' "$input" | base64 | tr -d '\n')"

if [ -n "${TMUX:-}" ]; then
  printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$payload"
else
  printf '\033]52;c;%s\a' "$payload"
fi
EOF

chmod +x "$PBCOPY"
ln -sf "$HOME/.local/bin/pbcopy" /usr/local/bin/pbcopy

append_if_missing() {
  file="$1"
  content="$2"
  [ -f "$file" ] || touch "$file"
  grep -qF "$content" "$file" 2>/dev/null || printf '\n%s\n' "$content" >> "$file"
}

if [ -f /etc/debian_version ]; then
  for rc in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile" "$HOME/.bashrc"; do
    if [ -f "$rc" ]; then
      append_if_missing "$rc" "$PATH_LINE"
    fi
  done
  if [ ! -f "$HOME/.bash_profile" ] && [ ! -f "$HOME/.bash_login" ]; then
    append_if_missing "$HOME/.profile" "$PATH_LINE"
  fi
fi

if [ -f /etc/alpine-release ]; then
  append_if_missing "$HOME/.profile" "$PATH_LINE"
  SHRC="$HOME/.shrc"
  append_if_missing "$SHRC" "$PATH_LINE"
  append_if_missing "$HOME/.profile" "export ENV=\"$SHRC\""
fi

if [ ! -f /etc/debian_version ] && [ ! -f /etc/alpine-release ]; then
  append_if_missing "$HOME/.profile" "$PATH_LINE"
  append_if_missing "$HOME/.bashrc" "$PATH_LINE"
fi

if command -v tmux >/dev/null 2>&1 || [ -f "$HOME/.tmux.conf" ]; then
  TMUXCONF="$HOME/.tmux.conf"
  [ -f "$TMUXCONF" ] || touch "$TMUXCONF"
  grep -qF "allow-passthrough" "$TMUXCONF" 2>/dev/null || printf '\nset -g allow-passthrough on\nset -g set-clipboard on\n' >> "$TMUXCONF"
fi

echo "pbcopy installed at $PBCOPY"
echo "Open a new shell session, then test with: echo -n 'hello' | pbcopy"
