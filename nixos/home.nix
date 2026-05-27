{ config, pkgs, ... }:

# Fetch dotfiles repo
let dotfiles = builtins.fetchGit {
  url = "https://github.com/ivfrost/dotfiles";
  rev = "267473ea102e5bae162d793c4a4a5464b753567e";
};
in
{
  home.username = "ivfrost";
  home.homeDirectory = "/home/ivfrost";
  home.stateVersion = "26.05";

  programs.zsh = {
    enable = false;
    dotDir = "${config.xdg.configHome}/zsh";
# Prevent HM from generating its own .zshrc — it's handled by dotfiles
    initContent = "";
    enableCompletion = false;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;
  };

# Create .zshrc symlink so HM can load it
  xdg.configFile."zsh/.zshrc".source =
    "${dotfiles}/common/.config/zsh/.zshrc";

  programs.ghostty = {
    enable = false; 
  };

  xdg.configFile."ghostty/config".source =
    "${dotfiles}/common/.config/ghostty/config";
  
  xdg.configFile."ghostty/themes".source =
    "${dotfiles}/common/.config/ghostty/themes";

# Disable GNOME Keyring
  services.gnome-keyring.enable = false;

# Enable plain SSH agent instead
  services.ssh-agent.enable = true;

# Disable GPG agent
  services.gpg-agent.enable = false;
}

