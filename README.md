# ivfrost’s dotfiles
This repository is organized for use with **GNU Stow**, a symlink farm manager that makes it easy to maintain modular, version‑controlled configuration files. Each directory inside the repo represents a self‑contained “package” of dotfiles that can be selectively deployed to your home directory.

## Example usage
```bash
git clone https://github.com/ivfrost/dotfiles ~/.config/dotfiles
cd ~/.config/dotfiles
stow common -t ~
stow gnome -t ~
```
