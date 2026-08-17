#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh: bring up a fresh Artix Linux (OpenRC) + Cinnamon machine
# from the ivfrost dotfiles repository.
#
# Run it as your normal user (it uses sudo internally where needed):
#   ./bootstrap.sh            # interactive
#   ./bootstrap.sh --yes      # non-interactive
#   ./bootstrap.sh --dry      # preview only
#
# Idempotent: safe to re-run. Each step is guarded to converge on the same state.

DOTFILES="${DOTFILES:-$HOME/.config/dotfiles}"

DRY=0
YES=0
NO_PACKAGES=0
NO_SYSTEM=0
NO_CINNAMON=0
ADOPT=0
LAPTOP=0

STOW_PACKAGES=(common cinnamon)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if (( DRY )); then
        printf '    [dry] %s\n' "$*"
    else
        "$@"
    fi
}

usage() {
    cat <<'EOF'
Usage: ./bootstrap.sh [options]

Sets up a fresh Artix Linux (OpenRC) + Cinnamon machine from these dotfiles.

Options:
  --dry            Print what would be done without changing anything.
  -y, --yes        Non-interactive mode (passes --noconfirm to pacman/paru).
  --no-packages    Skip package installation from the encrypted list.
  --no-system      Skip copying artix-sys/ into /etc.
  --no-cinnamon    Skip restoring Cinnamon dconf settings.
  --adopt          Adopt conflicting files when stowing (passes --adopt to stow).
  --laptop         Enable fractional scaling at 125% (laptop).
  --with <pkgs>    Extra stow packages to deploy (comma separated, e.g. sway,mpv).
  -h, --help       Show this help.
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry) DRY=1 ;;
        -y|--yes) YES=1 ;;
        --no-packages) NO_PACKAGES=1 ;;
        --no-system) NO_SYSTEM=1 ;;
        --no-cinnamon) NO_CINNAMON=1 ;;
        --adopt) ADOPT=1 ;;
        --laptop) LAPTOP=1 ;;
        --with)
            IFS=',' read -ra extra <<< "${2:?--with requires a comma-separated list}"
            shift
            STOW_PACKAGES+=("${extra[@]}")
            ;;
        -h|--help) usage ;;
        *) err "Unknown argument: $1" ;;
    esac
    shift
done

(( EUID == 0 )) && err "Run as your normal user (sudo is used internally when needed)."
[[ -d "$DOTFILES" ]] || err "Dotfiles repo not found at $DOTFILES. Set DOTFILES or clone it first."
command -v pacman >/dev/null || err "pacman not found; this script targets Artix/Arch."

info "Bootstrapping Artix OpenRC machine from $DOTFILES"

# 1. Bootstrap tools (needed before we can decrypt/install/stow anything).
info "Installing bootstrap tools (age, stow, git, base-devel, sudo)"
run sudo pacman -Sy --noconfirm --needed age stow git base-devel sudo

# 2. Arch Linux repositories (several packages live in Arch's [extra]/[multilib]).
info "Ensuring Arch Linux repositories are available"
if [[ ! -f /etc/pacman.d/mirrorlist-arch ]]; then
    run sudo pacman -S --noconfirm --needed artix-archlinux-support archlinux-keyring
fi
run sudo pacman-key --init
run sudo pacman-key --populate artix archlinux

if ! grep -qE '^\[extra\]' /etc/pacman.conf; then
    info "Enabling [extra] and [multilib] in /etc/pacman.conf"
    run sudo sed -i \
        -e 's|^#\[extra\]$|[extra]|' \
        -e 's|^#\[multilib\]$|[multilib]|' \
        -e '/^\[extra\]$/,/^\[/ s|^#Include = /etc/pacman.d/mirrorlist-arch$|Include = /etc/pacman.d/mirrorlist-arch|' \
        -e '/^\[multilib\]$/,/^\[/ s|^#Include = /etc/pacman.d/mirrorlist-arch$|Include = /etc/pacman.d/mirrorlist-arch|' \
        /etc/pacman.conf
fi
run sudo pacman -Sy --noconfirm

# 3. Ensure the AUR helper (paru) is available.
info "Ensuring paru (AUR helper) is installed"
if command -v paru >/dev/null; then
    info "paru is already installed"
else
    PARU_DIR="$(mktemp -d)"
    trap 'rm -rf "$PARU_DIR"' EXIT
    run git clone --depth 1 https://aur.archlinux.org/paru.git "$PARU_DIR/paru"
    if (( DRY )); then
        echo "    [dry] makepkg -si --noconfirm (in $PARU_DIR/paru)"
    else
        (cd "$PARU_DIR/paru" && makepkg -si --noconfirm)
    fi
fi

# 4. Restore packages from the age-encrypted list.
if (( NO_PACKAGES )); then
    warn "Skipping package installation (--no-packages)."
else
    info "Installing packages from the age-encrypted package list"
    PKG_INSTALL="$DOTFILES/cinnamon/.local/bin/pkg-install"
    [[ -x "$PKG_INSTALL" ]] || err "pkg-install not found at $PKG_INSTALL"
    "$PKG_INSTALL" ${YES:+--yes} ${DRY:+--dry}
fi

# 5. Deploy dotfiles with GNU Stow.
info "Deploying dotfiles with GNU Stow"
cd "$DOTFILES"
for pkg in "${STOW_PACKAGES[@]}"; do
    if [[ -d "$pkg" ]]; then
        run stow ${ADOPT:+--adopt} "$pkg" -t "$HOME"
    else
        warn "stow package '$pkg' not found; skipping"
    fi
done

