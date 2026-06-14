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
stow gnome -t ~

# Deploy artix system files
sudo cp -r ./artix-sys/etc/* /etc/
```
