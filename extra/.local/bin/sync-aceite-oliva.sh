#!/bin/bash
set -e

SRC=~/Documents/Projects/WebAceiteOliva
DEST=~/Documents/Projects/WebAceiteOliva-coolify

# 1. Clean dest, preserve .git
find "$DEST" -mindepth 1 -not -path "$DEST/.git" -not -path "$DEST/.git/*" -delete

# 2. Pull latest source
cd "$SRC"
git checkout main
git pull origin main

# 3. Copy src → dest (excluding .git)
rsync -a --exclude='.git' "$SRC/" "$DEST/"

# 4. Commit and push
cd "$DEST"
git add .
git commit -m "update" || echo "Nothing to commit"
git push origin main