# 6. Make zsh the login shell so ~/.config/zsh/.zshrc is sourced automatically.
info "Setting zsh as the default shell"
if command -v zsh >/dev/null; then
    ZSHPATH="$(command -v zsh)"
    if [[ "${SHELL:-}" == "$ZSHPATH" ]]; then
        info "zsh is already the default shell"
    else
        run sudo chsh -s "$ZSHPATH" "$USER"
    fi
else
    warn "zsh not found; skipping default-shell change (is it installed?)."
fi

# 7. System files (pacman hooks, dispatchers, ...) into /etc.
if (( NO_SYSTEM )); then
    warn "Skipping system file installation (--no-system)."
else
    info "Installing system files (artix-sys/) into /etc"
    if command -v rsync >/dev/null; then
        run sudo rsync -a --no-owner --no-group "$DOTFILES/artix-sys/etc/" /etc/
    else
        run sudo cp -a --no-preserve=ownership "$DOTFILES/artix-sys/etc/." /etc/
    fi
fi

# Greeter background: make the bing wallpaper directory user-writable so
# bing-wallpaper.py can populate the slick-greeter background.
if [[ -f /etc/lightdm/slick-greeter.conf ]]; then
    run sudo mkdir -p /usr/share/backgrounds/bing
    run sudo chown "$USER" /usr/share/backgrounds/bing
fi

# 8. Configure the Plymouth boot splash (hook, kernel cmdline, regenerate).
if command -v plymouth >/dev/null; then
    info "Configuring Plymouth boot splash"
    changed=0

    if grep -qE '^HOOKS=' /etc/mkinitcpio.conf; then
        if ! grep -qE '^HOOKS=.*\bplymouth\b' /etc/mkinitcpio.conf; then
            run sudo sed -i '/^HOOKS=/ s/ filesystems/ plymouth filesystems/' /etc/mkinitcpio.conf
            changed=1
        fi
        # The graphical spinner theme needs KMS available early in the initramfs.
        if ! grep -qE '^HOOKS=.*\bkms\b' /etc/mkinitcpio.conf; then
            run sudo sed -i '/^HOOKS=/ s/ udev/ udev kms/' /etc/mkinitcpio.conf
            changed=1
        fi
    fi

    if grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
        if grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=.*\bnosplash\b' /etc/default/grub; then
            run sudo sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\bnosplash\b[[:space:]]*//g' /etc/default/grub
            changed=1
        fi
        if ! grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\bsplash\b' /etc/default/grub; then
            run sudo sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/^GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="splash /' /etc/default/grub
            changed=1
        fi
    fi

    if (( changed )); then
        run sudo mkinitcpio -P
        if command -v grub-mkconfig >/dev/null; then
            run sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
    else
        info "Plymouth boot splash is already configured"
    fi
else
    warn "plymouth not installed; skipping splash configuration"
fi

# 9. Restore Cinnamon dconf settings (panels, applets, keybindings, ...).
if (( NO_CINNAMON )); then
    warn "Skipping Cinnamon settings restore (--no-cinnamon)."
elif command -v dconf >/dev/null; then
    info "Restoring Cinnamon settings (dconf)"
    CINN_DCONF="$DOTFILES/cinnamon/.config/cinnamon/cinnamon.dconf"
    KEYS_DCONF="$DOTFILES/cinnamon/.config/cinnamon/keybindings.dconf"
    if (( DRY )); then
        printf '    [dry] dconf load /org/cinnamon/ < %s\n' "$CINN_DCONF"
        printf '    [dry] dconf load /org/cinnamon/desktop/keybindings/ < %s\n' "$KEYS_DCONF"
    else
        dconf load /org/cinnamon/ < "$CINN_DCONF"
        dconf load /org/cinnamon/desktop/keybindings/ < "$KEYS_DCONF"
    fi
else
    warn "dconf not found; skipping Cinnamon settings restore."
fi

# 10. Laptop-specific: enable Cinnamon fractional scaling at 125%.
if (( LAPTOP )); then
    info "Configuring laptop fractional scaling (125%)"
    # Enable Cinnamon's experimental fractional scaling flag.
    run dconf write /org/cinnamon/muffin/experimental-features "['scale-monitor-framebuffer', 'x11-randr-fractional-scaling']"
    run dconf write /org/cinnamon/muffin/x11/fractional-scale-mode "'scale-ui-down'"

    # Best-effort: point the monitor config at the internal panel at 125%.
    connector=""
    mode=""
    for drm in /sys/class/drm/card*-*/; do
        [[ "$(cat "$drm/status" 2>/dev/null)" == "connected" ]] || continue
        c="$(basename "$drm")"
        c="${c#*-}"
        m="$(head -n1 "$drm/modes" 2>/dev/null)"
        if [[ -z "$connector" ]]; then
            connector="$c"
            mode="$m"
        fi
        if [[ "$c" == *eDP* || "$c" == *LVDS* ]]; then
            connector="$c"
            mode="$m"
            break
        fi
    done
    [[ -n "$connector" ]] || connector="eDP-1"
    [[ -n "$mode" ]] || mode="1920x1080"

    width="${mode%%x*}"
    height="${mode##*x}"
    if [[ ! "$width" =~ ^[0-9]+$ || ! "$height" =~ ^[0-9]+$ ]]; then
        width=1920
        height=1080
    fi

    monitors_conf="$HOME/.config/cinnamon-monitors.xml"
    if (( DRY )); then
        echo "    [dry] write $monitors_conf ($connector ${width}x${height}, scale=1.25)"
    elif [[ -f "$monitors_conf" ]]; then
        warn "$monitors_conf already exists; leaving it unchanged"
    else
        mkdir -p "$(dirname "$monitors_conf")"
        cat > "$monitors_conf" <<EOF
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1.25</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>$connector</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>$width</width>
          <height>$height</height>
          <rate>60</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
    fi
fi

info "Done. Reboot (or start services manually) when ready."
