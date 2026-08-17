# ivfrost’s dotfiles

This repository is organized for use with **GNU Stow**, a symlink farm manager
that makes it easy to maintain modular, version‑controlled configuration files.
Each directory inside the repo represents a self‑contained “package” of dotfiles
that can be selectively deployed to your home directory.

The `artix-sys/` folder is a special case:  
it contains **hooks** and other **system configurations/fixes** for Artix.  
It is **not stowable** and is meant to be copied into `/etc/` on an Artix OpenRC system.


## Example usage

```bash
git clone https://github.com/ivfrost/dotfiles ~/.config/dotfiles
cd ~/.config/dotfiles

# Deploy dotfiles
stow common -t ~
stow cinnamon -t ~

# Deploy artix system files (preventing accidental overwrites)
sudo rsync -avh --progress ./artix-sys/etc/ /etc/
```

## Fresh Artix OpenRC + Cinnamon install

On the new machine, once the base Artix install is done:

```bash
# 1. Get the essentials
sudo pacman -Sy --noconfirm --needed git

# 2. Clone the dotfiles
git clone https://github.com/ivfrost/dotfiles ~/.config/dotfiles

# 3. Add your age identity to the local secrets file
mkdir -p ~/.config/zsh
echo 'export AGE_KEY="AGE-SECRET-KEY-1..."' >> ~/.config/zsh/.zshrc.local
# or copy the file over from your existing machine

# 4. Run the bootstrap (installs packages, stows dotfiles, copies system files,
#    sets zsh as the default shell and restores Cinnamon)
cd ~/.config/dotfiles
./bootstrap.sh            # interactive
# ./bootstrap.sh --yes    # fully unattended
# ./bootstrap.sh --adopt  # adopt pre-existing conflicting files during stow
# ./bootstrap.sh --laptop # enable fractional scaling at 125% (laptop)
```

## Package dump / restore

Packages are recorded in `cinnamon/.config/pkglist.age`, an **age-encrypted**
file. Never commit a plaintext package list.

The tools live in `cinnamon/.local/bin/` and are stowed to `~/.local/bin/`:

- `pkg-dump` dumps the installed native and AUR packages and encrypts them with
  your age recipient key. An optional **local** skip list is read from
  `~/.config/pkg-skip` (one package name per line). It lists packages you want
  to keep private and must **never** be committed.
- `pkg-install` decrypts the list and installs everything back:
  - `pkg-install --dry`  preview without installing
  - `pkg-install --yes`  non-interactive (passes `--noconfirm` to pacman/paru)
  - `pkg-install --native-only`  only repository packages (skip the AUR)

The age identity is read from the `AGE_KEY` environment variable, which is
exported from `~/.config/zsh/.zshrc.local` and sourced by `.zshrc`. If the
variable is not in the environment, `pkg-install` falls back to reading that
file directly. You can also override it with `pkg-install --key PATH` or paste
the key when prompted.

## Keeping the install up to date

Before committing, refresh the snapshots so a fresh install reproduces your
current machine:

```bash
# Age-encrypted package list
pkg-dump

# Cinnamon settings and keybindings
dconf dump /org/cinnamon/ \
  > ~/.config/dotfiles/cinnamon/.config/cinnamon/cinnamon.dconf
dconf dump /org/cinnamon/desktop/keybindings/ \
  > ~/.config/dotfiles/cinnamon/.config/cinnamon/keybindings.dconf
```

`bootstrap.sh` restores both files with `dconf load`.
