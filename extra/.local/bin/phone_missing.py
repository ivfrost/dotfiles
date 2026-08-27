#!/usr/bin/env python3
import os, re, sys
from difflib import SequenceMatcher

EXTS = {'.flac', '.mp3', '.m4a', '.opus', '.ogg', '.wav', '.aac'}

TRAILING_QUAL = re.compile(
    r'\s*[-–—]\s*(\d{4}\s*)?'
    r'(remaster(ed)?|album version|single version|'
    r'deluxe( edition)?|explicit|original( single)? version)'
    r'\s*$',
    re.I,
)

def clean(s):
    n = s.lower()
    n = re.sub(r'^\s*\d{1,3}\s*[-._]\s+', '', n)         # leading track no.
    n = re.sub(r'[\(\[\{][^\)\]\}]*[\)\]\}]', '', n)     # bracket junk
    n = TRAILING_QUAL.sub('', n)                         # trailing remaster/etc
    n = n.replace('&', 'and')
    n = re.sub(r'\s+(ft|feat)\.?\s.*$', '', n)           # trailing feat.
    n = re.sub(r'[^\w]+', '', n, flags=re.UNICODE)       # keep Cyrillic etc
    return n

def variants(filename):
    base = os.path.splitext(filename)[0]
    base = re.sub(r'^\s*\d{1,3}\s*[-._]\s+', '', base)
    keys = {clean(base)}
    parts = re.split(r'\s[-–—]\s', base)
    for i in range(len(parts)):
        keys.add(clean(' '.join(parts[i:])))            # every "from here on" key
    return {k for k in keys if k}

def list_music(root):
    out = []
    for dp, dns, fns in os.walk(root):
        dns[:] = [d for d in dns if not d.startswith('.')]
        for f in fns:
            if f.startswith('.'):
                continue
            if os.path.splitext(f)[1].lower() in EXTS:
                out.append(os.path.join(dp, f))
    return out

def main():
    if len(sys.argv) != 3:
        print("Usage: phone_missing.py LOCAL_DIR PHONE_DIR")
        sys.exit(1)

    local_dir, phone_dir = sys.argv[1], sys.argv[2]
    local = list_music(local_dir)
    phone = list_music(phone_dir)

    local_by_key = {}
    for p in local:
        for k in variants(os.path.basename(p)):
            local_by_key.setdefault(k, []).append(p)
    local_keys = list(local_by_key.keys())

    exact, near, missing = [], [], []
    for p in sorted(phone):
        v = variants(os.path.basename(p))
        if v & local_by_key.keys():
            exact.append(p)
            continue
        best_r, best_lp = 0.0, None
        for lk in local_keys:
            for k in v:
                r = SequenceMatcher(None, k, lk).ratio()
                if r > best_r:
                    best_r, best_lp = r, local_by_key[lk][0]
        if best_r >= 0.90:
            near.append((p, best_r, best_lp))
        else:
            missing.append(p)

    print(f"Local: {len(local)}   Phone: {len(phone)}")
    print(f"Exact match: {len(exact)}   "
          f"Near-match (typo): {len(near)}   "
          f"Missing: {len(missing)}\n")

    if near:
        print("=== Near-matches (almost certainly same track) ===")
        for p, r, lp in near:
            print(f"{r:.2f}  {os.path.basename(p)}")
            print(f"      ≈ {os.path.basename(lp)}")
        print()

    print(f"=== {len(missing)} phone tracks with NO local match ===")
    for p in missing:
        print(p)

if __name__ == "__main__":
    main()
